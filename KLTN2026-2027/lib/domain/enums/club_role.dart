// lib/domain/enums/club_role.dart

/// Vai trò của người dùng trong một Câu lạc bộ cụ thể.
/// Một tài khoản có thể có nhiều vai trò độc lập ở các câu lạc bộ khác nhau.
enum ClubRole {
  member(1, 'Thành viên'),
  treasurer(2, 'Thủ quỹ'),
  host(3, 'Chủ câu lạc bộ (Host)'),
  guest(4, 'Khách vãng lai');

  final int value;
  final String displayName;

  const ClubRole(this.value, this.displayName);

  static ClubRole fromValue(dynamic val) {
    if (val is int) {
      return ClubRole.values.firstWhere(
        (e) => e.value == val,
        orElse: () => ClubRole.member,
      );
    }
    if (val is String) {
      final parsed = int.tryParse(val);
      if (parsed != null) {
        return fromValue(parsed);
      }
      final lower = val.trim().toLowerCase();
      return ClubRole.values.firstWhere(
        (e) => e.name.toLowerCase() == lower,
        orElse: () => ClubRole.member,
      );
    }
    return ClubRole.member;
  }

  bool get isHost => this == ClubRole.host;
  bool get isTreasurer => this == ClubRole.treasurer;
  bool get isMember => this == ClubRole.member;
  bool get isGuest => this == ClubRole.guest;
}
