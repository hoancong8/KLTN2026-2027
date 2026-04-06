import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import '../consts/storage_keys.dart';

class LocalizationService {
  Map<String, String> _localizedValues = {};
  String _currentLocale = 'vi';

  String get currentLocale => _currentLocale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString(StorageKeys.languageCode) ?? 'vi';
    await load(_currentLocale);
  }

  Future<void> load(String locale) async {
    _currentLocale = locale;
    String xmlString;
    try {
      final fileName = locale == 'vi' ? 'AbpZero-vi.xml' : 'AbpZero.xml';
      xmlString = await rootBundle.loadString('assets/localization/$fileName');

      final document = XmlDocument.parse(xmlString);
      final texts = document.findAllElements('text');

      _localizedValues = {
        for (var element in texts)
          element.getAttribute('name') ?? '': element.getAttribute('value') ?? ''
      };

      // Persist choice
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.languageCode, locale);
    } catch (e) {
      // Fallback or log error
      print('Error loading localization ($locale): $e');
    }
  }

  String translate(String key, {Map<String, String>? args}) {
    String value = _localizedValues[key] ?? key;
    if (args != null && args.isNotEmpty) {
      args.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }
}