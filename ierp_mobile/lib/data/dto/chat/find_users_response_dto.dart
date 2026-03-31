class FindUsersResponseDto {
  final FindUsersResultDto result;

  FindUsersResponseDto({required this.result});

  factory FindUsersResponseDto.fromJson(Map<String, dynamic> json) {
    return FindUsersResponseDto(
      result: FindUsersResultDto.fromJson(json['result']),
    );
  }
}

class FindUsersResultDto {
  final int totalCount;
  final List<UserLookupDto> items;

  FindUsersResultDto({required this.totalCount, required this.items});

  factory FindUsersResultDto.fromJson(Map<String, dynamic> json) {
    return FindUsersResultDto(
      totalCount: json['totalCount'] ?? 0,
      items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => UserLookupDto.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class UserLookupDto {
  final String name;
  final String value;

  UserLookupDto({required this.name, required this.value});

  factory UserLookupDto.fromJson(Map<String, dynamic> json) {
    return UserLookupDto(name: json['name'] ?? '', value: json['value'] ?? '');
  }
}