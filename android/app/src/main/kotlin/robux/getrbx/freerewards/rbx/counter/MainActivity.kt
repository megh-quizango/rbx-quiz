package robux.getrbx.freerewards.rbx.counter

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.browser.customtabs.CustomTabsCallback
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.customtabs.CustomTabsServiceConnection
import androidx.browser.customtabs.CustomTabsSession
import android.content.ComponentName
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val shareChannel = "rbx_quiz/share"
  private val customTabsChannel = "rbx_quiz/custom_tabs"
  private val customTabsEventsChannel = "rbx_quiz/custom_tabs_events"
  private var trackedCustomTabs: TrackedCustomTabs? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shareChannel)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "shareText" -> {
            val text = (call.argument<String>("text") ?: "").trim()
            if (text.isEmpty()) {
              result.success(null)
              return@setMethodCallHandler
            }
            try {
              runOnUiThread {
                val shareIntent = Intent(Intent.ACTION_SEND).apply {
                  type = "text/plain"
                  putExtra(Intent.EXTRA_TEXT, text)
                  addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(Intent.createChooser(shareIntent, "Share"))
              }
            } catch (_: Exception) {
              // ignore
            }
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }

    trackedCustomTabs = TrackedCustomTabs(this)

    EventChannel(flutterEngine.dartExecutor.binaryMessenger, customTabsEventsChannel)
      .setStreamHandler(trackedCustomTabs)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, customTabsChannel)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "warmup" -> {
            trackedCustomTabs?.warmup()
            result.success(null)
          }
          "open" -> {
            val url = (call.argument<String>("url") ?: "").trim()
            if (url.isNotEmpty()) trackedCustomTabs?.open(url)
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }

  override fun onDestroy() {
    trackedCustomTabs?.dispose()
    trackedCustomTabs = null
    super.onDestroy()
  }
}

private class TrackedCustomTabs(private val activity: FlutterActivity) : EventChannel.StreamHandler {
  private val fallbackPackage = "com.android.chrome"
  private var customTabsPackage: String? = null
  private var eventSink: EventChannel.EventSink? = null

  private var client: CustomTabsClient? = null
  private var session: CustomTabsSession? = null
  private var connection: CustomTabsServiceConnection? = null

  private val handler = Handler(Looper.getMainLooper())
  private var pendingUrl: String? = null
  private var pendingFallbackLaunch: Runnable? = null

  private val callback = object : CustomTabsCallback() {
    override fun onNavigationEvent(navigationEvent: Int, extras: Bundle?) {
      when (navigationEvent) {
        CustomTabsCallback.TAB_SHOWN -> sendEvent("shown")
        CustomTabsCallback.TAB_HIDDEN -> sendEvent("hidden")
      }
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }

  private fun sendEvent(event: String) {
    try {
      activity.runOnUiThread {
        eventSink?.success(mapOf("event" to event, "ts" to System.currentTimeMillis()))
      }
    } catch (_: Exception) {
      // ignore
    }
  }

  fun warmup() {
    if (connection != null) return

    customTabsPackage =
      try {
        CustomTabsClient.getPackageName(activity, null) ?: fallbackPackage
      } catch (_: Exception) {
        fallbackPackage
      }

    connection =
      object : CustomTabsServiceConnection() {
        override fun onCustomTabsServiceConnected(name: ComponentName, client: CustomTabsClient) {
          this@TrackedCustomTabs.client = client
          try {
            client.warmup(0L)
          } catch (_: Exception) {
            // ignore
          }
          session = client.newSession(callback)

          val url = pendingUrl
          if (!url.isNullOrBlank()) {
            pendingUrl = null
            pendingFallbackLaunch?.let { handler.removeCallbacks(it) }
            pendingFallbackLaunch = null
            activity.runOnUiThread { launchNow(url, session) }
          }
        }

        override fun onServiceDisconnected(name: ComponentName) {
          client = null
          session = null
        }
      }

    try {
      val pkg = customTabsPackage ?: fallbackPackage
      CustomTabsClient.bindCustomTabsService(activity, pkg, connection as CustomTabsServiceConnection)
    } catch (_: Exception) {
      // ignore
    }
  }

  fun open(url: String) {
    warmup()

    val s = session
    if (s != null) {
      pendingUrl = null
      try {
        s.mayLaunchUrl(Uri.parse(url), null, null)
      } catch (_: Exception) {
        // ignore
      }
      launchNow(url, s)
      return
    }

    // Service connection is async; defer launch briefly so the first open uses
    // a session and we can receive TAB_SHOWN/TAB_HIDDEN callbacks.
    pendingUrl = url
    if (pendingFallbackLaunch == null) {
      pendingFallbackLaunch =
        Runnable {
          val u = pendingUrl
          pendingUrl = null
          pendingFallbackLaunch = null
          if (!u.isNullOrBlank()) launchNow(u, null)
        }
      handler.postDelayed(pendingFallbackLaunch!!, 1200)
    }
  }

  private fun launchNow(url: String, session: CustomTabsSession?) {
    val builder = if (session != null) CustomTabsIntent.Builder(session) else CustomTabsIntent.Builder()
    val intent =
      builder
        .setShowTitle(true)
        .setUrlBarHidingEnabled(true)
        .setShareState(CustomTabsIntent.SHARE_STATE_OFF)
        .setToolbarColor(0xFF201402.toInt())
        .setNavigationBarColor(0xFF0B0700.toInt())
        .build()

    try {
      val pkg = customTabsPackage
      if (!pkg.isNullOrBlank()) {
        intent.intent.setPackage(pkg)
      }
      intent.launchUrl(activity, Uri.parse(url))
    } catch (_: Exception) {
      // ignore
    }
  }

  fun dispose() {
    try {
      pendingFallbackLaunch?.let { handler.removeCallbacks(it) }
      pendingFallbackLaunch = null
      pendingUrl = null
      val conn = connection
      if (conn != null) activity.unbindService(conn)
    } catch (_: Exception) {
      // ignore
    } finally {
      connection = null
      client = null
      session = null
      eventSink = null
    }
  }
}
