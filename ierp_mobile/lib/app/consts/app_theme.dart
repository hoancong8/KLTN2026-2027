import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
  );

  static final dark = ThemeData.dark(useMaterial3: true);
}
