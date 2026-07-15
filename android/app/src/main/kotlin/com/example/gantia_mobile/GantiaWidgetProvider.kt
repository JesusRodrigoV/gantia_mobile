package com.example.gantia_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.example.gantia_mobile.R

class GantiaWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Widget added
    }

    override fun onDisabled(context: Context) {
        // Last widget removed
    }

    companion object {
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(
                "home_widget_plugin_shared_preferences",
                Context.MODE_PRIVATE
            )

            val status = prefs.getString("status", "Sin conexión") ?: "Sin conexión"
            val lastAction = prefs.getString("lastAction", "—") ?: "—"
            val flexIndex = prefs.getString("flexIndex", "0") ?: "0"
            val flexMiddle = prefs.getString("flexMiddle", "0") ?: "0"

            val views = RemoteViews(context.packageName, R.layout.gantia_widget_layout)
            views.setTextViewText(R.id.tv_status, status)
            views.setTextViewText(R.id.tv_last_action, "Última acción: $lastAction")
            views.setTextViewText(R.id.tv_flex, "I:$flexIndex M:$flexMiddle")

            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(android.R.id.background, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
