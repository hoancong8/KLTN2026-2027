import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:sipm_mobile/app/services/localization_service.dart';
final localizationServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService();
});

final localizationProvider = StateNotifierProvider<LocalizationNotifier, String>((ref) {
  final service = ref.watch(localizationServiceProvider);
  return LocalizationNotifier(service, 'vi');
});

class LocalizationNotifier extends StateNotifier<String> {
  final LocalizationService _service;

  LocalizationNotifier(this._service, String initialLocale) : super(initialLocale);

  /// Call this when starting the application
  Future<void> init() async {
    await _service.init();
    state = _service.currentLocale;
  }

  Future<void> changeLocale(String locale) async {
    if (state == locale) return;
    await _service.load(locale);
    state = locale;
  }

  String translate(String key, {Map<String, String>? args}) {
    return _service.translate(key, args: args);
  }
}

/// Helper extension to use ref.l('key')
extension LocalizationRefExtension on WidgetRef {
  String l(String key, {Map<String, String>? args}) {
    watch(localizationProvider); // Watch state to trigger rebuilds
    return watch(localizationProvider.notifier).translate(key, args: args);
  }
}