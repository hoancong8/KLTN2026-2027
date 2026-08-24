class PagedResultDto<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PagedResultDto({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PagedResultDto.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) itemFromJson,
  ) {
    final rawItems = json['items'];
    final items = (rawItems is List)
        ? rawItems.map((e) => itemFromJson(e)).toList()
        : <T>[];

    return PagedResultDto<T>(
      items: items,
      totalCount: _parseInt(json['totalCount']),
      pageNumber: _parseInt(json['pageNumber'], defaultValue: 1),
      pageSize: _parseInt(json['pageSize'], defaultValue: 10),
      totalPages: _parseInt(json['totalPages']),
      hasPreviousPage: _parseBool(json['hasPreviousPage']),
      hasNextPage: _parseBool(json['hasNextPage']),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
