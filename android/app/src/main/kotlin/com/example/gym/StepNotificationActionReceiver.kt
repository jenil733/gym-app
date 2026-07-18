package com.example.gym

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class StepNotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            StepForegroundService.ACTION_DELETE_NOTIFICATION -> {
                context.stopService(Intent(context, StepForegroundService::class.java))
                context.getSystemService(NotificationManager::class.java)
                    .cancel(StepForegroundService.NOTIFICATION_ID)
            }

            StepForegroundService.ACTION_RESTORE_NOTIFICATION -> {
                val serviceIntent = Intent(context, StepForegroundService::class.java).apply {
                    action = StepForegroundService.ACTION_RESTORE_NOTIFICATION
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            }
        }
    }
}
