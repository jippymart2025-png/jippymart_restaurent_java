// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:latlong2/latlong.dart' as latlong;
//
// import '../../themes/app_them_data.dart';
// import '../../themes/round_button_fill.dart';
// import '../../widget/osm_map/map_controller.dart';
//
// class MapPickerPage extends StatefulWidget {
//   final LatLng initialPosition;
//
//   const MapPickerPage({super.key, required this.initialPosition});
//
//   @override
//   State<MapPickerPage> createState() => _MapPickerPageState();
// }
//
// class _MapPickerPageState extends State<MapPickerPage> {
//   final OSMMapController osmController = Get.find<OSMMapController>();
//   GoogleMapController? _mapController;
//   LatLng _currentPosition = const LatLng(20.5937, 78.9629);
//   Set<Marker> _markers = {};
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _currentPosition = widget.initialPosition;
//     _initializeMarker();
//   }
//
//   void _initializeMarker() {
//     if (osmController.pickedPlace.value != null) {
//       final place = osmController.pickedPlace.value!;
//       final latLng = LatLng(
//         place.coordinates.latitude,
//         place.coordinates.longitude,
//       );
//       _currentPosition = latLng;
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('selected_location'),
//           position: latLng,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Pick Location".tr),
//         backgroundColor: AppThemeData.surface,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _currentPosition,
//               zoom: 15,
//             ),
//             markers: _markers,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             onMapCreated: (controller) {
//               _mapController = controller;
//             },
//             onTap: (LatLng position) {
//               _handleLocationTap(position);
//             },
//           ),
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search location...'.tr,
//                 filled: true,
//                 fillColor: Colors.white,
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onChanged: (value) {
//                 osmController.searchPlace(value);
//               },
//             ),
//           ),
//           Obx(() => osmController.searchResults.isNotEmpty
//               ? Positioned(
//                   top: 80,
//                   left: 16,
//                   right: 16,
//                   child: Container(
//                     constraints: const BoxConstraints(maxHeight: 280),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 10,
//                         ),
//                       ],
//                     ),
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: osmController.searchResults.length,
//                       itemBuilder: (context, index) {
//                         final place =
//                             osmController.searchResults[index] as Map<String, dynamic>;
//                         return ListTile(
//                           title: Text(
//                             place['display_name'] ?? '',
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           onTap: () {
//                             osmController.selectSearchResult(place);
//                             final lat = double.parse(place['lat'].toString());
//                             final lng = double.parse(place['lon'].toString());
//                             final newPosition = LatLng(lat, lng);
//                             setState(() {
//                               _currentPosition = newPosition;
//                               _markers.clear();
//                               _markers.add(
//                                 Marker(
//                                   markerId: const MarkerId('selected_location'),
//                                   position: newPosition,
//                                   icon: BitmapDescriptor.defaultMarkerWithHue(
//                                     BitmapDescriptor.hueRed,
//                                   ),
//                                 ),
//                               );
//                             });
//                             _mapController?.animateCamera(
//                               CameraUpdate.newLatLngZoom(newPosition, 15),
//                             );
//                             _searchController.text =
//                                 place['display_name'] ?? '';
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 )
//               : const SizedBox.shrink()),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         color: Colors.white,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Obx(() {
//               final place = osmController.pickedPlace.value;
//               if (place == null) {
//                 return Text(
//                   "No location selected".tr,
//                   style: const TextStyle(color: Colors.grey),
//                 );
//               }
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Selected Location:".tr,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppThemeData.primary300,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(place.address),
//                   Text(
//                     "Lat: ${place.coordinates.latitude.toStringAsFixed(5)}, "
//                         "Lng: ${place.coordinates.longitude.toStringAsFixed(5)}",
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               );
//             }),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: RoundedButtonFill(
//                     title: "Confirm Location".tr,
//                     color: AppThemeData.primary300,
//                     textColor: AppThemeData.grey50,
//                     height: 5,
//                     onPress: () {
//                       final place = osmController.pickedPlace.value;
//                       if (place != null) {
//                         Get.back(result: {
//                           'location': LatLng(
//                             place.coordinates.latitude,
//                             place.coordinates.longitude,
//                           ),
//                           'address': place.address,
//                         });
//                       } else {
//                         Get.back();
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _handleLocationTap(LatLng position) {
//     setState(() {
//       _currentPosition = position;
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('selected_location'),
//           position: position,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     });
//
//     // Update the OSM controller
//     final latlongCoords = latlong.LatLng(position.latitude, position.longitude);
//     osmController.addLatLngOnly(latlongCoords);
//
//     // Center map on tapped location
//     _mapController?.animateCamera(
//       CameraUpdate.newLatLngZoom(position, 15),
//     );
//   }
//
//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
// }





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
  final OSMMapController osmController = Get.find<OSMMapController>();
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Always start from the position passed in (current GPS location),
    // never from a stale pickedPlace left over from a previous session.
    _currentPosition = widget.initialPosition;

    // Show a marker immediately so the map isn't empty on open.
    _markers = {
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    // Clear any stale previous selection, then seed the controller with the
    // current location so Confirm works even if the user doesn't tap/search.
    osmController.pickedPlace.value = null;
    _seedInitialLocation();
  }

  Future<void> _seedInitialLocation() async {
    final latlongCoords = latlong.LatLng(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );
    // This should reverse-geocode and set osmController.pickedPlace
     osmController.addLatLngOnly(latlongCoords);
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
              constraints: const BoxConstraints(maxHeight: 280),
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
                  final place =
                  osmController.searchResults[index] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      place['display_name'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      osmController.selectSearchResult(place);
                      final lat = double.parse(place['lat'].toString());
                      final lng = double.parse(place['lon'].toString());
                      final newPosition = LatLng(lat, lng);
                      setState(() {
                        _currentPosition = newPosition;
                        _markers = {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: newPosition,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        };
                        _searchController.text =
                            place['display_name'] ?? '';
                        osmController.searchResults.clear();
                      });
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(newPosition, 15),
                      );
                    },
                  );
                },
              ),
            ),
          )
              : const SizedBox.shrink()),
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
                        // Use the resolved place (has address from reverse geocoding)
                        Get.back(result: {
                          'location': LatLng(
                            place.coordinates.latitude,
                            place.coordinates.longitude,
                          ),
                          'address': place.address,
                        });
                      } else {
                        // Fallback: pickedPlace hasn't resolved yet (e.g. geocoding
                        // still in flight) — still return the current map position
                        // instead of returning null and dropping the selection.
                        Get.back(result: {
                          'location': _currentPosition,
                          'address': '',
                        });
                      }
                    },
                  ),
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
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });

    // Update the OSM controller (reverse-geocodes + sets pickedPlace)
    final latlongCoords = latlong.LatLng(position.latitude, position.longitude);
    osmController.addLatLngOnly(latlongCoords);

    // Center map on tapped location
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 15),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}