import 'dart:convert';
import 'dart:io';
import 'package:esam_yout_tube/video_detail_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void handleRemoteMessage(BuildContext context, RemoteMessage message) {
  final data = message.data;
  // CallUi.showIncomingCall("callerId", "callerName", "channelName");

  _handleNotificationPressed(context, data);
}

Future<void> setUpNotificationListener(BuildContext context) async {
  final message = await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    if (context.mounted) {
      handleRemoteMessage(context, message);
    }
  }

  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
  //   if (message != null) {
  //     handleRemoteMessage(context, message);
  //   }
  // });

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
    // CallUi.showIncomingCall("callerId", "callerName", "channelName");
    if (message != null) {
      handleForegroundMessage(context, message);
    }
  });
  // عند الضغط على الإشعار والتطبيق مفتوح في الخلفية:
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final videoId = message.data['videoId'];
    if (videoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoDetailPage(videoId: videoId, apiKey: "AIzaSyATvIHo8sbo7UO8ene6xeqmfKeoF1p5p6U")),
      );
    }
  });

// عند فتح التطبيق من الإشعار وهو مغلق:
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      final videoId = message.data['videoId'];
      if (videoId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VideoDetailPage(videoId: videoId, apiKey: "AIzaSyATvIHo8sbo7UO8ene6xeqmfKeoF1p5p6U")),
        );
      }
    }
  });

}


void _handleNotificationPressed(
    BuildContext context, Map<String, dynamic> data) {
  final type = data["type"];

  // final NotificationType notificationType;
  //
  // switch (type) {
  //   case "user_verified":
  //     notificationType = const UserVerified();
  //     break;
  //   case "new_match":
  //     notificationType = const NewMatchType();
  //     break;
  //   case "session_not_valid":
  //     notificationType = const SessionNotValidType();
  //     break;
  //   case "user_not_sure":
  //     notificationType = const UserNotSureType();
  //     break;
  //   case "partner_accept":
  //     notificationType = const PartnerAcceptType();
  //     break;
  //   case "match_not_valid":
  //     notificationType = const MatchNotValidType();
  //     break;
  //   default:
      return;
  // }

  // final visitor = NotificationNavigationVisitor(context);
  // notificationType.accept(visitor);
}

void handleForegroundMessage(
    BuildContext context, RemoteMessage message) async {
  final notification = message.notification;
  final notificationType = message.data["type"];
  if (notificationType != null) {
    //   if (notificationType == "session_not_valid") {
    //     Navigator.popUntil(context, (route) => route.isFirst);
    //
    //     pushMaterialPage(context, const DontCompatibleUi(), rootNavigator: true);
    //   } else if (notificationType == "user_not_sure") {
    //     Navigator.popUntil(context, (route) => route.isFirst);
    //
    //     pushMaterialPage(context, const NotSureUi(), rootNavigator: true);
    //   }
    // }
  }
  if (notification != null) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: const AndroidInitializationSettings("@mipmap/launcher_icon"),
          iOS: DarwinInitializationSettings(
            onDidReceiveLocalNotification: (id, title, body, payload) {},
          )),
      onDidReceiveNotificationResponse: (details) =>
          _onDidReceiveLocalNotification(context, details),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: notification.apple?.sound?.name,
          ),
        ),
        payload: json.encode(message.data),
      );

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions();
    } else if (Platform.isAndroid) {
      final android = message.notification?.android;
      if (android == null) return;
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "high_importance_channel",
              "High Importance Notifications",
              channelDescription:
                  'This channel is used for important notifications.',
              icon: "@mipmap/launcher_icon",
              importance: Importance.max,
            ),
          ),
          payload: json.encode(message.data));
    }
  }
}

void _onDidReceiveLocalNotification(
    BuildContext context, NotificationResponse? notificationResponse) {
  final Map<String, dynamic>? data =
      json.decode(notificationResponse?.payload ?? "");
  if (data != null) {
    _handleNotificationPressed(context, data);
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}
