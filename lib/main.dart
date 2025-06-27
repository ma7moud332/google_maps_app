import 'package:flutter/material.dart';
import 'package:google_maps_app/views/widgets/custom_google_map.dart';

void main() {
  runApp(const GoogleMapsApp());
}

class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(child: CustomGoogleMap()),
      ),
    );
  }
}
