import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/firebase_options.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/utils/notification/daily_notification_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';

// "Good Morning! Are you opening your restaurant today? ",
// "శుభోదయం!ఈరోజు మీ రెస్టారెంట్ తెరవాలా?",
Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Preferences.initPref();
  // Show local notification when in background so user always sees it (FCM may not show if data-only)
  final notificationService = NotificationService();
  await notificationService.showBackgroundNotification(message);
}
const String _orderChannelId = 'order_channel_v2';

class NotificationService {
  NotificationHandler notificationHandler = NotificationHandler();
  //////////////
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initInfo() async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          // Let OS play notification sound from channel.
          sound: true,
        );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      // Allow system sound (configured via notification channels).
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized ||
        request.authorizationStatus == AuthorizationStatus.provisional) {
      if (Platform.isIOS) {
        // APNs token is required before FCM token generation on iOS.
        await _waitForApnsToken();
      }
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings(
            '@mipmap/ic_launcher',
            // '@mipmap/ic_launcher'
          );
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iosInitializationSettings,
          );
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
          await AudioPlayerService.playSound(false);
        },
      );
      // Create order_channel at startup so FCM background/terminated notifications use it
      await _ensureOrderChannelCreated();
      // ✅ Initialize and schedule daily 8 AM notification
      await notificationHandler.initializeNotification();
      setupInteractedMessage();
    }
  }

  Future<void> _waitForApnsToken() async {
    try {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      int attempts = 0;
      while (apnsToken == null && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        attempts++;
      }
      log("APNs token available: ${apnsToken != null}");
    } catch (e) {
      log("Failed waiting APNs token: $e");
    }
  }

  /// Called from background handler. Ensures plugin is inited and shows the notification.
  Future<void> showBackgroundNotification(RemoteMessage message) async {
    try {
      final title = message.notification?.title ?? message.data['title'] ?? 'New order';
      final body = message.notification?.body ?? message.data['body'] ?? 'You have a new order';
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: DarwinInitializationSettings(),
      );
      await flutterLocalNotificationsPlugin.initialize(initSettings);
      await _ensureOrderChannelCreated();
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _orderChannelId,
        'Order Notifications',
        channelDescription: 'Channel for order notifications',
        importance: Importance.high,
        priority: Priority.high,
        // Play bundled raw sound + vibration.
        sound: RawResourceAndroidNotificationSound('order_ringtone'),
        playSound: true,
        enableVibration: true,
      );
      final details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      await flutterLocalNotificationsPlugin.show(
        message.hashCode & 0x7FFFFFFF,
        title,
        body,
        details,
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );
    } catch (e) {
      log('showBackgroundNotification: $e');
    }
  }

  Future<void> setupInteractedMessage() async {
    // onBackgroundMessage is already registered in main() — do not re-register here

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("::::::::::::onMessage:::::::::::::::::");
      if (message.notification != null) {
        log(message.notification.toString());
        // iOS already presents notification (setForegroundNotificationPresentationOptions),
        // so showing a local notification again causes duplicates.
        if (!Platform.isIOS) {
          display(message);
        }
      } else if (message.data.isNotEmpty) {
        // Data-only message: show a local notification on both platforms.
        display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        log(message.notification.toString());
      }
    });
    log("::::::::::::Permission authorized:::::::::::::::::");
    await FirebaseMessaging.instance.subscribeToTopic("restaurant");
  }

  static Future<String?> getToken() async {
    if (Firebase.apps.isEmpty) {
      print("❌ Firebase not initialized yet — skipping FCM token");
      return null;
    }

    try {
      if (Platform.isIOS) {
        // On iOS, ensure APNs registration finished before requesting FCM.
        int attempts = 0;
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        while (apnsToken == null && attempts < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          attempts++;
        }
      }
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print("❌ FCM getToken error: $e");
      return null;
    }
  }


  /// Check if there are actually new orders in the system
  /// This prevents sound from playing when orders have been accepted/rejected
  static Future<bool> checkIfHasNewOrders() async {
    try {
      // Try to get HomeController if it's registered
      if (Get.isRegistered<HomeController>()) {
        HomeController controller = Get.find<HomeController>();
        if (controller.newOrderList.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      } else {
        // If controller not available (e.g., in background isolate), default to false
        return false;
      }
    } catch (e) {
      // On error, default to false (don't play sound)
      return false;
    }
  }

  /// Check if sound should be played for this notification (static version for background handler)
  /// Only play sound for new/pending orders, not for already accepted/rejected orders
  static bool shouldPlaySoundForNotification(RemoteMessage message) {
    try {
      // Check notification data for order status
      if (message.data.containsKey('status')) {
        String? status = message.data['status']?.toString();
        log("Notification status: $status");
        
        // Don't play sound if order is already accepted, rejected, cancelled, or completed
        if (status == Constant.orderAccepted ||
            status == Constant.orderRejected ||
            status == Constant.orderCancelled ||
            status == Constant.orderCompleted ||
            status == Constant.orderInTransit ||
            status == Constant.orderShipped) {
          return false;
        }
        
        // Play sound for new/pending orders
        if (status == Constant.orderPlaced || 
            status?.toLowerCase() == Constant.orderPending.toLowerCase()) {
          return true;
        }
      }
      
      // Check if notification type indicates a new order
      String? notificationType = message.data['type']?.toString();
      if (notificationType == Constant.newOrderPlaced || 
          notificationType == Constant.newDeliveryOrder) {
        return true;
      }
      
      // Default: don't play sound if we can't determine the status
      return false;
    } catch (e) {
      // On error, default to false (don't play sound)
      return false;
    }
  }


  /// Ensures order_channel exists so FCM and local notifications can use it.
  Future<void> _ensureOrderChannelCreated() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _orderChannelId,
        'Order Notifications',
        description: 'Channel for order notifications',
        importance: Importance.max,
        // Use bundled raw sound + vibration for all order notifications.
        sound: RawResourceAndroidNotificationSound('order_ringtone'),
        playSound: true,
        enableVibration: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    } catch (e) {
      log('_ensureOrderChannelCreated: $e');
    }
  }

  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log(
      'Message data:  [32m${message.notification?.body ?? message.data['body'] ?? ''} [0m',
    );
    try {
      await _ensureOrderChannelCreated();
      const AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(
        _orderChannelId,
        'Order Notifications',
        channelDescription: 'Channel for order notifications',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        // No explicit sound – AudioPlayerService handles ringtone using Preferences.orderRingtone.
      );
      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
      final NotificationDetails notificationDetailsBoth = NotificationDetails(
        android: notificationDetails,
        iOS: darwinNotificationDetails,
      );
      // Use the initialized plugin instance so the notification actually shows
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ?? message.data['title'] ?? 'New order',
        message.notification?.body ?? message.data['body'] ?? '',
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}

