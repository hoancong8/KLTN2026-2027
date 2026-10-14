// lib/domain/enums/club_member_status.dart

/// Trạng thái thành viên trong Câu lạc bộ
enum ClubMemberStatus {
  active(1, 'Đang hoạt động'),
  pending(2, 'Chờ duyệt'),
  blocked(3, 'Đã khóa');

  final int value;
  final String displayName;

  const ClubMemberStatus(this.value, this.displayName);

  static ClubMemberStatus fromValue(dynamic val) {
    if (val is int) {
      return ClubMemberStatus.values.firstWhere(
        (e) => e.value == val,
        orElse: () => ClubMemberStatus.active,
      );
    }
    if (val is String) {
      final parsed = int.tryParse(val);
      if (parsed != null) {
        return fromValue(parsed);
      }
      final lower = val.trim().toLowerCase();
      return ClubMemberStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == lower,
        orElse: () => ClubMemberStatus.active,
      );
    }
    return ClubMemberStatus.active;
  }
}
