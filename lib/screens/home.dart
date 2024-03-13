import 'package:bike_app/screens/profile.dart';
import 'package:bike_app/screens/scanner.dart';
import 'package:bike_app/screens/wallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

// late SharedPreferences prefs;

String name = '';
int? balance;

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    // prefs = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
        .get()
        .then((DocumentSnapshot doc) {
      setState(() {
        name = (doc.data() as Map<String, dynamic>)['name'];
        if ((doc.data() as Map<String, dynamic>)['balance'] != null) {
          balance = (doc.data() as Map<String, dynamic>)['balance'];
          print(balance);
        }
      });

      // print("######################");
      // print((doc.data() as Map<String, dynamic>)['name']);
      // print("######################");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green.shade600,
          title: const Text("Home",style: TextStyle(color: Colors.white),),
          automaticallyImplyLeading: false),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: screenHeight / 2.5,
                width: screenWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/scan.png',
                      width: screenHeight / 4.5,
                      height: screenHeight / 4.5,
                    ),
                    SizedBox(
                      width: screenHeight / 4.5,
                      height: 45,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            if (balance == null || balance! < 200) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    "Please Add minimum 200 points to your wallet to unlock and ride"),
                                backgroundColor: Colors.red,
                              ));
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Scanner()),
                              );
                            }
                          },
                          child: const Text("Scan to Unlock",style: TextStyle(color: Colors.white),)),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: (screenHeight / 4),
                    width: (screenWidth / 2.5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/wallet.png',
                          width: screenHeight / 8,
                          height: screenHeight / 8,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: screenHeight / 8,
                          height: 45,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Wallet()),
                                );
                              },
                              child: const Text("Wallet",style: TextStyle(color: Colors.white),)),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: (screenHeight / 4),
                    width: (screenWidth / 2.5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/bike.png',
                          width: screenHeight / 8,
                          height: screenHeight / 8,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: screenHeight / 8,
                          height: 45,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: () async {
                                // await prefs.setBool('profile', true);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Profile()),
                                );
                              },
                              child: const Text("Profile",style: TextStyle(color: Colors.white),)),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
