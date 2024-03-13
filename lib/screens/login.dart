// ignore_for_file: prefer_const_constructors

import 'package:bike_app/admin/adminLogin.dart';
import 'package:bike_app/screens/loadingdialog.dart';
import 'package:bike_app/screens/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({Key? key}) : super(key: key);

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  var receivedID = '';
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    countryController.text = "+91";
    super.initState();
  }

  Future<void> _verifyPhone(String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then(
                (value) => print('Logged In Successfully'),
              )
              .catchError((err) {
                Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("$err : Please try again"),
              backgroundColor: Colors.red,
            ));
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("The provided phone number is not valid."),
              backgroundColor: Colors.red,
            ));
            print('The provided phone number is not valid.');
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e.message!),
              backgroundColor: Colors.red,
            ));
          }

          // Handle other errors
        },
        codeSent: (String verificationId, int? resendToken) {
          receivedID = verificationId;

          setState(() {
            loading = false;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MyVerify(
                        receivedID: receivedID,
                        phone: phone,
                      )),
            );
          });
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          print('TimeOut');
        });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img1.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "We need to register your phone to get started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: countryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextField(
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Phone",
                      ),
                    ))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      if (phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Please Enter Phone Number"),
                          backgroundColor: Colors.red,
                        ));
                      } else if (!RegExp(
                              r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                          .hasMatch(phoneController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Please Enter Valid Phone Number"),
                          backgroundColor: Colors.red,
                        ));
                      } else {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return LoadingAlertDialog(
                                  message: "Authenticating");
                            });
                        var phone = countryController.text.toString() +
                            phoneController.text.toString();
                        _verifyPhone(phone);
                      }
                    },
                    child: const Text("Send the code",style: TextStyle(color: Colors.white),)),
              ),
              SizedBox(
                height: screenHeight/10,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AdminLogin()),
                              );
                  },
                  child: Text(
                    "Admin Login",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
