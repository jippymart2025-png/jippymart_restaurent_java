import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/add_outlet_controller.dart';
import '../../../utils/input_decorations.dart';
import '../../edit_profile_screen/widgets/MerchantForm.dart';
import 'cuisine_picker_sheet.dart';

class OutletInfoSection extends StatelessWidget {
  const OutletInfoSection({super.key, required this.controller});

  final AddOutletController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Outlet Information",
      icon: Icons.storefront,
      children: [
        _buildOutletName(),
        const SizedBox(height: 16),
        _buildCuisinePicker(context),
        const SizedBox(height: 16),
        _buildPhone(),
        const SizedBox(height: 16),
        _buildAlternatePhone(),
        const SizedBox(height: 16),
        _buildEmail(),
        const SizedBox(height: 16),
        _buildFssai(),
        const SizedBox(height: 16),
        _buildGst(),
        const SizedBox(height: 8),
        _buildVegCheckbox(),
        _buildGstCheckbox(),
        const SizedBox(height: 8),
        _buildUsername(),
        const SizedBox(height: 16),
        _buildPassword(),
      ],
    );
  }

  Widget _buildOutletName() {
    return TextField(
      controller: controller.outletNameController,
      decoration: AppInputDecoration.box(
        labelText: "Outlet Name",
        hintText: "Enter Outlet Name",
        prefixIcon: const Icon(Icons.store, size: 20),
      ),
    );
  }

  Widget _buildCuisinePicker(BuildContext context) {
    return Obx(() {
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
        onTap: () => CuisinePickerSheet.show(context, controller),
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: "Cuisine Type",
            hintText: "Select Cuisine Types",
            prefixIcon: Icon(Icons.restaurant_menu, size: 20),
            suffixIcon: Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          child: Text(
            selectedNames.isEmpty ? "Select Cuisine Types" : selectedNames,
            style: TextStyle(
              color: selectedNames.isEmpty ? Colors.grey : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    });
  }

  Widget _buildPhone() {
    return TextField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      decoration: AppInputDecoration.box(
        labelText: "Phone Number",
        hintText: "Enter Outlet Phone",
        prefixIcon: const Icon(Icons.phone, size: 20),
      ),
    );
  }

  Widget _buildAlternatePhone() {
    return TextFormField(
      controller: controller.alternatePhoneController,
      decoration: AppInputDecoration.box(
        labelText: "Alternate Phone Number",
        hintText: "Enter Alternate Phone Number",
        prefixIcon: const Icon(Icons.phone_android, size: 20),
      ),
    );
  }

  Widget _buildEmail() {
    return TextField(
      controller: controller.emailController,
      decoration: AppInputDecoration.box(
        labelText: "Email",
        hintText: "Enter Outlet Email",
        prefixIcon: const Icon(Icons.email, size: 20),
      ),
    );
  }

  Widget _buildFssai() {
    return TextField(
      controller: controller.fssaiNumberController,
      keyboardType: TextInputType.number,
      decoration: AppInputDecoration.box(
        labelText: "FSSAI Number",
        hintText: "Enter FSSAI Number",
        prefixIcon: const Icon(Icons.verified, size: 20),
      ),
    );
  }

  Widget _buildGst() {
    return TextField(
      controller: controller.gstNumberController,
      textCapitalization: TextCapitalization.characters,
      decoration: AppInputDecoration.box(
        labelText: "GST Number",
        hintText: "Enter GST Number",
        prefixIcon: const Icon(Icons.receipt_long, size: 20),
      ),
    );
  }

  Widget _buildVegCheckbox() {
    return Obx(() => CheckboxListTile(
      value: controller.isVegOutlet.value,
      onChanged: (v) => controller.isVegOutlet.value = v ?? false,
      title: const Text("Is Veg Outlet"),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.red,
    ));
  }

  Widget _buildGstCheckbox() {
    return Obx(() => CheckboxListTile(
      value: controller.isGstApplied.value,
      onChanged: (v) => controller.isGstApplied.value = v ?? false,
      title: const Text("Is GST Applied"),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.red,
    ));
  }

  Widget _buildUsername() {
    return TextField(
      controller: controller.usernameController,
      decoration: AppInputDecoration.box(
        labelText: "Username",
        hintText: "Enter Username",
        prefixIcon: const Icon(Icons.person, size: 20),
      ),
    );
  }

  Widget _buildPassword() {
    return Obx(() => TextField(
      controller: controller.passwordController,
      obscureText: controller.isPasswordHidden.value,
      decoration: AppInputDecoration.box(
        labelText: "Password",
        hintText: "Enter Password",
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          onPressed: () => controller.isPasswordHidden.value =
          !controller.isPasswordHidden.value,
          icon: SvgPicture.asset(
            controller.isPasswordHidden.value
                ? "assets/icons/ic_password_close.svg"
                : "assets/icons/ic_password_show.svg",
            width: 22,
            height: 22,
          ),
        ),
      ),
    ));
  }
}