import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_app/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/location_info/lat_lng.dart';
import '../../models/location_info/location.dart';
import '../../models/location_info/location_info.dart';
import '../../models/place_details_model/place_details_model.dart';
import '../../models/routes_model/routes_model.dart';
import 'google_maps_places_service.dart';
import 'location_service.dart';
import 'route_service.dart';

class MapServices {
  PlacesService placesService;
  LocationService locationService;
  RouteService routeService;
  MapServices({
    required this.placesService,
    required this.locationService,
    required this.routeService,
  });

  Future<void> getPredictions({
    required String input,
    required String sessionToken,
    required List<PlaceModel> places,
  }) async {
    if (input.isNotEmpty) {
      var result = await placesService.getPredictions(
        sessionToken: sessionToken,
        input: input,
      );
      places.clear();
      places.addAll(result);
    } else {
      places.clear();
    }
  }

  Future<List<LatLng>> getRouteData({
    required LatLng currentLocation,
    required LatLng destination,
  }) async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        ),
      ),
    );
    LocationInfoModel destinations = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: destination.latitude,
          longitude: destination.longitude,
        ),
      ),
    );
    RoutesModel routes = await routeService.fetchRoutes(
      origin: origin,
      destination: destinations,
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

  void displayRoutes(
    List<LatLng> poinst, {
    required GoogleMapController googleMapController,
    required Set<Polyline> polylines,
  }) {
    Polyline route = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 5,
      points: poinst,
    );
    polylines.add(route);
    LatLngBounds bounds = getLatLongBounds(poinst);
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 16));
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

  Future<LatLng> updateCurrentLocation({
    required GoogleMapController googleMapController,
    required Set<Marker> markers,
  }) async {
    var locationData = await locationService.getLocation();
    var currentLocation = LatLng(
      locationData.latitude!,
      locationData.longitude!,
    );
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
    return currentLocation;
  }

  Future<PlaceDetailsModel> getPlacesDetails({required String placeId}) async {
    return await placesService.getPlacesDetails(placeId: placeId);
  }
}
