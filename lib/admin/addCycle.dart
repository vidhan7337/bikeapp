import 'package:bike_app/admin/adminHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCycle extends StatefulWidget {
  const AddCycle({super.key});

  @override
  State<AddCycle> createState() => _AddCycleState();
}

class _AddCycleState extends State<AddCycle> {
  TextEditingController idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade600,
        
          title: const Text("Add Cycle Id",style: TextStyle(color: Colors.white),),
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
                  'Enter cycle id to add to the system:',
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Container(
                height: 55,
                width: screenWidth / 2,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: idController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none,
                    hintText: "Id",
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: screenWidth / 2.5,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      if (idController.text.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Please provide Id"),
                          backgroundColor: Colors.red,
                        ));
                      } else {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        var id = prefs.getString('adminId');
                        FirebaseFirestore.instance
                            .collection('admin')
                            .doc(id)
                            .collection('cycle')
                            .doc(idController.text)
                            .set({
                          'cycleId': idController.text,
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Cycle added successfully"),
                          backgroundColor: Colors.green,
                        ));
                        Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MapPage()),
                                );
                      }
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        ));
  }
}
