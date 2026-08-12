import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltn2026_2027/app/consts/storage_keys.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';

final localizationProvider = StateNotifierProvider<LocalizationNotifier, Locale>((ref) {
  return LocalizationNotifier();
});

class LocalizationNotifier extends StateNotifier<Locale> {
  AppLocalizations? _l10n;

  LocalizationNotifier() : super(const Locale('vi'));

  AppLocalizations? get l10n => _l10n;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(StorageKeys.languageCode) ?? 'vi';
    state = Locale(langCode);
    _l10n = lookupAppLocalizations(state);
  }

  Future<void> changeLocale(String langCode) async {
    if (state.languageCode == langCode) return;
    
    final newLocale = Locale(langCode);
    state = newLocale;
    _l10n = lookupAppLocalizations(newLocale);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.languageCode, langCode);
  }
}

extension LocalizationRefExtension on WidgetRef {
  /// New type-safe way: ref.l10n.login
  AppLocalizations get l10n {
    watch(localizationProvider);
    final notifier = watch(localizationProvider.notifier);
    return notifier.l10n ?? lookupAppLocalizations(watch(localizationProvider));
  }
}

extension LocalizationBuildContextExtension on BuildContext {
  /// Shortcut for AppLocalizations.of(context)
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
