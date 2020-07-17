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
  @override
  void initState() {
    Intercom.initialize(
        androidApiKey: 'android_sdk-516e7d257ee2d4b98bf801c146e6c5c92c5a77e5',
        iOSApiKey: 'ios_sdk-f89bc4dce1f127d8a65b36e18dcbbc5baf53b907',
        appId: 'xypa8ezx');

    Intercom.registerUnidentifiedUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: Column(
              children: <Widget>[
                FlatButton(
                  child: Text("Display messenger"),
                  onPressed: () async {
                    await Intercom.displayMessenger();
                  },
                ),
                FlatButton(
                  child: Text("Logs a event"),
                  onPressed: () async {
                    await Intercom.logEvent("First event",
                        metadata: {"meta": "data"});

                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Event logged with success"),
                    ));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
