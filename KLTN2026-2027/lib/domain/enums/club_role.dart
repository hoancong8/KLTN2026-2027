// lib/domain/enums/club_role.dart

/// Vai trò của người dùng trong một Câu lạc bộ cụ thể.
/// Một tài khoản có thể có nhiều vai trò độc lập ở các câu lạc bộ khác nhau.
enum ClubRole {
  member(1, 'Thành viên'),
  treasurer(2, 'Thủ quỹ'),
  host(3, 'Chủ câu lạc bộ (Host)'),
  guest(4, 'Khách vãng lai'),
  deputy(5, 'Phó nhóm');

  final int value;
  final String displayName;

  const ClubRole(this.value, this.displayName);

  static ClubRole fromValue(dynamic val) {
    if (val == null) return ClubRole.member;

    if (val is int) {
      return ClubRole.values.firstWhere(
        (e) => e.value == val,
        orElse: () => ClubRole.member,
      );
    }

    if (val is String) {
      final parsed = int.tryParse(val.trim());
      if (parsed != null) {
        return fromValue(parsed);
      }

      final lower = val.trim().toLowerCase();

      // So khớp tên Enum tiếng Anh
      for (final e in ClubRole.values) {
        if (e.name.toLowerCase() == lower) return e;
      }

      // So khớp từ khóa tiếng Việt / tiếng Anh
      if (lower.contains('host') ||
          lower.contains('chủ') ||
          lower.contains('admin')) {
        return ClubRole.host;
      }
      if (lower.contains('phó') ||
          lower.contains('deputy')) {
        return ClubRole.deputy;
      }
      if (lower.contains('quỹ') ||
          lower.contains('treasurer')) {
        return ClubRole.treasurer;
      }
      if (lower.contains('khách') ||
          lower.contains('guest')) {
        return ClubRole.guest;
      }
      if (lower.contains('thành viên') ||
          lower.contains('thanh vien') ||
          lower.contains('hội viên') ||
          lower.contains('member')) {
        return ClubRole.member;
      }
    }

    return ClubRole.member;
  }

  bool get isHost => this == ClubRole.host;
  bool get isDeputy => this == ClubRole.deputy;
  bool get isTreasurer => this == ClubRole.treasurer;
  bool get isMember => this == ClubRole.member;
  bool get isGuest => this == ClubRole.guest;
}
