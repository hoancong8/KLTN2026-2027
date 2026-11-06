class NotificationDto {
  final String id;
  final String title;
  final String content;
  final String type;
  final String? referenceType;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationDto({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.referenceType,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: _parseString(json['id']),
      title: _parseString(json['title']),
      content: _parseString(json['content']),
      type: _parseString(json['type']),
      referenceType: json['referenceType'] != null ? _parseString(json['referenceType']) : null,
      referenceId: json['referenceId'] != null ? _parseString(json['referenceId']) : null,
      isRead: _parseBool(json['isRead']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final str = value.toString().toLowerCase().trim();
    return str == 'true' || str == '1';
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}

