package com.example.gym

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

class StepForegroundService : Service(), SensorEventListener {
    companion object {
        const val ACTION_DELETE_NOTIFICATION =
            "com.example.gym.action.DELETE_STEP_NOTIFICATION"
        const val ACTION_RESTORE_NOTIFICATION =
            "com.example.gym.action.RESTORE_STEP_NOTIFICATION"
        const val NOTIFICATION_ID = 4101
        private const val CHANNEL_ID = "daily_steps_live_v2"
        internal const val PREFS_NAME = "GymStepServiceState"
        internal const val DATE_KEY = "step_tracking_date"
        internal const val TODAY_KEY = "step_tracking_today"
        internal const val LAST_RAW_KEY = "step_tracking_last_raw"
        internal const val YESTERDAY_DATE_KEY = "step_tracking_yesterday_date"
        internal const val YESTERDAY_STEPS_KEY = "step_tracking_yesterday_steps"

        fun snapshot(context: Context): Map<String, Any?> {
            val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            rollOverStoredDay(preferences)
            return mapOf(
                "date" to preferences.getString(DATE_KEY, null),
                "todaySteps" to readLong(preferences, TODAY_KEY),
                "lastRawSteps" to if (preferences.contains(LAST_RAW_KEY)) {
                    readLong(preferences, LAST_RAW_KEY)
                } else {
                    null
                },
                "yesterdayDate" to preferences.getString(YESTERDAY_DATE_KEY, null),
                "yesterdaySteps" to readLong(preferences, YESTERDAY_STEPS_KEY),
            )
        }

        fun reconcileTodaySteps(context: Context, savedSteps: Long): Long {
            val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            rollOverStoredDay(preferences)
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val storedDate = preferences.getString(DATE_KEY, null)
            val current = if (storedDate == today) readLong(preferences, TODAY_KEY) else 0L
            val realSteps = maxOf(current, savedSteps.coerceAtLeast(0L))
            preferences.edit()
                .putString(DATE_KEY, today)
                .putLong(TODAY_KEY, realSteps)
                .apply()
            return realSteps
        }

        fun resetTodaySteps(context: Context) {
            val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            preferences.edit()
                .putString(DATE_KEY, today)
                .putLong(TODAY_KEY, 0L)
                .apply()
        }

        private fun readLong(
            preferences: android.content.SharedPreferences,
            key: String,
        ): Long {
            return try {
                preferences.getLong(key, 0L)
            } catch (_: ClassCastException) {
                preferences.getInt(key, 0).toLong()
            }
        }

        private fun rollOverStoredDay(
            preferences: android.content.SharedPreferences,
        ) {
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val storedDate = preferences.getString(DATE_KEY, null)
            if (storedDate == today) return

            val calendar = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, -1)
            }
            val yesterday = SimpleDateFormat("yyyy-MM-dd", Locale.US)
                .format(calendar.time)
            val editor = preferences.edit()
            if (storedDate == yesterday) {
                editor
                    .putString(YESTERDAY_DATE_KEY, yesterday)
                    .putLong(YESTERDAY_STEPS_KEY, readLong(preferences, TODAY_KEY))
            }
            editor
                .putString(DATE_KEY, today)
                .putLong(TODAY_KEY, 0L)
                .apply()
        }
    }

    private lateinit var sensorManager: SensorManager
    private val preferences by lazy {
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    override fun onCreate() {
        super.onCreate()
        Companion.rollOverStoredDay(preferences)
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification(savedTodaySteps()))

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        if (stepSensor == null) {
            updateNotification("Step sensor is unavailable")
            return
        }
        sensorManager.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_NORMAL)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_RESTORE_NOTIFICATION) {
            startForeground(NOTIFICATION_ID, buildNotification(savedTodaySteps()))
        }
        return START_STICKY
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_STEP_COUNTER) return
        val rawSteps = event.values.firstOrNull()?.toLong() ?: return
        val today = dateValue(Date())
        val storedDate = preferences.getString(DATE_KEY, null)
        var todaySteps = savedTodaySteps()
        var lastRaw = if (preferences.contains(LAST_RAW_KEY)) {
            preferences.getLong(LAST_RAW_KEY, rawSteps)
        } else {
            -1L
        }

        if (storedDate != today) {
            val yesterday = yesterdayDate()
            val editor = preferences.edit()
            if (storedDate == yesterday) {
                editor.putString(YESTERDAY_DATE_KEY, yesterday)
                editor.putLong(YESTERDAY_STEPS_KEY, todaySteps)
            }
            todaySteps = if (lastRaw >= 0 && rawSteps >= lastRaw) {
                rawSteps - lastRaw
            } else {
                0L
            }
            lastRaw = rawSteps
            editor
                .putString(DATE_KEY, today)
                .putLong(TODAY_KEY, todaySteps)
                .putLong(LAST_RAW_KEY, lastRaw)
                .apply()
            updateNotification(todaySteps)
            return
        }

        if (lastRaw < 0) {
            lastRaw = rawSteps
        } else {
            val delta = if (rawSteps >= lastRaw) rawSteps - lastRaw else rawSteps
            if (delta > 0) todaySteps += delta
        }
        preferences.edit()
            .putString(DATE_KEY, today)
            .putLong(TODAY_KEY, todaySteps)
            .putLong(LAST_RAW_KEY, rawSteps)
            .apply()
        updateNotification(todaySteps)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun savedTodaySteps(): Long {
        return try {
            preferences.getLong(TODAY_KEY, 0L)
        } catch (_: ClassCastException) {
            preferences.getInt(TODAY_KEY, 0).toLong()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Daily steps",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Shows today's live footstep count"
            setShowBadge(false)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun buildNotification(steps: Long): Notification {
        return buildNotification("$steps steps today")
    }

    private fun buildNotification(message: String): Notification {
        val launchIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val deleteIntent = Intent(
            this,
            StepNotificationActionReceiver::class.java,
        ).apply {
            action = ACTION_DELETE_NOTIFICATION
        }
        val deletePendingIntent = PendingIntent.getBroadcast(
            this,
            1,
            deleteIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(R.drawable.ic_stat_steps)
            .setContentTitle("Gym footsteps")
            .setContentText(message)
            .setContentIntent(pendingIntent)
            .setOngoing(false)
            .setDeleteIntent(deletePendingIntent)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()
    }

    private fun updateNotification(steps: Long) {
        updateNotification("$steps steps today")
    }

    private fun updateNotification(message: String) {
        getSystemService(NotificationManager::class.java)
            .notify(NOTIFICATION_ID, buildNotification(message))
    }

    private fun dateValue(date: Date): String {
        return SimpleDateFormat("yyyy-MM-dd", Locale.US).format(date)
    }

    private fun yesterdayDate(): String {
        val calendar = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, -1)
        }
        return dateValue(calendar.time)
    }
}
