// lib/domain/entities/club/club_member.dart

import '../../enums/club_member_status.dart';
import '../../enums/club_role.dart';

/// Thành viên trong một Câu lạc bộ
class ClubMember {
  final String id;
  final String clubId;
  final String userId;
  final String? userName;
  final String? email;
  final ClubRole role;
  final String? roleName;
  final String? roleId;
  final ClubMemberStatus status;
  final String? nickname;
  final DateTime? joinedAt;

  const ClubMember({
    required this.id,
    required this.clubId,
    required this.userId,
    this.userName,
    this.email,
    required this.role,
    this.roleName,
    this.roleId,
    required this.status,
    this.nickname,
    this.joinedAt,
  });
}
