import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_app/core/utils/google_maps_places_service.dart';
import 'package:google_maps_app/core/utils/location_service.dart';
import 'package:google_maps_app/core/utils/map_services.dart';
import 'package:google_maps_app/core/utils/route_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/widget/custom_list_view.dart';
import '../../core/widget/custom_text_field.dart';
import '../../models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  late MapServices mapServices;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late Uuid uuid;
  String? sessionToken;
  List<PlaceModel> places = [];
  Set<Marker> markers = {};
  late LatLng destination;
  Set<Polyline> polylines = {};
  Timer? debounce;

  @override
  void initState() {
    uuid = const Uuid();
    initialCameraPosition = const CameraPosition(target: LatLng(0, 0));
    mapServices = MapServices(
      placesService: PlacesService(),
      locationService: LocationService(),
      routeService: RouteService(),
    );
    textEditingController = TextEditingController();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (debounce?.isActive ?? false) {
        debounce!.cancel();
      }

      sessionToken ??= uuid.v4();
      debounce = Timer(const Duration(milliseconds: 100), () async {
        await mapServices.getPredictions(
          input: textEditingController.text,
          sessionToken: sessionToken!,
          places: places,
        );
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
    debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          markers: markers,
          polylines: polylines,
          zoomControlsEnabled: true,
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();
          },
          initialCameraPosition: initialCameraPosition,
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              CustomTextField(textEditingController: textEditingController),
              const SizedBox(height: 16),
              CustomListView(
                onPlaceSelected: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();
                  sessionToken = null;
                  setState(() {});
                  destination = LatLng(
                    placeDetailsModel.geometry!.location!.lat!,
                    placeDetailsModel.geometry!.location!.lng!,
                  );

                  var poinst = await mapServices.getRouteData(
                    destination: destination,
                  );
                  mapServices.displayRoutes(
                    poinst,
                    googleMapController: googleMapController,
                    polylines: polylines,
                  );
                  setState(() {});
                },
                places: places,
                mapServices: mapServices,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateCurrentLocation() {
    try {
      mapServices.updateCurrentLocation(
        onUpdateCurrentLocation: () {
          setState(() {});
        },
        googleMapController: googleMapController,
        markers: markers,
      );
      setState(() {});
    } on LocationServiceException catch (e) {
      //To do
    } on LocationPermissionException catch (e) {
      //To do
    } catch (e) {
      //To do
    }
  }
}
