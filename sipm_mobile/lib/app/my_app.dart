import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_router.dart';
import 'package:sipm_mobile/app/consts/app_theme.dart';
import 'package:sipm_mobile/app/provider.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sipm_mobile/app/provider/localization_provider.dart';
import 'package:sipm_mobile/app/l10n_gen/app_localizations.dart';

class MyApp extends ConsumerStatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _initializeLocalization();
    await _initializeNotification();
    if (mounted) setState(() => _isInit = true);
  }

  Future<void> _initializeNotification() async {
    try {
      await ref.read(initializeNotificationUseCaseProvider).execute();
    } catch (e) {
      print('[MyApp] Failed to initialize notification: $e');
    }
  }

  Future<void> _initializeLocalization() async {
    try {
      await ref.read(localizationProvider.notifier).init();
    } catch (e) {
      print('[MyApp] Failed to initialize localization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Generate router using the determined initialRoute
    final router = generateAppRouter(widget.initialRoute);
    final locale = ref.watch(localizationProvider);

    // Remove the native splash screen now that first frame is ready
    FlutterNativeSplash.remove();

    return MaterialApp.router(
      routerConfig: router,
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
