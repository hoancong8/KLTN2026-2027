import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/consts/app_log.dart';
import 'package:kltn2026_2027/app/consts/app_router.dart';
import 'package:kltn2026_2027/app/consts/app_theme.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'consts/app_config.dart';
import 'provider.dart';
import 'provider/reputation_provider.dart';
import 'services/push_notification_service.dart';
import 'services/realtime_hub_service.dart';
import 'services/reputation_notification_coordinator.dart';
import 'theme/theme.dart';
import '../ui/screen/notification/notification_vm/notification_vm.dart';

class MyApp extends ConsumerStatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  bool _isInit = false;
  late final GoRouter _router;
  final _reputationNotices = ReputationNotificationCoordinator();
  ReputationNotice? _pendingNotice;
  StreamSubscription<Map<String, dynamic>>? _reputationSubscription;
  StreamSubscription<void>? _reconnectionSubscription;
  DateTime? _lastReputationRefresh;
  Timer? _reputationRefreshTimer;

  @override
  void initState() {
    super.initState();
    _router = generateAppRouter(widget.initialRoute);
    _router.routeInformationProvider.addListener(_openPendingReputationNotice);
    WidgetsBinding.instance.addObserver(this);
    final hub = RealtimeHubService.instance;
    _reputationSubscription = hub.onReputation.listen(_receiveReputationNotice);
    _reconnectionSubscription = hub.onReconnected.listen((_) => _refreshReputation());
    ref.listenManual(authTokenProvider, (before, after) {
      if (before?.userId != after?.userId) {
        _reputationNotices.reset();
        _reputationRefreshTimer?.cancel();
        _lastReputationRefresh = null;
        if (before != null) _pendingNotice = null;
      }
      if (after == null) {
        unawaited(hub.stop());
      } else {
        unawaited(hub.start());
        _openPendingReputationNotice();
      }
    }, fireImmediately: true);
    _initApp();
  }

  Future<void> _initApp() async {
    await _initializeLocalization();
    if (!mounted) return;
    PushNotificationService.instance.initForegroundHandler(
      onReputationNotification: _receiveReputationNotice,
      onNotificationReceived: () {
        ref.read(notificationViewModelProvider.notifier).refresh();
      },
    );
    if (!mounted) return;
    setState(() => _isInit = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PushNotificationService.instance.initSessionNotificationNavigation(
          _router,
          onReputationOpened: _openReputationNotice,
        );
      }
    });
  }

  void _refreshReputation({bool force = false}) {
    if (mounted && ref.read(authTokenProvider) != null) {
      final now = DateTime.now();
      final lastRefresh = _lastReputationRefresh;
      final elapsed = lastRefresh == null ? const Duration(seconds: 30) : now.difference(lastRefresh);
      if (!force && elapsed < const Duration(seconds: 30)) {
        _reputationRefreshTimer ??= Timer(const Duration(seconds: 30) - elapsed, () {
          _reputationRefreshTimer = null;
          _refreshReputation();
        });
        return;
      }
      _reputationRefreshTimer?.cancel();
      _reputationRefreshTimer = null;
      _lastReputationRefresh = now;
      ref.read(reputationRevisionProvider.notifier).state++;
    }
  }

  bool _receiveReputationNotice(Map<String, dynamic> data) {
    final notice = ReputationNotice.fromData(data);
    if (notice == null) return false;
    if (!mounted) return true;
    final userId = ref.read(authTokenProvider)?.userId;
    if (userId == null || !_reputationNotices.claim(notice, userId)) return true;
    _refreshReputation(force: true);
    ref.read(notificationViewModelProvider.notifier).refresh();
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(notice.isInvitation ? context.l10n.reputation_invitations : context.l10n.reputation_updated),
        action: SnackBarAction(
          label: context.l10n.reputation_title,
          onPressed: () {
            if (mounted && ref.read(authTokenProvider)?.userId == userId) {
              _router.push(notice.route);
            }
          },
        ),
      ));
    }
    return true;
  }

  bool _openReputationNotice(Map<String, dynamic> data) {
    final notice = ReputationNotice.fromData(data);
    if (notice == null) return false;
    _pendingNotice = notice;
    _openPendingReputationNotice();
    return true;
  }

  void _openPendingReputationNotice() {
    final notice = _pendingNotice;
    final userId = mounted ? ref.read(authTokenProvider)?.userId : null;
    if (notice == null || userId == null || !_isInit ||
        _router.routeInformationProvider.value.uri.path == AppConfig.loginPath) {
      return;
    }
    _pendingNotice = null;
    if (notice.belongsTo(userId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ref.read(authTokenProvider)?.userId == userId) {
          _refreshReputation(force: true);
          _router.push(notice.route);
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && ref.read(authTokenProvider) != null) {
      unawaited(RealtimeHubService.instance.start());
      _refreshReputation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.routeInformationProvider.removeListener(_openPendingReputationNotice);
    _reputationSubscription?.cancel();
    _reconnectionSubscription?.cancel();
    _reputationRefreshTimer?.cancel();
    PushNotificationService.instance.dispose();
    unawaited(RealtimeHubService.instance.stop());
    _router.dispose();
    super.dispose();
  }

  Future<void> _initializeLocalization() async {
    try {
      await ref.read(localizationProvider.notifier).init();
    } catch (e) {
      AppLog.info('[MyApp] Failed to initialize localization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final locale = ref.watch(localizationProvider);

    // Remove the native splash screen now that first frame is ready
    FlutterNativeSplash.remove();

    return MaterialApp.router(
      title: 'KLTN2026 - Badminton Club',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
