import 'dart:convert';

import 'package:google_maps_app/models/location_info/location_info.dart';
import 'package:google_maps_app/models/routes_model/routes_model.dart';
import 'package:google_maps_app/models/routes_modifiers.dart';
import 'package:http/http.dart' as http;

class RouteService {
  final String baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyCqKzXq_j1qFtQ92lKeAXh57ey7HgmSD-w';

  Future<RoutesModel> fetchRoutes({
    required LocationInfoModel origin,
    required LocationInfoModel destination,
    RoutesModifiers? modifiers,
  }) async {
    Uri url = Uri.parse(baseUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };

    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination": destination.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": modifiers != null
          ? modifiers.toJson()
          : RoutesModifiers().toJson(),
      "languageCode": "en-US",
      "units": "METRIC",
    };
    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return RoutesModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load routes');
    }
  }
}
