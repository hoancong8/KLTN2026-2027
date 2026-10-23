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
  final String memberType;
  final DateTime? monthlyExpiryDate;

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
    this.memberType = 'MONTHLY',
    this.monthlyExpiryDate,
  });

  bool get isMonthlyMember => memberType.toUpperCase() == 'MONTHLY';

  ClubMember copyWith({
    String? id,
    String? clubId,
    String? userId,
    String? userName,
    String? email,
    ClubRole? role,
    String? roleName,
    String? roleId,
    ClubMemberStatus? status,
    String? nickname,
    DateTime? joinedAt,
    String? memberType,
    DateTime? monthlyExpiryDate,
  }) {
    return ClubMember(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      role: role ?? this.role,
      roleName: roleName ?? this.roleName,
      roleId: roleId ?? this.roleId,
      status: status ?? this.status,
      nickname: nickname ?? this.nickname,
      joinedAt: joinedAt ?? this.joinedAt,
      memberType: memberType ?? this.memberType,
      monthlyExpiryDate: monthlyExpiryDate ?? this.monthlyExpiryDate,
    );
  }
}
