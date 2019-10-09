import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globe_app/globe_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui' as ui;

void main() => runApp(MyApp());


class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });

    var _sysLng = ui.window.locale == null ? "": ui.window.locale.languageCode;
    //_sysLng : en, ko, ja, es
    fcmSubscribe(_sysLng);
//    _firebaseMessaging.subscribeToTopic("/topics/all");
  }

  void fcmSubscribe(String lang) {
    switch(lang){
      case "es":
      case "ko":
      case "ja":{
        _firebaseMessaging.subscribeToTopic('language_'+lang);
        break;
      }
      default:{
        _firebaseMessaging.subscribeToTopic('language_en');
        break;
      }
    }

  }

  void fcmUnSubscribe(String lang) {
    _firebaseMessaging.unsubscribeFromTopic('language_'+lang);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GlobeView(),
    );
  }
}

