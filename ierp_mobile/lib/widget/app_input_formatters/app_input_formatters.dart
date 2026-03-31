import 'package:flutter/services.dart';

class AppInputFormatters {
  static final numbersOnly = FilteringTextInputFormatter.digitsOnly;

  static final lettersOnly = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-ZÀ-ỹ\s]'),
  );

  static final noSpecialCharacters = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z0-9À-ỹ\s]'),
  );

  static TextInputFormatter phoneFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(' ', '');
      if (text.isEmpty) return newValue;

      final buffer = StringBuffer();
      for (int i = 0; i < text.length && i < 10; i++) {
        if (i == 4 || i == 7) buffer.write(' ');
        buffer.write(text[i]);
      }

      final string = buffer.toString();
      return TextEditingValue(
        text: string,
        selection: TextSelection.collapsed(offset: string.length),
      );
    });
  }

  static TextInputFormatter priceFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;

      final value = int.tryParse(newValue.text.replaceAll(',', ''));
      if (value == null) return oldValue;

      final formatted = value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  static LengthLimitingTextInputFormatter maxLength(int length) {
    return LengthLimitingTextInputFormatter(length);
  }
}