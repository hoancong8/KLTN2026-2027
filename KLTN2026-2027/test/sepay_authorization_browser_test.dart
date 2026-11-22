import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/services/sepay_authorization_browser.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  const native = MethodChannel('com.sipm.sipm_mobile/sepay_auth');
  const browser = MethodChannel('plugins.flutter.io/url_launcher');
  final url = Uri.parse('https://my.sepay.vn/oauth/authorize?state=test');
  var browserCalls = 0;

  setUp(() {
    browserCalls = 0;
    messenger.setMockMethodCallHandler(browser, (call) async {
      expect(call.method, 'launch');
      expect(call.arguments['url'], url.toString());
      expect(call.arguments['useSafariVC'], isFalse);
      expect(call.arguments['useWebView'], isFalse);
      browserCalls++;
      return true;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(native, null);
    messenger.setMockMethodCallHandler(browser, null);
  });

  test('Android opens the supported Custom Tab directly', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    messenger.setMockMethodCallHandler(native, (call) async {
      expect(call.method, 'openCustomTab');
      expect(call.arguments, url.toString());
      return true;
    });

    expect(
      (await openSepayAuthorization(url)).outcome,
      SepayBrowserOutcome.opened,
    );
    expect(browserCalls, 0);
  });

  test(
    'Android falls back to the browser when Custom Tabs are unavailable',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      messenger.setMockMethodCallHandler(native, (_) async => false);

      expect(
        (await openSepayAuthorization(url)).outcome,
        SepayBrowserOutcome.opened,
      );
      expect(browserCalls, 1);
    },
  );

  test('iOS falls back if the system session cannot open', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(native, (_) async {
      throw PlatformException(code: 'unavailable');
    });

    expect(
      (await openSepayAuthorization(url)).outcome,
      SepayBrowserOutcome.opened,
    );
    expect(browserCalls, 1);
  });

  test('iOS cancellation does not reopen the browser', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(native, (call) async {
      expect(call.method, 'authenticate');
      return null;
    });

    expect(
      (await openSepayAuthorization(url)).outcome,
      SepayBrowserOutcome.cancelled,
    );
    expect(browserCalls, 0);
  });

  test(
    'iOS returns the callback and only the original club path is accepted',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      messenger.setMockMethodCallHandler(
        native,
        (_) async =>
            'legendsbadminton:///club/current/sepay?sepay=authorized&ticket=one-time',
      );

      final result = await openSepayAuthorization(url);
      expect(result.outcome, SepayBrowserOutcome.completed);
      expect(isSepayAppCallback(result.callback!, 'current'), isTrue);
      expect(isSepayAppCallback(result.callback!, 'different'), isFalse);
      expect(browserCalls, 0);
    },
  );

  test(
    'an authorization URL from another host cannot open a browser',
    () async {
      final result = await openSepayAuthorization(
        Uri.parse('https://example.com/oauth/authorize'),
      );
      expect(result.outcome, SepayBrowserOutcome.failed);
      expect(browserCalls, 0);
    },
  );
}
