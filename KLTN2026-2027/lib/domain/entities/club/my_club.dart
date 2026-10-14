// lib/domain/entities/club/my_club.dart

import '../../enums/club_member_status.dart';
import '../../enums/club_role.dart';

/// Đại diện cho Câu lạc bộ mà tài khoản người dùng đang tham gia
/// kèm theo vai trò và trạng thái độc lập của họ trong CLB đó.
class MyClub {
  final String clubId;
  final String clubName;
  final String clubCode;
  final String? description;
  final String? avatarUrl;
  final ClubRole role;
  final ClubMemberStatus status;
  final DateTime? joinedAt;

  const MyClub({
    required this.clubId,
    required this.clubName,
    required this.clubCode,
    this.description,
    this.avatarUrl,
    required this.role,
    required this.status,
    this.joinedAt,
  });
}
