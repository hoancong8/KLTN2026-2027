// lib/data/repositories/club_repository_impl.dart

import '../../domain/entities/club/active_club_context.dart';
import '../../domain/entities/club/club.dart';
import '../../domain/entities/club/club_detail.dart';
import '../../domain/entities/club/club_member.dart';
import '../../domain/entities/club/club_role_item.dart';
import '../../domain/entities/club/explore_club.dart';
import '../../domain/entities/club/join_request.dart';
import '../../domain/entities/club/my_club.dart';
import '../../domain/enums/club_role.dart';
import '../../domain/enums/session_enums.dart';
import '../../domain/repositories/club_repository.dart';
import '../datasource/remote/abstract/club_remote_datasource.dart';
import '../dto/club/approve_join_request_dto.dart';
import '../dto/club/club_member_response_dto.dart';
import '../dto/club/create_club_request_dto.dart';
import '../dto/club/create_club_role_request_dto.dart';
import '../dto/club/create_join_request_dto.dart';
import '../dto/club/join_club_request_dto.dart';
import '../dto/club/my_club_response_dto.dart';
import '../dto/club/update_member_role_request_dto.dart';
import '../mapper/club_detail_mapper.dart';
import '../mapper/club_mapper.dart';
import '../mapper/club_role_mapper.dart';
import '../mapper/explore_club_mapper.dart';
import '../mapper/join_request_mapper.dart';

class ClubRepositoryImpl implements ClubRepository {
  final ClubRemoteDatasource remoteDatasource;

  ClubRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<MyClub>> getMyClubs() async {
    final List<MyClubResponseDto> dtos = await remoteDatasource.getMyClubs();
    return dtos.map((MyClubResponseDto e) => ClubMapper.toMyClubEntity(e)).toList();
  }

  @override
  Future<Club> getClubById(String id) async {
    final dto = await remoteDatasource.getClubById(id);
    return ClubMapper.toClubEntity(dto);
  }

  @override
  Future<String> createClub({
    required String name,
    String? description,
    String? avatarUrl,
  }) async {
    final request = CreateClubRequestDto(
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );
    return remoteDatasource.createClub(request);
  }

  @override
  Future<String> joinClub({
    required String clubCode,
    ClubRole role = ClubRole.member,
    String? nickname,
  }) async {
    final request = JoinClubRequestDto(
      clubCode: clubCode,
      role: role.value,
      nickname: nickname,
    );
    return remoteDatasource.joinClub(request);
  }

  @override
  Future<List<ClubMember>> getClubMembers(String clubId) async {
    final List<ClubMemberResponseDto> dtos = await remoteDatasource.getClubMembers(clubId);
    return dtos.map((ClubMemberResponseDto e) => ClubMapper.toClubMemberEntity(e)).toList();
  }

  @override
  Future<bool> updateMemberRole({
    required String clubId,
    required String userId,
    required ClubRole role,
  }) async {
    String? roleId;
    try {
      final roles = await remoteDatasource.getClubRoles(clubId);
      final matched = roles.where((r) {
        final lower = r.roleName.toLowerCase();
        switch (role) {
          case ClubRole.host:
            return r.isHostRole || lower.contains('host');
          case ClubRole.deputy:
            return lower.contains('phó') || lower.contains('deputy');
          case ClubRole.treasurer:
            return lower.contains('thủ quỹ') || lower.contains('quỹ') || lower.contains('treasurer');
          case ClubRole.guest:
            return lower.contains('khách') || lower.contains('guest');
          case ClubRole.member:
            return r.isDefault || lower.contains('thành viên') || lower.contains('member');
        }
      }).toList();

      if (matched.isNotEmpty) {
        roleId = matched.first.id;
      }
    } catch (_) {
      // Fallback to role code if getClubRoles fails
    }

    final request = UpdateMemberRoleRequestDto(
      role: role.value,
      roleId: roleId,
      roleName: role.displayName,
    );
    return remoteDatasource.updateMemberRole(clubId, userId, request);
  }

  @override
  Future<bool> removeMember({
    required String clubId,
    required String userId,
  }) async {
    return remoteDatasource.removeMember(clubId, userId);
  }

  @override
  Future<ActiveClubContext> switchClubContext(String clubId) async {
    final dto = await remoteDatasource.switchContext(clubId);
    return ClubMapper.toActiveContextEntity(dto);
  }

