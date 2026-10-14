// lib/domain/entities/club/active_club_context.dart

import '../../enums/club_role.dart';

/// Ngữ cảnh Câu lạc bộ đang hoạt động hiện tại (Active Context)
/// Được trả về sau khi chuyển đổi ngữ cảnh thành công qua /switch-context.
class ActiveClubContext {
  final String accessToken;
  final String clubId;
  final String clubName;
  final ClubRole role;
  final List<String> permissions;

  const ActiveClubContext({
    required this.accessToken,
    required this.clubId,
    required this.clubName,
    required this.role,
    required this.permissions,
  });

  ActiveClubContext copyWith({
    String? accessToken,
    String? clubId,
    String? clubName,
    ClubRole? role,
    List<String>? permissions,
  }) {
    return ActiveClubContext(
      accessToken: accessToken ?? this.accessToken,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
    );
  }
}
