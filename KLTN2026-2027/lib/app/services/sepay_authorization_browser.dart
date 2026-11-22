import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../consts/app_config.dart';

enum SepayBrowserOutcome { opened, completed, cancelled, failed }

typedef SepayBrowserResult = ({SepayBrowserOutcome outcome, Uri? callback});

const _sepayBrowserChannel = MethodChannel('com.sipm.sipm_mobile/sepay_auth');

bool isSepayAuthorizationUrl(Uri uri) =>
    uri.scheme == 'https' &&
    uri.host == 'my.sepay.vn' &&
    uri.port == 443 &&
    uri.userInfo.isEmpty &&
    uri.path == '/oauth/authorize';

bool isSepayAppCallback(Uri uri, String clubId) =>
    uri.scheme == 'legendsbadminton' &&
    uri.host.isEmpty &&
    uri.path == AppConfig.clubSepayScreenPath(clubId);

Future<SepayBrowserResult> openSepayAuthorization(Uri uri) async {
  if (!isSepayAuthorizationUrl(uri)) {
    return (outcome: SepayBrowserOutcome.failed, callback: null);
  }

  try {
    if (!kIsWeb) {
      final result = await _openSystemAuthorization(uri);
      if (result != null) return result;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    return (
      outcome: opened ? SepayBrowserOutcome.opened : SepayBrowserOutcome.failed,
      callback: null,
    );
  } on PlatformException {
    return (outcome: SepayBrowserOutcome.failed, callback: null);
  } on MissingPluginException {
    return (outcome: SepayBrowserOutcome.failed, callback: null);
  }
}

Future<SepayBrowserResult?> _openSystemAuthorization(Uri uri) async {
  try {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final opened = await _sepayBrowserChannel.invokeMethod<bool>(
          'openCustomTab',
          uri.toString(),
        );
        return opened == true
            ? (outcome: SepayBrowserOutcome.opened, callback: null)
            : null;
      case TargetPlatform.iOS:
        final callback = await _sepayBrowserChannel.invokeMethod<String>(
          'authenticate',
          uri.toString(),
        );
        if (callback == null) {
          return (outcome: SepayBrowserOutcome.cancelled, callback: null);
        }
        final parsed = Uri.tryParse(callback);
        return (
          outcome: parsed == null
              ? SepayBrowserOutcome.failed
              : SepayBrowserOutcome.completed,
          callback: parsed,
        );
      default:
        return null;
    }
  } on MissingPluginException {
    return null;
  } on PlatformException catch (error) {
    if (error.code == 'unavailable') return null;
    rethrow;
  }
}
