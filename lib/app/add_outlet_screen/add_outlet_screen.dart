import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jippymart_restaurant/widget/osm_map/map_picker_page.dart'
    hide MapPickerPage;
import '../../widget/locationselection.dart';
import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/add_outlet_controller.dart';
import '../../models/location_model.dart';

class AddOutletScreen extends StatelessWidget {
  AddOutletScreen({super.key});

  final AddOutletController controller = Get.put(AddOutletController());

  // ============================================================
  // REUSABLE SECTION BUILDER
  // ============================================================
  Widget buildSection({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: Colors.red),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUISINE PICKER
  // ============================================================
  void _showCuisinePicker(
      BuildContext context, AddOutletController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Select Cuisine Types",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onChanged: (_) {
                              controller
                                  .toggleCuisine(cuisine.cuisineTypeId);
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
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

  // ============================================================
  // LOCATION PICKER
  // ============================================================
  void _openLocationPickerForOutlet(
      BuildContext context, AddOutletController controller) {
    Constant.checkPermission(
      context: context,
      onTap: () async {
        try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            ShowToastDialog.showToast("Please enable location services".tr);
            return;
          }

          LocationPermission permission = await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              ShowToastDialog.showToast("Location permission denied".tr);
              return;
            }
          }

          if (permission == LocationPermission.deniedForever) {
            ShowToastDialog.showToast(
              "Location permission permanently denied, please enable it from app settings"
                  .tr,
            );
            return;
          }

          ShowToastDialog.showLoader("Getting location...".tr);
          final position = await Geolocator.getCurrentPosition();
          ShowToastDialog.closeLoader();

          final initialPosition =
          LatLng(position.latitude, position.longitude);

          final result = await Get.to(
                () => MapPickerPage(initialPosition: initialPosition),
            fullscreenDialog: Constant.selectedMapType != 'osm',
          );

          if (result != null) {
            final data = result as Map<String, dynamic>;
            final LatLng selectedLatLng = data['location'] as LatLng;
            final String selectedAddress = data['address'] as String? ?? '';
            controller.latitudeController.text =
                selectedLatLng.latitude.toString();
            controller.longitudeController.text =
                selectedLatLng.longitude.toString();
            controller.locationDisplayController.text = selectedAddress;
          }
        } catch (e) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Failed to get location: ${e.toString()}".tr);
        }
      },
    );
  }

  // ============================================================
  // TIME FIELD WIDGET (Read-only with time picker)
  // ============================================================
  Widget _buildTimeField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
    IconData icon = Icons.access_time,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.red.shade300),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Text(
          value.trim().isEmpty ? "Select time" : value,
          style: TextStyle(
            color: value.trim().isEmpty ? Colors.grey : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Outlet Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =====================================================
            // OUTLET INFORMATION
            // =====================================================
            buildSection(
              title: "Outlet Information",
              icon: Icons.storefront,
              children: [
                TextField(
                  controller: controller.outletNameController,
                  decoration: _boxDecoration(
                    labelText: "Outlet Name",
                    hintText: "Enter Outlet Name",
                    prefixIcon: Icon(Icons.store, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isCuisineLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final selectedNames = controller.cuisineTypes
                      .where((c) =>
                      controller.isCuisineSelected(c.cuisineTypeId))
                      .map((c) => c.cuisineTypeName)
                      .join(", ");

                  return InkWell(
                    onTap: () => _showCuisinePicker(context, controller),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Cuisine Type",
                        hintText: "Select Cuisine Types",
                        prefixIcon:
                        const Icon(Icons.restaurant_menu, size: 20),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        selectedNames.isEmpty
                            ? "Select Cuisine Types"
                            : selectedNames,
                        style: TextStyle(
                          color: selectedNames.isEmpty
                              ? Colors.grey
                              : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _boxDecoration(
                    labelText: "Phone Number",
                    hintText: "Enter Outlet Phone",
                    prefixIcon: Icon(Icons.phone, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.alternatePhoneController,
                  decoration: _boxDecoration(
                    labelText: "Alternate Phone Number",
                    hintText: "Enter Alternate Phone Number",
                    prefixIcon: Icon(Icons.phone_android, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.emailController,
                  decoration: _boxDecoration(
                    labelText: "Email",
                    hintText: "Enter Outlet Email",
                    prefixIcon: Icon(Icons.email, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.fssaiNumberController,
                  keyboardType: TextInputType.number,
                  decoration: _boxDecoration(
                    labelText: "FSSAI Number",
                    hintText: "Enter FSSAI Number",
                    prefixIcon: Icon(Icons.verified, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.gstNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _boxDecoration(
                    labelText: "GST Number",
                    hintText: "Enter GST Number",
                    prefixIcon: Icon(Icons.receipt_long, size: 20),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => CheckboxListTile(
                  value: controller.isVegOutlet.value,
                  onChanged: (value) {
                    controller.isVegOutlet.value = value ?? false;
                  },
                  title: const Text("Is Veg Outlet"),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.red,
                )),
                Obx(() => CheckboxListTile(
                  value: controller.isGstApplied.value,
                  onChanged: (value) {
                    controller.isGstApplied.value = value ?? false;
                  },
                  title: const Text("Is GST Applied"),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.red,
                )),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.usernameController,
                  decoration: _boxDecoration(
                    labelText: "Username",
                    hintText: "Enter Username",
                    prefixIcon: Icon(Icons.person, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => TextField(
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  decoration: _boxDecoration(
                    labelText: "Password",
                    hintText: "Enter Password",
                    prefixIcon:
                    const Icon(Icons.lock_outline, size: 20),
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

            // =====================================================
            // ADDRESS INFORMATION
            // =====================================================
            buildSection(
              title: "Address Information",
              icon: Icons.location_on,
              children: [
                TextField(
                  controller: controller.buildingController,
                  decoration: _boxDecoration(
                    labelText: "Building Number",
                    hintText: "12/345",
                    prefixIcon: Icon(Icons.home, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.roadController,
                  decoration: _boxDecoration(
                    labelText: "Road",
                    hintText: "Road Name",
                    prefixIcon: Icon(Icons.add_road, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.landmarkController,
                  decoration: _boxDecoration(
                    labelText: "Landmark",
                    hintText: "Enter Landmark",
                    prefixIcon: Icon(Icons.place, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  return DropdownButtonFormField<StateModel>(
                    value: controller.selectedState.value,
                    decoration: _boxDecoration(
                      labelText: "State",
                      hintText: "Select State",
                      prefixIcon: Icon(Icons.map, size: 20),
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
                }),
                const SizedBox(height: 16),
                Obx(() {
                  return DropdownButtonFormField<CityModel>(
                    value: controller.selectedCity.value,
                    decoration: _boxDecoration(
                      labelText: "City",
                      hintText: "Select City",
                      prefixIcon: Icon(Icons.location_city, size: 20),
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
                const SizedBox(height: 16),
                Obx(() {
                  return DropdownButtonFormField<AreaModel>(
                    value: controller.selectedArea.value,
                    decoration: _boxDecoration(
                      labelText: "Area",
                      hintText: "Select Area",
                      prefixIcon: Icon(Icons.my_location, size: 20),
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
                }),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () =>
                      _openLocationPickerForOutlet(context, controller),
                  borderRadius: BorderRadius.circular(12),
                  child: IgnorePointer(
                    child: TextField(
                      controller: controller.locationDisplayController,
                      keyboardType: TextInputType.text,
                      decoration: _boxDecoration(
                        labelText: "Outlet Location",
                        hintText: "Tap to select on map",
                        prefixIcon:
                        const Icon(Icons.location_on, color: Colors.red),
                        suffixIcon: const Icon(Icons.map),
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),

            // =====================================================
            // OPERATING HOURS
            // =====================================================
            buildSection(
              title: "Operating Hours",
              icon: Icons.schedule,
              children: [
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    value: controller.sameTimingForAllDays.value,
                    onChanged: (value) {
                      controller.sameTimingForAllDays.value = value!;
                    },
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(
                      "Same timings for all days",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.red,
                  ),
                )),
                const SizedBox(height: 16),
                Obx(() {
                  // ============ SAME TIMING FOR ALL DAYS ============
                  if (controller.sameTimingForAllDays.value) {
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.commonTimeSlots.length,
                          itemBuilder: (context, slotIndex) {
                            final slot =
                            controller.commonTimeSlots[slotIndex];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Slot ${slotIndex + 1}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          controller
                                              .removeCommonTimeSlot(
                                              slotIndex);
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTimeField(
                                          context: context,
                                          label: "Opening Time",
                                          value: slot["openingTime"]
                                              .toString(),
                                          icon: Icons.wb_sunny_outlined,
                                          onTap: () =>
                                              controller
                                                  .pickCommonOpeningTime(
                                                  context, slotIndex),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTimeField(
                                          context: context,
                                          label: "Closing Time",
                                          value: slot["closingTime"]
                                              .toString(),
                                          icon: Icons.nights_stay_outlined,
                                          onTap: () =>
                                              controller
                                                  .pickCommonClosingTime(
                                                  context, slotIndex),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: controller.addCommonTimeSlot,
                            icon: const Icon(Icons.add),
                            label: const Text("Add Another Time Slot"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // ============ DIFFERENT TIMINGS PER DAY ============
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.operatingDays.length,
                        itemBuilder: (context, dayIndex) {
                          final day = controller.operatingDays[dayIndex];
                          final slots = day["slots"] as List<dynamic>;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border:
                              Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      day["dayName"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        controller
                                            .removeOperatingDay(dayIndex);
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ...List.generate(slots.length, (slotIndex) {
                                  final slot = slots[slotIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 12),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTimeField(
                                                context: context,
                                                label: "Opening Time",
                                                value: slot["openingTime"]
                                                    .toString(),
                                                icon: Icons
                                                    .wb_sunny_outlined,
                                                onTap: () => controller
                                                    .pickOpeningTime(
                                                    context,
                                                    dayIndex,
                                                    slotIndex),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _buildTimeField(
                                                context: context,
                                                label: "Closing Time",
                                                value: slot["closingTime"]
                                                    .toString(),
                                                icon: Icons
                                                    .nights_stay_outlined,
                                                onTap: () => controller
                                                    .pickClosingTime(
                                                    context,
                                                    dayIndex,
                                                    slotIndex),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Align(
                                          alignment:
                                          Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () {
                                              controller.removeTimeSlot(
                                                  dayIndex, slotIndex);
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                            label: const Text(
                                              "Remove Slot",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (slotIndex < slots.length - 1)
                                          const Divider(height: 1),
                                      ],
                                    ),
                                  );
                                }),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      controller.addTimeSlot(dayIndex);
                                    },
                                    icon: const Icon(Icons.add,
                                        color: Colors.red),
                                    label: const Text(
                                      "Add Slot",
                                      style:
                                      TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.operatingDays.length >= 7
                              ? null
                              : controller.addOperatingDay,
                          icon: const Icon(Icons.add),
                          label: Text(
                            controller.operatingDays.length >= 7
                                ? "All 7 Days Added"
                                : "Add Day (${controller.weekDays[controller.operatingDays.length]})",
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            // =====================================================
            // BANK DETAILS
            // =====================================================
            buildSection(
              title: "Bank Details",
              icon: Icons.account_balance,
              children: [
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    value: controller.useMerchantBankDetails.value,
                    onChanged: (value) {
                      controller.onMerchantBankChanged(value ?? false);
                    },
                    title: const Text(
                      "Same as Merchant Bank Details",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.red,
                  ),
                )),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.accountHolderController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration:  _boxDecoration(
                    labelText: "Account Holder",
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.accountNumberController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: _boxDecoration(
                    labelText: "Account Number",
                    prefixIcon: Icon(Icons.numbers, size: 20),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.ifscController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: _boxDecoration(
                    labelText: "IFSC Code",
                    prefixIcon: Icon(Icons.code, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.bankNameController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: _boxDecoration(
                    labelText: "Bank Name",
                    prefixIcon: Icon(Icons.account_balance, size: 20),
                  ),
                ),
              ],
            ),

            // =====================================================
            // SAVE BUTTON
            // =====================================================
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.red.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  if (!controller.validateOutletForm()) return;
                  await controller.submitOutlet();
                },
                child: const Text(
                  "Save Outlet",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOX-STYLE DECORATION HELPERS
// ============================================================
InputDecoration _boxDecoration({
  required String labelText,
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  int maxLines = 1,
  bool readOnly = false,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    filled: true,
    fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
    floatingLabelStyle: const TextStyle(color: Colors.red, fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}