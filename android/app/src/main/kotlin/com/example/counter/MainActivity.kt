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
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sim_service"
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
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSimCards") {
                result.success(getSimCards())
            } else {
                result.notImplemented()
            }
        }
    }
    private fun getSimCards(): List<Map<String, Any?>> {
        val simList = mutableListOf<Map<String, Any?>>()
        val subscriptionManager = getSystemService(SubscriptionManager::class.java)

        val activeSubs: List<SubscriptionInfo>? = subscriptionManager.activeSubscriptionInfoList

        activeSubs?.forEach { sub ->
            val simInfo = mapOf(
                "carrierName" to (sub.carrierName?.toString() ?: "Unknown"),
                "displayName" to (sub.displayName?.toString() ?: "SIM ${sub.simSlotIndex+1}"),
                "number" to (sub.number ?: ""),
                "slotIndex" to sub.simSlotIndex
            )
            simList.add(simInfo)
        }
        return simList
    }
}
