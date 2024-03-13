// ignore_for_file: prefer_const_constructors

import 'package:bike_app/admin/cycleOption.dart';
import 'package:bike_app/mqtt.dart';
import 'package:bike_app/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:bike_app/admin/addCycle.dart';
import 'package:bike_app/admin/adminLogin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with OSMMixinObserver {
  MQTTClientWrapper adminclient = new MQTTClientWrapper();
  late MapController controller;
  List<GeoPoint>? cycleLocation;
  List<String>? adminCycleIds;
  @override
  void initState() {
    controller = MapController(
      initPosition: GeoPoint(latitude: 23.215635, longitude: 72.636940),
      areaLimit: BoundingBox(
        east: 10.4922941,
        north: 47.8084648,
        south: 45.817995,
        west: 5.9559113,
      ),
    );

    // TODO: implement initState

    super.initState();
  }

  @override
  void onSingleTap(GeoPoint position) {
    super.onSingleTap(position);
    print("###################");
    print(position);

    if (position ==
        GeoPoint(latitude: 23.232260476111165, longitude: 72.6053466796875)) {
      print("###################");
      print("1233123123");
    }

    /// TODO
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        automaticallyImplyLeading: false,
        title: const Text(
          "Admin Home",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('adminId');
              prefs.remove('unlocked');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MyPhone()));
              // TODO: Implement logout functionality here
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - screenHeight * 0.19,
              child: OSMFlutter(
                  onGeoPointClicked: (GeoPoint point) async {
                    for (int i = 0; i < cycleLocation!.length; i++) {
                      if (point.latitude == cycleLocation![i].latitude &&
                          point.longitude == cycleLocation![i].longitude) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        var id = prefs.getString('adminId');
                        print(adminCycleIds![i]);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CycleOption(
                                  adminId: id!,
                                  cycleID: adminCycleIds![i],
                                  initialPosition: cycleLocation![i])),
                        );
                      }
                    }
                  },
                  controller: controller,
                  mapIsLoading: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 12.0),
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
              height: screenHeight * 0.0875,
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
                        onPressed: () async {
                          if (cycleLocation != null) {
                            controller.removeMarkers(cycleLocation!);
                          }
                          List<String> cycleId = [];
                          List<GeoPoint> cycleLoc = [];
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var id = prefs.getString('adminId');
                          cloud_firestore.FirebaseFirestore.instance
                              .collection('admin')
                              .doc(id)
                              .collection('cycle')
                              .get()
                              .then((value) {
                            for (var element in value.docs) {
                              cycleId.add(element.id.toString());
                            }
                            adminclient.adminRefereshClientConnection(
                                id!, cycleId);
                            for (int i = 0; i < cycleId.length; i++) {
                              cloud_firestore.FirebaseFirestore.instance
                                  .collection('cycles')
                                  .doc(cycleId[i])
                                  .get()
                                  .then((value) {
                                cycleLoc.add(GeoPoint(
                                  latitude: value.data()!['latitude'],
                                  longitude: value.data()!['longitude'],
                                ));
                                controller.addMarker(
                                  GeoPoint(
                                      latitude: value.data()!['latitude'],
                                      longitude: value.data()!['longitude']),
                                  markerIcon: MarkerIcon(
                                    icon: Icon(
                                      semanticLabel: cycleId[i],
                                      Icons.pedal_bike_sharp,
                                      color: Colors.black,
                                      size: 50,
                                    ),
                                  ),
                                );
                              });
                            }
                            cycleLocation = cycleLoc;
                            adminCycleIds = cycleId;
                          });
                        },
                        child: const Text(
                          "Tap to Refresh",
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
                          if (cycleLocation != null) {
                            controller.removeMarkers(cycleLocation!);
                          }

                          List<String> cycleId = [];
                          List<GeoPoint> cycleLoc = [];
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var id = prefs.getString('adminId');
                          cloud_firestore.FirebaseFirestore.instance
                              .collection('admin')
                              .doc(id)
                              .collection('cycle')
                              .get()
                              .then((value) {
                            for (var element in value.docs) {
                              cycleId.add(element.id.toString());
                            }
                            adminclient.adminClientConnection(id!, cycleId);
                            for (int i = 0; i < cycleId.length; i++) {
                              cloud_firestore.FirebaseFirestore.instance
                                  .collection('cycles')
                                  .doc(cycleId[i])
                                  .get()
                                  .then((value) {
                                cycleLoc.add(GeoPoint(
                                  latitude: value.data()!['latitude'],
                                  longitude: value.data()!['longitude'],
                                ));
                                controller.addMarker(
                                  GeoPoint(
                                      latitude: value.data()!['latitude'],
                                      longitude: value.data()!['longitude']),
                                  markerIcon: MarkerIcon(
                                    icon: Icon(
                                      semanticLabel: cycleId[i],
                                      Icons.pedal_bike_sharp,
                                      color: Colors.black,
                                      size: 50,
                                    ),
                                  ),
                                );
                              });
                            }
                            cycleLocation = cycleLoc;
                            adminCycleIds = cycleId;
                          });
                        },
                        child: const Text(
                          "Connect",
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddCycle()),
                          );
                          
                        },
                        child: const Text(
                          "Add Cycle",
                          style: TextStyle(color: Colors.white),
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) {
    // TODO: implement mapIsReady

    throw UnimplementedError();
  }
}
