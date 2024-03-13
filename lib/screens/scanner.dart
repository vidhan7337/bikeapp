// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:bike_app/mqtt.dart';
import 'package:bike_app/screens/dialog.dart';
import 'package:bike_app/screens/loadingdialog.dart';
import 'package:bike_app/screens/trip%20pages/trip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  String qrResult = 'Scanned Data will appear here';
  Future<void> scanQR() async {
    try {
      final qrcode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);

      if (!mounted) return;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('cycleID', qrcode.toString());
      setState(() {
        qrResult = qrcode.toString();

        MQTTClientWrapper newclient = MQTTClientWrapper();
        newclient.prepareMqttClient(qrResult);
      });
    } on PlatformException {
      qrResult = 'Fail to read QR code';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade600,
          title: const Text(
            "Scan to unlock",
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
                  'Press the button scan the QR on lock you will get authorized after that cycle will get unlocked',
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
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
                      await scanQR();
                      if (qrResult != 'Fail to read QR code' ||
                          qrResult != 'Scanned Data will appear here') {
                        print(qrResult);
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return LoadingAlertDialog(message: "Processing");
                            });
                      }
                    },
                    child: const Text(
                      "Scan Code",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
        ));
  }
}
