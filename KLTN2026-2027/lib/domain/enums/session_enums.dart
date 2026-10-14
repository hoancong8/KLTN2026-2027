// lib/domain/enums/session_enums.dart

enum SessionStatus {
  open(1, 'OPEN', 'Đang mở đăng ký'),
  locked(2, 'LOCKED', 'Đã khóa sổ'),
  playing(3, 'PLAYING', 'Đang thi đấu'),
  calculated(4, 'CALCULATED', 'Đã tính tiền'),
  completed(5, 'COMPLETED', 'Đã kết thúc');

  final int id;
  final String value;
  final String displayName;
  const SessionStatus(this.id, this.value, this.displayName);

  static SessionStatus fromString(dynamic val) {
    if (val == null) return SessionStatus.open;
    if (val is int) {
      return SessionStatus.values.firstWhere(
        (e) => e.id == val,
        orElse: () => SessionStatus.open,
      );
    }
    final str = val.toString().trim();
    final parsed = int.tryParse(str);
    if (parsed != null) {
      return SessionStatus.values.firstWhere(
        (e) => e.id == parsed,
        orElse: () => SessionStatus.open,
      );
    }
    return SessionStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == str.toUpperCase(),
      orElse: () => SessionStatus.open,
    );
  }
}

enum BookingStatus {
  confirmed(1, 'CONFIRMED', 'Chính thức'),
  waiting(2, 'WAITING', 'Hàng đợi'),
  absent(3, 'ABSENT', 'Báo vắng'),
  checkedIn(4, 'CHECKED_IN', 'Đã điểm danh');

  final int id;
  final String value;
  final String displayName;
  const BookingStatus(this.id, this.value, this.displayName);

  static BookingStatus fromString(dynamic val) {
    if (val == null) return BookingStatus.confirmed;
    if (val is int) {
      return BookingStatus.values.firstWhere(
        (e) => e.id == val,
        orElse: () => BookingStatus.confirmed,
      );
    }
    final str = val.toString().trim();
    final parsed = int.tryParse(str);
    if (parsed != null) {
      return BookingStatus.values.firstWhere(
        (e) => e.id == parsed,
        orElse: () => BookingStatus.confirmed,
      );
    }
    return BookingStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == str.toUpperCase(),
      orElse: () => BookingStatus.confirmed,
    );
  }
}

enum RecruitmentStatus {
  active(1, 'ACTIVE', 'Đang tuyển'),
  filled(2, 'FILLED', 'Đã đủ người'),
  expired(3, 'EXPIRED', 'Đã hết hạn');

  final int id;
  final String value;
  final String displayName;
  const RecruitmentStatus(this.id, this.value, this.displayName);

  static RecruitmentStatus fromString(dynamic val) {
    if (val == null) return RecruitmentStatus.active;
    if (val is int) {
      return RecruitmentStatus.values.firstWhere(
        (e) => e.id == val,
        orElse: () => RecruitmentStatus.active,
      );
    }
    final str = val.toString().trim();
    final parsed = int.tryParse(str);
    if (parsed != null) {
      return RecruitmentStatus.values.firstWhere(
        (e) => e.id == parsed,
        orElse: () => RecruitmentStatus.active,
      );
    }
    return RecruitmentStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == str.toUpperCase(),
      orElse: () => RecruitmentStatus.active,
    );
  }
}

enum SkillLevel {
  nb(1, 'NB', 'Newbie', 'Mới tập chơi'),
  y(2, 'Y', 'Yếu', 'Nắm luật cơ bản'),
  tby(3, 'TBY', 'Trung bình yếu', 'Phong trào giải trí'),
  tb(4, 'TB', 'Trung bình', 'Phong trào ổn định'),
  tbk(5, 'TBK', 'Trung bình khá', 'Chiến thuật tốt'),
  k(6, 'K', 'Khá', 'Kỹ thuật toàn diện'),
  g(7, 'G', 'Giỏi / Bán chuyên', 'Đẳng cấp bán chuyên');

  final int level;
  final String code;
  final String displayName;
  final String description;
  const SkillLevel(this.level, this.code, this.displayName, this.description);

  static SkillLevel fromString(dynamic val) {
    if (val == null) return SkillLevel.nb;
    if (val is int) {
      return SkillLevel.values.firstWhere(
        (e) => e.level == val,
        orElse: () => SkillLevel.nb,
      );
    }
    final str = val.toString().trim().toUpperCase();
    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return SkillLevel.values.firstWhere(
        (e) => e.level == parsedInt,
        orElse: () => SkillLevel.nb,
      );
    }
    return SkillLevel.values.firstWhere(
      (e) => e.code.toUpperCase() == str,
      orElse: () => SkillLevel.nb,
    );
  }
}

enum JoinRequestStatus {
  pending(1, 'PENDING', 'Chờ duyệt'),
  approved(2, 'APPROVED', 'Đã chấp thuận'),
  rejected(3, 'REJECTED', 'Đã từ chối');

  final int id;
  final String value;
  final String displayName;
  const JoinRequestStatus(this.id, this.value, this.displayName);

  static JoinRequestStatus fromString(dynamic val) {
    if (val == null) return JoinRequestStatus.pending;
    if (val is int) {
      return JoinRequestStatus.values.firstWhere(
        (e) => e.id == val,
        orElse: () => JoinRequestStatus.pending,
      );
    }
    final str = val.toString().trim();
    final parsed = int.tryParse(str);
    if (parsed != null) {
      return JoinRequestStatus.values.firstWhere(
        (e) => e.id == parsed,
        orElse: () => JoinRequestStatus.pending,
      );
    }
    return JoinRequestStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == str.toUpperCase(),
      orElse: () => JoinRequestStatus.pending,
    );
  }
}
