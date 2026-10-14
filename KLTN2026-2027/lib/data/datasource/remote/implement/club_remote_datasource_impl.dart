// lib/data/datasource/remote/implement/club_remote_datasource_impl.dart

import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
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
import '../abstract/club_remote_datasource.dart';
import '../base_remote_datasource.dart';

class ClubRemoteDatasourceImpl extends BaseRemoteDatasource implements ClubRemoteDatasource {
  final Dio dio;

  ClubRemoteDatasourceImpl(this.dio);

  @override
  Future<List<MyClubResponseDto>> getMyClubs() async {
    try {
      final response = await dio.get('${AppConfig.clubsPath}/my-clubs');
      return handleListResponse(response, (item) => MyClubResponseDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<ClubResponseDto> getClubById(String id) async {
    try {
      final response = await dio.get('${AppConfig.clubsPath}/$id');
      return handleResponse(response, (data) => ClubResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<String> createClub(CreateClubRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.clubsPath,
        data: request.toJson(),
      );
      // BE returns Results.Created($"/api/v1/clubs/{clubId}", clubId)
      return handleResponse(response, (data) => data?.toString() ?? '');
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<String> joinClub(JoinClubRequestDto request) async {
    try {
      final response = await dio.post(
        '${AppConfig.clubsPath}/join',
        data: request.toJson(),
      );
      // BE returns Results.Ok(new { MemberId = memberId })
      return handleResponse(response, (data) {
        if (data is Map) {
          return data['memberId']?.toString() ?? '';
        }
        return data?.toString() ?? '';
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<ClubMemberResponseDto>> getClubMembers(String clubId) async {
    try {
      final response = await dio.get('${AppConfig.clubsPath}/$clubId/members');
      return handleListResponse(response, (item) => ClubMemberResponseDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<bool> updateMemberRole(
    String clubId,
    String userId,
    UpdateMemberRoleRequestDto request,
  ) async {
    try {
      final response = await dio.put(
        '${AppConfig.clubsPath}/$clubId/members/$userId/role',
        data: request.toJson(),
      );
      return handleResponse(response, (data) {
        if (data is Map && data.containsKey('success')) {
          return data['success'] == true;
        }
        return true;
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<bool> removeMember(String clubId, String userId) async {
    try {
      final response = await dio.delete(
        '${AppConfig.clubsPath}/$clubId/members/$userId',
      );
      return handleResponse(response, (data) {
        if (data is Map && data.containsKey('success')) {
          return data['success'] == true;
        }
        return true;
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SwitchClubResponseDto> switchContext(String clubId) async {
    try {
      final response = await dio.post(
        '${AppConfig.clubsPath}/$clubId/switch-context',
      );
      return handleResponse(response, (data) => SwitchClubResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- Club Roles ---
  @override
  Future<List<ClubRoleResponseDto>> getClubRoles(String clubId) async {
    try {
      final response = await dio.get(
        AppConfig.clubRolesPath(clubId),
        options: Options(headers: {'X-Group-Id': clubId}),
      );
      return handleListResponse(response, (item) => ClubRoleResponseDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<String> createClubRole(String clubId, CreateClubRoleRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.clubRolesPath(clubId),
        data: request.toJson(),
        options: Options(headers: {'X-Group-Id': clubId}),
      );
      return handleResponse(response, (data) {
        if (data is Map && data.containsKey('roleId')) {
          return data['roleId'].toString();
        }
        return data?.toString() ?? '';
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<bool> updateClubRolePermissions(String clubId, String roleId, List<String> permissionIds) async {
    try {
      final response = await dio.put(
        AppConfig.clubRolePermissionsPath(clubId, roleId),
        data: {'permissionIds': permissionIds},
        options: Options(headers: {'X-Group-Id': clubId}),
      );
      return handleResponse(response, (data) => true);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<bool> deleteClubRole(String clubId, String roleId) async {
    try {
      await dio.delete(
        AppConfig.clubRoleDetailPath(clubId, roleId),
        options: Options(headers: {'X-Group-Id': clubId}),
      );
      return true;
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- Join Requests ---
  @override
  Future<String> createJoinRequest(String clubId, CreateJoinRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.clubJoinRequestsPath(clubId),
        data: request.toJson(),
      );
      return handleResponse(response, (data) {
        if (data is Map && data.containsKey('requestId')) {
          return data['requestId'].toString();
        }
        return data?.toString() ?? '';
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<JoinRequestResponseDto>> getJoinRequests(String clubId, {String? status}) async {
    try {
      final response = await dio.get(
        AppConfig.clubJoinRequestsPath(clubId),
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
        },
        options: Options(headers: {'X-Group-Id': clubId}),
      );
      return handleListResponse(response, (item) => JoinRequestResponseDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<String> approveJoinRequest(String clubId, String requestId, ApproveJoinRequestDto request) async {
    try {
      final response = await dio.put(
        AppConfig.clubApproveJoinRequestPath(clubId, requestId),
        data: request.toJson(),
        options: Options(headers: {'X-Group-Id': clubId}),
      );
      return handleResponse(response, (data) {
        if (data is Map && data.containsKey('memberId')) {
          return data['memberId'].toString();
        }
        return data?.toString() ?? '';
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<bool> rejectJoinRequest(String clubId, String requestId) async {
    try {
      await dio.put(
        AppConfig.clubRejectJoinRequestPath(clubId, requestId),
        options: Options(headers: {'X-Group-Id': clubId}),
      );
      return true;
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- FR06: Khám phá nhóm theo vị trí GPS & Bán kính ---
  @override
  Future<List<ExploreClubDto>> exploreClubs({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? skillLevel,
    bool? isRecruiting,
    String? searchTerm,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radiusKm != null) queryParams['radiusKm'] = radiusKm;
      if (skillLevel != null && skillLevel.isNotEmpty) queryParams['skillLevel'] = skillLevel;
      if (isRecruiting != null) queryParams['isRecruiting'] = isRecruiting;
      if (searchTerm != null && searchTerm.trim().isNotEmpty) queryParams['searchTerm'] = searchTerm.trim();

      final response = await dio.get(
        AppConfig.clubsExplorePath,
        queryParameters: queryParams,
      );
      return handleListResponse(response, (data) => ExploreClubDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- FR07: Thông tin chi tiết & Lịch sinh hoạt nhóm ---
  @override
  Future<ClubDetailDto> getClubDetail(String clubId) async {
    try {
      final response = await dio.get(AppConfig.clubDetailPath(clubId));
      return handleResponse(response, (data) => ClubDetailDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateClubInfo(String clubId, UpdateClubInfoRequestDto request) async {
    try {
      await dio.put(
        AppConfig.clubInfoPath(clubId),
        data: request.toJson(),
        options: Options(headers: {'X-Group-Id': clubId}),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateClubSchedules(String clubId, UpdateClubSchedulesRequestDto request) async {
    try {
      await dio.put(
        AppConfig.clubSchedulesPath(clubId),
        data: request.toJson(),
        options: Options(headers: {'X-Group-Id': clubId}),
      );
    } catch (e) {
      throw handleError(e);
    }
  }
}
