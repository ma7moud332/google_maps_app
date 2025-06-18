import 'package:flutter/material.dart';
import 'package:google_maps_app/models/place_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;

  late Location location;
  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      target: LatLng(37.7749, -122.4194), // San Francisco coordinates
      zoom: 12,
    );
    initMarkers();
    location = Location();
    checkAndRequestLocationService();
    super.initState();
  }

  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: markers,
      onMapCreated: (controller) {
        googleMapController = controller;

        location.onLocationChanged.listen((locationData) {});
      },
      initialCameraPosition: initialCameraPosition,
    );
  }

  void initMarkers() async {
    var customMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(50, 50)),
      'assets/images/marker.jpg',
    );
    var myMarkers = places
        .map(
          (placeModel) => Marker(
            icon: customMarkerIcon,
            markerId: MarkerId(placeModel.id.toString()),
            position: placeModel.latlng,
            infoWindow: InfoWindow(title: placeModel.name),
          ),
        )
        .toSet();
    markers.addAll(myMarkers);
    setState(() {});
  }

  void checkAndRequestLocationService() async {
    var isServiceEnabled = await location.serviceEnabled();

    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        // Handle the case where the user did not enable the location service
      }
    }
    checkAndRequestLocationPermission();
  }

  void checkAndRequestLocationPermission() async {
    var permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        // Handle the case where the user did not grant the location permission
      }
    }
  }
}
