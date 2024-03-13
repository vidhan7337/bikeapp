import 'package:bike_app/firebase_options.dart';
import 'package:bike_app/mqtt.dart';
import 'package:bike_app/navigator_key.dart';
import 'package:bike_app/screens/home.dart';
import 'package:bike_app/screens/profile.dart';
import 'package:bike_app/screens/trip%20pages/currentTrip.dart';
import 'package:bike_app/screens/trip%20pages/payment.dart';
import 'package:bike_app/screens/trip%20pages/trip.dart';
import 'package:bike_app/screens/wallet.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? trip = prefs.getBool('trip');
  bool? payment = prefs.getBool('payment');
  // bool? unlocked = prefs.getBool('unlocked');
  String? cycleId = prefs.getString('cycleID');
  if (trip != null) {
    MQTTClientWrapper newclient = MQTTClientWrapper();
    newclient.tripstartMqtt(cycleId!);
  }
  runApp(MaterialApp(
    
    initialRoute: FirebaseAuth.instance.currentUser != null
        ? trip != null
            ? payment != null
                ? 'payment'
                : 'lockedPage'
            : 'home'
        : 'phone',
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    routes: {
      'phone': (context) => const MyPhone(),
      'home': (context) => const Home(),
      'wallet': (context) => const Wallet(),
      'profile': (context) => const Profile(),
      'payment': (context) => const Payment(),
      // 'unlockedPage': (context) => CurrentTrip(
      //       cycleID: cycleId!,
      //     ),
      'lockedPage': (context) => Trip(
            cycleID: cycleId!,
          )
    },
  ));
}
