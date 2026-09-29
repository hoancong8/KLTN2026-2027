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
    dynamic rawJson,
    T Function(dynamic) itemFromJson,
  ) {
    if (rawJson is! Map) {
      return PagedResultDto<T>(
        items: [],
        totalCount: 0,
        pageNumber: 1,
        pageSize: 10,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    final rawItems = rawJson['items'];
    final items = (rawItems is List)
        ? rawItems.map((e) => itemFromJson(e)).toList()
        : <T>[];

    return PagedResultDto<T>(
      items: items,
      totalCount: _parseInt(rawJson['totalCount']),
      pageNumber: _parseInt(rawJson['pageNumber'], defaultValue: 1),
      pageSize: _parseInt(rawJson['pageSize'], defaultValue: 10),
      totalPages: _parseInt(rawJson['totalPages']),
      hasPreviousPage: _parseBool(rawJson['hasPreviousPage']),
      hasNextPage: _parseBool(rawJson['hasNextPage']),
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
