//package com.sensible.callLogs
//
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity()

package com.sensible.callLogs

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 🔔 Create a Notification Channel for background service
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "sensiblecall_service", // must match the channelId you use in Dart
                "SensibleCall Background Service",
                NotificationManager.IMPORTANCE_LOW
            )
            channel.description = "Notifications for background call sync"

            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}
