// lib/data/dto/club/create_join_request_dto.dart

class CreateJoinRequestDto {
  final String? introduction;

  CreateJoinRequestDto({this.introduction});

  Map<String, dynamic> toJson() => {
    if (introduction != null) 'introduction': introduction,
  };
}
