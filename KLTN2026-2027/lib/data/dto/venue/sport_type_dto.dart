class SportTypeDto {
  final String id;
  final String name;

  SportTypeDto({
    required this.id,
    required this.name,
  });

  factory SportTypeDto.fromJson(dynamic json) {
    if (json is! Map) {
      return SportTypeDto(id: '', name: '');
    }
    return SportTypeDto(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
