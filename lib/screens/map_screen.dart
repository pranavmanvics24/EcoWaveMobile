import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatelessWidget {
  final Product product;
  const MapScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final location = product.location;
    if (location == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Location Not Available')),
        body: const Center(child: Text('This item does not have a location set.')),
      );
    }

    final pos = LatLng(location['lat']!, location['lng']!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ecoSurface,
        title: Text(product.title, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: pos,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId(product.id),
            position: pos,
            infoWindow: InfoWindow(title: product.title, snippet: product.sellerLocation),
          ),
        },
      ),
    );
  }
}
