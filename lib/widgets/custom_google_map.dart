import 'package:flutter/material.dart';
import 'package:google_maps_app/utils/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_platform_interface/location_platform_interface.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      target: LatLng(37.7749, -122.4194), // San Francisco coordinates
      zoom: 12,
    );
    locationService = LocationService();
    updateMyLocation();
    super.initState();
  }

  bool isFirstCall = true;
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: markers,
      onMapCreated: (controller) {
        googleMapController = controller;
      },
      initialCameraPosition: initialCameraPosition,
    );
  }

  void updateMyLocation() async {
    await locationService.checkAndRequestLocationService();
    var hasPermission = await locationService
        .checkAndRequestLocationPermission();
    if (hasPermission) {
      locationService.getRealTimeLocationData((locationData) {
        setMyLocationMarker(locationData);
        updateMyCamera(locationData);
      });
    }
  }

  void updateMyCamera(LocationData locationData) {
    if (isFirstCall) {
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 14,
      );
      googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
      isFirstCall = false;
    } else {
      googleMapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!),
        ),
      );
    }
  }

  void setMyLocationMarker(LocationData locationData) {
    var myLocationMarker = Marker(
      markerId: const MarkerId('my_location'),
      position: LatLng(locationData.latitude!, locationData.longitude!),
    );
    markers.add(myLocationMarker);
    setState(() {});
  }
}
