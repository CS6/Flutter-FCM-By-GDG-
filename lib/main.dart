import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterBase',
      home: Scaffold(
        body: MessageHandler(),
      ),
    );
  }
}

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  final String name = "";
  final TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
//        _saveDeviceToken();
        ///歡迎登入
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
//      _saveDeviceToken();
      ///歡迎登入

    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _handleMessages(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text('FCM Push Notifications')),
      body: new Center(
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text('FCM by GDG 1024'),
            new TextField(
              controller: _controller,
              decoration: new InputDecoration(
                border: OutlineInputBorder(),
                hintText: '請問如何稱呼？',
              ),
            ),
            new RaisedButton(
              onPressed: () {
                _saveToken();
                showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text('What you typed'),
                    content: new Text(_controller.text),
                  ),
                );
              },
              child: new Text('DONE'),
            ),
            new Image.network(
              'https://cdn.jsdelivr.net/gh/flutterchina/website@1.0/images/flutter-mark-square-100.png',
            ),
          ])),
    );
  }

  /// Get the token, save it to the database for current user
  ///main.dart _saveDeviceToken()修改為以下
  _saveToken() async {
    // Get the current user
//    String uid = 'jeffd23';
    String uid = _controller.text;
    // FirebaseUser user = await _auth.currentUser();
    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = _db.collection('tokens').document(fcmToken);
      await tokens.setData({
        'token': fcmToken,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

  /// Subscribe the user to a topic
  _subscribeToTopic() async {
    // Subscribe the user to a topic
    _fcm.subscribeToTopic('puppies');
  }
}
