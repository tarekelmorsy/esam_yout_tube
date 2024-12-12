import 'dart:io';
import 'package:esam_yout_tube/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const unregisteredTopic =
      "unregistered" ;

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, name: "esam_yout_tube");
  await _initializeCloudMessaging();
}

Future<void> _initializeCloudMessaging() async {
  final messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    _enableForegroundNotifications();
  }
}

Future<void> _enableForegroundNotifications() async {
  //iOS setup
  if (Platform.isIOS) {
    // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    //   alert: true, // Required to display a heads up notification
    //   badge: true,
    //   sound: true,
    // );
  } else {
    //android setup
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      // description
      importance: Importance.max,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

void subscribeToGuestTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic(unregisteredTopic);
}

void unsubscribeToGuestTopic() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic(unregisteredTopic);
}

@pragma('vm:entry-point')
Future<void> userFirebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await initializeFirebase();
}

void setPushTokenCleverTapPlugin(){

  final _firebaseMessaging = FirebaseMessaging.instance;

  _firebaseMessaging.getToken().then((token) {
    print("FCM Token: $token");

   });
}
