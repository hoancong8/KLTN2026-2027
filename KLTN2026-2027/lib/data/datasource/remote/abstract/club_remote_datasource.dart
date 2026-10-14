import '../../../dto/club/approve_join_request_dto.dart';
import '../../../dto/club/club_detail_dto.dart';
import '../../../dto/club/club_member_response_dto.dart';
import '../../../dto/club/club_response_dto.dart';
import '../../../dto/club/club_role_response_dto.dart';
import '../../../dto/club/create_club_request_dto.dart';
import '../../../dto/club/create_club_role_request_dto.dart';
import '../../../dto/club/create_join_request_dto.dart';
import '../../../dto/club/explore_club_dto.dart';
import '../../../dto/club/join_club_request_dto.dart';
import '../../../dto/club/join_request_response_dto.dart';
import '../../../dto/club/my_club_response_dto.dart';
import '../../../dto/club/switch_club_response_dto.dart';
import '../../../dto/club/update_club_info_request_dto.dart';
import '../../../dto/club/update_club_schedules_request_dto.dart';
import '../../../dto/club/update_member_role_request_dto.dart';

abstract class ClubRemoteDatasource {
  Future<List<MyClubResponseDto>> getMyClubs();

  Future<ClubResponseDto> getClubById(String id);

  Future<String> createClub(CreateClubRequestDto request);

  Future<String> joinClub(JoinClubRequestDto request);

  Future<List<ClubMemberResponseDto>> getClubMembers(String clubId);

  Future<bool> updateMemberRole(String clubId, String userId, UpdateMemberRoleRequestDto request);

  Future<bool> removeMember(String clubId, String userId);

  Future<SwitchClubResponseDto> switchContext(String clubId);

  // --- Club Roles ---
  Future<List<ClubRoleResponseDto>> getClubRoles(String clubId);

  Future<String> createClubRole(String clubId, CreateClubRoleRequestDto request);

  Future<bool> updateClubRolePermissions(String clubId, String roleId, List<String> permissionIds);

  Future<bool> deleteClubRole(String clubId, String roleId);

  // --- Join Requests ---
  Future<String> createJoinRequest(String clubId, CreateJoinRequestDto request);

  Future<List<JoinRequestResponseDto>> getJoinRequests(String clubId, {String? status});

  Future<String> approveJoinRequest(String clubId, String requestId, ApproveJoinRequestDto request);

  Future<bool> rejectJoinRequest(String clubId, String requestId);

  // --- FR06: Khám phá nhóm theo vị trí GPS & Bán kính ---
  Future<List<ExploreClubDto>> exploreClubs({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? skillLevel,
    bool? isRecruiting,
    String? searchTerm,
  });

  // --- FR07: Thông tin chi tiết & Lịch sinh hoạt nhóm ---
  Future<ClubDetailDto> getClubDetail(String clubId);

  Future<void> updateClubInfo(String clubId, UpdateClubInfoRequestDto request);

  Future<void> updateClubSchedules(String clubId, UpdateClubSchedulesRequestDto request);
}