//
//
// import 'dart:convert';
// import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
//   log("BackGround Message :: ${message.messageId}");
// }
//
// class NotificationService {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   initInfo() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     var request = await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     if (request.authorizationStatus == AuthorizationStatus.authorized ||
//         request.authorizationStatus == AuthorizationStatus.provisional) {
//       const AndroidInitializationSettings initializationSettingsAndroid =
//           AndroidInitializationSettings('@mipmap/ic_launcher');
//       var iosInitializationSettings = const DarwinInitializationSettings();
//       final InitializationSettings initializationSettings =
//           InitializationSettings(
//               android: initializationSettingsAndroid,
//               iOS: iosInitializationSettings);
//       await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//           onDidReceiveNotificationResponse: (payload) {});
//       setupInteractedMessage();
//     }
//   }
//
//   Future<void> setupInteractedMessage() async {
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       FirebaseMessaging.onBackgroundMessage(
//           (message) => firebaseMessageBackgroundHandle(message));
//     }
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       log("::::::::::::onMessage:::::::::::::::::");
//       if (message.notification != null) {
//         log(message.notification.toString());
//         display(message);
//       }
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         log(message.notification.toString());
//       }
//     });
//     log("::::::::::::Permission authorized:::::::::::::::::");
//     await FirebaseMessaging.instance.subscribeToTopic("restaurant");
//   }
//
//   static getToken() async {
//     String? token = await FirebaseMessaging.instance.getToken();
//     return token!;
//   }
//
//   void display(RemoteMessage message) async {
//     log('Got a message whilst in the foreground!');
//     log('Message data:  [32m${message.notification!.body.toString()} [0m');
//     try {
//       AndroidNotificationChannel channel = const AndroidNotificationChannel(
//         'order_channel', // <-- new channel ID
//         'Order Notifications', // <-- new channel name
//         description: 'Channel for order notifications',
//         importance: Importance.max,
//         sound: RawResourceAndroidNotificationSound('order_ringtone'), // <-- custom sound
//       );
//       await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
//       AndroidNotificationDetails notificationDetails =
//           AndroidNotificationDetails(channel.id, channel.name,
//               channelDescription: channel.description,
//               importance: Importance.high,
//               priority: Priority.high,
//               ticker: 'ticker',
//               sound: RawResourceAndroidNotificationSound('order_ringtone'));
//       const DarwinNotificationDetails darwinNotificationDetails =
//           DarwinNotificationDetails(
//               presentAlert: true, presentBadge: true, presentSound: true);
//       NotificationDetails notificationDetailsBoth = NotificationDetails(
//           android: notificationDetails, iOS: darwinNotificationDetails);
//       await FlutterLocalNotificationsPlugin().show(
//         0,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetailsBoth,
//         payload: jsonEncode(message.data),
//       );
//     } on Exception catch (e) {
//       log(e.toString());
//     }
//   }
// }
