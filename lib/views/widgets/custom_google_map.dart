import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_app/core/utils/google_maps_places_service.dart';
import 'package:google_maps_app/core/utils/location_service.dart';
import 'package:google_maps_app/core/utils/route_service.dart';
import 'package:google_maps_app/models/location_info/lat_lng.dart';
import 'package:google_maps_app/models/routes_model/routes_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/widget/custom_list_view.dart';
import '../../core/widget/custom_text_field.dart';
import '../../models/location_info/location.dart';
import '../../models/location_info/location_info.dart';
import '../../models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  late GoogleMapsPlacesService googleMapsPlacesService;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late Uuid uuid;
  String? sessionToken;
  List<PlaceAutocompleteModel> places = [];
  Set<Marker> markers = {};
  late RouteService routeService;
  late LatLng currentLocation;
  late LatLng destination;
  Set<Polyline> polylines = {};

  @override
  void initState() {
    uuid = const Uuid();
    initialCameraPosition = const CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    textEditingController = TextEditingController();
    googleMapsPlacesService = GoogleMapsPlacesService();
    routeService = RouteService();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      sessionToken ??= uuid.v4();
      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapsPlacesService.getPredictions(
          sessionToken: sessionToken!,
          input: textEditingController.text,
        );
        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        places.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
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

                  var poinst = await getRouteData();
                  displayRoutes(poinst);
                },
                places: places,
                googleMapsPlacesService: googleMapsPlacesService,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: currentLocation,
      );
      CameraPosition cameraPosition = CameraPosition(
        target: currentLocation,
        zoom: 15,
      );
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
      markers.add(currentLocationMarker);
      setState(() {});
    } on LocationServiceException catch (e) {
      //To do
    } on LocationPermissionException catch (e) {
      //To do
    } catch (e) {
      //To do
    }
  }

  Future<List<LatLng>> getRouteData() async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        ),
      ),
    );
    LocationInfoModel destination = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: this.destination.latitude,
          longitude: this.destination.longitude,
        ),
      ),
    );
    RoutesModel routes = await routeService.fetchRoutes(
      origin: origin,
      destination: destination,
    );
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> points = getDecodedRoute(polylinePoints, routes);
    return points;
  }

  List<LatLng> getDecodedRoute(
    PolylinePoints polylinePoints,
    RoutesModel routes,
  ) {
    List<PointLatLng> result = polylinePoints.decodePolyline(
      routes.routes!.first.polyline!.encodedPolyline!,
    );
    List<LatLng> points = result
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
    return points;
  }

  void displayRoutes(List<LatLng> poinst) {
    Polyline route = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 5,
      points: poinst,
    );
    polylines.add(route);
    LatLngBounds bounds = getLatLongBounds(poinst);
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 16));
    setState(() {});
  }

  LatLngBounds getLatLongBounds(List<LatLng> poinst) {
    var southWestLat = poinst.first.latitude;
    var southWestLng = poinst.first.longitude;
    var northEastLat = poinst.last.latitude;
    var northEastLng = poinst.last.longitude;

    for (var point in poinst) {
      southWestLat = min(southWestLat, point.latitude);
      southWestLng = min(southWestLng, point.longitude);
      northEastLat = max(northEastLat, point.latitude);
      northEastLng = max(northEastLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }
}
