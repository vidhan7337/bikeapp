// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:bike_app/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  int? balance;
  int? amount;
  var start;
  var end;
  TextEditingController feedbackController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
        .get()
        .then((DocumentSnapshot doc) {
      setState(() {
        if ((doc.data() as Map<String, dynamic>)['balance'] != null) {
          balance = (doc.data() as Map<String, dynamic>)['balance'];
        } else {
          balance = 0;
        }
      });
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
        .collection('currentTrip')
        .doc('currentTrip')
        .get()
        .then((DocumentSnapshot doc) {
      setState(() {
        start = (doc.data() as Map<String, dynamic>)['startTime'].toDate();
        end = (doc.data() as Map<String, dynamic>)['endTime'].toDate();
        Duration diff = end.difference(start);
        var min = diff.inMinutes;
        print('#######');
        print(min);

        if (min < 10) {
          amount = 10;
        } else {
          var x = ((min) / 5);
          amount = x.ceil() * 5;
        }
      });
    });
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
            "Current Trip Page",
            style: TextStyle(color: Colors.white),
          ),
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
                  'Total Fees are: $amount',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              SizedBox(
                width: screenWidth / 1.2,
                child: Text(
                  'Your wallet balance is: $balance',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 25, right: 25),
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none,
                    hintText: "Feedback (Optional)",
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: screenWidth / 1.5,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('trip');
                      await prefs.remove('cycleID');
                      await prefs.remove('unlocked');
                      await prefs.remove('payment');
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
                          .collection('currentTrip')
                          .doc('currentTrip')
                          .delete();
                      balance = (balance! - amount!);
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
                          .update({'balance': balance});
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
                          .collection('trips')
                          .add({
                        'start_time': start,
                        'end_time': end,
                        'total_mins': (end.difference(start).inMinutes),
                        'amount': amount,
                        'feedback': feedbackController.text,
                        'payment_time': DateTime.now()
                      });
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return Home();
                      }));
                    },
                    child: const Text(
                      "Make Payment",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
        ));
  }
}
