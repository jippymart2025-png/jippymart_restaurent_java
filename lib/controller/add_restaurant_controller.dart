import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';
import 'package:jippymart_restaurant/controller/product_list_controller.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/models/zone_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/widget/geoflutterfire/src/geoflutterfire.dart';

class AddRestaurantController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isAddressEnable = false.obs;
  RxBool isEnableDeliverySettings = true.obs;
  final myKey1 = GlobalKey<DropdownSearchState<VendorCategoryModel>>();

  Rx<TextEditingController> restaurantNameController = TextEditingController().obs;
  Rx<TextEditingController> restaurantDescriptionController = TextEditingController().obs;
  Rx<TextEditingController> mobileNumberController = TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;

  Rx<TextEditingController> chargePerKmController = TextEditingController().obs;
  Rx<TextEditingController> minDeliveryChargesController = TextEditingController().obs;
  Rx<TextEditingController> minDeliveryChargesWithinKMController = TextEditingController().obs;

  final dashBoardController = Get.find<DashBoardController>();
  LatLng? selectedLocation;

  RxList<dynamic> images = <dynamic>[].obs;

  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  Rx<ZoneModel> selectedZone = ZoneModel().obs;

  RxList<String> selectedService = <String>[].obs;
  RxList<VendorCategoryModel> selectedCategories = <VendorCategoryModel>[].obs;

  @override
  void onInit() {
    print("🔄 AddRestaurantController initialized");
    getRestaurant();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;
  Rx<DeliveryCharge> deliveryChargeModel = DeliveryCharge().obs;
  RxBool isSelfDelivery = false.obs;

  final ImagePicker _imagePicker = ImagePicker();
  Map<String, dynamic> filters = {};

  getRestaurant() async {
    try {
      isLoading.value = true;
      print("🔄 Starting getRestaurant()...");

      // Get current user ID
      String? userId = await FireStoreUtils.getCurrentUid();
      if (userId == null || userId.isEmpty) {
        ShowToastDialog.showToast("User not authenticated".tr);
        isLoading.value = false;
        return;
      }
      print("👤 User ID: $userId");

      // Get user profile
      UserModel? user = await FireStoreUtils.getUserProfile(userId);
      if (user != null) {
        userModel.value = user;
        Constant.userModel = user;
        print("✅ User profile loaded: ${user.firstName}");
      } else {
        print("⚠️ Warning: User profile is null");
      }

      // Get vendor categories
      List<VendorCategoryModel>? categories = await FireStoreUtils.getMerchantCategoryById();
      if (categories != null) {
        vendorCategoryList.value = categories;
        print("✅ Loaded ${categories.length} vendor categories");
      } else {
        print("⚠️ Warning: Vendor categories are null");
      }

      // Get zones
      List<ZoneModel>? zones = await FireStoreUtils.getZone();
      if (zones != null) {
        zoneList.value = zones;
        print("✅ Loaded ${zones.length} zones");
      } else {
        print("⚠️ Warning: Zones are null");
      }

      // Check if user has existing vendor
      if (userModel.value.vendorID != null && userModel.value.vendorID!.isNotEmpty) {
        print("🏪 Loading existing vendor: ${userModel.value.vendorID}");
        VendorModel? vendor = await FireStoreUtils.getVendorById(userModel.value.vendorID!);
        if (vendor != null) {
          vendorModel.value = vendor;
          print("✅ Vendor loaded: ${vendor.title}");

          // Populate form fields
          _populateFormFields(vendor);
        } else {
          print("⚠️ Warning: Vendor not found for ID: ${userModel.value.vendorID}");
        }
      } else {
        print("🆕 No existing vendor found, creating new one");
      }

      // Get delivery settings
      DeliveryCharge? delivery = await FireStoreUtils.getDelivery();
      if (delivery != null) {
        deliveryChargeModel.value = delivery;
        isEnableDeliverySettings.value = delivery.vendorCanModify ?? false;
        print("✅ Delivery settings loaded");

        // Set delivery charge fields
        _setDeliveryChargeFields(delivery);
      } else {
        print("⚠️ Warning: Delivery settings are null");
      }

    } catch (e, stackTrace) {
      print("❌ Error in getRestaurant(): $e");
      print("Stack trace: $stackTrace");
      ShowToastDialog.showToast("Failed to load data: ${e.toString()}".tr);
    } finally {
      isLoading.value = false;
      print("🏁 getRestaurant() completed");
    }
  }

  void _populateFormFields(VendorModel vendor) {
    restaurantNameController.value.text = vendor.title ?? '';
    restaurantDescriptionController.value.text = vendor.description ?? '';
    mobileNumberController.value.text = vendor.phonenumber ?? '';
    addressController.value.text = vendor.location ?? '';
    isSelfDelivery.value = vendor.isSelfDelivery ?? false;

    if (addressController.value.text.isNotEmpty) {
      isAddressEnable.value = true;
    }

    if (vendor.latitude != null && vendor.longitude != null) {
      selectedLocation = LatLng(vendor.latitude!, vendor.longitude!);
    }

    // Set photos
    images.clear();
    if (vendor.photos != null && vendor.photos!.isNotEmpty) {
      images.addAll(vendor.photos!);
    }

    // Set zone
    if (vendor.zoneId != null && zoneList.isNotEmpty) {
      for (var zone in zoneList) {
        if (zone.id == vendor.zoneId) {
          selectedZone.value = zone;
          break;
        }
      }
    }

    // Set categories
    selectedCategories.clear();
    if (vendor.categoryID != null && vendorCategoryList.isNotEmpty) {
      for (var categoryId in vendor.categoryID!) {
        var category = vendorCategoryList.firstWhere(
              (cat) => cat.id == categoryId,
          orElse: () => VendorCategoryModel(),
        );
        if (category.id != null) {
          selectedCategories.add(category);
        }
      }
    }

    // Set services (filters)
    selectedService.clear();
    if (vendor.filters != null) {
      vendor.filters!.toJson().forEach((key, value) {
        if (value == 'Yes') {
          selectedService.add(key);
        }
      });
    }
  }

  void _setDeliveryChargeFields(DeliveryCharge delivery) {
    if (delivery.vendorCanModify == true && vendorModel.value.deliveryCharge != null) {
      // Use vendor's custom delivery charges
      chargePerKmController.value.text =
          vendorModel.value.deliveryCharge!.deliveryChargesPerKm?.toString() ?? '';
      minDeliveryChargesController.value.text =
          vendorModel.value.deliveryCharge!.minimumDeliveryCharges?.toString() ?? '';
      minDeliveryChargesWithinKMController.value.text =
          vendorModel.value.deliveryCharge!.minimumDeliveryChargesWithinKm?.toString() ?? '';
    } else {
      // Use default delivery charges
      chargePerKmController.value.text = delivery.deliveryChargesPerKm?.toString() ?? '';
      minDeliveryChargesController.value.text = delivery.minimumDeliveryCharges?.toString() ?? '';
      minDeliveryChargesWithinKMController.value.text = delivery.minimumDeliveryChargesWithinKm?.toString() ?? '';
    }
  }

  void _prepareFilters() {
    filters.clear();

    // Define all possible filter services
    List<String> allServices = [
      'Good for Breakfast',
      'Good for Lunch',
      'Good for Dinner',
      'Takes Reservations',
      'Vegetarian Friendly',
      'Live Music',
      'Outdoor Seating',
      'Free Wi-Fi'
    ];

    // Set each service to 'Yes' if selected, otherwise 'No'
    for (var service in allServices) {
      filters[service] = selectedService.contains(service) ? 'Yes' : 'No';
    }

    print("📋 Prepared filters: $filters");
  }

  num? _parseNumber(String value) {
    if (value.isEmpty) return null;
    try {
      return num.parse(value);
    } catch (e) {
      print("⚠️ Failed to parse number: $value, error: $e");
      return null;
    }
  }

  Future<void> _uploadImages(String userId) async {
    if (images.isEmpty) {
      print("📸 No images to upload");
      return;
    }

    print("📤 Uploading ${images.length} image(s)...");

    List<Future<String>> uploadFutures = [];
    List<int> uploadIndices = [];

    for (int i = 0; i < images.length; i++) {
      if (images[i] is XFile) {
        print("  📤 Queueing image $i for upload");
        uploadIndices.add(i);
        uploadFutures.add(
          Constant.uploadUserImageToFireStorage(
            File((images[i] as XFile).path),
            "vendor/$userId/restaurant",
            "${DateTime.now().millisecondsSinceEpoch}_${(images[i] as XFile).path.split('/').last}",
          ),
        );
      }
    }

    if (uploadFutures.isNotEmpty) {
      try {
        List<String> uploadedUrls = await Future.wait(uploadFutures);
        print("✅ Successfully uploaded ${uploadedUrls.length} image(s)");

        for (int i = 0; i < uploadIndices.length; i++) {
          if (i < uploadedUrls.length && uploadedUrls[i].isNotEmpty) {
            images[uploadIndices[i]] = uploadedUrls[i];
          }
        }
      } catch (uploadError) {
        print("⚠️ Image upload error: $uploadError");
        // Continue even if image upload fails
        ShowToastDialog.showToast("Some images failed to upload, but restaurant was saved".tr);
      }
    }
  }

  Future<void> saveDetails() async {
    try {
      print("🟡 Save Details button clicked!");

      // 1. Validate form
      print("🔍 Validating form...");
      if (restaurantNameController.value.text.isEmpty) {
        ShowToastDialog.showToast("Please enter restaurant name".tr);
        print("❌ Validation failed: Restaurant name empty");
        return;
      }
      if (restaurantDescriptionController.value.text.isEmpty) {
        ShowToastDialog.showToast("Please enter Description".tr);
        print("❌ Validation failed: Description empty");
        return;
      }
      if (mobileNumberController.value.text.isEmpty) {
        ShowToastDialog.showToast("Please enter phone number".tr);
        print("❌ Validation failed: Phone number empty");
        return;
      }
      if (mobileNumberController.value.text.length != 10) {
        ShowToastDialog.showToast("Mobile number must be 10 digits".tr);
        print("❌ Validation failed: Phone number not 10 digits");
        return;
      }
      if (addressController.value.text.isEmpty) {
        ShowToastDialog.showToast("Please enter address".tr);
        print("❌ Validation failed: Address empty");
        return;
      }
      if (selectedZone.value.id == null) {
        ShowToastDialog.showToast("Please select zone".tr);
        print("❌ Validation failed: Zone not selected");
        return;
      }
      if (selectedCategories.isEmpty) {
        ShowToastDialog.showToast("Please select category".tr);
        print("❌ Validation failed: Category not selected");
        return;
      }
      if (selectedLocation == null) {
        ShowToastDialog.showToast("Please select location on map".tr);
        print("❌ Validation failed: Location not selected");
        return;
      }

      print("✅ Form validation passed!");

      // 2. Check if location is within zone
      print("📍 Checking location within zone...");
      if (selectedZone.value.area == null) {
        ShowToastDialog.showToast("Selected zone has no area defined".tr);
        print("❌ Zone area is null");
        return;
      }

      if (!Constant.isPointInPolygon(selectedLocation!, selectedZone.value.area!)) {
        ShowToastDialog.showToast("The chosen area is outside the selected zone.".tr);
        print("❌ Location outside zone");
        return;
      }
      print("✅ Location is within zone!");

      // 3. Show loader
      print("⏳ Showing loader...");
      ShowToastDialog.showLoader("Please wait".tr);

      // 4. Prepare filters
      print("⚙️ Preparing filters...");
      _prepareFilters();
      print("✅ Filters prepared: $filters");

      // 5. Create delivery charge model
      print("💰 Creating delivery charge model...");
      DeliveryCharge deliveryChargeModel = DeliveryCharge(
        vendorCanModify: true,
        deliveryChargesPerKm: _parseNumber(chargePerKmController.value.text) ?? 0.0,
        minimumDeliveryCharges: _parseNumber(minDeliveryChargesController.value.text) ?? 0.0,
        minimumDeliveryChargesWithinKm: _parseNumber(minDeliveryChargesWithinKMController.value.text) ?? 0.0,
      );
      print("✅ Delivery charge model created");

      // 6. Initialize vendor model if new
      if (vendorModel.value.id == null) {
        print("🆕 Initializing new vendor model...");
        vendorModel.value = VendorModel();
        vendorModel.value.createdAt = Timestamp.now();
        print("✅ New vendor model initialized");
      } else {
        print("📝 Updating existing vendor: ${vendorModel.value.id}");
      }

      // 7. Get user ID
      print("👤 Getting user ID...");
      String? userId = await FireStoreUtils.getCurrentUid();
      if (userId == null || userId.isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("User not authenticated".tr);
        print("❌ User ID is null or empty");
        return;
      }
      print("✅ User ID: $userId");

      // 8. Upload images
      print("🖼️ Uploading images...");
      await _uploadImages(userId);
      print("✅ Images uploaded");

      // 9. Set vendor data - FIXED NULL CHECKS
      print("📋 Setting vendor data...");

      // Get current user model safely
      UserModel? currentUser = Constant.userModel ?? userModel.value;
      if (currentUser == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("User data not found".tr);
        print("❌ Current user is null");
        return;
      }

      vendorModel.value.id = vendorModel.value.id ?? currentUser.vendorID;
      vendorModel.value.author = currentUser.id;
      vendorModel.value.authorName = currentUser.firstName;
      vendorModel.value.authorProfilePic = currentUser.profilePictureURL;

      // Handle categories safely
      List<String> categoryIds = selectedCategories
          .where((cat) => cat.id != null && cat.id!.isNotEmpty)
          .map((cat) => cat.id!)
          .toList();

      List<String> categoryTitles = selectedCategories
          .where((cat) => cat.title != null && cat.title!.isNotEmpty)
          .map((cat) => cat.title!)
          .toList();

      vendorModel.value.categoryID = categoryIds;
      vendorModel.value.categoryTitle = categoryTitles;

      // Set location data
      vendorModel.value.g = G(
        geohash: Geoflutterfire()
            .point(
            latitude: selectedLocation!.latitude,
            longitude: selectedLocation!.longitude
        )
            .hash,
        geopoint: GeoPoint(
            selectedLocation!.latitude,
            selectedLocation!.longitude
        ),
      );

      vendorModel.value.description = restaurantDescriptionController.value.text;
      vendorModel.value.phonenumber = mobileNumberController.value.text;
      vendorModel.value.filters = Filters.fromJson(filters);
      vendorModel.value.location = addressController.value.text;
      vendorModel.value.latitude = selectedLocation!.latitude;
      vendorModel.value.longitude = selectedLocation!.longitude;
      vendorModel.value.photos = images.toList();

      if (images.isNotEmpty) {
        vendorModel.value.photo = images.first;
      } else {
        vendorModel.value.photo = null;
      }

      vendorModel.value.deliveryCharge = deliveryChargeModel;
      vendorModel.value.title = restaurantNameController.value.text;
      vendorModel.value.zoneId = selectedZone.value.id;
      vendorModel.value.isSelfDelivery = isSelfDelivery.value;

      // Handle subscription safely
      // if ((Constant.adminCommission?.isEnabled == true || Constant.isSubscriptionModelApplied == true) &&
      //     currentUser.subscriptionPlanId != null) {
      //   vendorModel.value.subscriptionPlanId = currentUser.subscriptionPlanId;
      //   vendorModel.value.subscriptionPlan = currentUser.subscriptionPlan;
      //   vendorModel.value.subscriptionExpiryDate = currentUser.subscriptionExpiryDate;
      //   vendorModel.value.subscriptionTotalOrders = currentUser.subscriptionPlan?.orderLimit;
      // }

      print("✅ Vendor data set");

      // 10. Save to Firestore
      print("🔥 Saving to Firestore...");
      bool isNewVendor = currentUser.vendorID == null || currentUser.vendorID!.isEmpty;

      if (isNewVendor) {
        print("🆕 Creating new vendor...");
        vendorModel.value.adminCommission = Constant.adminCommission;

        // Set default working hours for new vendor
        vendorModel.value.workingHours = [
          WorkingHours(
              day: 'Monday',
              timeslot: [Timeslot(from: '00:00', to: '23:59')]
          ),
          WorkingHours(
              day: 'Tuesday',
              timeslot: [Timeslot(from: '00:00', to: '23:59')]
          ),
          WorkingHours(
              day: 'Wednesday',
              timeslot: [Timeslot(from: '00:00', to: '23:59')]
          ),
          WorkingHours(
              day: 'Thursday',
              timeslot: [Timeslot(from: '00:00', to: '23:59')]
          ),
          WorkingHours(
              day: 'Friday',
              timeslot: [Timeslot(from: '00:00', to: '23:59')]
          ),
          WorkingHours(
              day: 'Saturday',
              timeslot: [Timeslot(from: '00:00', to: '23:59')]
          ),
          WorkingHours(
              day: 'Sunday',
              timeslot: [Timeslot(from: '00:00', to: '23:59')]
          )
        ];

        VendorModel? createdVendor = await FireStoreUtils.firebaseCreateNewVendor(vendorModel.value);

        if (createdVendor != null && createdVendor.id != null) {
          print("✅ New vendor created with ID: ${createdVendor.id}");
          vendorModel.value = createdVendor;

          // Update user's vendorID
          currentUser.vendorID = createdVendor.id;
          await FireStoreUtils.updateUser(currentUser);

          // Update local user model and Constant
          userModel.value.vendorID = createdVendor.id;
          Constant.userModel?.vendorID = createdVendor.id;
        } else {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Failed to create vendor".tr);
          print("❌ Vendor creation failed");
          return;
        }
      } else {
        print("📝 Updating existing vendor...");
        VendorModel? updatedVendor = await FireStoreUtils.updateVendor(vendorModel.value);

        if (updatedVendor != null) {
          print("✅ Vendor updated successfully");
          vendorModel.value = updatedVendor;
        } else {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Failed to update vendor".tr);
          print("❌ Vendor update failed");
          return;
        }
      }

      // 11. Update controllers — force fresh vendor fetch so dashboard shows saved data immediately
      print("🔄 Updating controllers...");
      FireStoreUtils.invalidateVendorCache();
      await dashBoardController.getVendor();

      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.vendermodel.value = vendorModel.value;
        if (isNewVendor) {
          homeController.resumeOrderPolling();
        }
      }

      if (Get.isRegistered<ProductListController>()) {
        final productListController = Get.find<ProductListController>();
        await productListController.getUserProfile();
      }

      // 12. Update admin commission
      if (vendorModel.value.adminCommission != null) {
        Constant.vendorAdminCommission = vendorModel.value.adminCommission!;
      }

      // 13. Show success and navigate back immediately (dashboard already updated via getVendor() above)
      print("🎉 Success! Navigating back...");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Restaurant details saved successfully".tr);
      Get.back(result: true);

    } catch (e, stackTrace) {
      print("❌ ERROR in saveDetails(): $e");
      print("Stack trace: $stackTrace");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error saving details: ${e.toString()}".tr);
    }
  }

  Future<void> selectLocation(BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Getting location...".tr);

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Location permission denied".tr);
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      ShowToastDialog.closeLoader();

      // For now, just set the location directly
      // You can implement the map selection logic here
      selectedLocation = LatLng(position.latitude, position.longitude);
      addressController.value.text =
      "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
      isAddressEnable.value = true;
      update();

    } catch (e) {
      ShowToastDialog.closeLoader();
      print("❌ Error in selectLocation: $e");
      ShowToastDialog.showToast("Failed to get location: ${e.toString()}".tr);
    }
  }

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      images.add(image);
      update();

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
    } on PlatformException catch (e) {
      print("❌ PlatformException in pickFile: $e");
      ShowToastDialog.showToast("Failed to pick image: ${e.message}".tr);
    } catch (e) {
      print("❌ Error in pickFile: $e");
      ShowToastDialog.showToast("Failed to pick image".tr);
    }
  }

  // Add this method to update the UI
  void updateUI() {
    update();
  }
}