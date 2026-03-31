import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_router.dart';
import 'package:sipm_mobile/app/consts/app_theme.dart';
import 'package:sipm_mobile/app/provider.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

class MyApp extends ConsumerStatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotification();
  }

  Future<void> _initializeNotification() async {
    try {
      await ref.read(initializeNotificationUseCaseProvider).execute();
    } catch (e) {
      print('[MyApp] Failed to initialize notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate router using the determined initialRoute
    final router = generateAppRouter(widget.initialRoute);

    // Remove the native splash screen now that first frame is ready
    FlutterNativeSplash.remove();

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
