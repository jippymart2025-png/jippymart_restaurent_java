import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controller/add_outlet_controller.dart';
import '../../../../models/location_model.dart';
import '../../../../utils/input_decorations.dart';
import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../widget/locationselection.dart';
import '../../edit_profile_screen/widgets/MerchantForm.dart';

class AddressInfoSection extends StatelessWidget {
  const AddressInfoSection({super.key, required this.controller});

  final AddOutletController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Address Information",
      children: [
        _buildLocationField(context),
        const SizedBox(height: 16),
        _buildRoad(),
        const SizedBox(height: 16),
        _buildLandmark(),
        const SizedBox(height: 16),
        _buildStateDropdown(),
        const SizedBox(height: 16),
        _buildCityDropdown(),
        const SizedBox(height: 16),
        _buildAreaDropdown(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationField(BuildContext context) {
    return InkWell(
      onTap: () => _openLocationPickerForOutlet(context, controller),
      borderRadius: BorderRadius.circular(12),
      child: IgnorePointer(
        child: TextField(
          controller: controller.locationDisplayController,
          keyboardType: TextInputType.text,
          decoration: AppInputDecoration.box(
            labelText: "Outlet Location",
            hintText: "Tap to select on map",
            prefixIcon: const Icon(Icons.location_on, color: Colors.red),
            suffixIcon: const Icon(Icons.map),
          ),
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildRoad() {
    return TextField(
      controller: controller.roadController,
      decoration: AppInputDecoration.box(
        labelText: "Road",
        hintText: "Road Name",
        prefixIcon: const Icon(Icons.add_road, size: 20),
      ),
    );
  }

  Widget _buildLandmark() {
    return TextField(
      controller: controller.landmarkController,
      decoration: AppInputDecoration.box(
        labelText: "Landmark",
        hintText: "Enter Landmark",
        prefixIcon: const Icon(Icons.place, size: 20),
      ),
    );
  }

  Widget _buildStateDropdown() {
    return Obx(() =>
        DropdownButtonFormField<StateModel>(
          value: controller.selectedState.value,
          decoration: AppInputDecoration.box(
            labelText: "State",
            hintText: "Select State",
            prefixIcon: const Icon(Icons.map, size: 20),
          ),
          isExpanded: true,
          items: controller.states
              .map((s) =>
              DropdownMenuItem(
                value: s,
                child: Text(s.stateName),
              ))
              .toList(),
          onChanged: controller.onStateSelected,
        ));
  }

  Widget _buildCityDropdown() {
    return Obx(() =>
        DropdownButtonFormField<CityModel>(
          value: controller.selectedCity.value,
          decoration: AppInputDecoration.box(
            labelText: "City",
            hintText: "Select City",
            prefixIcon: const Icon(Icons.location_city, size: 20),
          ),
          isExpanded: true,
          items: controller.cities
              .map((c) =>
              DropdownMenuItem(
                value: c,
                child: Text(c.cityName),
              ))
              .toList(),
          onChanged: controller.onCitySelected,
        ));
  }

  Widget _buildAreaDropdown() {
    return Obx(() =>
        DropdownButtonFormField<AreaModel>(
          value: controller.selectedArea.value,
          decoration: AppInputDecoration.box(
            labelText: "Area",
            hintText: "Select Area",
            prefixIcon: const Icon(Icons.my_location, size: 20),
          ),
          isExpanded: true,
          items: controller.areas
              .map((a) =>
              DropdownMenuItem(
                value: a,
                child: Text(a.areaName),
              ))
              .toList(),
          onChanged: controller.onAreaSelected,
        ));
  }
}

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
                () => MapPickerPage(
              initialPosition: initialPosition,
            ),
            fullscreenDialog: Constant.selectedMapType != 'osm',
          );

          if (result != null) {
            final data = result as Map<String, dynamic>;

            final LatLng selectedLatLng = data['location'] as LatLng;
            final String selectedAddress =
                data['address'] as String? ?? '';

            controller.latitudeController.text =
                selectedLatLng.latitude.toString();

            controller.longitudeController.text =
                selectedLatLng.longitude.toString();

            controller.locationDisplayController.text = selectedAddress;
          }
        }catch (e) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Failed to get location: ${e.toString()}".tr);
        }
      },
    );
  }
