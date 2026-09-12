import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:jippymart_restaurant/app/auth_screen/screens/login_screen.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/common.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../app/landing_screen.dart';

class AppUpdateService {
  static const String appTypeMerchant = 'merchant';

  static bool _hasCheckedForUpdate = false;

  /// Check if a version is older than another version
  static bool isVersionOlder(String current, String latest) {
    try {
      print('[UPDATE DEBUG] Comparing versions:');
      print('[UPDATE DEBUG]   Current: "$current"');
      print('[UPDATE DEBUG]   Latest: "$latest"');
      
      List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      print('[UPDATE DEBUG]   Current parts: $currentParts');
      print('[UPDATE DEBUG]   Latest parts: $latestParts');

      // Pad with zeros if needed
      while (currentParts.length < latestParts.length) {
        currentParts.add(0);
      }
      while (latestParts.length < currentParts.length) {
        latestParts.add(0);
      }

      print('[UPDATE DEBUG]   After padding - Current: $currentParts, Latest: $latestParts');

      for (int i = 0; i < latestParts.length; i++) {
        print('[UPDATE DEBUG]   Comparing part $i: ${currentParts[i]} vs ${latestParts[i]}');
        if (i >= currentParts.length || currentParts[i] < latestParts[i]) {
          print('[UPDATE DEBUG]   Result: Current is OLDER (returning true)');
          return true;
        }
        if (currentParts[i] > latestParts[i]) {
          print('[UPDATE DEBUG]   Result: Current is NEWER (returning false)');
          return false;
        }
      }
      print('[UPDATE DEBUG]   Result: Versions are EQUAL (returning false)');
      return false;
    } catch (e) {
      print('[UPDATE] Version comparison error: $e');
      return false;
    }
  }

