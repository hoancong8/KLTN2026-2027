// lib/domain/entities/club/club_role_item.dart

class ClubRolePermission {
  final String id;
  final String code;
  final String name;
  final String moduleGroup;
  final String? description;

  const ClubRolePermission({
    required this.id,
    required this.code,
    required this.name,
    required this.moduleGroup,
    this.description,
  });

  String get displayDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    return defaultDescriptions[code] ?? 'Quyền hạn trong câu lạc bộ.';
  }

  static const Map<String, String> defaultDescriptions = {
    // Operations
    'OPERATIONS.SCHEDULE.MANAGE': 'Tạo, sửa và xóa lịch sinh hoạt lặp lại hàng tuần của nhóm.',
    'OPERATIONS.SESSION.VIEW': 'Xem danh sách và chi tiết các buổi sinh hoạt cầu lông.',
    'OPERATIONS.SESSION.CREATE': 'Lên lịch và mở buổi sinh hoạt cầu lông mới.',
    'OPERATIONS.SESSION.UPDATE': 'Chỉnh sửa thông tin, thời gian, sân bãi của buổi chơi.',
    'OPERATIONS.SESSION.DELETE': 'Hủy hoặc xóa buổi sinh hoạt cầu lông.',
    'OPERATIONS.BOOKING.MANAGE': 'Duyệt đặt chỗ, điểm danh và xếp slot người chơi.',
    'OPERATIONS.MATCH.MANAGE': 'Tạo trận đấu, ghép cặp và cập nhật kết quả trận đấu.',
    'OPERATIONS.RECRUIT.MANAGE': 'Đăng tin tuyển khách và quản lý lượt đăng ký vãng lai.',
    // Finance
    'FINANCE.LEDGER.VIEW': 'Xem báo cáo thu chi và số dư quỹ câu lạc bộ.',
    'FINANCE.LEDGER.MANAGE': 'Lập, sửa và hủy phiếu thu chi quỹ nhóm phát sinh.',
    'FINANCE.FEE.VIEW': 'Xem danh sách và trạng thái nộp phí của người chơi.',
    'FINANCE.FEE.MANAGE': 'Xác nhận nộp phí, miễn giảm hoặc kiểm tra đối soát ngân hàng.',
    'FINANCE.BANK.MANAGE': 'Cấu hình tài khoản ngân hàng nhận tiền và các quy tắc tính phí nhóm.',
    // Member
    'MEMBER.VIEW': 'Xem danh sách thành viên và khách trong câu lạc bộ.',
    'MEMBER.JOIN_REQUEST.MANAGE': 'Duyệt hoặc từ chối đơn xin gia nhập nhóm của người chơi.',
    'MEMBER.ROLE.MANAGE': 'Thay đổi vai trò hoặc cấu hình quyền hạn cho thành viên.',
    'MEMBER.REMOVE': 'Xóa hoặc cấm thành viên rời khỏi câu lạc bộ.',
    'MEMBER.INFO.UPDATE': 'Thay đổi tên nhóm, ảnh đại diện, địa chỉ sân cố định.',
  };
}

class ClubRoleItem {
  final String id;
  final String clubId;
  final String roleName;
  final String? description;
  final bool isDefault;
  final bool isHostRole;
  final DateTime createdAt;
  final List<ClubRolePermission> permissions;

  const ClubRoleItem({
    required this.id,
    required this.clubId,
    required this.roleName,
    this.description,
    required this.isDefault,
    required this.isHostRole,
    required this.createdAt,
    required this.permissions,
  });
}
