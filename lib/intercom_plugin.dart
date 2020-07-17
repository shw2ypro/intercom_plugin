import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Intercom {
  static const MethodChannel _channel = const MethodChannel('intercom_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Initializes a instance of Intercom
  ///
  /// Receives an [appId] and a [iOSApiKey] and [androidApiKey]
  /// you can retrieve this credentials by going to [https://developers.intercom.com/building-apps/docs]
  /// and start building your workspace
  static Future<void> initialize({
    @required String androidApiKey,
    @required String iOSApiKey,
    @required String appId,
  }) {
    return _channel.invokeMethod("initialize",
        {"apiKey": Platform.isIOS ? iOSApiKey : androidApiKey, "appId": appId});
  }

  /// Sent the [token] to Intercom
  ///
  /// This sent the token for Intercom and is used by
  /// him to send push notifications for the device
  static Future<void> sentDeviceToken(String token) {
    return _channel.invokeMethod("setDeviceToken", {"deviceToken": token});
  }

  /// Send token and register user
  ///
  /// Send the [token] to the Intercom and register
  /// the user with [userId], as well updates him
  /// with some data that you can send about your user
  static Future<void> setTokenAndRegisterUser(
      {String email,
      String userId,
      String phone,
      String name,
      DateTime signedUpAt,
      String token}) async {
    await sentDeviceToken(token);

    await registerWithUserId(userId);

    return await updateUser(
        userId: userId,
        email: email,
        name: name,
        signedUpAt: signedUpAt,
        phone: phone);
  }

  /// Register the an unidentified user on Intercom
  static Future<void> registerUnidentifiedUser() {
    return _channel.invokeMethod("registerUnidentifiedUser");
  }

  /// Register the user with an userId
  static Future<void> registerWithUserId(String userId) {
    return _channel.invokeMethod("registerUserWithUserId", {"userId": userId});
  }

  /// Register the user with an email
  static Future<void> registerUserWithEmail(String email) {
    return _channel.invokeMethod("registerUserWithEmail", {"email": email});
  }

  /// Register the user with email and userId
  ///
  /// Receives an [userId] and a [email] for complete the
  /// registration
  static Future<void> registerUserWithEmailAndUserId(
      {String email, String userId}) {
    return _channel.invokeMethod(
        "registerUserWithEmailAndUserId", {"email": email, "userId": userId});
  }

  /// Logout the user from Intercom
  static Future<void> logout() {
    return _channel.invokeMethod("logout");
  }

  /// Updates the user with some custom data
  static Future<void> updateUser(
      {String email,
      String userId,
      String phone,
      String name,
      DateTime signedUpAt}) {
    return _channel.invokeMethod("updateUser", <String, dynamic>{
      "email": email,
      "userId": userId,
      "name": name,
      "phone": phone,
      "signedUpAt": DateFormat("yyyy-MM-dd hh:mm:ss").format(signedUpAt)
    });
  }

  /// Logs a event to the Intercom
  ///
  /// It can receive a [name] and a optional [metadata] for sending to Intercom
  static Future<void> logEvent(String name, {Map<String, dynamic> metadata}) {
    return _channel
        .invokeMethod("logEvent", {"name": name, "metaData": metadata});
  }

  /// Updates the visibility of the launcher
  static setLauncherVisibility(bool visibility) {
    return _channel
        .invokeMethod("setLauncherVisibility", {"visibility": visibility});
  }

  /// Hides the messenger
  static hideMessenger() {
    _channel.invokeMethod("hideMessenger");
  }

  /// This helps you to know when a message is from Intercom or not
  ///
  /// It receives a [message] and returns a [bool] telling if the
  /// message is from Intercom or not
  static Future<bool> isIntercomPush(Map<String, dynamic> message) {
    return _channel
        .invokeMethod("isIntercomPush", {"notificationData": message});
  }

  /// Tells Intercom to handle the push message
  ///
  /// It receives a [message] for giving to Intercom handling
  static handlePush(Map<String, dynamic> message) {
    return _channel.invokeMethod("handlePush", {"notificationData": message});
  }

  /// Displays the Intercom messenger
  static Future<void> displayMessenger() {
    return _channel.invokeMethod("displayMessenger");
  }
}
