import 'package:bike_app/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool loading = false;
  late Razorpay razorpay;
  int? balance;
  String? name;
  @override
  void initState() {
    setState(() {
      loading = true;
    });
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
          print("#############");
        } else {
          balance = 0;
        }
        loading = false;
      });
    });
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, errorHandler);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, successHandler);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, externalWalletHandler);
    super.initState();
  }

  TextEditingController amountController = TextEditingController();
  void errorHandler(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.message!),
      backgroundColor: Colors.red,
    ));
  }

  void successHandler(PaymentSuccessResponse response) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
        .update({'balance': balance! + num.parse(amountController.text)});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Success with payment id :${response.paymentId!}"),
      backgroundColor: Colors.green,
    ));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }

  void externalWalletHandler(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.walletName!),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text(
          "Wallet",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 12.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
              ),
            )
          : Container(
              margin: const EdgeInsets.only(left: 25, right: 25),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Text(
                    "Current Balance : $balance",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            hintText: "Amount",
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 0.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 0.0)),
                            disabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 0.0)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: screenHeight / 4,
                        height: 45,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () {
                              if (amountController.text.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Please enter the amount"),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                openCheckout();
                              }
                            },
                            child: const Text(
                              "Add Points",
                              style: TextStyle(color: Colors.white),
                            )),
                      )
                      // MaterialButton(
                      //   onPressed: () {
                      //     openCheckout();
                      //   },
                      //   child: const Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                      //     child: Text("Add now"),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              )),
            ),
    );
  }

  void openCheckout() {
    var options = {
      "key": "rzp_live_N9g5vVTL0lkepi",
      // "key": "rzp_test_CwT07E8UCX8kd2",
      "amount": num.parse(amountController.text) * 100,
      "name": "EONIC PEDALS",
      "description": " Adding points to wallet",
      "timeout": "180",
      "currency": "INR",
      "prefill": {
        "contact": FirebaseAuth.instance.currentUser?.phoneNumber.toString(),
        "name": name,
      }
    };
    razorpay.open(options);
  }
}
