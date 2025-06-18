import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng latlng;

  PlaceModel({required this.id, required this.name, required this.latlng});
}

List<PlaceModel> places = [
  PlaceModel(
    id: 1,
    name: 'San Francisco',
    latlng: const LatLng(37.7749, -122.4194),
  ),
  PlaceModel(
    id: 2,
    name: 'Los Angeles',
    latlng: const LatLng(34.0522, -118.2437),
  ),
  PlaceModel(id: 3, name: 'New York', latlng: const LatLng(40.7128, -74.0060)),
  PlaceModel(id: 4, name: 'Chicago', latlng: const LatLng(41.8781, -87.6298)),
  PlaceModel(id: 5, name: 'Miami', latlng: const LatLng(25.7617, -80.1918)),
];
