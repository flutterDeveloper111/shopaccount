import 'package:account/global/global.dart';
import 'package:account/notifications/supp_creditDue_notification.dart';
//import 'package:account/notifications/notificationservice.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splashScreen/splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //NotificationService().initNotification();

  sharedPreferences = await SharedPreferences.getInstance();
  //FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);

  // initialise app based on platform- web or mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAw2yuMwY5KD2E4qm_pR6wtiVEcKkgc6nc",
        appId: "1:304297050713:web:d07c3d63d0b790ce212748",
        messagingSenderId: "304297050713",
        projectId: "shopaccount-8d7ba",
        storageBucket: "shopaccount-8d7ba.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NotificationService())],
      child: MaterialApp(
        // Application name
        title: 'Shop Account',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          // Application theme data, you can set the colors for the application as
          // you want
          primarySwatch: Colors.blue,
        ),
        home: MySplashScreen(),
      ),
    );
  }
}