  // --- Club Roles ---
  @override
  Future<List<ClubRolePermission>> getClubPermissions() async {
    final dtos = await remoteDatasource.getClubPermissions();
    return dtos
        .map((p) => ClubRolePermission(
              id: p.id,
              code: p.code,
              name: p.name,
              moduleGroup: p.moduleGroup,
            ))
        .toList();
  }

  @override
  Future<List<ClubRoleItem>> getClubRoles(String clubId) async {
    final dtos = await remoteDatasource.getClubRoles(clubId);
    return dtos.map(ClubRoleMapper.toEntity).toList();
  }

  @override
  Future<String> createClubRole({
    required String clubId,
    required String roleName,
    String? description,
    List<String> permissionIds = const [],
    bool isDefault = false,
  }) async {
    final request = CreateClubRoleRequestDto(
      roleName: roleName,
      description: description,
      permissionIds: permissionIds,
      isDefault: isDefault,
    );
    return await remoteDatasource.createClubRole(clubId, request);
  }

  @override
  Future<bool> updateClubRolePermissions({
    required String clubId,
    required String roleId,
    required List<String> permissionIds,
  }) async {
    return await remoteDatasource.updateClubRolePermissions(clubId, roleId, permissionIds);
  }

  @override
  Future<bool> deleteClubRole({
    required String clubId,
    required String roleId,
  }) async {
    return await remoteDatasource.deleteClubRole(clubId, roleId);
  }

  // --- Join Requests ---
  @override
  Future<String> createJoinRequest({
    required String clubId,
    String? introduction,
  }) async {
    final request = CreateJoinRequestDto(introduction: introduction);
    return await remoteDatasource.createJoinRequest(clubId, request);
  }

  @override
  Future<List<JoinRequest>> getJoinRequests(String clubId, {String? status}) async {
    final dtos = await remoteDatasource.getJoinRequests(clubId, status: status);
    return dtos.map(JoinRequestMapper.toEntity).toList();
  }

  @override
  Future<String> approveJoinRequest({
    required String clubId,
    required String requestId,
    String? roleId,
    String? memberType,
  }) async {
    final request = ApproveJoinRequestDto(roleId: roleId, memberType: memberType);
    return await remoteDatasource.approveJoinRequest(clubId, requestId, request);
  }

  @override
  Future<bool> rejectJoinRequest({
    required String clubId,
    required String requestId,
  }) async {
    return await remoteDatasource.rejectJoinRequest(clubId, requestId);
  }

  // --- FR06: Khám phá nhóm theo vị trí GPS & Bán kính ---
  @override
  Future<List<ExploreClub>> exploreClubs({
    double? latitude,
    double? longitude,
    double? radiusKm,
    SkillLevel? skillLevel,
    bool? isRecruiting,
    String? searchTerm,
  }) async {
    final dtos = await remoteDatasource.exploreClubs(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      skillLevel: skillLevel?.code,
      isRecruiting: isRecruiting,
      searchTerm: searchTerm,
    );
    return dtos.map(ExploreClubMapper.toEntity).toList();
  }

  // --- FR07: Thông tin chi tiết & Lịch sinh hoạt nhóm ---
  @override
  Future<ClubDetail> getClubDetail(String clubId) async {
    final dto = await remoteDatasource.getClubDetail(clubId);
    return ClubDetailMapper.toEntity(dto);
  }

  @override
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
  }) async {
    final request = ClubDetailMapper.toUpdateInfoDto(
      groupName: groupName,
      description: description,
      avatarUrl: avatarUrl,
      fixedVenueName: fixedVenueName,
      fixedAddress: fixedAddress,
      lat: lat,
      lng: lng,
      minSkillLevel: minSkillLevel,
      maxSkillLevel: maxSkillLevel,
      isRecruiting: isRecruiting,
    );
    await remoteDatasource.updateClubInfo(clubId, request);
  }

  @override
  Future<void> updateClubSchedules(
    String clubId,
    List<ClubScheduleInput> schedules,
  ) async {
    final request = ClubDetailMapper.toUpdateSchedulesDto(schedules);
    await remoteDatasource.updateClubSchedules(clubId, request);
  }
}
