import Flutter
import UIKit
import Intercom

public class SwiftIntercomPlugin: NSObject, FlutterPlugin {
  let channel: FlutterMethodChannel
    
  init(_ channel: FlutterMethodChannel) {
    self.channel = channel
    
    super.init()
  }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "intercom_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftIntercomPlugin(channel)
    
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
    
    print("Calling method \(String(describing: method))")
    
    let method = call.method
    var arguments = call.arguments as? NSDictionary
    var disablePush = false
    
    switch method {
    case "initialize":
        if let apiKey = arguments?["apiKey"] as? String,
            let appId = arguments?["appId"] as? String,
            let disablePushOnIOS = arguments?["disablePushOnIOS"] as? Bool {
            Intercom.setApiKey(apiKey, forAppId: appId)
            disablePush = disablePushOnIOS
        }
        
        result("apiKey or appId was not passed correctly")
    case "registerUnidentifiedUser":
        Intercom.registerUnidentifiedUser()
    case "registerUserWithUserId":
        if let userId = arguments?["userId"] as? String {
            Intercom.registerUser(withUserId: userId)
        }
        
        result(FlutterError(
            code: "argument",
            message: "userId was not passed correctly",
            details: "try to pass an userId")
        )
    case "registerUserWithEmail":
        if let email = arguments?["email"] as? String {
            Intercom.registerUser(withEmail: email)
        }
        
        result(FlutterError(
            code: "argument",
            message: "email was not passed correctly",
            details: "try to pass an valid email like example@domain.com")
        )
    case "registerUserWithEmailAndUserId":
        if let email = arguments?["email"] as? String, let userId = arguments?["userId"] as? String {
            Intercom.registerUser(withUserId: userId, email: email)
        }
        
        result(FlutterError(
            code: "argument",
            message: "email or userId was not passed correctly",
            details: "try to pass an valid email and userId")
        )
    case "logout":
        Intercom.logout()
    case "updateUser":
        let userAttributes = ICMUserAttributes()
        
        if let email = arguments?["email"] as? String {
            userAttributes.email? = email
        }
        
        if let userId = arguments?["userId"] as? String {
            userAttributes.userId = userId
        }
        
        if let phone = arguments?["phone"] as? String {
            userAttributes.phone = phone
        }
        
        if let name = arguments?["name"] as? String {
            userAttributes.name = name
        }
        
        if let signedUpAt = arguments?["signedUpAt"] as? String {
            if let date = signedUpAt.dateFromString(withLocale: Locale.current) {
                userAttributes.signedUpAt = date
            }
        }
        
        Intercom.updateUser(userAttributes)
    case "logEvent":
        if let eventName = arguments?["name"] as? String,
            let metaData = arguments?["metaData"] as? [AnyHashable : Any] {
            Intercom.logEvent(withName: eventName, metaData: metaData)
        } else if let eventName = arguments?["name"] as? String {
            Intercom.logEvent(withName: eventName)
        }
    case "setLauncherVisible":
        let launcherArgs = call.arguments as? [String:Bool]
        
        if let visibility = launcherArgs?["visibility"] {
            Intercom.setLauncherVisible(visibility)
        }
    case "hideMessenger":
        Intercom.hideMessenger()
    case "setDeviceToken":
        if let deviceToken = arguments?["deviceToken"] as? String {
            if let dataToken = deviceToken.dataFromString() {
                Intercom.setDeviceToken(dataToken)
            }
        }
        
        result(FlutterError(
            code: "argument",
            message: "device token was not passed correctly",
            details: "try to pass an an valid deviceToken")
        )
    case "isIntercomPush":
        let notificationArgs = call.arguments as? [String: [AnyHashable : Any]]
        
        if let notificationData = notificationArgs?["notificationData"] {
            result(Intercom.isIntercomPushNotification(notificationData))
        }
        
        result(FlutterError(
            code: "argument",
            message: "notification data was not passed correctly",
            details: "try to pass an an valid notification data")
        )
    case "handlePush":
        let notificationArgs = call.arguments as? [String: [AnyHashable : Any]]
        
        if let notificationData = notificationArgs?["notificationData"] {
            result(Intercom.handlePushNotification(notificationData))
        }
        
        result(FlutterError(
            code: "argument",
            message: "notification data was not passed correctly",
            details: "try to pass an an valid notification data")
        )
    case "displayMessenger":
        Intercom.presentMessenger()
    case "UnreadConversationCount":
        result(Intercom.unreadConversationCount())
    case "onUnreadConversationCount":
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUnreadConversationCount), name: NSNotification.Name.IntercomUnreadConversationCountDidChange, object: nil
        )
    default:
//        result(FlutterMethodNotImplemented("Method \(method) was not implemented"))
        result("error")
    }
  }
    
  @objc func onUnreadConversationCount() {
    channel.invokeMethod("onUnreadConversationCount", arguments: Intercom.unreadConversationCount())
  }

}

extension String {
    func dataFromString() -> Data? {
        return Data(base64Encoded: self)
    }
    
    func dateFromString(withLocale locale: Locale) -> Date? {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        return dateFormatter.date(from: self)
    }
}
