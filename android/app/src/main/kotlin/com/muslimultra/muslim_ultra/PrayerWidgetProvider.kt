package com.muslimultra.muslim_ultra

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class PrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_PRAYER_NAME = "flutter.widget_next_prayer_name"
        private const val KEY_PRAYER_TIME = "flutter.widget_next_prayer_time"
        private const val KEY_LAST_UPDATED = "flutter.widget_last_updated"
        private const val MAX_STALE_MS = 24 * 60 * 60 * 1000L // 24 hours

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, PrayerWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (id in allWidgetIds) {
                updateAppWidget(context, appWidgetManager, id)
            }
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val lastUpdated = prefs.getLong(KEY_LAST_UPDATED, 0L)
            val now = System.currentTimeMillis()
            val isStale = (now - lastUpdated) > MAX_STALE_MS || lastUpdated == 0L

            val rawPrayerName = prefs.getString(KEY_PRAYER_NAME, null)
            val rawPrayerTime = prefs.getString(KEY_PRAYER_TIME, null)

            val prayerName = if (!isStale && !rawPrayerName.isNullOrEmpty()) {
                rawPrayerName
            } else {
                "Next Prayer"
            }

            val prayerTime = if (!isStale && !rawPrayerTime.isNullOrEmpty()) {
                rawPrayerTime
            } else {
                "Open Muslim Ultra"
            }

            val views = RemoteViews(context.packageName, R.layout.widget_prayer).apply {
                setTextViewText(R.id.tv_prayer_name, prayerName)
                setTextViewText(R.id.tv_prayer_time, prayerTime)

                // Tapping anywhere on the widget launches the app
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_prayer_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
