// lib/data/mapper/club_mapper.dart

import '../../domain/entities/club/active_club_context.dart';
import '../../domain/entities/club/club.dart';
import '../../domain/entities/club/club_member.dart';
import '../../domain/entities/club/my_club.dart';
import '../../domain/enums/club_member_status.dart';
import '../../domain/enums/club_role.dart';
import '../dto/club/club_member_response_dto.dart';
import '../dto/club/club_response_dto.dart';
import '../dto/club/my_club_response_dto.dart';
import '../dto/club/switch_club_response_dto.dart';

class ClubMapper {
  static Club toClubEntity(ClubResponseDto dto) {
    return Club(
      id: dto.id,
      name: dto.name,
      code: dto.code,
      description: dto.description,
      avatarUrl: dto.avatarUrl,
      isActive: dto.isActive,
    );
  }

  static MyClub toMyClubEntity(MyClubResponseDto dto) {
    return MyClub(
      clubId: dto.clubId,
      clubName: dto.clubName,
      clubCode: dto.clubCode,
      description: dto.description,
      avatarUrl: dto.avatarUrl,
      role: ClubRole.fromValue(dto.role ?? dto.roleName),
      roleName: dto.roleName,
      roleId: dto.roleId,
      status: ClubMemberStatus.fromValue(dto.status),
      joinedAt: dto.joinedAt != null ? DateTime.tryParse(dto.joinedAt!) : null,
    );
  }

  static ClubMember toClubMemberEntity(ClubMemberResponseDto dto) {
    return ClubMember(
      id: dto.id,
      clubId: dto.clubId,
      userId: dto.userId,
      userName: dto.userName,
      email: dto.email,
      role: ClubRole.fromValue(dto.role ?? dto.roleName),
      roleName: dto.roleName,
      roleId: dto.roleId,
      status: ClubMemberStatus.fromValue(dto.status),
      nickname: dto.nickname,
      joinedAt: dto.joinedAt != null ? DateTime.tryParse(dto.joinedAt!) : null,
    );
  }

  static ActiveClubContext toActiveContextEntity(SwitchClubResponseDto dto) {
    return ActiveClubContext(
      accessToken: dto.accessToken,
      clubId: dto.clubId,
      clubName: dto.clubName,
      role: ClubRole.fromValue(dto.role ?? dto.roleName),
      permissions: dto.permissions,
    );
  }
}
