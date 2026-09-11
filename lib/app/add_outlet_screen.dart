// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../controller/add_outlet_controller.dart';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../controller/add_outlet_controller.dart';
// import '../models/location_model.dart';
//
// class AddOutletScreen extends StatelessWidget {
//   AddOutletScreen({super.key});
//
//   final AddOutletController controller =
//   Get.put(AddOutletController());
//   // ADD HERE 👇
//   Widget buildSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: Colors.red.shade300,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.red,
//             ),
//           ),
//           const SizedBox(height: 14),
//           ...children,
//         ],
//       ),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Outlet Details"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           children: [
//
//             /// Outlet Information
//             buildSection(
//               title: "Outlet Information",
//               children: [
//
//                 TextField(
//                   controller: controller.outletNameController,
//                   decoration: const InputDecoration(
//                     labelText: "Outlet Name",
//                     hintText:"Enter Outlet Name",
//                   ),
//                 ),
//
//                 const SizedBox(height: 14),
//                 Obx(() {
//                   if (controller.isCuisineLoading.value) {
//                     return const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       child: Center(child: CircularProgressIndicator()),
//                     );
//                   }
//
//                   final selectedNames = controller.cuisineTypes
//                       .where((c) => controller.isCuisineSelected(c.cuisineTypeId))
//                       .map((c) => c.cuisineTypeName)
//                       .join(", ");
//
//                   return InkWell(
//                     onTap: () => _showCuisinePicker(context, controller),
//                     child: InputDecorator(
//                       decoration: const InputDecoration(
//                         labelText: "Cuisine Type",
//                         hintText: "Select Cuisine Types",
//                         suffixIcon: Icon(Icons.arrow_drop_down),
//                       ),
//                       child: Text(
//                         selectedNames.isEmpty ? "Select Cuisine Types" : selectedNames,
//                         style: TextStyle(
//                           color: selectedNames.isEmpty ? Colors.grey : Colors.black,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   );
//                 }),
//
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.phoneController,
//                   keyboardType: TextInputType.phone,
//                   decoration: const InputDecoration(
//                     labelText: "Phone Number",
//                     hintText: "Enter Outlet Phone",
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: controller.alternatePhoneController,
//                   decoration: const InputDecoration(
//                     labelText: "Alternate Phone Number",
//                     hintText: "Enter Alternate Phone Number",
//                   ),
//                   // keyboardType: TextInputType.phone,
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: controller.emailController,
//                   decoration: const InputDecoration(
//                     labelText: "Email",
//                     hintText: "Enter Outlet Email",
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: controller.fssaiNumberController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: "FSSAI Number",
//                     hintText: "Enter FSSAI Number",
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.gstNumberController,
//                   textCapitalization: TextCapitalization.characters,
//                   decoration: const InputDecoration(
//                     labelText: "GST Number",
//                     hintText: "Enter GST Number",
//                   ),
//                 ),
//                 TextField(
//                   controller: controller.usernameController,
//                   decoration: const InputDecoration(
//                     labelText: "Username",
//                     hintText: "Enter Username",
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: "Password",
//                     hintText: "Enter Password",
//                   ),
//                 ),
//               ],
//             ),
//
//             /// Address Information
//             buildSection(
//               title: "Address Information",
//               children: [
//
//                 TextField(
//                   controller: controller.buildingController,
//                   decoration: const InputDecoration(
//                     labelText: "Building Number",
//                     hintText: "12/345",
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.roadController,
//                   decoration: const InputDecoration(
//                     labelText: "Road",
//                     hintText: "Road Name",
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.landmarkController,
//                   decoration: const InputDecoration(
//                     labelText: "Landmark",
//                     hintText: " Enter Landmark",
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//                 Obx(() {
//                   return DropdownButtonFormField<StateModel>(
//                     value: controller.selectedState.value,
//                     decoration: const InputDecoration(
//                       labelText: "State",
//                       hintText: "Select State",
//                     ),
//                     isExpanded: true,
//                     items: controller.states.map((state) {
//                       return DropdownMenuItem<StateModel>(
//                         value: state,
//                         child: Text(state.stateName),
//                       );
//                     }).toList(),
//                     onChanged: (value) async {
//                       await controller.onStateSelected(value);
//                     },
//                   );
//                 }) ,
//                 const SizedBox(height: 12),
//                 Obx(() {
//                   return DropdownButtonFormField<CityModel>(
//                     value: controller.selectedCity.value,
//                     decoration: const InputDecoration(
//                       labelText: "City",
//                       hintText: "Select City",
//                     ),
//                     isExpanded: true,
//                     items: controller.cities.map((city) {
//                       return DropdownMenuItem<CityModel>(
//                         value: city,
//                         child: Text(city.cityName),
//                       );
//                     }).toList(),
//                     onChanged: (value) async {
//                       await controller.onCitySelected(value);
//                     },
//                   );
//                 }),
//                 const SizedBox(height: 12),
//                 Obx(() {
//                   return DropdownButtonFormField<AreaModel>(
//                     value: controller.selectedArea.value,
//                     decoration: const InputDecoration(
//                       labelText: "Area",
//                       hintText: "Select Area",
//                     ),
//                     isExpanded: true,
//                     items: controller.areas.map((area) {
//                       return DropdownMenuItem<AreaModel>(
//                         value: area,
//                         child: Text(area.areaName),
//                       );
//                     }).toList(),
//                     onChanged: controller.onAreaSelected,
//                   );
//                 }) ,
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.latitudeController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: "Latitude",
//                     hintText: "Enter Latitude"
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.longitudeController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: "Longitude",
//                     hintText: "Enter Longitude",
//                   ),
//                 ),
//               ],
//             ),
//
//             /// Operating Hours
//             buildSection(
//               title: "Operating Hours",
//               children: [
//
//                 Obx(() => CheckboxListTile(
//                   value: controller.sameTimingForAllDays.value,
//                   onChanged: (value) {
//                     controller.sameTimingForAllDays.value = value!;
//                   },
//                   contentPadding: EdgeInsets.zero,
//                   title: const Text("Same timings for all days"),
//                   controlAffinity: ListTileControlAffinity.leading,
//                 )),
//
//                 const SizedBox(height: 15),
//                 Obx(() {
//                   if (controller.sameTimingForAllDays.value) {
//                     return Column(
//                       children: [
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: controller.commonTimeSlots.length,
//                           itemBuilder: (context, slotIndex) {
//                             final slot = controller.commonTimeSlots[slotIndex];
//
//                             return Card(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(12),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     DropdownButtonFormField<String>(
//                                       value: slot["slotType"],
//                                       decoration: const InputDecoration(
//                                         labelText: "Slot Type",
//                                       ),
//                                       items: controller.slotTypes.map((type) {
//                                         return DropdownMenuItem(
//                                           value: type,
//                                           child: Text(type),
//                                         );
//                                       }).toList(),
//                                       onChanged: (value) {
//                                         if (value != null) {
//                                           controller.updateCommonSlotType(
//                                               slotIndex, value);
//                                         }
//                                       },
//                                     ),
//                                     const SizedBox(height: 12),
//                                     TextFormField(
//                                       initialValue: slot["openingTime"],
//                                       decoration: const InputDecoration(
//                                         labelText: "Opening Time",
//                                         hintText: "09:00",
//                                       ),
//                                       onChanged: (value) {
//                                         controller.updateCommonOpeningTime(
//                                             slotIndex, value);
//                                       },
//                                     ),
//                                     const SizedBox(height: 12),
//                                     TextFormField(
//                                       initialValue: slot["closingTime"],
//                                       decoration: const InputDecoration(
//                                         labelText: "Closing Time",
//                                         hintText: "22:00",
//                                       ),
//                                       onChanged: (value) {
//                                         controller.updateCommonClosingTime(
//                                             slotIndex, value);
//                                       },
//                                     ),
//                                     Align(
//                                       alignment: Alignment.centerRight,
//                                       child: IconButton(
//                                         onPressed: () {
//                                           controller.removeCommonTimeSlot(slotIndex);
//                                         },
//                                         icon: const Icon(Icons.delete),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 12),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: controller.addCommonTimeSlot,
//                             icon: const Icon(Icons.add),
//                             label: const Text("Add Another Time Slot"),
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//
//                   return Column(
//                     children: [
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: controller.operatingDays.length,
//                         itemBuilder: (context, dayIndex) {
//                           final day = controller.operatingDays[dayIndex];
//                           final slots = day["slots"] as List<dynamic>;
//
//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 15),
//                             child: Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     day["dayName"],
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   ...List.generate(slots.length, (slotIndex) {
//                                     final slot = slots[slotIndex];
//                                     return Column(
//                                       children: [
//                                         DropdownButtonFormField<String>(
//                                           value: slot["slotType"],
//                                           decoration: const InputDecoration(
//                                             labelText: "Slot Type",
//                                           ),
//                                           items: controller.slotTypes.map((type) {
//                                             return DropdownMenuItem(
//                                               value: type,
//                                               child: Text(type),
//                                             );
//                                           }).toList(),
//                                           onChanged: (value) {
//                                             if (value != null) {
//                                               controller.updateSlotType(
//                                                   dayIndex, slotIndex, value);
//                                             }
//                                           },
//                                         ),
//                                         const SizedBox(height: 12),
//                                         TextFormField(
//                                           initialValue: slot["openingTime"],
//                                           decoration: const InputDecoration(
//                                             labelText: "Opening Time",
//                                             hintText: "09:00",
//                                           ),
//                                           onChanged: (value) {
//                                             controller.updateOpeningTime(
//                                                 dayIndex, slotIndex, value);
//                                           },
//                                         ),
//                                         const SizedBox(height: 12),
//                                         TextFormField(
//                                           initialValue: slot["closingTime"],
//                                           decoration: const InputDecoration(
//                                             labelText: "Closing Time",
//                                             hintText: "22:00",
//                                           ),
//                                           onChanged: (value) {
//                                             controller.updateClosingTime(
//                                                 dayIndex, slotIndex, value);
//                                           },
//                                         ),
//                                         Align(
//                                           alignment: Alignment.centerRight,
//                                           child: IconButton(
//                                             onPressed: () {
//                                               controller.removeTimeSlot(
//                                                   dayIndex, slotIndex);
//                                             },
//                                             icon: const Icon(Icons.delete),
//                                           ),
//                                         ),
//                                         const Divider(),
//                                       ],
//                                     );
//                                   }),
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: TextButton.icon(
//                                       onPressed: () {
//                                         controller.addTimeSlot(dayIndex);
//                                       },
//                                       icon: const Icon(Icons.add),
//                                       label: const Text("Add Slot"),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   );
//                 }),
//
//               ],
//             ),
//
//             const SizedBox(height: 20),
//             buildSection(
//               title: "Bank Details",
//               children: [
//
//                 Obx(() => CheckboxListTile(
//                   value: controller.useMerchantBankDetails.value,
//                   onChanged: (value) {
//                     controller.onMerchantBankChanged(value ?? false);
//                   },
//                   title: const Text(
//                     "Same as Merchant Bank Details",
//                   ),
//                   contentPadding: EdgeInsets.zero,
//                   controlAffinity:
//                   ListTileControlAffinity.leading,
//                 )),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.accountHolderController,
//                   readOnly: controller.useMerchantBankDetails.value,
//                   decoration: const InputDecoration(
//                     labelText: "Account Holder",
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.accountNumberController,
//                   readOnly: controller.useMerchantBankDetails.value,
//                   decoration: const InputDecoration(
//                     labelText: "Account Number",
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.ifscController,
//                   readOnly: controller.useMerchantBankDetails.value,
//                   decoration: const InputDecoration(
//                     labelText: "IFSC Code",
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 TextField(
//                   controller: controller.bankNameController,
//                   readOnly: controller.useMerchantBankDetails.value,
//                   decoration: const InputDecoration(
//                     labelText: "Bank Name",
//                   ),
//                 ),
//               ],
//             ),
//             /// Save Outlet Button
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 onPressed: () async {
//                   await controller.saveOutlet();
//                 },
//                 child: const Text(
//                   "Save Outlet",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jippymart_restaurant/widget/osm_map/map_picker_page.dart' hide MapPickerPage;
import '../widget/locationselection.dart';
import '../constant/constant.dart';       // adjust to your actual path
import '../constant/show_toast_dialog.dart'; // already imported if used elsewhere
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_outlet_controller.dart';


import '../models/location_model.dart';
import 'auth_screen/outlet_otp_verification_screen.dart';

class AddOutletScreen extends StatelessWidget {
  AddOutletScreen({super.key});

  final AddOutletController controller =
  Get.put(AddOutletController());
  // ADD HERE 👇
  Widget buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
  void _showCuisinePicker(
      BuildContext context, AddOutletController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Cuisine Types",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: controller.cuisineTypes.map((cuisine) {
                        return Obx(() {
                          final selected = controller
                              .isCuisineSelected(cuisine.cuisineTypeId);

                          return CheckboxListTile(
                            value: selected,
                            title: Text(cuisine.cuisineTypeName),
                            controlAffinity:
                            ListTileControlAffinity.leading,
                            onChanged: (_) {
                              controller.toggleCuisine(cuisine.cuisineTypeId);
                            },
                          );
                        });
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _openLocationPickerForOutlet(
  //     BuildContext context, AddOutletController controller) {
  //   Constant.checkPermission(
  //     context: context,
  //     onTap: () async {
  //       ShowToastDialog.showLoader("Getting location...".tr);
  //       try {
  //         await Geolocator.requestPermission();
  //         final position = await Geolocator.getCurrentPosition();
  //         ShowToastDialog.closeLoader();
  //
  //         final initialPos = Constant.selectedMapType == 'osm'
  //             ? const LatLng(20.5937, 78.9629)
  //             : LatLng(position.latitude, position.longitude);
  //
  //         final result = await Get.to(
  //               () => MapPickerPage(initialPosition: initialPos),
  //           fullscreenDialog: Constant.selectedMapType != 'osm',
  //         );
  //
  //         if (result != null) {
  //           final data = result as Map<String, dynamic>;
  //           final LatLng selectedLatLng = data['location'] as LatLng;
  //           final String selectedAddress = data['address'] as String? ?? '';
  //           controller.latitudeController.text =
  //               selectedLatLng.latitude.toString();
  //           controller.longitudeController.text =
  //               selectedLatLng.longitude.toString();
  //           controller.locationDisplayController.text = selectedAddress;
  //         }
  //       } catch (e) {
  //         ShowToastDialog.closeLoader();
  //         ShowToastDialog.showToast(
  //             "Failed to get location: ${e.toString()}".tr);
  //       }
  //     },
  //   );
  // }
  void _openLocationPickerForOutlet(
      BuildContext context, AddOutletController controller) {
    Constant.checkPermission(
      context: context,
      onTap: () async {
        try {
          // 1. Check if location services are enabled on the device
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            ShowToastDialog.showToast("Please enable location services".tr);
            return;
          }

          // 2. Check current permission status
          LocationPermission permission = await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            // 3. Ask for permission if not granted yet
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              ShowToastDialog.showToast("Location permission denied".tr);
              return;
            }
          }

          if (permission == LocationPermission.deniedForever) {
            ShowToastDialog.showToast(
              "Location permission permanently denied, please enable it from app settings".tr,
            );
            return;
          }

          // 4. Permission granted — fetch current location
          ShowToastDialog.showLoader("Getting location...".tr);
          final position = await Geolocator.getCurrentPosition();
          ShowToastDialog.closeLoader();

          // Always use the real GPS position (MapPickerPage only renders GoogleMap)
          final initialPosition = LatLng(position.latitude, position.longitude);

          final result = await Get.to(
                () => MapPickerPage(initialPosition: initialPosition),
            fullscreenDialog: Constant.selectedMapType != 'osm',
          );

          if (result != null) {
            final data = result as Map<String, dynamic>;
            final LatLng selectedLatLng = data['location'] as LatLng;
            final String selectedAddress = data['address'] as String? ?? '';
            controller.latitudeController.text = selectedLatLng.latitude.toString();
            controller.longitudeController.text = selectedLatLng.longitude.toString();
            controller.locationDisplayController.text = selectedAddress;
          }
        } catch (e) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Failed to get location: ${e.toString()}".tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Outlet Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            /// Outlet Information
            buildSection(
              title: "Outlet Information",
              children: [

                TextField(
                  controller: controller.outletNameController,
                  decoration: const InputDecoration(
                    labelText: "Outlet Name",
                    hintText:"Enter Outlet Name",
                  ),
                ),

                const SizedBox(height: 14),
                Obx(() {
                  if (controller.isCuisineLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final selectedNames = controller.cuisineTypes
                      .where((c) => controller.isCuisineSelected(c.cuisineTypeId))
                      .map((c) => c.cuisineTypeName)
                      .join(", ");

                  return InkWell(
                    onTap: () => _showCuisinePicker(context, controller),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Cuisine Type",
                        hintText: "Select Cuisine Types",
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        selectedNames.isEmpty ? "Select Cuisine Types" : selectedNames,
                        style: TextStyle(
                          color: selectedNames.isEmpty ? Colors.grey : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),


                const SizedBox(height: 12),

                TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Enter Outlet Phone",
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.alternatePhoneController,
                  decoration: const InputDecoration(
                    labelText: "Alternate Phone Number",
                    hintText: "Enter Alternate Phone Number",
                  ),
                  // keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Enter Outlet Email",
                  ),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: controller.fssaiNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "FSSAI Number",
                    hintText: "Enter FSSAI Number",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.gstNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: "GST Number",
                    hintText: "Enter GST Number",
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => CheckboxListTile(
                  value: controller.isVegOutlet.value,
                  onChanged: (value) {
                    controller.isVegOutlet.value = value ?? false;
                  },
                  title: const Text("Is Veg Outlet"),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                )),
// ADDED: Checkbox for isGstApplied
                Obx(() => CheckboxListTile(
                  value: controller.isGstApplied.value,
                  onChanged: (value) {
                    controller.isGstApplied.value = value ?? false;
                  },
                  title: const Text("Is GST Applied"),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                )),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    hintText: "Enter Username",
                  ),
                ),

                const SizedBox(height: 12),
                Obx(() => TextField(
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter Password",
                    suffixIcon: IconButton(
                      onPressed: () {
                        controller.isPasswordHidden.value =
                        !controller.isPasswordHidden.value;
                      },
                      icon: SvgPicture.asset(
                        controller.isPasswordHidden.value
                            ? "assets/icons/ic_password_close.svg"
                            : "assets/icons/ic_password_show.svg",
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
                )),

              ],
            ),

            /// Address Information
            buildSection(
              title: "Address Information",
              children: [

                TextField(
                  controller: controller.buildingController,
                  decoration: const InputDecoration(
                    labelText: "Building Number",
                    hintText: "12/345",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.roadController,
                  decoration: const InputDecoration(
                    labelText: "Road",
                    hintText: "Road Name",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.landmarkController,
                  decoration: const InputDecoration(
                    labelText: "Landmark",
                    hintText: " Enter Landmark",
                  ),
                ),

                const SizedBox(height: 12),
                Obx(() {
                  return DropdownButtonFormField<StateModel>(
                    value: controller.selectedState.value,
                    decoration: const InputDecoration(
                      labelText: "State",
                      hintText: "Select State",
                    ),
                    isExpanded: true,
                    items: controller.states.map((state) {
                      return DropdownMenuItem<StateModel>(
                        value: state,
                        child: Text(state.stateName),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      await controller.onStateSelected(value);
                    },
                  );
                }) ,
                const SizedBox(height: 12),
                Obx(() {
                  return DropdownButtonFormField<CityModel>(
                    value: controller.selectedCity.value,
                    decoration: const InputDecoration(
                      labelText: "City",
                      hintText: "Select City",
                    ),
                    isExpanded: true,
                    items: controller.cities.map((city) {
                      return DropdownMenuItem<CityModel>(
                        value: city,
                        child: Text(city.cityName),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      await controller.onCitySelected(value);
                    },
                  );
                }),
                const SizedBox(height: 12),
                Obx(() {
                  return DropdownButtonFormField<AreaModel>(
                    value: controller.selectedArea.value,
                    decoration: const InputDecoration(
                      labelText: "Area",
                      hintText: "Select Area",
                    ),
                    isExpanded: true,
                    items: controller.areas.map((area) {
                      return DropdownMenuItem<AreaModel>(
                        value: area,
                        child: Text(area.areaName),
                      );
                    }).toList(),
                    onChanged: controller.onAreaSelected,
                  );
                }) ,
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _openLocationPickerForOutlet(context, controller),
                  child: IgnorePointer(
                    child: TextField(
                      controller: controller.locationDisplayController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Outlet Location",
                        hintText: "Tap to select on map",
                        suffixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),

                // const SizedBox(height: 12),
                //
                // InkWell(
                //   onTap: () => _openLocationPickerForOutlet(context, controller),
                //   child: IgnorePointer(
                //     child: TextField(
                //       controller: controller.longitudeController,
                //       keyboardType: TextInputType.number,
                //       decoration: const InputDecoration(
                //         labelText: "Longitude",
                //         hintText: "Tap to select on map",
                //         suffixIcon: Icon(Icons.location_on),
                //       ),
                //     ),
                //   ),
                // ),

              ],
            ),

            /// Operating Hours
            buildSection(
              title: "Operating Hours",
              children: [

                Obx(() => CheckboxListTile(
                  value: controller.sameTimingForAllDays.value,
                  onChanged: (value) {
                    controller.sameTimingForAllDays.value = value!;
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Same timings for all days"),
                  controlAffinity: ListTileControlAffinity.leading,
                )),

                const SizedBox(height: 15),
                Obx(() {
                  if (controller.sameTimingForAllDays.value) {
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.commonTimeSlots.length,
                          itemBuilder: (context, slotIndex) {
                            final slot = controller.commonTimeSlots[slotIndex];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // DropdownButtonFormField<String>(
                                    //   value: slot["slotType"],
                                    //   decoration: const InputDecoration(
                                    //     labelText: "Slot Type",
                                    //   ),
                                    //   items: controller.slotTypes.map((type) {
                                    //     return DropdownMenuItem(
                                    //       value: type,
                                    //       child: Text(type),
                                    //     );
                                    //   }).toList(),
                                    //   onChanged: (value) {
                                    //     if (value != null) {
                                    //       controller.updateCommonSlotType(
                                    //           slotIndex, value);
                                    //     }
                                    //   },
                                    // ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      initialValue: slot["openingTime"],
                                      decoration: const InputDecoration(
                                        labelText: "Opening Time",
                                        hintText: "09:00",
                                      ),
                                      onChanged: (value) {
                                        controller.updateCommonOpeningTime(
                                            slotIndex, value);
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      initialValue: slot["closingTime"],
                                      decoration: const InputDecoration(
                                        labelText: "Closing Time",
                                        hintText: "22:00",
                                      ),
                                      onChanged: (value) {
                                        controller.updateCommonClosingTime(
                                            slotIndex, value);
                                      },
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        onPressed: () {
                                          controller.removeCommonTimeSlot(slotIndex);
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.addCommonTimeSlot,
                            icon: const Icon(Icons.add),
                            label: const Text("Add Another Time Slot"),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.operatingDays.length,
                        itemBuilder: (context, dayIndex) {
                          final day = controller.operatingDays[dayIndex];
                          final slots = day["slots"] as List<dynamic>;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day["dayName"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(slots.length, (slotIndex) {
                                    final slot = slots[slotIndex];
                                    return Column(
                                      children: [
                                        // DropdownButtonFormField<String>(
                                        //   value: slot["slotType"],
                                        //   decoration: const InputDecoration(
                                        //     labelText: "Slot Type",
                                        //   ),
                                        //   items: controller.slotTypes.map((type) {
                                        //     return DropdownMenuItem(
                                        //       value: type,
                                        //       child: Text(type),
                                        //     );
                                        //   }).toList(),
                                        //   onChanged: (value) {
                                        //     if (value != null) {
                                        //       controller.updateSlotType(
                                        //           dayIndex, slotIndex, value);
                                        //     }
                                        //   },
                                        // ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          initialValue: slot["openingTime"],
                                          decoration: const InputDecoration(
                                            labelText: "Opening Time",
                                            hintText: "09:00",
                                          ),
                                          onChanged: (value) {
                                            controller.updateOpeningTime(
                                                dayIndex, slotIndex, value);
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          initialValue: slot["closingTime"],
                                          decoration: const InputDecoration(
                                            labelText: "Closing Time",
                                            hintText: "22:00",
                                          ),
                                          onChanged: (value) {
                                            controller.updateClosingTime(
                                                dayIndex, slotIndex, value);
                                          },
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            onPressed: () {
                                              controller.removeTimeSlot(
                                                  dayIndex, slotIndex);
                                            },
                                            icon: const Icon(Icons.delete),
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  }),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        controller.addTimeSlot(dayIndex);
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text("Add Slot"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.operatingDays.length >= 7
                              ? null
                              : controller.addOperatingDay,
                          icon: const Icon(Icons.add),
                          label: Text(
                            controller.operatingDays.length >= 7
                                ? "All 7 Days Added"
                                : "Add Day (${controller.weekDays[controller.operatingDays.length]})",
                          ),
                        ),
                      ),
                    ],
                  );
                }),

              ],
            ),

            const SizedBox(height: 20),
            buildSection(
              title: "Bank Details",
              children: [

                Obx(() => CheckboxListTile(
                  value: controller.useMerchantBankDetails.value,
                  onChanged: (value) {
                    controller.onMerchantBankChanged(value ?? false);
                  },
                  title: const Text(
                    "Same as Merchant Bank Details",
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity:
                  ListTileControlAffinity.leading,
                )),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.accountHolderController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: const InputDecoration(
                    labelText: "Account Holder",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.accountNumberController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: const InputDecoration(
                    labelText: "Account Number",
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.ifscController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: const InputDecoration(
                    labelText: "IFSC Code",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.bankNameController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: const InputDecoration(
                    labelText: "Bank Name",
                  ),
                ),
              ],
            ),
            /// Save Outlet Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                // onPressed: () async {
                //   if (!controller.validateOutletForm()) return;
                //
                //   final verified = await Get.to(() => const OutletOtpVerificationScreen());
                //   if (verified == true) {
                //     await controller.submitOutlet();
                //   }
                //
                // },
                onPressed: () async {
                  if (!controller.validateOutletForm()) return;
                  await controller.submitOutlet();
                },
                child: const Text(
                  "Save Outlet",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}