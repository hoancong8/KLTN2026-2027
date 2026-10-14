// lib/data/dto/club/approve_join_request_dto.dart

class ApproveJoinRequestDto {
  final String? roleId;
  final String? memberType;

  ApproveJoinRequestDto({this.roleId, this.memberType});

  Map<String, dynamic> toJson() => {
    if (roleId != null) 'roleId': roleId,
    if (memberType != null) 'memberType': memberType,
  };
}
