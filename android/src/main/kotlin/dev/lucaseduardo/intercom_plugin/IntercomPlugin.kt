package dev.lucaseduardo.intercom_plugin

import android.app.Application
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.intercom.android.sdk.Intercom
import io.intercom.android.sdk.UserAttributes
import io.intercom.android.sdk.identity.Registration
import io.intercom.android.sdk.push.IntercomPushClient
import java.text.SimpleDateFormat

/** IntercomPlugin */
public class IntercomPlugin(private val application: Application?): FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
//  private lateinit var application: Application

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "intercom_plugin")
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "intercom_plugin")
      channel.setMethodCallHandler(IntercomPlugin(registrar.context() as? Application))
    }
  }

  private val intercomPushClient = IntercomPushClient()

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "initialize" -> {
        application?.let {
          Intercom.initialize(it, call.argument("apiKey"), call.argument("appId"))
        }
        result.success("Intercom initialized with success")
      }
      "registerUnidentifiedUser" -> {
        Intercom.client().registerUnidentifiedUser()
        result.success("Intercom initialized with success")
      }
      "registerUserWithUserId" -> {
        call.argument<String>("userId")?.let {
          val registration = Registration.create().withUserId(it)

          Intercom.client().registerIdentifiedUser(registration)
          result.success("User registered with id: ${it}")
        }
      }
      "registerUserWithEmail" -> {
        call.argument<String>("email")?.let {
          val registration = Registration.create().withEmail(it)

          Intercom.client().registerIdentifiedUser(registration)
        }
      }
      "registerUserWithEmailAndUserId" -> {
        call.argument<String>("userId")?.let { userId ->
          call.argument<String>("email")?.let { email ->
            val registration = Registration.create()

            registration
              .withUserId(userId)
              .withEmail(email)

            Intercom.client().registerIdentifiedUser(registration)
          }
        }
      }
      "logout" -> Intercom.client().logout()
      "updateUser" -> {
        val userAttributes = UserAttributes.Builder()

        call.argument<String>("userId")?.let {
          userAttributes.withUserId(it)
        }

        call.argument<String>("email")?.let {
          userAttributes.withEmail(it)
        }

        call.argument<String>("phone")?.let {
          userAttributes.withPhone(it)
        }

        call.argument<String>("name")?.let {
          userAttributes.withName(it)
        }

        call.argument<String>("signedUpAt")?.let {
          val format = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")

          format.parse(it)?.let { date ->
            userAttributes.withSignedUpAt(date)
          }
        }

        call.argument<Map<String, Any>>("customAttributes")?.let {
          for((key, value) in it) {
            userAttributes.withCustomAttribute(key, value)
          }
        }

        Intercom.client().updateUser(userAttributes.build())
        result.success("User updated with success")
      }
      "logEvent" -> {
        call.argument<String>("name")?.let {
          val metaData = HashMap<String, Any>()

          call.argument<Map<String, Any>>("metaData")?.let { meta ->
            metaData.putAll(meta)
          }

          if (metaData.isNullOrEmpty()) {
            Intercom.client().logEvent(it)
          }
          else Intercom.client().logEvent(it, metaData)

          result.success("Event $it logged with success")
        }
      }
      "setLauncherVisible" -> {
        call.argument<Boolean>("visibility")?.let {
          val visibility = if (it) {
            Intercom.Visibility.VISIBLE
          }
          else Intercom.Visibility.GONE

          Intercom.client().setLauncherVisibility(visibility)

          result.success("Launcher visibility updated to $visibility")
        }
      }
      "hideMessenger" -> {
        Intercom.client().hideMessenger()

        result.success("Messenger hidden with success")
      }
      "isIntercomPush" -> {
        call.argument<Map<String, String>>("notificationData")?.let {
          result.success(intercomPushClient.isIntercomPush(it))
        }
      }
      "handlePush" -> {
        call.argument<Map<String, String>>("notificationData")?.let {
          Intercom.client().handlePushMessage()

          result.success("Push handled by Intercom")
        }
      }
      "displayMessenger" -> {
        Intercom.client().displayMessenger()

        result.success("Displaying messenger")
      }
      "setDeviceToken" -> {
        call.argument<String>("deviceToken")?.let { token ->
          application?.let { application ->
            intercomPushClient.sendTokenToIntercom(application, token)
          }

          result.success("Token sent to Intercom")
        }
      }
      "unreadConversationCount" -> {
        result.success(Intercom.client().unreadConversationCount)
      }
      "onUnreadConversationCount" -> {
        Intercom.client().addUnreadConversationCountListener {
          channel.invokeMethod("onUnreadConversationCountListener", it)

          result.success("Listening for unread conversations")
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
