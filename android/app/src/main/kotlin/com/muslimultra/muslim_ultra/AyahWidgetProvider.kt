package com.muslimultra.muslim_ultra

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class AyahWidgetProvider : AppWidgetProvider() {

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
        private const val KEY_AYAH_ARABIC = "flutter.widget_daily_ayah_arabic"
        private const val KEY_AYAH_TRANSLATION = "flutter.widget_daily_ayah_translation"
        private const val KEY_AYAH_REF = "flutter.widget_daily_ayah_ref"
        private const val KEY_LAST_UPDATED = "flutter.widget_last_updated"
        private const val MAX_STALE_MS = 24 * 60 * 60 * 1000L // 24 hours

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, AyahWidgetProvider::class.java)
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

            val rawArabic = prefs.getString(KEY_AYAH_ARABIC, null)
            val rawTranslation = prefs.getString(KEY_AYAH_TRANSLATION, null)
            val rawRef = prefs.getString(KEY_AYAH_REF, null)

            val ayahArabic = if (!isStale && !rawArabic.isNullOrEmpty()) {
                rawArabic
            } else {
                "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
            }

            val ayahTranslation = if (!isStale && !rawTranslation.isNullOrEmpty()) {
                rawTranslation
            } else {
                "Open Muslim Ultra"
            }

            val ayahRef = if (!isStale && !rawRef.isNullOrEmpty()) {
                rawRef
            } else {
                "Muslim Ultra"
            }

            val views = RemoteViews(context.packageName, R.layout.widget_ayah).apply {
                setTextViewText(R.id.tv_ayah_arabic, ayahArabic)
                setTextViewText(R.id.tv_ayah_translation, ayahTranslation)
                setTextViewText(R.id.tv_ayah_ref, ayahRef)

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
                setOnClickPendingIntent(R.id.widget_ayah_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
