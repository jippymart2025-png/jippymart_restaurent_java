
import 'package:flutter/services.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/signup_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../constant/constant.dart';
import '../../models/location_model.dart';
 // ADD THIS
import '../add_restaurant_screen/locationselection.dart';
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  final cityIdController = 3;


  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<SignupController>(
        init: SignupController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : AppThemeData.surface,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create an Account".tr,
                      style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontSize: 22,
                          fontFamily: AppThemeData.semiBold),
                    ),
                    Text(
                      "Join Jippymart Restaurant today and start managing your restaurant's orders and reservations effortlessly."
                          .tr,
                      style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey400
                              : AppThemeData.grey500,
                          fontSize: 16,
                          fontFamily: AppThemeData.regular),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    merchantForm(controller, themeChange,context),
                    // Obx(
                    //       () => Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //
                    //       const Text(
                    //         "Account Type",
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //
                    //       Row(
                    //         children: [
                    //
                    //           Expanded(
                    //             child: RadioListTile<String>(
                    //               title: const Text(
                    //                 "Merchant",
                    //               ),
                    //               value: "Merchant",
                    //               groupValue:
                    //               controller.accountType.value,
                    //               onChanged: (value) {
                    //                 controller.accountType.value =
                    //                 value!;
                    //               },
                    //             ),
                    //           ),
                    //
                    //           Expanded(
                    //             child: RadioListTile<String>(
                    //               title: const Text(
                    //                 "Outlet",
                    //               ),
                    //               value: "Outlet",
                    //               groupValue:
                    //               controller.accountType.value,
                    //               onChanged: (value) {
                    //                 controller.accountType.value =
                    //                 value!;
                    //               },
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Obx(() {
                    //   return controller.accountType.value == "Merchant"
                    //       ? merchantForm(controller, themeChange)
                    //       : outletForm(controller, themeChange);
                    // }),
                    const SizedBox(height: 20),
                    RoundedButtonFill(
                      title: "Sign Up".tr,
                      color: AppThemeData.secondary300,
                      textColor: AppThemeData.grey50,
                      onPress: () async {
                        // // OUTLET FLOW
                        // if (controller.accountType.value == "Outlet") {
                        //
                        //   if (controller.outletNameController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter outlet name");
                        //     return;
                        //   }
                        //
                        //   if (controller.cuisineTypeController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter cuisine type");
                        //     return;
                        //   }
                        //
                        //   if (controller.outletPhoneController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter outlet phone");
                        //     return;
                        //   }
                        //
                        //   if (controller.outletPhoneController.value.text.trim().length != 10) {
                        //     ShowToastDialog.showToast("Phone number must be 10 digits");
                        //     return;
                        //   }
                        //
                        //   if (controller.buildingNumberController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter building number");
                        //     return;
                        //   }
                        //
                        //   if (controller.roadController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter road");
                        //     return;
                        //   }
                        //
                        //   if (controller.landmarkController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter landmark");
                        //     return;
                        //   }
                        //
                        //   if (controller.cityController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter city");
                        //     return;
                        //   }
                        //
                        //   if (controller.stateNameController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter state");
                        //     return;
                        //   }
                        //
                        //   if (controller.areaNameController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter area");
                        //     return;
                        //   }
                        //
                        //   if (controller.latitudeController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter latitude");
                        //     return;
                        //   }
                        //
                        //   if (controller.longitudeController.value.text.trim().isEmpty) {
                        //     ShowToastDialog.showToast("Please enter longitude");
                        //     return;
                        //   }
                        //
                        //    controller.createOutlet( );
                        //
                        //   return;
                        // }
                        if (controller.type.value == "google" ||
                            controller.type.value == "apple" ||
                            controller.type.value == "mobileNumber") {
                          if (controller.firstNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter first name".tr);
                          } else if (controller.lastNameEditingController.value.text.trim().isEmpty) {
                            ShowToastDialog.showToast("Please enter last name".tr);
                          } else if (controller.emailEditingController.value.text.trim().isEmpty) {
                            ShowToastDialog.showToast("Please enter valid email".tr);
                          } else if (controller.phoneNUmberEditingController.value.text.trim().isEmpty ) {
                            ShowToastDialog.showToast("Please enter phone number".tr);
                          } else if (controller.phoneNUmberEditingController.value.text.length !=10) {
                            ShowToastDialog.showToast("Number Must Be 10".tr);
                          }else {
                            controller.signUpWithEmailAndPassword();
                          }
                        } else {
                          if (controller.firstNameEditingController.value.text.trim().isEmpty) {
                            ShowToastDialog.showToast("Please enter first name".tr);
                          } else if (controller.lastNameEditingController.value.text.trim().isEmpty) {
                            ShowToastDialog.showToast("Please enter last name".tr);
                          } else if (controller.emailEditingController.value.text.trim().isEmpty) {
                            ShowToastDialog.showToast("Please enter email".tr);
                          } else if (!isValidEmail(controller.emailEditingController.value.text.trim())) {
                            ShowToastDialog.showToast("Please enter valid email".tr);
                          } else if (controller.phoneNUmberEditingController.value.text.trim().isEmpty) {
                            ShowToastDialog.showToast("Please enter Phone number".tr);
                          } else if (controller.phoneNUmberEditingController.value.text.length != 10) {
                            ShowToastDialog.showToast("Number must be 10 digits".tr);
                          } else if (controller.passwordEditingController.value.text.trim().isEmpty) {
                            ShowToastDialog.showToast(
                                "Please enter password".tr);
                            // } else if (controller.conformPasswordEditingController.value.text.trim().isEmpty) {
                            //   ShowToastDialog.showToast("Please enter confirm password".tr);
                            // } else if (controller.passwordEditingController.value.text.trim() !=
                            //     controller.conformPasswordEditingController.value.text.trim()) {
                            //   ShowToastDialog.showToast("Password and confirm password don't match".tr);
                            // }
                          } else if (controller.gstController.value.text.trim().isNotEmpty &&
                              !isValidGSTIN(controller.gstController.value.text.trim())) {
                            ShowToastDialog.showToast("Please enter a valid 15-character GSTIN".tr);
                          } else {
                            controller.signUpWithEmailAndPassword();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
  // void _openLocationPicker(BuildContext context, SignupController controller) {
  //   Constant.checkPermission(
  //     context: context,
  //     onTap: () async {
  //       ShowToastDialog.showLoader("Getting location...".tr);
  //       try {
  //         await Geolocator.requestPermission();
  //         final position = await Geolocator.getCurrentPosition();
  //         ShowToastDialog.closeLoader();
  //         final initialPos = Constant.selectedMapType == 'osm'
  //             ? const LatLng(20.5937, 78.9629)
  //             : LatLng(position.latitude, position.longitude);
  //         final result = await Get.to(
  //               () => MapPickerPage(initialPosition: initialPos),
  //           fullscreenDialog: Constant.selectedMapType != 'osm',
  //         );
  //         if (result != null) {
  //           final data = result as Map<String, dynamic>;
  //           final LatLng selectedLatLng = data['location'] as LatLng;
  //           final String selectedAddress = data['address'] as String? ?? '';
  //           controller.latitudeController.value.text = selectedLatLng.latitude.toString();
  //           controller.longitudeController.value.text = selectedLatLng.longitude.toString();
  //           controller.locationDisplayController.text = selectedAddress;
  //         }
  //       } catch (e) {
  //         ShowToastDialog.closeLoader();
  //         ShowToastDialog.showToast("Failed to get location: ${e.toString()}".tr);
  //       }
  //     },
  //   );
  // }

  void _openLocationPicker(BuildContext context, SignupController controller) {
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
            controller.latitudeController.value.text = selectedLatLng.latitude.toString();
            controller.longitudeController.value.text = selectedLatLng.longitude.toString();
            controller.locationDisplayController.text = selectedAddress;
          }
        } catch (e) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Failed to get location: ${e.toString()}".tr);
        }
      },
    );
  }  // call site, inside build():
  //merchantForm(controller, themeChange, context),
  Widget merchantForm(
      SignupController controller,
      DarkThemeProvider themeChange,
      BuildContext context,
      ) {
    return Column(
      children: [
        // Merchant fields
        buildSection(
          title: "Personal Information",
          child: Column(
            children: [

              // FIRST NAME + LAST NAME
              Row(
                children: [
                  Expanded(
                    child: TextFieldWidget(
                      title: 'First Name'.tr,
                      controller: controller.firstNameEditingController.value,
                      hintText: 'Enter First Name'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_user.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem()
                                ? AppThemeData.grey300
                                : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFieldWidget(
                      title: 'Last Name'.tr,
                      controller: controller.lastNameEditingController.value,
                      hintText: 'Enter Last Name'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_user.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem()
                                ? AppThemeData.grey300
                                : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // EMAIL
              TextFieldWidget(
                title: 'Email Address'.tr,
                textInputType: TextInputType.emailAddress,
                controller: controller.emailEditingController.value,
                hintText: 'Enter Email Address'.tr,
                enable: controller.type.value == "google" ||
                    controller.type.value == "apple"
                    ? false
                    : true,
                prefix: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    "assets/icons/ic_mail.svg",
                    colorFilter: ColorFilter.mode(
                      themeChange.getThem()
                          ? AppThemeData.grey300
                          : AppThemeData.grey600,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              // PHONE
              TextFieldWidget(
                title: 'Phone Number'.tr,
                controller: controller.phoneNUmberEditingController.value,
                hintText: 'Enter Phone Number'.tr,
                enable: controller.type.value == "mobileNumber"
                    ? false
                    : true,
                textInputType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                ],
                prefix: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🇮🇳',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // DOB
              TextFieldWidget(
                title: 'Date of Birth',
                controller: controller.dobController.value,
                hintText: 'YYYY-MM-DD',
              ),
              TextFieldWidget(
                title: 'Username',
                controller: controller.usernameController.value,
                hintText: 'Enter Username',
              ),
              // PASSWORDS
              if (!(controller.type.value == "google" ||
                  controller.type.value == "apple" ||
                  controller.type.value == "mobileNumber"))
                Column(
                  children: [
                    Obx(() => TextFieldWidget(
                      title: 'Password'.tr,
                      controller: controller.passwordEditingController.value,
                      hintText: 'Enter Password'.tr,

                      // true = password hidden
                      obscureText: controller.passwordVisible.value,

                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_lock.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem()
                                ? AppThemeData.grey300
                                : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),

                      suffix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: InkWell(
                          onTap: () {
                            controller.passwordVisible.value =
                            !controller.passwordVisible.value;
                          },
                          child: SvgPicture.asset(
                            controller.passwordVisible.value
                                ? "assets/icons/ic_password_close.svg"
                                : "assets/icons/ic_password_show.svg",
                            colorFilter: ColorFilter.mode(
                              themeChange.getThem()
                                  ? AppThemeData.grey300
                                  : AppThemeData.grey600,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ))


                   // TextFieldWidget(
                   //    title: 'Confirm Password'.tr,
                   //    controller:
                   //    controller.conformPasswordEditingController.value,
                   //    hintText: 'Enter Confirm Password'.tr,
                   //    obscureText:
                   //    controller.conformPasswordVisible.value,
                   //    prefix: Padding(
                   //      padding: const EdgeInsets.all(12),
                   //      child: SvgPicture.asset(
                   //        "assets/icons/ic_lock.svg",
                   //        colorFilter: ColorFilter.mode(
                   //          themeChange.getThem()
                   //              ? AppThemeData.grey300
                   //              : AppThemeData.grey600,
                   //          BlendMode.srcIn,
                   //        ),
                   //      ),
                   //    ),
                   //    suffix: Padding(
                   //      padding: const EdgeInsets.all(12),
                   //      child: InkWell(
                   //        onTap: () {
                   //          controller.conformPasswordVisible.value =
                   //          !controller.conformPasswordVisible.value;
                   //        },
                   //        child: controller.conformPasswordVisible.value
                   //            ? SvgPicture.asset(
                   //          "assets/icons/ic_password_show.svg",
                   //          colorFilter: ColorFilter.mode(
                   //            themeChange.getThem()
                   //                ? AppThemeData.grey300
                   //                : AppThemeData.grey600,
                   //            BlendMode.srcIn,
                   //          ),
                   //        )
                   //            : SvgPicture.asset(
                   //          "assets/icons/ic_password_close.svg",
                   //          colorFilter: ColorFilter.mode(
                   //            themeChange.getThem()
                   //                ? AppThemeData.grey300
                   //                : AppThemeData.grey600,
                   //            BlendMode.srcIn,
                   //          ),
                   //        ),
                   //      ),
                   //    ),
                   //  ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),


        buildSection(
          title: "Identity Documents",
          child: Column(
            children: [

              TextFieldWidget(
                title: 'PAN Number',
                controller: controller.panController.value,
                hintText: 'Enter PAN Number',
              ),

              TextFieldWidget(
                title: 'Aadhaar Number',
                controller: controller.aadhaarController.value,
                hintText: 'Enter Aadhaar Number',
              ),
            ],
          ),
        ),
        buildSection(
          title: "Business Information",
          child: Column(
            children: [

              TextFieldWidget(
                title: 'Outlet Type',
                controller: controller.outletTypeController.value,
                hintText: 'Restaurant/Mart/Cafe',
              ),

              TextFieldWidget(
                title: 'FSSAI Number',
                controller: controller.fssaiController.value,
                hintText: 'Enter FSSAI Number',
              ),

              TextFieldWidget(
                title: 'GST Number',
                controller: controller.gstController.value,
                hintText: 'Enter GST Number',
              ),
            ],
          ),
        ),
        buildSection(
          title: "Address Information",
          child: Column(
            children: [
              TextFieldWidget(
                title: 'Building Number',
                controller: controller.buildingNumberController.value,
                hintText: '12/345',
              ),
              TextFieldWidget(
                title: 'Road',
                controller: controller.roadController.value,
                hintText: 'Road Name',
              ),
              TextFieldWidget(
                title: 'Landmark',
                controller: controller.landmarkController.value,
                hintText: 'Enter Landmark',
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
              }),
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
              }),
              const SizedBox(height: 12),
              // InkWell(
              //   onTap: () => _openLocationPicker(context, controller),
              //   child: IgnorePointer(
              //     child: TextField(
              //       controller: controller.locationDisplayController,
              //       decoration: const InputDecoration(
              //         labelText: "Outlet Location",
              //         hintText: "Tap to select on map",
              //         suffixIcon: Icon(Icons.location_on),
              //       ),
              //       maxLines: 2,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        buildSection(
          title: "Bank Information",
          child: Column(
            children: [

              TextFieldWidget(
                title: 'Account Holder Name',
                controller: controller.accountHolderController.value,
                hintText: 'Enter Account Holder Name',
              ),

              TextFieldWidget(
                title: 'Account Number',
                controller: controller.accountNumberController.value,
                hintText: 'Enter Account Number',
              ),

              TextFieldWidget(
                title: 'IFSC Code',
                controller: controller.ifscController.value,
                hintText: 'Enter IFSC Code',
              ),

              TextFieldWidget(
                title: 'Bank Location',
                controller: controller.bankLocationController.value,
                hintText: 'Enter Bank Location',
              ),



              const SizedBox(height: 8),
            ],
          ),
        ),

      ],
    );
  }
  // Widget outletForm(
  //     SignupController controller,
  //     DarkThemeProvider themeChange,
  //     ) {
  //   return Column(
  //     children: [
  //
  //       buildSection(
  //         title: "Outlet Information",
  //         child: Column(
  //           children: [
  //
  //             TextFieldWidget(
  //               title: "Outlet Name",
  //               controller:
  //               controller.outletNameController.value,
  //               hintText: "Enter Outlet Name",
  //             ),
  //
  //             TextFieldWidget(
  //               title: "MerchantId",
  //               controller:
  //               controller.merchantIdController.value,
  //               hintText: "merchantId",
  //             ),
  //             TextFieldWidget(
  //               title: "Cuisine Type",
  //               controller:
  //               controller.cuisineTypeController.value,
  //               hintText: "South Indian",
  //             ),
  //
  //             TextFieldWidget(
  //               title: "Outlet Phone",
  //               controller:
  //               controller.outletPhoneController.value,
  //               hintText: "Enter Outlet Phone",
  //             ),
  //           ],
  //         ),
  //       ),
  //
  //       buildSection(
  //         title: "Address Information",
  //         child: Column(
  //           children: [
  //
  //             TextFieldWidget(
  //               title: "Building Number",
  //               controller:
  //               controller.buildingNumberController.value,
  //               hintText: "12/345",
  //             ),
  //
  //             TextFieldWidget(
  //               title: "Road",
  //               controller:
  //               controller.roadController.value,
  //               hintText: "Road",
  //             ),
  //
  //             TextFieldWidget(
  //               title: "Landmark",
  //               controller:
  //               controller.landmarkController.value,
  //               hintText: "Landmark",
  //             ),
  //             TextFieldWidget(
  //               title: "CityId",
  //               controller:
  //               controller.cityController.value,
  //               hintText: "CityId",
  //             ),
  //             TextFieldWidget(
  //               title: "StateName",
  //               controller:
  //               controller.stateNameController.value,
  //               hintText: "StateName",
  //             ),
  //
  //             TextFieldWidget(
  //               title: "AreaName",
  //               controller:
  //               controller.areaNameController.value,
  //               hintText: "AreaName",
  //             ),
  //
  //             TextFieldWidget(
  //               title: "Latitude",
  //               controller:
  //               controller.latitudeController.value,
  //               hintText: "Latitude",
  //             ),
  //
  //             TextFieldWidget(
  //               title: "Longitude",
  //               controller:
  //               controller.longitudeController.value,
  //               hintText: "Longitude",
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppThemeData.secondary300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 10,
              bottom: 4,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: AppThemeData.secondary300,
                fontFamily: AppThemeData.semiBold,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: child,
          ),
        ],
      ),
    );
  }
  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    );
    return emailRegExp.hasMatch(email);
  }
  bool isValidGSTIN(String gstin) {
    final RegExp gstinRegExp = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    return gstinRegExp.hasMatch(gstin.trim().toUpperCase());
  }
}
