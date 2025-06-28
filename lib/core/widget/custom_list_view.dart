import 'package:flutter/material.dart';
import 'package:google_maps_app/core/utils/map_services.dart';
import 'package:google_maps_app/models/place_details_model/place_details_model.dart';

import '../../models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
    required this.onPlaceSelected,
    required this.mapServices,
  });

  final List<PlaceModel> places;
  final MapServices mapServices;
  final Function(PlaceDetailsModel) onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(places[index].description!),
            trailing: IconButton(
              onPressed: () async {
                var placeDetails = await mapServices.getPlacesDetails(
                  placeId: places[index].placeId!,
                );
                onPlaceSelected(placeDetails);
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 0);
        },
        itemCount: places.length,
      ),
    );
  }
}
