// ignore_for_file: constant_identifier_names, avoid_print, unused_element

import 'dart:io';

import 'package:bike_app/navigator_global.dart';
import 'package:bike_app/navigator_key.dart';

import 'package:bike_app/screens/trip%20pages/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/trip pages/currentTrip.dart';

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

enum MqttSubscriptionState { IDLE, SUBSCRIBED }

class MQTTClientWrapper {
  late MqttServerClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  void adminClientConnection(String id, List<String> cycleIDs) async {
    setupMqttClient(id);
    await connectClient();

    for (var cycleID in cycleIDs) {
      adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
    }
  }

  void adminRefereshClientConnection(String id, List<String> cycleIDs) async {
    setupMqttClient(id);
    await connectClient();

    for (var cycleID in cycleIDs) {
      publishMessage("1", 'protech/location/$cycleID');
      adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
    }
  }

  void adminStartRealTime(String id, List<String> cycleIDs) async {
    setupMqttClient(id);
    await connectClient();

    for (var cycleID in cycleIDs) {
      publishMessage("1", 'protech/location/$cycleID');
      adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
      publishMessage('1', 'protech/realtime/$cycleID');
    }
  }

  void adminEndtRealTime(String id, List<String> cycleIDs) async {
    setupMqttClient(id);
    await connectClient();

    for (var cycleID in cycleIDs) {
      publishMessage("1", 'protech/location/$cycleID');
      adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
      publishMessage("0", 'protech/realtime/$cycleID');
    }
  }



  void adminCycleOption(String id, String cycleID) async {
    setupMqttClient(id);
    await connectClient();
    adminsubscribeToTopic('protech/lockstat/$cycleID', cycleID);
    adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
  }

  void adminLockCycle(String id, String cycleID) async {
    setupMqttClient(id);
    await connectClient();
    publishMessage("admin_lock", 'protech/lock/$cycleID');
    adminsubscribeToTopic('protech/lockstat/$cycleID', cycleID);
    adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
  }

  void adminUnlockCycle(String id, String cycleID) async {
    setupMqttClient(id);
    await connectClient();
    publishMessage("admin_unlock", 'protech/lock/$cycleID');
    adminsubscribeToTopic('protech/lockstat/$cycleID', cycleID);
    adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
  }

  void adminEndTrip(String id, String cycleID) async {
    setupMqttClient(id);
    await connectClient();
    publishMessage("admin", 'protech/endtrip/$cycleID');
    adminsubscribeToTopic('protech/lockstat/$cycleID', cycleID);
    adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
  }

  void adminUserDiasbale(String id, String cycleID) async {
    setupMqttClient(id);
    await connectClient();
    publishMessage("admin_disable", 'protech/lock/$cycleID');
    adminsubscribeToTopic('protech/lockstat/$cycleID', cycleID);
    adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
  }

  void adminReferesh(String id, String cycleID) async {
    setupMqttClient(id);
    await connectClient();
    publishMessage("1", 'protech/location/$cycleID');
    adminsubscribeToTopic('protech/lockstat/$cycleID', cycleID);
    adminsubscribeToTopic('protech/lat/$cycleID', cycleID);
  }

  // using async tasks, so the connection won't hinder the code flow
  //Scanning and connecting to the cycle
  void prepareMqttClient(String cycleID) async {
    var a = FirebaseAuth.instance.currentUser?.phoneNumber;
    setupMqttClient(a!);
    await connectClient();
    publishMessage(
        FirebaseAuth.instance.currentUser!.uid, 'protech/lock/$cycleID');
    subscribeToTopic('protech/lockstat/$cycleID', cycleID);
  }

  //Between the trip unlocking the cycle
  void tripstartMqtt(String cycleID) async {
    var a = FirebaseAuth.instance.currentUser?.phoneNumber;
    setupMqttClient(a!);
    await connectClient();
    subscribeToTopic('protech/lockstat/$cycleID', cycleID);
  }

  //ending the trip and locking the cycle
  void tripendMqtt(String cycleID) async {
    var a = FirebaseAuth.instance.currentUser?.phoneNumber;
    setupMqttClient(a!);
    await connectClient();
    publishMessage(
        FirebaseAuth.instance.currentUser!.uid, 'protech/endtrip/$cycleID');
    _unsubscribeToTopic('protech/lockstat/$cycleID');
  }

  // waiting for the connection, if an error occurs, print it and disconnect
  Future<void> connectClient() async {
    try {
      print('client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      // await client.connect('abcde', 'Vidhan@7337');
      await client.connect();
    } on Exception catch (e) {
      print('client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    // when connected, print a confirmation, else print an error
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('client connected');
    } else {
      print(
          'ERROR client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void setupMqttClient(String phone) {
    // client = MqttServerClient.withPort(
    //     '976dd325b21a438f80b6d81ac42eb8a4.s2.eu.hivemq.cloud', phone, 8883);
    client = MqttServerClient.withPort('broker.hivemq.com', phone, 1883);
    // the next 2 lines are necessary to connect with tls, which is used by HiveMQ Cloud
    client.secure = false;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  void subscribeToTopic(String topicName, String cycleID) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    // print the message when it is received
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final recMess = c[0].payload as MqttPublishMessage;
      String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('YOU GOT A NEW MESSAGE:');
      print(message);
      if (message == "proceed") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('trip', true);
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
            .collection('currentTrip')
            .doc('currentTrip')
            .set({'startTime': DateTime.now()});
        GlobalNavigator.loadingAlertDialog(
            'Authorized, The Cycle will unlock soon');
      } else if (message == "unauthorized") {
        _unsubscribeToTopic(topicName);
        GlobalNavigator.showAlertDialog(
            'The cycle is currently in use by another user or you are not allowed to unlock the cycle');
      } else if (message == "unlocked") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('unlocked', true);
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => Trip(cycleID: cycleID)),
        );
      } else if (message == "locked") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('unlocked', false);
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => Trip(cycleID: cycleID)),
        );
        GlobalNavigator.lockAlertDialog(
            "Cycle Locked, you can end the trip now");
      }
    });
  }

  void _unsubscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.unsubscribe(topicName);
  }

  void publishMessage(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('Publishing message "$message" to topic ${'$topic'}');
    client.publishMessage('$topic', MqttQos.exactlyOnce, builder.payload!);
  }

  // callbacks for different events
  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print('OnConnected client callback - Client connection was sucessful');
  }

  void adminsubscribeToTopic(String topicName, String cycleID) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    // print the message when it is received
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final recMess = c[0].payload as MqttPublishMessage;
      String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('YOU GOT A NEW MESSAGE:');
      print(message);
      if (message != "unlocked" && message != "locked") {
        final splitMsg = message.split(',');
        print(splitMsg[6]);
        FirebaseFirestore.instance.collection('cycles').doc(splitMsg[6]).set({
          'latitude': double.parse(splitMsg[0]),
          'longitude': double.parse(splitMsg[1]),
          'user_id': splitMsg[2],
          'lock_status': splitMsg[3],
          'ebike_battery': splitMsg[4],
          'lock_battery': splitMsg[5],
        });
        
      } else if (message == "unlocked") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('unlocked', true);
      } else if (message == "locked") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('unlocked', false);
      }
    });
  }
}
