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
      permissions: dto.permissions,
    );
  }

  static ClubMember toClubMemberEntity(ClubMemberResponseDto dto) {
    final parsedRole = ClubRole.fromValue(dto.role ?? dto.roleName);
    final rawMemberType = dto.memberType?.toUpperCase().trim();
    final effectiveMemberType = (rawMemberType == 'DAILY' || parsedRole == ClubRole.guest)
        ? 'DAILY'
        : 'MONTHLY';

    return ClubMember(
      id: dto.id,
      clubId: dto.clubId,
      userId: dto.userId,
      userName: dto.userName,
      email: dto.email,
      role: parsedRole,
      roleName: dto.roleName,
      roleId: dto.roleId,
      status: ClubMemberStatus.fromValue(dto.status),
      nickname: dto.nickname,
      joinedAt: dto.joinedAt != null ? DateTime.tryParse(dto.joinedAt!) : null,
      memberType: effectiveMemberType,
      monthlyExpiryDate: dto.monthlyExpiryDate != null ? DateTime.tryParse(dto.monthlyExpiryDate!) : null,
    );
  }

  static ActiveClubContext fromMyClub(MyClub club) {
    return ActiveClubContext(
      clubId: club.clubId,
      clubName: club.clubName,
      role: club.role,
      roleName: club.roleName,
      roleId: club.roleId,
      permissions: club.permissions,
    );
  }

  static ActiveClubContext toActiveContextEntity(SwitchClubResponseDto dto) {
    return ActiveClubContext(
      accessToken: dto.accessToken,
      clubId: dto.clubId,
      clubName: dto.clubName,
      role: ClubRole.fromValue(dto.role ?? dto.roleName),
      roleName: dto.roleName,
      roleId: dto.roleId,
      permissions: dto.permissions,
    );
  }
}
