// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:bike_app/mqtt.dart';
import 'package:bike_app/screens/loadingdialog.dart';
import 'package:bike_app/screens/trip%20pages/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Trip extends StatefulWidget {
  final String cycleID;
  const Trip({required this.cycleID});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  MQTTClientWrapper newclient = new MQTTClientWrapper();

  @override
  void initState() {
    // TODO: implement initState
    MQTTClientWrapper newclient = MQTTClientWrapper();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade600,
          automaticallyImplyLeading: false,
          title: const Text("Current Trip Page",style: TextStyle(color: Colors.white),),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: screenWidth / 1.2,
                child: Text(
                  'Your Trip is with cycle id: ' + widget.cycleID,
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              SizedBox(
                width: screenWidth / 1.2,
                child: Text(
                  '(Please lock the cycle to end trip)',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: screenWidth / 2.3,
                    height: 45,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var unlock = prefs.getBool('unlocked');
                          if (unlock!) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Please Lock the cycle to unlock again"),
                              backgroundColor: Colors.red,
                            ));
                          } else {
                            newclient.prepareMqttClient(widget.cycleID);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return LoadingAlertDialog(
                                      message: "Processing");
                                });
                          }
                        },
                        child: const Text("Unlock Cycle",style: TextStyle(color: Colors.white),)),
                  ),
                  SizedBox(
                    width: screenWidth / 2.3,
                    height: 45,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var unlock = prefs.getBool('unlocked');
                          if (unlock!) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Please Lock the cycle to end trip"),
                              backgroundColor: Colors.red,
                            ));
                          } else {
                            newclient.tripendMqtt(widget.cycleID);
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth
                                    .instance.currentUser?.phoneNumber)
                                .collection('currentTrip')
                                .doc('currentTrip')
                                .update({'endTime': DateTime.now()});
                                await prefs.setBool('payment', true);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Payment()),
                            );
                          }
                        },
                        child: const Text("End Trip",style: TextStyle(color: Colors.white),)),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
