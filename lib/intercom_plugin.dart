import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Intercom {
  static const MethodChannel _channel =
      const MethodChannel('intercom_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> initialize({
    @required String androidApiKey,
    @required String iOSApiKey,
    @required String appId,
  }) {
    return _channel.invokeMethod("initialize", {
      "apiKey": Platform.isIOS ? iOSApiKey : androidApiKey,
      "appId": appId
    });
  }

  static Future<void> sentDeviceToken(String token) {
    return _channel.invokeMethod("setDeviceToken", {
      "deviceToken": token
    });
  }

  static Future<void> setTokenAndRegisterUser({
    String email, String userId, String phone,
    String name, DateTime signedUpAt, String token
  }) async {
    print("$email, $userId, $token");
    await sentDeviceToken(token);

    await registerWithUserId(userId);

    return await updateUser(
      userId: userId,
      email: email,
      name: name,
      signedUpAt: signedUpAt,
      phone: phone
    );
  }

  static Future<void> registerUnidentifiedUser() {
    return _channel.invokeMethod("registerUnidentifiedUser");
  }

  static Future<void> registerWithUserId(String userId) {
    return _channel.invokeMethod("registerUserWithUserId", {
      "userId": userId
    });
  }

  static Future<void> registerUserWithEmail(String email) {
    return _channel.invokeMethod("registerUserWithEmail", {
      "email": email
    });
  }

  static Future<void> registerUserWithEmailAndUserId({ String email, String userId }) {
    return _channel.invokeMethod("registerUserWithEmailAndUserId", {
      "email": email,
      "userId": userId
    });
  }

  static Future<void> logout(){
    return _channel.invokeMethod("logout");
  }

  static Future<void> updateUser({
    String email, String userId, String phone,
    String name, DateTime signedUpAt
  }){
    return _channel.invokeMethod("updateUser", <String, dynamic>{
      "email": email,
      "userId": userId,
      "name": name,
      "phone": phone,
      "signedUpAt": DateFormat("yyyy-MM-dd hh:mm:ss").format(signedUpAt)
    });
  }

  static Future<void> logEvent(String name, { Map<String, dynamic> metadata }) {
    return _channel.invokeMethod("logEvent", {
      "name": name,
      "metaData": metadata
    });
  }

  static setLauncherVisibility(bool visibility) {
    return _channel.invokeMethod("setLauncherVisibility", {
      "visibility": visibility
    });
  }

  static hideMessenger() {
    _channel.invokeMethod("hideMessenger");
  }

  static Future<bool> isIntercomPush(Map<String, dynamic> message) {
    return _channel.invokeMethod("isIntercomPush", {
      "notificationData": message
    });
  }

  static handlePush(Map<String, dynamic> message) {
    return _channel.invokeMethod("handlePush", {
      "notificationData": message
    });
  }

  static Future<void> displayMessenger() {
    return _channel.invokeMethod("displayMessenger");
  }
}
