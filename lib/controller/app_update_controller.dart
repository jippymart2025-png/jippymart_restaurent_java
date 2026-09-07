import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/widget/app_update_dialog.dart';
import 'package:http/http.dart' as http;
class AppUpdateController extends GetxController {
  static AppUpdateController get to => Get.find();
  
  // Observable variables
  final RxBool isCheckingForUpdates = false.obs;
  final RxBool isUpdateAvailable = false.obs;
  final RxBool isForceUpdate = false.obs;
  final RxString latestVersion = ''.obs;
  final RxString updateMessage = ''.obs;
  final RxString updateUrl = ''.obs;
  final RxString currentVersion = ''.obs;
  
  // Private variables
  String? _minRequiredVersion;
  StreamSubscription<DocumentSnapshot>? _updateSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _initializeCurrentVersion();
  }
  
  @override
  void onClose() {
    _updateSubscription?.cancel();
    _updateTimer?.cancel();
    super.onClose();
  }

  /// Update global Constant appVersion* based on a version payload from API/Firestore.
  /// This ensures UI that reads Constant.appVersion reflects backend values.
  void _updatePlatformVersionFromApi(Map<String, dynamic> data) {
    try {
      String? apiAndroidVersion = data['android_version']?.toString();
      String? apiIosVersion = data['ios_version']?.toString();

      // Ignore placeholder strings
      if (apiAndroidVersion == 'latest_version' || apiAndroidVersion == 'version_info') {
        apiAndroidVersion = null;
      }
      if (apiIosVersion == 'latest_version' || apiIosVersion == 'version_info') {
        apiIosVersion = null;
      }

      if (apiAndroidVersion != null && apiAndroidVersion.isNotEmpty) {
        Constant.appVersionAndroid = apiAndroidVersion;
      }
      if (apiIosVersion != null && apiIosVersion.isNotEmpty) {
        Constant.appVersionIos = apiIosVersion;
      }
    } catch (e) {
      print('❌ Error updating platform version from API: $e');
    }
  }
  /// Initialize current app version
  Future<void> _initializeCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion.value = packageInfo.version;
      print('📱 Current App Version: ${packageInfo.version}+${packageInfo.buildNumber}');
    } catch (e) {
      print('❌ Error getting current version: $e');
      currentVersion.value = '1.0.0';
    }
  }
  
  /// Fetches force-update config from API and sets Constant.showUpdate.
  /// When show_update is true, also parses min version and dialog data for mandatory update screen.
  Future<void> getForceUpdateConfig() async {
    try {
      if (currentVersion.value.isEmpty) await _initializeCurrentVersion();
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/version'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) return;
      final body = json.decode(response.body);
      final data = body is Map && body['success'] == true && body['data'] != null
          ? body['data'] as Map<String, dynamic>
          : body is Map
              ? body as Map<String, dynamic>
              : null;
      if (data == null) return;

      // Always update platform version constants from API if available,
      // even if show_update is false or missing. This keeps UI like the
      // profile screen in sync with backend version info.
      _updatePlatformVersionFromApi(data);

      Constant.showUpdate = _parseBool(data['show_update']);
      if (!Constant.showUpdate) {
        print('📱 show_update is false – skipping update check');
        return;
      }
      _minRequiredVersion = data['min_required_version']?.toString() ?? data['min_app_version']?.toString();
      // Use platform-specific version from API (android_version / ios_version)
      String? platformVersion = Platform.isAndroid
          ? (data['android_version']?.toString() ?? data['latest_version']?.toString() ?? data['app_version']?.toString())
          : (data['ios_version']?.toString() ?? data['latest_version']?.toString() ?? data['app_version']?.toString());
      if (platformVersion == 'latest_version' || platformVersion == 'version_info') {
        platformVersion = null;
      }
      latestVersion.value = platformVersion ?? '';
      // Let Constant.appVersion use this override for UI like profile screen
      if (platformVersion != null && platformVersion.isNotEmpty) {
        Constant.overrideAppVersion = platformVersion;
      }
      // Use platform-specific update URL (android_update_url / ios_update_url)
      final platformUpdateUrl = Platform.isAndroid
          ? (data['android_update_url']?.toString() ?? data['update_url']?.toString() ?? data['googlePlayLink']?.toString())
          : (data['ios_update_url']?.toString() ?? data['update_url']?.toString() ?? data['appStoreLink']?.toString());
      updateUrl.value = platformUpdateUrl ?? '';
      if (updateUrl.value.isEmpty && data['appStoreLink'] != null && data['appStoreLink'].toString() != 'update_url') {
        updateUrl.value = data['appStoreLink']?.toString() ?? '';
      }
      updateMessage.value = data['update_message']?.toString() ?? 'Update available!';
      isForceUpdate.value = _parseBool(data['force_update']);
      print('📱 show_update is true, min_required_version: $_minRequiredVersion');
      // Process and show update dialog if required (using same data we just fetched)
      _processUpdateData(data);
    } catch (e) {
      print('❌ getForceUpdateConfig error: $e');
    }
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final n = value.toLowerCase();
      return n == 'true' || n == '1';
    }
    return false;
  }

  /// Returns true only when show_update is true and current version < min_app_version.
  bool isMandatoryUpdateRequired() {
    if (!Constant.showUpdate) return false;
    if (_minRequiredVersion == null || _minRequiredVersion!.isEmpty) return false;
    final required = _isVersionLower(currentVersion.value, _minRequiredVersion!);
    print('📱 isMandatoryUpdateRequired: $required (current: ${currentVersion.value}, min: $_minRequiredVersion)');
    return required;
  }

  /// Check for app updates (runs only when Constant.showUpdate is true).
  Future<void> checkForUpdates() async {
    if (isCheckingForUpdates.value) return;
    try {
      isCheckingForUpdates.value = true;
      print('🔍 Checking for updates...');
      if (currentVersion.value.isEmpty) await _initializeCurrentVersion();
      await getForceUpdateConfig();
      if (!Constant.showUpdate) {
        print('📱 Update check skipped (show_update is false)');
        return;
      }
      await _setupUpdateListener();
      await _performUpdateCheck();
    } catch (e) {
      print('❌ Error checking for updates: $e');
    } finally {
      isCheckingForUpdates.value = false;
    }
  }
  /// Setup real-time listener for app updates


  Timer? _updateTimer;

  Future<void> _setupUpdateListener() async {
    try {
      _updateSubscription?.cancel();
      _updateTimer?.cancel();
      // Initial check
      await _checkForUpdates();

      // Set up periodic checks (every 5 minutes)
      _updateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
        _checkForUpdates();
      });

      print('👂 Set up API update listener');
    } catch (e) {
      print('❌ Error setting up update listener: $e');
    }
  }
  // void _showUpdateDialog(Map<String, dynamic> data) {
  //   // Show update dialog to user
  //   // You can use your existing dialog implementation
  // }
  Future<void> _checkForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/version'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is! Map) return;
        final data = body['success'] == true && body['data'] != null
            ? body['data'] as Map<String, dynamic>
            : body as Map<String, dynamic>;
        if (data.isNotEmpty) _processUpdateData(data);
      } else {
        print('❌ API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
    }
  }

  // void _processUpdateData(Map<String, dynamic> data) {
  //   // Process your update data here
  //   print('📱 Update data received: $data');
  //
  //   // Example: Check if force update is required
  //   if (data['force_update'] == true) {
  //     _showUpdateDialog(data);
  //   }
  // }



  


  Future<void> _performUpdateCheck() async {
    final String url = '${Constant.baseUrl}restaurant/version';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        print('❌ Failed to fetch update info. Status code: ${response.statusCode}');
        return;
      }
      final body = json.decode(response.body);
      if (body is! Map) return;
      final data = body['success'] == true && body['data'] != null
          ? body['data'] as Map<String, dynamic>
          : body as Map<String, dynamic>;
      if (data.isNotEmpty) _processUpdateData(data);
    } catch (e) {
      print('❌ Error performing update check: $e');
    }
  }

  
  /// Process update data from Firestore
  void _processUpdateData(Map<String, dynamic> data) {
    try {
      print('📊 Processing update data: $data');
      
      // Extract data from Firestore / API (platform-specific version and URL)
      String latestVersionFromFirestore = Platform.isAndroid
          ? (data['android_version']?.toString() ?? data['latest_version']?.toString() ?? data['app_version']?.toString() ?? '')
          : (data['ios_version']?.toString() ?? data['latest_version']?.toString() ?? data['app_version']?.toString() ?? '');
      if (latestVersionFromFirestore == 'latest_version' || latestVersionFromFirestore == 'version_info') {
        latestVersionFromFirestore = '';
      }
      final forceUpdate = _parseBool(data['force_update']);
      String updateUrlFromFirestore = Platform.isAndroid
          ? (data['android_update_url']?.toString() ?? data['update_url']?.toString() ?? data['googlePlayLink']?.toString() ?? '')
          : (data['ios_update_url']?.toString() ?? data['update_url']?.toString() ?? data['appStoreLink']?.toString() ?? '');
      if (updateUrlFromFirestore.isEmpty) {
        final fallback = Platform.isAndroid ? data['googlePlayLink'] : data['appStoreLink'];
        final appStore = fallback?.toString();
        if (appStore != null && appStore != 'update_url') updateUrlFromFirestore = appStore;
      }
      final updateMessageFromFirestore = data['update_message']?.toString() ?? 'Update available!';
      final minRequiredVersion = data['min_required_version']?.toString() ?? data['min_app_version']?.toString();
      
      // Update observable variables
      latestVersion.value = latestVersionFromFirestore;
      isForceUpdate.value = forceUpdate;
      updateUrl.value = updateUrlFromFirestore;
      updateMessage.value = updateMessageFromFirestore;
      _minRequiredVersion = minRequiredVersion;
      // And update Constant.overrideAppVersion so UI displays this when present
      if (latestVersionFromFirestore.isNotEmpty) {
        Constant.overrideAppVersion = latestVersionFromFirestore;
      }
      
      // Keep Constant.appVersion* in sync so UI using Constant.appVersion shows latest API version.
      if (latestVersionFromFirestore.isNotEmpty) {
        if (Platform.isAndroid) {
          Constant.appVersionAndroid = latestVersionFromFirestore;
        } else if (Platform.isIOS) {
          Constant.appVersionIos = latestVersionFromFirestore;
        }
      }

      print('📱 Current: ${currentVersion.value}');
      print('🚀 Latest: ${latestVersion.value}');
      print('⚡ Force Update: $forceUpdate');
      
      // Check if update is available
      final updateAvailable = _isUpdateAvailable();
      isUpdateAvailable.value = updateAvailable;
      
      if (updateAvailable) {
        print('✅ Update available! Force: $forceUpdate');
        _showUpdateDialog();
      } else {
        print('✅ App is up to date');
      }
      
    } catch (e) {
      print('❌ Error processing update data: $e');
    }
  }
  
  /// Check if update is available
  bool _isUpdateAvailable() {
    try {
      // Check minimum required version first (works even when latest_version is not in API)
      if (_minRequiredVersion != null && _minRequiredVersion!.isNotEmpty && _isVersionLower(currentVersion.value, _minRequiredVersion!)) {
        print('🚨 Current version is below minimum required version');
        isForceUpdate.value = true; // Force update if below minimum
        return true;
      }

      if (latestVersion.value.isEmpty) return false;

      // Check if current version is lower than latest
      return _isVersionLower(currentVersion.value, latestVersion.value);
    } catch (e) {
      print('❌ Error comparing versions: $e');
      return false;
    }
  }
  
  /// Compare two semantic versions
  bool _isVersionLower(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();
      
      // Pad with zeros if needed
      while (currentParts.length < 3) currentParts.add(0);
      while (latestParts.length < 3) latestParts.add(0);
      
      for (int i = 0; i < 3; i++) {
        if (currentParts[i] < latestParts[i]) return true;
        if (currentParts[i] > latestParts[i]) return false;
      }
      
      return false; // Versions are equal
    } catch (e) {
      print('❌ Error parsing versions: $e');
      return false;
    }
  }
  
  /// Show update dialog
  void _showUpdateDialog() {
    if (Get.isDialogOpen == true) return; // Prevent multiple dialogs
    
    Get.dialog(
      AppUpdateDialog(
        isForceUpdate: isForceUpdate.value,
        updateMessage: updateMessage.value,
        onUpdate: _launchUpdateUrl,
        onDismiss: isForceUpdate.value ? null : () => Get.back(),
      ),
      barrierDismissible: !isForceUpdate.value,
    );
  }
  
  /// Launch update URL
  Future<void> _launchUpdateUrl() async {
    try {
      if (updateUrl.value.isEmpty) {
        // Fallback to default URLs
        if (Platform.isAndroid) {
          updateUrl.value = 'https://play.google.com/store/apps/details?id=${Constant.packageName}';
        } else if (Platform.isIOS) {
          updateUrl.value = 'https://apps.apple.com/app/id${Constant.appStoreId}';
        }
      }
      
      final uri = Uri.parse(updateUrl.value);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('🚀 Launched update URL: ${updateUrl.value}');
      } else {
        print('❌ Could not launch update URL: ${updateUrl.value}');
        ShowToastDialog.showToast('Could not open update link');
      }
    } catch (e) {
      print('❌ Error launching update URL: $e');
      ShowToastDialog.showToast('Error opening update link');
    }
  }
  
  /// For logged-in users (e.g. dashboard): fetch config and show mandatory update screen if required.
  Future<void> checkMandatoryUpdateForLoggedInUser() async {
    await getForceUpdateConfig();
    if (isMandatoryUpdateRequired()) _showUpdateDialog();
  }

  /// Manual update check (for profile screen)
  Future<void> manualUpdateCheck() async {
    print('🔍 Manual update check triggered');
    await checkForUpdates();
  }
  
  /// Get update available status
  bool getUpdateAvailable() => isUpdateAvailable.value;
  
  /// Get latest version
  String getLatestVersion() => latestVersion.value;
  
  /// Get update message
  String getUpdateMessage() => updateMessage.value;
  
  /// Get current version
  String getCurrentVersion() => currentVersion.value;
  
  /// Get force update status
  bool getForceUpdate() => isForceUpdate.value;
}
