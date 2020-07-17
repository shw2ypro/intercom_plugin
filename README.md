# intercom_plugin

A plugin that translates the Intercom SDK into a plugin for Flutter

## Usage

Import package:intercom_plugin/intercom_plugin.dart and use the methods in Intercom class.

## Example

```dart
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
      androidApiKey: 'ANDROID API KEY', 
      iOSApiKey: 'iOS API KEY', 
      appId: 'YOUR APP ID'
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text("Display messenget"),
                onPressed: () async{
                  await Intercom.displayMessenger();
                },
              ),
              FlatButton(
                child: Text("Logs a event"),
                onPressed: () async{
                  await Intercom.logEvent("First event", metadata: {
                    "meta":"data"
                  });
                  
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Event logged with success"),
                    )
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
```

## Android integration

First you need to add this permission

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Other permissions that you can set, but is optional

```xml
<manifest>
    ...
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    ...
</manifest>
```

## Push notifications support

This plugin allows push notifications for Intercom and FCM. You can explore better in the IntercomInterceptor.kt file, but
basically, we verify if the push is coming from Intercom and pass to him the responsability to handle the push, otherwise
FCM will handle it.

- First, implement the [firebase_messaging](https://pub.dev/packages/firebase_messaging) and take a look
in the [android](https://pub.dev/packages/firebase_messaging#android-integration) part.
- Then, add the Firebase server key to Intercom, as described [here](https://developers.intercom.com/installing-intercom/docs/android-fcm-push-notifications#section-step-3-add-your-server-key-to-intercom-for-android-settings) (you can skip 1 and 2)
- Lastly, add this to you AndroidManifest.xml, above the closing </application> tag

```xml
  <service
    android:name="dev.lucaseduardo.intercom_plugin.IntercomInterceptor"
    android:enabled="true"
    android:exported="true">
    <intent-filter>
      <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
  </service>
```