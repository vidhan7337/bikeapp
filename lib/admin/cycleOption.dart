// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:bike_app/admin/adminHome.dart';
import 'package:bike_app/mqtt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;

class CycleOption extends StatefulWidget {
  final String cycleID;
  final String adminId;
  final GeoPoint initialPosition;
  const CycleOption(
      {required this.adminId,
      required this.cycleID,
      required this.initialPosition});

  @override
  State<CycleOption> createState() => _CycleOptionState();
}

class _CycleOptionState extends State<CycleOption> {
  MQTTClientWrapper adminclient = new MQTTClientWrapper();
  late MapController controller;
  GeoPoint? cyclePosition;
  String? userid;
  String? userName = '';
  String? lockStatus = '';
  String? ebikeBattery = '';
  String? lockBattery = '';
  String? adminId;

  void setData() {
    cloud_firestore.FirebaseFirestore.instance
        .collection('cycles')
        .doc(widget.cycleID)
        .get()
        .then((cloud_firestore.DocumentSnapshot doc) {
      setState(() {
        userid = (doc.data() as Map<String, dynamic>)['user_id'];
        lockStatus = (doc.data() as Map<String, dynamic>)['lock_status'];
        ebikeBattery = (doc.data() as Map<String, dynamic>)['ebike_battery'];
        lockBattery = (doc.data() as Map<String, dynamic>)['lock_battery'];
        cyclePosition = widget.initialPosition;
        controller.addMarker(
          widget.initialPosition,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.pedal_bike_sharp,
              color: Colors.black,
              size: 50,
            ),
          ),
        );
        if (userid != null) {
          cloud_firestore.FirebaseFirestore.instance
              .collection('users')
              .doc(userid!)
              .get()
              .then((cloud_firestore.DocumentSnapshot doc) {
            setState(() {
              userName = (doc.data() as Map<String, dynamic>)['name'];
            });
          });
        }
      });
    });
  }

  @override
  void initState() {
    controller = MapController(
      initPosition: widget.initialPosition,
      areaLimit: BoundingBox(
        east: 10.4922941,
        north: 47.8084648,
        south: 45.817995,
        west: 5.9559113,
      ),
    );

    adminclient.adminCycleOption(widget.adminId, widget.cycleID);

    setData();
    // TODO: implement initState
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
        title: Text(
          "Cycle Id : ${widget.cycleID}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height:
                  MediaQuery.of(context).size.height - screenHeight * 0.3625,
              child: OSMFlutter(
                  onGeoPointClicked: (GeoPoint point) {},
                  controller: controller,
                  mapIsLoading: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 12.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
                    ),
                  ),
                  osmOption: OSMOption(
                    // userTrackingOption: const UserTrackingOption(
                    //   enableTracking: true,
                    //   unFollowUser: false,
                    // ),
                    zoomOption: const ZoomOption(
                      initZoom: 12,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    // userLocationMarker: UserLocationMaker(
                    //   personMarker: const MarkerIcon(
                    //     icon: Icon(
                    //       Icons.location_history_rounded,
                    //       color: Colors.red,
                    //       size: 80,
                    //     ),
                    //   ),
                    //   directionArrowMarker: const MarkerIcon(
                    //     icon: Icon(
                    //       Icons.double_arrow,
                    //       size: 48,
                    //     ),
                    //   ),
                    // ),
                    // roadConfiguration: const RoadOption(
                    //   roadColor: Colors.yellowAccent,
                    // ),
                    markerOption: MarkerOption(
                        defaultMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 56,
                      ),
                    )),
                  )),
            ),
            Container(
                height: MediaQuery.of(context).size.height / 9.8,
                child: Column(
                  children: [
                    SizedBox(
                      width: screenWidth,
                      child: userName == null
                          ? Text(
                              'The Cycle is currently in use by Name :',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenHeight * 0.018),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              'The Cycle is currently in use by Name :' +
                                  userName!,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenHeight * 0.018),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    SizedBox(
                      width: screenWidth,
                      child: lockStatus == null
                          ? Text(
                              "Cycle Status :",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenHeight * 0.018),
                              textAlign: TextAlign.center,
                            )
                          : lockStatus == '0'
                              ? Text(
                                  "Cycle Status : locked",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight * 0.018),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "Cycle Status : unlocked",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight * 0.018),
                                  textAlign: TextAlign.center,
                                ),
                    ),
                    SizedBox(
                      width: screenWidth,
                      child: ebikeBattery == null || lockBattery == null
                          ? Text(
                              "Ebike Battery: , Lock Battery: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenHeight * 0.018),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              "Ebike Battery: $ebikeBattery, Lock Battery: $lockBattery",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenHeight * 0.018),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ],
                )),
            Container(
              height: MediaQuery.of(context).size.height / 13,
              margin: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: screenHeight * 0.0625,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          if (cyclePosition != null) {
                            controller.removeMarker(cyclePosition!);
                          }
                          adminclient.adminLockCycle(
                              widget.adminId, widget.cycleID);
                          setData();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Cycle locked by admin",
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.yellowAccent,
                          ));
                        },
                        child: const Text(
                          "Lock",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  SizedBox(
                    height: screenHeight * 0.0625,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          if (cyclePosition != null) {
                            controller.removeMarker(cyclePosition!);
                          }
                          adminclient.adminReferesh(
                              widget.adminId, widget.cycleID);
                          setData();
                        },
                        child: const Text(
                          "Referesh",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  SizedBox(
                    height: screenHeight * 0.0625,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          if (cyclePosition != null) {
                            controller.removeMarker(cyclePosition!);
                          }
                          adminclient.adminUnlockCycle(
                              widget.adminId, widget.cycleID);
                          setData();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Cycle unlocked by admin",
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.yellowAccent,
                          ));
                        },
                        child: const Text(
                          "Unlock",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  SizedBox(
                    height: screenHeight * 0.0625,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          if (cyclePosition != null) {
                            controller.removeMarker(cyclePosition!);
                          }
                          adminclient.adminEndTrip(
                              widget.adminId, widget.cycleID);
                          setData();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Trip ended by admin",
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.yellowAccent,
                          ));
                        },
                        child: const Text(
                          "End Trip",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 13,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: screenHeight * 0.0625,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          if (cyclePosition != null) {
                            controller.removeMarker(cyclePosition!);
                          }
                          adminclient.adminUserDiasbale(
                              widget.adminId, widget.cycleID);
                          setData();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "User disabled by admin",
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.yellowAccent,
                          ));
                        },
                        child: const Text(
                          "User Disable",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  SizedBox(
                    height: screenHeight * 0.0625,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          prefs.remove('unlocked');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapPage()),
                          );
                        },
                        child: const Text(
                          "Home",
                          style: TextStyle(color: Colors.white),
                        )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
