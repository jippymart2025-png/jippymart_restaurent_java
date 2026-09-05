import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../themes/app_them_data.dart';
import '../../themes/round_button_fill.dart';
import '../../widget/osm_map/map_controller.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerPage({super.key, required this.initialPosition});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  // Use Get.find with fallback to Get.put if not already initialized
  late OSMMapController osmController;
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(20.5937, 78.9629);
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller safely
    try {
      osmController = Get.find<OSMMapController>();
    } catch (e) {
      // If not found, put it first
      osmController = Get.put(OSMMapController());
    }

    _currentPosition = widget.initialPosition;
    _initializeMarker();
  }

  void _initializeMarker() {
    if (osmController.pickedPlace.value != null) {
      final place = osmController.pickedPlace.value!;
      final latLng = LatLng(
        place.coordinates.latitude,
        place.coordinates.longitude,
      );
      _currentPosition = latLng;
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick Location".tr),
        backgroundColor: AppThemeData.surface,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng position) {
              _handleLocationTap(position);
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location...'.tr,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                osmController.searchPlace(value);
              },
            ),
          ),
          Obx(() => osmController.searchResults.isNotEmpty
              ? Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: osmController.searchResults.length,
                itemBuilder: (context, index) {
                  final place = osmController.searchResults[index];
                  return ListTile(
                    title: Text(place['display_name'] ?? ''),
                    onTap: () {
                      osmController.selectSearchResult(place);
                      final lat = double.parse(place['lat']);
                      final lng = double.parse(place['lon']);
                      final newPosition = LatLng(lat, lng);
                      _markers.clear();
                      _markers.add(
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: newPosition,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                        ),
                      );
                      _mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(newPosition, 15),
                      );
                      setState(() {});
                      _searchController.text = place['display_name'] ?? '';
                    },
                  );
                },
              ),
            ),
          )
              : const SizedBox()),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final place = osmController.pickedPlace.value;
              if (place == null) {
                return Text(
                  "No location selected".tr,
                  style: const TextStyle(color: Colors.grey),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selected Location:".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppThemeData.primary300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(place.address),
                  Text(
                    "Lat: ${place.coordinates.latitude.toStringAsFixed(5)}, "
                        "Lng: ${place.coordinates.longitude.toStringAsFixed(5)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RoundedButtonFill(
                    title: "Confirm Location".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    height: 5,
                    onPress: () {
                      final place = osmController.pickedPlace.value;
                      if (place != null) {
                        Get.back(result: {
                          'location': LatLng(
                            place.coordinates.latitude,
                            place.coordinates.longitude,
                          ),
                          'address': place.address,
                        });
                      } else {
                        Get.back();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    osmController.clearAll();
                    setState(() {
                      _markers.clear();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleLocationTap(LatLng position) {
    setState(() {
      _currentPosition = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });

    // Update the OSM controller
    final latlongCoords = latlong.LatLng(position.latitude, position.longitude);
    osmController.addLatLngOnly(latlongCoords);

    // Center map on tapped location
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(position, 15),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}