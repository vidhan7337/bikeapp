// // ignore_for_file: prefer_const_constructors

// import 'dart:io';
// import 'package:bike_app/mqtt.dart';
// import 'package:bike_app/screens/loadingdialog.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:mqtt_client/mqtt_browser_client.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';

// class CurrentTrip extends StatefulWidget {
//   final String cycleID;
//   const CurrentTrip({required this.cycleID});

//   @override
//   State<CurrentTrip> createState() => _CurrentTripState();
// }

// class _CurrentTripState extends State<CurrentTrip> {
  
//   @override
//   void initState() {
//     // TODO: implement initState
   
        
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var screenHeight = MediaQuery.of(context).size.height;
//     var screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.green.shade600,
//           automaticallyImplyLeading: false,
//           title: const Text("Current Trip Page"),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 30,
//               ),
//               SizedBox(
//                 width: screenWidth / 1.2,
//                 child: Text(
//                   'Your Trip is with cycle id: ' + widget.cycleID,
//                   style: TextStyle(color: Colors.black),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               SizedBox(
//                 height: 2,
//               ),
//               SizedBox(
//                 width: screenWidth / 1.2,
//                 child: Text(
//                   '(Please lock the cycle to end Trip)',
//                   style: TextStyle(color: Colors.black, fontSize: 12),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//              ],
//           ),
//         ));
//   }
// }
