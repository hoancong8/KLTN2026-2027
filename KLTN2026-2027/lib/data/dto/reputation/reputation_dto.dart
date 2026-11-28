class ReputationDto {
  const ReputationDto._(this._fields);

  factory ReputationDto.fromJson(Object? json) {
    if (json is! Map) throw const FormatException('Expected reputation object');
    return ReputationDto._(json);
  }

  final Map<dynamic, dynamic> _fields;

  String? string(String key) => _parseString(_fields[key]);
  int? integer(String key) => _parseInt(_fields[key]);
  double? number(String key) {
    final value = _fields[key];
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    return parsed != null && parsed.isFinite ? parsed : null;
  }

  DateTime? date(String key) => DateTime.tryParse(string(key) ?? '')?.toUtc();

  ReputationDto? object(String key) {
    final value = _fields[key];
    return value is Map ? ReputationDto.fromJson(value) : null;
  }

  List<ReputationDto> list(String key) {
    final value = _fields[key];
    return value is List
        ? value.whereType<Map>().map(ReputationDto.fromJson).toList(growable: false)
        : const [];
  }

  static String? _parseString(Object? value) => value is String && value.trim().isNotEmpty ? value : null;

  static int? _parseInt(Object? value) => value is int ? value : int.tryParse('$value');
}
