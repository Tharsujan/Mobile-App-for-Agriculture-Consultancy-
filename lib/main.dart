import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project_02_final/authentication/screens/login.dart';
import 'package:project_02_final/reusable_widgets/theme_provider.dart';
import 'package:provider/provider.dart';
import 'Admin/FirebaseApi.dart';
import 'Admin/SessionTimeout.dart';
import 'firebase_options.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> backroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification!.title);
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(backroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification!.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher'),
          ));
    }
  });

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      themeMode: themeProvider.themeMode,

      darkTheme: ThemeData.dark(), // Define your dark theme
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),

      home: const login_screen(),
      navigatorObservers: [SessionTimeout()],
    );
  }
}

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => home()),
      );
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Image(
                image: AssetImage("assets/images/logo1.png"),
                width: 300,
                color: Colors.white,
              ),
              SizedBox(
                height: 50,
              ),
              SpinKitChasingDots(
                color: Colors.yellow,
                size: 100.0,
              )
            ],
          ),
        ),
      ),
    );
  }
  // return MaterialApp(
  //
  //   title: 'Flutter Demo',
  //   theme: ThemeData(
  //     // This is the theme of your application.
  //     //
  //     // Try running your application with "flutter run". You'll see the
  //     // application has a blue toolbar. Then, without quitting the app, try
  //     // changing the primarySwatch below to Colors.green and then invoke
  //     // "hot reload" (press "r" in the console where you ran "flutter run",
  //     // or simply save your changes to "hot reload" in a Flutter IDE).
  //     // Notice that the counter didn't reset back to zero; the application
  //     // is not restarted.
  //     primarySwatch: Colors.blue,
  //   ),
  //   home: const home(),
  // );
  // }
}
*/
