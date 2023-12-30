import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyNotification extends StatefulWidget {
  const MyNotification({Key? key}) : super(key: key);

  @override
  _MyNotificationState createState() => _MyNotificationState();
}

class _MyNotificationState extends State<MyNotification> {
  String notificationMsg = "Waiting for notifications";

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Cloud Messaging
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        processMessage(event);
      }
    });

    FirebaseMessaging.onMessage.listen((event) {
      processMessage(event);
      showForegroundNotification(event);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      processMessage(event);
    });
  }

  void processMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final title = notification.title ?? "";
      final body = notification.body ?? "";
      setState(() {
        notificationMsg = "$title:\n$body";
      });
    }
  }

  Future<void> showForegroundNotification(RemoteMessage message) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.example.firebase_push_notification',
      'firebase_push_notification',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      styleInformation: BigTextStyleInformation(''),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().microsecondsSinceEpoch,
      message.notification!.title,
      "${message.notification!.title}: ${message.notification!.body}",
      platformChannelSpecifics,
      payload: message.data['message'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("Firebase Notifications"),
      ),
      body: Center(
        child: Text(
          notificationMsg,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