  /// Get current app version
  static Future<String> getCurrentVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      print('[UPDATE DEBUG] Current app version: "$version"');
      return version;
    } catch (e) {
      print('[UPDATE] Error getting current version: $e');
      return '1.0.0';
    }
  }

  /// Get current app build number
  static Future<String> getCurrentBuildNumber() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String buildNumber = packageInfo.buildNumber;
      print('[UPDATE DEBUG] Current app build number: "$buildNumber"');
      return buildNumber;
    } catch (e) {
      print('[UPDATE] Error getting current build number: $e');
      return '1';
    }
  }

  /// Get platform-specific version info
  static String getPlatformVersion(Map<String, dynamic> versionInfo) {
    String platformVersion = '';
    if (Platform.isAndroid) {
      platformVersion = versionInfo['android_version'] ?? versionInfo['latest_version'] ?? '';
      print('[UPDATE DEBUG] Platform: Android');
      print('[UPDATE DEBUG]   android_version from Firestore: "${versionInfo['android_version']}"');
      print('[UPDATE DEBUG]   latest_version from Firestore: "${versionInfo['latest_version']}"');
      print('[UPDATE DEBUG]   Selected platform version: "$platformVersion"');
    } else if (Platform.isIOS) {
      platformVersion = versionInfo['ios_version'] ?? versionInfo['latest_version'] ?? '';
      print('[UPDATE DEBUG] Platform: iOS');
      print('[UPDATE DEBUG]   ios_version from Firestore: "${versionInfo['ios_version']}"');
      print('[UPDATE DEBUG]   latest_version from Firestore: "${versionInfo['latest_version']}"');
      print('[UPDATE DEBUG]   Selected platform version: "$platformVersion"');
    } else {
      platformVersion = versionInfo['latest_version'] ?? '';
      print('[UPDATE DEBUG] Platform: Unknown');
      print('[UPDATE DEBUG]   latest_version from Firestore: "${versionInfo['latest_version']}"');
      print('[UPDATE DEBUG]   Selected platform version: "$platformVersion"');
    }
    return platformVersion;
  }

  /// Get platform-specific build number
  static String getPlatformBuildNumber(Map<String, dynamic> versionInfo) {
    String platformBuild = '';
    if (Platform.isAndroid) {
      platformBuild = versionInfo['android_build'] ?? '';
      print('[UPDATE DEBUG]   android_build from Firestore: "${versionInfo['android_build']}"');
    } else if (Platform.isIOS) {
      platformBuild = versionInfo['ios_build'] ?? '';
      print('[UPDATE DEBUG]   ios_build from Firestore: "${versionInfo['ios_build']}"');
    }
    print('[UPDATE DEBUG]   Selected platform build: "$platformBuild"');
    return platformBuild;
  }

  /// Get platform-specific update URL
  static String getPlatformUpdateUrl(Map<String, dynamic> versionInfo) {
    String platformUrl = '';
    if (Platform.isAndroid) {
      String androidUrl = versionInfo['android_update_url'] ??
          versionInfo['googlePlayLink']?.toString() ?? '';
      if (androidUrl.isNotEmpty &&
          androidUrl != "update_url" &&
          androidUrl.startsWith('http')) {
        platformUrl = androidUrl;
        print('[UPDATE DEBUG]   Using android_update_url/googlePlayLink: "$androidUrl"');
      } else {
        platformUrl = versionInfo['googlePlayLink']?.toString() ??
            Constant.googlePlayLink;
        print('[UPDATE DEBUG]   No valid android url, using googlePlayLink: "$platformUrl"');
      }
    } else if (Platform.isIOS) {
      String iosUrl = versionInfo['ios_update_url'] ??
          versionInfo['appStoreLink']?.toString() ?? '';
      if (iosUrl.isNotEmpty &&
          iosUrl != "update_url" &&
          iosUrl.startsWith('http')) {
        platformUrl = iosUrl;
        print('[UPDATE DEBUG]   Using ios_update_url/appStoreLink: "$iosUrl"');
      } else {
        platformUrl = versionInfo['appStoreLink']?.toString() ??
            Constant.appStoreLink;
        print('[UPDATE DEBUG]   No valid ios url, using appStoreLink: "$platformUrl"');
      }
    } else {
      platformUrl = versionInfo['googlePlayLink']?.toString() ??
          Constant.googlePlayLink;
    }
    print('[UPDATE DEBUG]   Selected platform URL: "$platformUrl"');
    return platformUrl;
  }

  static Future<Map<String, dynamic>?> getLatestVersionInfo({
    String appType = appTypeMerchant,
  }) async {
    try {
      print('[UPDATE DEBUG] Fetching version info from API...');
      final endpoint =
          '${Constant.baseUrl}fm/app-settings/getApplicationVersionByAppType?appType=$appType';
      print('[UPDATE DEBUG] Endpoint: $endpoint');
      final response = await http
          .get(Uri.parse(endpoint), headers: await getHeaders())
          .timeout(const Duration(seconds: 12));

      print('[UPDATE DEBUG] API response status: ${response.statusCode}');
      print('[UPDATE DEBUG] API response body: ${response.body}');

      if (response.statusCode != 200) {
        print('[UPDATE DEBUG] API request failed with status: ${response.statusCode}');
        return null;
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        print('[UPDATE DEBUG] Invalid JSON response: $e');
        return null;
      }
      if (decoded is! Map) {
        print('[UPDATE DEBUG] API response is not a JSON object');
        return null;
      }

      final Map<String, dynamic> responseData = Map<String, dynamic>.from(decoded);

      // Support both a direct object and a { success: true, data: {...} } envelope.
      dynamic body = responseData['data'];
      if (body is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(body);
        if (data.isNotEmpty) {
          print('[UPDATE DEBUG] API returned {success, data} envelope');
          print('[UPDATE DEBUG] Version data:');
          data.forEach((key, value) {
            print('[UPDATE DEBUG]   $key: "$value" (${value.runtimeType})');
          });
          return data;
        }
      } else if (responseData['success'] == false) {
        print('[UPDATE DEBUG] API returned success: false');
        print('[UPDATE DEBUG] Message: ${responseData['message']}');
        return null;
      }

      print('[UPDATE DEBUG] Version data:');
      responseData.forEach((key, value) {
        print('[UPDATE DEBUG]   $key: "$value" (${value.runtimeType})');
      });
      return responseData;
    } catch (e) {
      print('[UPDATE] Error fetching version info: $e');
      return null;
    }
  }
  /// Show update dialog
  static void showUpdateDialog({
    required String latestVersion,
    required bool forceUpdate,
    required String updateUrl,
    String? currentVersion,
    String? updateMessage,
  }) {
    print('[UPDATE DEBUG] Showing update dialog:');
    print('[UPDATE DEBUG]   Latest version: "$latestVersion"');
    print('[UPDATE DEBUG]   Force update: $forceUpdate');
    print('[UPDATE DEBUG]   Update URL: "$updateUrl"');
    print('[UPDATE DEBUG]   Current version: "$currentVersion"');
    print('[UPDATE DEBUG]   Update message: "$updateMessage"');
    
    Get.dialog(
      WillPopScope(
        onWillPop: () async => !forceUpdate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.system_update_alt,
                color: Colors.blue,
                size: 20,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Update Available",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          content: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      updateMessage ?? "A new version of Jippy Restaurant is available!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (currentVersion != null) ...[
                      Text(
                        "Current Version: $currentVersion",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "Latest Version: $latestVersion",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                    if (forceUpdate)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "This update is required to continue using the app",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/ic_logo.png",
                  width: 76,
                  height: 76,
                ),
              ),
            ],
          ),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () async {
                  print('[UPDATE DEBUG] User clicked "Later"');
                  Get.back();
                  // Navigate to main app after dismissing dialog
                  await _navigateAfterUpdate();
                },
                child: Text(
                  "Later",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                print('[UPDATE DEBUG] User clicked "Update Now"');
                try {
                  final uri = Uri.parse(updateUrl);
                  print('[UPDATE DEBUG] Attempting to launch URL: $updateUrl');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    print('[UPDATE DEBUG] Successfully launched URL');
                  } else {
                    print('[UPDATE DEBUG] Could not launch URL, trying fallback');
                    // Fallback to Play Store
                    final playStoreUrl = "https://play.google.com/store/apps/details?id=com.jippymart.restaurant";
                    final fallbackUri = Uri.parse(playStoreUrl);
                    if (await canLaunchUrl(fallbackUri)) {
                      await launchUrl(
                        fallbackUri,
                        mode: LaunchMode.externalApplication,
                      );
                      print('[UPDATE DEBUG] Successfully launched fallback URL');
                    }
                  }
                } catch (e) {
                  print('[UPDATE] Error launching URL: $e');
                  // Show error message
                  Get.snackbar(
                    "Error",
                    "Could not open app store. Please update manually.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Update Now",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: !forceUpdate,
    );
  }

  /// Check for app updates
  static Future<bool> checkForUpdate() async {
    if (_hasCheckedForUpdate) {
      print('[UPDATE DEBUG] Update check already performed this session - SKIPPING');
      return false;
    }
    
    _hasCheckedForUpdate = true; // Mark as checked
    try {
      print('[UPDATE DEBUG] ==========================================');
      print('[UPDATE DEBUG] STARTING UPDATE CHECK');
      print('[UPDATE DEBUG] ==========================================');
      
      // Get current version
      String currentVersion = await getCurrentVersion();
      String currentBuild = await getCurrentBuildNumber();
      print('[UPDATE DEBUG] Current version: $currentVersion (build: $currentBuild)');
      // Get latest version info from Firestore
      Map<String, dynamic>? versionInfo = await getLatestVersionInfo();
      
      if (versionInfo == null) {
        print('[UPDATE DEBUG] No version info found in Firestore - EXITING');
        return false;
      }

      // Get platform-specific version info
      String latestVersion = getPlatformVersion(versionInfo);
      String latestBuild = getPlatformBuildNumber(versionInfo);
      bool forceUpdate = _parseBool(versionInfo['force_update']);
      String updateUrl = getPlatformUpdateUrl(versionInfo);
      String updateMessage = versionInfo['update_message'] ?? '';

      print('[UPDATE DEBUG] ==========================================');
      print('[UPDATE DEBUG] VERSION COMPARISON SUMMARY');
      print('[UPDATE DEBUG] ==========================================');
      print('[UPDATE DEBUG] Current version: "$currentVersion"');
      print('[UPDATE DEBUG] Latest version: "$latestVersion"');
      print('[UPDATE DEBUG] Current build: "$currentBuild"');
      print('[UPDATE DEBUG] Latest build: "$latestBuild"');
      print('[UPDATE DEBUG] Force update: $forceUpdate');
      print('[UPDATE DEBUG] Update URL: "$updateUrl"');
      print('[UPDATE DEBUG] Update message: "$updateMessage"');

      // Check if latest version is empty or invalid
      if (latestVersion.isEmpty) {
        print('[UPDATE DEBUG] Latest version is empty - EXITING');
        return false;
      }

      // Check if latest version is a placeholder
      if (latestVersion == "latest_version" || 
          latestVersion == "Android build number" || 
          latestVersion == "iOS build number" ||
          latestVersion == "update_url") {
        print('[UPDATE DEBUG] Latest version is a placeholder string - EXITING');
        print('[UPDATE DEBUG] This means your Firestore document has placeholder values instead of real version numbers');
        return false;
      }

      bool isUpdateAvailable = isVersionOlder(currentVersion, latestVersion);
      print('[UPDATE DEBUG] Is update available? $isUpdateAvailable');

      if (isUpdateAvailable) {
        print('[UPDATE DEBUG] Update available! Showing dialog...');
        showUpdateDialog(
          latestVersion: latestVersion,
          forceUpdate: forceUpdate,
          updateUrl: updateUrl,
          currentVersion: currentVersion,
          updateMessage: updateMessage,
        );
        print('[UPDATE DEBUG] ==========================================');
        print('[UPDATE DEBUG] UPDATE CHECK COMPLETED - UPDATE REQUIRED');
        print('[UPDATE DEBUG] ==========================================');
        return true; // Update is required
      } else {
        print('[UPDATE DEBUG] App is up to date - no dialog shown');
        print('[UPDATE DEBUG] ==========================================');
        print('[UPDATE DEBUG] UPDATE CHECK COMPLETED - NO UPDATE REQUIRED');
        print('[UPDATE DEBUG] ==========================================');
        return false; // No update required
      }
    } catch (e) {
      print('[UPDATE] Error checking for updates: $e');
      return false; // Allow navigation on error
    }
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  /// Navigate to main app after update dialog is dismissed
  static Future<void> _navigateAfterUpdate() async {
    String userId = await FireStoreUtils.getCurrentUid();
    print('[UPDATE DEBUG] Navigating to main app after update dialog dismissed');
    
    // Use the same logic as SplashController to determine where to go
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      Get.offAll(
        () => const LandingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 1200),
      );
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin == true) {
        await FireStoreUtils.getUserProfile(userId).then((value) async {
          if (value != null) {
            if (value.role == "vendor") {
              if (value.active == true) {
                Get.offAll(
                  () => const DashBoardScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 1200),
                );
              } else {
                Get.offAll(
                  () => const LoginScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 1200),
                );
              }
            } else {
              Get.offAll(
                () => const LoginScreen(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 1200),
              );
            }
          } else {
            Get.offAll(
              () => const LoginScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 1200),
            );
          }
        });
      } else {
        Get.offAll(
          () => const LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1200),
        );
      }
    }
  }

  /// Check if app meets minimum required version
  static Future<bool> checkMinimumVersion() async {
    try {
      print('[UPDATE DEBUG] Checking minimum required version...');
      String currentVersion = await getCurrentVersion();
      Map<String, dynamic>? versionInfo = await getLatestVersionInfo();
      
      if (versionInfo == null) {
        print('[UPDATE DEBUG] No version info found - allowing access');
        return true; // Allow if no version info
      }

      String minRequiredVersion = versionInfo['min_required_version'] ?? '';
      print('[UPDATE DEBUG] Minimum required version: "$minRequiredVersion"');
      
      if (minRequiredVersion.isNotEmpty && isVersionOlder(currentVersion, minRequiredVersion)) {
        print('[UPDATE DEBUG] App version below minimum required version - BLOCKING ACCESS');
        return false;
      }
      
      print('[UPDATE DEBUG] App version meets minimum requirement - ALLOWING ACCESS');
      return true;
    } catch (e) {
      print('[UPDATE] Error checking minimum version: $e');
      return true; // Allow if error
    }
  }

  /// Reset the update check flag (for testing purposes)
  static void resetUpdateCheckFlag() {
    _hasCheckedForUpdate = false;
    print('[UPDATE DEBUG] Update check flag reset - can check again');
  }
}
