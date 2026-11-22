import 'dart:convert';

class LedgerDto {
  final Map<String, dynamic> _data;
  LedgerDto.fromJson(Object? value) : _data = object(value);

  static Map<String, dynamic> object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Expected a ledger JSON object');
  }

  String? optionalText(String key) {
    final value = _data[key];
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  String text(String key) =>
      optionalText(key) ?? (throw FormatException('Missing $key'));

  DateTime? optionalDate(String key) =>
      DateTime.tryParse(optionalText(key) ?? '');

  DateTime date(String key) =>
      optionalDate(key) ?? (throw FormatException('Invalid $key'));

  bool flag(String key) {
    final value = _data[key];
    return value == true || value == 'true' || value == '1' || value == 1;
  }

  int integer(String key) {
    final value = int.tryParse(_data[key]?.toString() ?? '');
    if (value == null || value < 0) throw FormatException('Invalid $key');
    return value;
  }

  LedgerDto child(String key) => LedgerDto.fromJson(_data[key]);

  List<LedgerDto> rows(String key) {
    final value = _data[key];
    if (value is! List) throw FormatException('Invalid $key');
    return value.map(LedgerDto.fromJson).toList(growable: false);
  }
}

final _jsonToken = RegExp(
  r'"(?:[^"\\]|\\.)*"|(-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)',
);

Object? decodeLedgerJson(String source) => jsonDecode(
  source.replaceAllMapped(_jsonToken, (match) {
    final number = match.group(1);
    return number == null ? match.group(0)! : jsonEncode(number);
  }),
);
