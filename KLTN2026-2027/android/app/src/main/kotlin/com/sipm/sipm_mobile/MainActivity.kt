package com.sipm.sipm_mobile

import android.content.ActivityNotFoundException
import android.net.Uri
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.sipm.sipm_mobile/sepay_auth")
            .setMethodCallHandler { call, result ->
                if (call.method != "openCustomTab") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val url = (call.arguments as? String)?.let(Uri::parse)
                if (url == null || url.scheme != "https" || url.host != "my.sepay.vn" ||
                    url.path != "/oauth/authorize" || url.userInfo != null ||
                    (url.port != -1 && url.port != 443)
                ) {
                    result.error("invalid_url", null, null)
                    return@setMethodCallHandler
                }
                result.success(openSepayCustomTab(url))
            }
    }

    private fun openSepayCustomTab(url: Uri): Boolean {
        return try {
            val packageName = CustomTabsClient.getPackageName(this, null) ?: return false
            val tab = CustomTabsIntent.Builder().setShowTitle(true).build()
            tab.intent.setPackage(packageName)
            tab.launchUrl(this, url)
            true
        } catch (_: ActivityNotFoundException) {
            false
        } catch (_: SecurityException) {
            false
        }
    }
}
