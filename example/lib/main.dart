import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:intercom_plugin/intercom_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FlatButton(
            child: Text("INTERCOM"),
            onPressed: () async{
              await Intercom.initialize(androidApiKey: 'android_sdk-516e7d257ee2d4b98bf801c146e6c5c92c5a77e5', iOSApiKey: '', appId: 'xypa8ezx');
//              await Intercom.logout();
              await Intercom.setTokenAndRegisterUser(
                token: "fJ8WUh0iRg6zUFadpy9ffY:APA91bGDi5_8xjQwFAGy10t0TTgHMxS2ufKdt2gF6uWl7W7rp6NCIMTdYNrMMmzNU-d_IAQyavDoj4e5kULacR5B3CAUiX4iBsuEMGDjOuF-Q1Qjk0u5hPwAXWKsZVIZcJRGlH9vJhdC",
                email: "ihihihihi@hotmail.com",
                name: "Jocka",
                phone: "+5511942710174",
                userId: "f5711ced-1ab1-415b-bbff-a291501a2966"  ,
                signedUpAt: DateTime.now()
              );
            },
          ),
        ),
      ),
    );
  }
}
