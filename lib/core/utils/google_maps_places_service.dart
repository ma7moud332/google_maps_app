import 'dart:convert';

import 'package:google_maps_app/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_app/models/place_details_model/place_details_model.dart';
import 'package:http/http.dart' as http;

class GoogleMapsPlacesService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey = 'AIzaSyCqKzXq_j1qFtQ92lKeAXh57ey7HgmSD-w';
  Future<List<PlaceAutocompleteModel>> getPredictions({
    required String input,
    required String sessionToken,
  }) async {
    var response = await http.get(
      Uri.parse(
        '$baseUrl/autocomplete/json?key=$apiKey&input=$input&sessiontoken=$sessionToken',
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceAutocompleteModel> places = [];
      for (var item in data) {
        places.add(PlaceAutocompleteModel.fromJson(item));
      }
      return places;
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<PlaceDetailsModel> getPlacesDetails({required String placeId}) async {
    var response = await http.get(
      Uri.parse('$baseUrl/details/json?key=$apiKey&place_id=$placeId'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['result'];
      return PlaceDetailsModel.fromJson(data);
    } else {
      throw Exception('Failed to load place details');
    }
  }
}
