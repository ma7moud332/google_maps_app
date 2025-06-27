import 'dart:convert';

import 'package:google_maps_app/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:http/http.dart' as http;

class GoogleMapsPlacesService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey = 'AIzaSyCqKzXq_j1qFtQ92lKeAXh57ey7HgmSD-w';
  Future<List<PlaceAutocompleteModel>> getPredictions({
    required String input,
  }) async {
    var response = await http.get(
      Uri.parse('$baseUrl/autocomplete/json?key=$apiKey&input=$input'),
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
}
