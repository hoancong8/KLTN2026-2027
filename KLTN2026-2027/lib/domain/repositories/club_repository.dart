// lib/domain/repositories/club_repository.dart

import '../entities/club/active_club_context.dart';
import '../entities/club/club.dart';
import '../entities/club/club_detail.dart';
import '../entities/club/club_member.dart';
import '../entities/club/club_role_item.dart';
import '../entities/club/explore_club.dart';
import '../entities/club/join_request.dart';
import '../entities/club/my_club.dart';
import '../enums/club_role.dart';
import '../enums/session_enums.dart';

abstract class ClubRepository {
  /// Lấy danh sách các câu lạc bộ người dùng hiện tại đang tham gia kèm vai trò (FR03)
  Future<List<MyClub>> getMyClubs();

  /// Xem thông tin chi tiết câu lạc bộ
  Future<Club> getClubById(String id);

  /// Tạo một câu lạc bộ mới (Người tạo tự động thành Host)
  Future<String> createClub({
    required String name,
    String? description,
    String? avatarUrl,
    String? fixedVenueName,
    String? fixedAddress,
    double? lat,
    double? lng,
    int? minSkillLevel,
    int? maxSkillLevel,
    List<dynamic>? schedules,
  });

  /// Tham gia câu lạc bộ bằng mã Code với vai trò mong muốn (FR03)
  Future<String> joinClub({
    required String clubCode,
    ClubRole role = ClubRole.member,
    String? nickname,
  });

  /// Xem danh sách thành viên và vai trò trong câu lạc bộ (FR03)
  Future<List<ClubMember>> getClubMembers(String clubId);

  /// Cập nhật vai trò của thành viên trong câu lạc bộ (Chỉ Host)
  Future<bool> updateMemberRole({
    required String clubId,
    required String userId,
    required ClubRole role,
  });

  /// Rời khỏi câu lạc bộ hoặc xóa thành viên khỏi nhóm
  Future<bool> removeMember({
    required String clubId,
    required String userId,
  });

  /// Chuyển đổi câu lạc bộ đang hoạt động, trả về Token & Phân quyền mới (FR04)
  Future<ActiveClubContext> switchClubContext(String clubId);

  // --- Club Roles (FR03) ---
  Future<List<ClubRolePermission>> getClubPermissions();

  Future<List<ClubRoleItem>> getClubRoles(String clubId);

  Future<String> createClubRole({
    required String clubId,
    required String roleName,
    String? description,
    List<String> permissionIds = const [],
    bool isDefault = false,
  });

  Future<bool> updateClubRolePermissions({
    required String clubId,
    required String roleId,
    required List<String> permissionIds,
  });

  Future<bool> deleteClubRole({
    required String clubId,
    required String roleId,
  });

  // --- Join Requests (FR03) ---
  Future<String> createJoinRequest({
    required String clubId,
    String? introduction,
  });

  Future<List<JoinRequest>> getJoinRequests(String clubId, {String? status});

  Future<String> approveJoinRequest({
    required String clubId,
    required String requestId,
    String? roleId,
    String? memberType,
  });

  Future<bool> rejectJoinRequest({
    required String clubId,
    required String requestId,
  });

  // --- FR06: Khám phá nhóm theo vị trí GPS & Bán kính ---
  Future<List<ExploreClub>> exploreClubs({
    double? latitude,
    double? longitude,
    double? radiusKm,
    SkillLevel? skillLevel,
    bool? isRecruiting,
    String? searchTerm,
  });

  // --- FR07: Thông tin chi tiết & Lịch sinh hoạt nhóm ---
  Future<ClubDetail> getClubDetail(String clubId);

  Future<void> updateClubInfo(
    String clubId, {
    required String groupName,
    String? description,
    String? avatarUrl,
    String? fixedVenueName,
    String? fixedAddress,
    double? lat,
    double? lng,
    SkillLevel? minSkillLevel,
    SkillLevel? maxSkillLevel,
    required bool isRecruiting,
  });

  Future<void> updateClubSchedules(
    String clubId,
    List<ClubScheduleInput> schedules,
  );
}
