package dev.lucaseduardo.intercom_plugin

import android.annotation.SuppressLint
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import io.intercom.android.sdk.push.IntercomPushClient

@SuppressLint("MissingFirebaseInstanceTokenRefresh")
class IntercomInterceptor : FirebaseMessagingService() {
    private val TAG = "PushInterceptService"
    private val intercomPushClient = IntercomPushClient()

    override fun onMessageReceived(remoteMessage: RemoteMessage?) {
        remoteMessage?.data?.let {
            if (intercomPushClient.isIntercomPush(it)) {
                Log.d(TAG, "Push handled by Intercom")
                intercomPushClient.handlePush(application, it)
            }
            else {
                Log.d(TAG, "Push handled by Firebase")
                super.onMessageReceived(remoteMessage)
            }
        }
    }
}