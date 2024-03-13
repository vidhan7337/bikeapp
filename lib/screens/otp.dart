// ignore_for_file: use_build_context_synchronously, prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'package:bike_app/screens/home.dart';
import 'package:bike_app/screens/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class MyVerify extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final String receivedID;
  final String phone;
  const MyVerify({required this.receivedID, required this.phone});

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

var finalPIN;
var id;

bool logged = false;

class _MyVerifyState extends State<MyVerify> {

var receivedID = '';
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("$err : Please try again"),
              backgroundColor: Colors.red,
            ));
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("The provided phone number is not valid."),
              backgroundColor: Colors.red,
            ));
            print('The provided phone number is not valid.');
          } else {
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
            // loading = false;
            Navigator.push(
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



  Future<void> verifyOTPCode() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: id,
      smsCode: finalPIN,
    );
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
      print(value.user?.uid);

      var usersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(value.user?.phoneNumber);

      var data = await usersRef.get();

      if (data.exists) {
        logged = true;
         Navigator.pushNamedAndRemoveUntil(context, "home", (r) => false);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const Home()),
        // );
      } else {
        logged = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUp()),
        );
      }
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err.message),
        backgroundColor: Colors.red,
      ));
    });
    // if (logged) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const Home()),
    //   );
    // } else {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const SignUp()),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: const Icon(
        //     Icons.arrow_back_ios_rounded,
        //     color: Colors.black,
        //   ),
        // ),
        elevation: 0,
      ),
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
                "Please enter otp received on phone number",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                  length: 6,
                  // defaultPinTheme: defaultPinTheme,
                  // focusedPinTheme: focusedPinTheme,
                  // submittedPinTheme: submittedPinTheme,

                  showCursor: true,
                  onCompleted: (pin) {
                    setState(() {
                      finalPIN = pin;
                      id = widget.receivedID;
                    });
                  }),
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
                    onPressed: () async {
                      await verifyOTPCode();
                      // if (logged) {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => const Home()),
                      //   );
                      // } else {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => const SignUp()),
                      //   );
                      // }
                    },
                    child: const Text("Verify Phone Number",style: TextStyle(color: Colors.white),)),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          'phone',
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Edit Phone Number? " + "(" + widget.phone + ")",
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                       _verifyPhone(widget.phone);
                      },
                      child: Text(
                        "Resend Code?",
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}
