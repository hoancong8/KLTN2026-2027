// lib/data/datasource/remote/implement/session_remote_datasource_impl.dart

import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/session/create_recruitment_request_dto.dart';
import '../../../dto/session/create_session_request_dto.dart';
import '../../../dto/session/guest_recruitment_dto.dart';
import '../../../dto/session/my_booking_item_dto.dart';
import '../../../dto/session/session_booking_dto.dart';
import '../../../dto/session/session_detail_dto.dart';
import '../../../dto/session/session_dto.dart';
import '../../../dto/session/update_session_request_dto.dart';
import '../abstract/session_remote_datasource.dart';
import '../base_remote_datasource.dart';

class SessionRemoteDataSourceImpl extends BaseRemoteDatasource implements SessionRemoteDataSource {
  final Dio dio;

  SessionRemoteDataSourceImpl(this.dio);

  @override
  Future<String> createSession(String clubId, CreateSessionRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.sessionClubPath(clubId),
        data: request.toJson(),
        options: Options(headers: {'X-Group-Id': clubId}),
      );
      return handleResponse(response, (data) {
        if (data is Map && data.containsKey('sessionId')) {
          return data['sessionId'].toString();
        }
        return data?.toString() ?? '';
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<SessionDto>> getClubSessions(String clubId) async {
    try {
      final response = await dio.get(AppConfig.sessionClubPath(clubId));
      return handleListResponse(response, (item) => SessionDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SessionDetailDto> getSessionDetail(String sessionId) async {
    try {
      final response = await dio.get(AppConfig.sessionDetailPath(sessionId));
      return handleResponse(response, (data) => SessionDetailDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateSession(String sessionId, UpdateSessionRequestDto request) async {
    try {
      await dio.put(
        AppConfig.sessionDetailPath(sessionId),
        data: request.toJson(),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateSessionStatus(String sessionId, String status) async {
    try {
      await dio.patch(
        AppConfig.sessionStatusPath(sessionId),
        data: {'status': status},
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await dio.delete(AppConfig.sessionDetailPath(sessionId));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SessionBookingDto> voteBooking(String sessionId) async {
    try {
      final response = await dio.post(AppConfig.sessionBookingsPath(sessionId));
      return handleResponse(response, (data) => SessionBookingDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> cancelBooking(String sessionId) async {
    try {
      await dio.delete(AppConfig.sessionMyBookingPath(sessionId));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> confirmBooking(String sessionId, String bookingId) async {
    try {
      await dio.post(AppConfig.sessionConfirmBookingPath(sessionId, bookingId));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<SessionBookingDto>> getSessionBookings(String sessionId) async {
    try {
      final response = await dio.get(AppConfig.sessionBookingsPath(sessionId));
      return handleListResponse(response, (item) => SessionBookingDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SessionBookingDto?> getMyBooking(String sessionId) async {
    try {
      final response = await dio.get(AppConfig.sessionMyBookingPath(sessionId));
      return handleResponse(response, (data) => SessionBookingDto.fromJson(data));
    } on DioException catch (dioErr) {
      if (dioErr.response?.statusCode == 404) {
        return null;
      }
      throw handleError(dioErr);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<MyBookingItemDto>> getMyBookings() async {
    try {
      final response = await dio.get(AppConfig.myBookingsPath);
      return handleListResponse(response, (item) => MyBookingItemDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<String> createRecruitment(String sessionId, CreateRecruitmentRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.sessionRecruitmentsPath(sessionId),
        data: request.toJson(),
      );
      return handleResponse(response, (data) {
        if (data is Map && data.containsKey('recruitmentId')) {
          return data['recruitmentId'].toString();
        }
        return data?.toString() ?? '';
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<GuestRecruitmentDto?> getSessionRecruitment(String sessionId) async {
    try {
      final response = await dio.get(AppConfig.sessionRecruitmentsPath(sessionId));
      return handleResponse(response, (data) => GuestRecruitmentDto.fromJson(data));
    } on DioException catch (dioErr) {
      if (dioErr.response?.statusCode == 404) {
        return null;
      }
      throw handleError(dioErr);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteRecruitment(String sessionId) async {
    try {
      await dio.delete(AppConfig.sessionRecruitmentsPath(sessionId));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<GuestRecruitmentDto>> exploreRecruitments({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? minSkillLevel,
  }) async {
    try {
      final response = await dio.get(
        AppConfig.exploreRecruitmentsPath,
        queryParameters: {
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
          if (radiusKm != null) 'radiusKm': radiusKm.toString(),
          if (minSkillLevel != null && minSkillLevel.isNotEmpty) 'minSkillLevel': minSkillLevel,
        },
      );
      return handleListResponse(response, (item) => GuestRecruitmentDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SessionBookingDto> joinRecruitment(String recruitmentId) async {
    try {
      final response = await dio.post(AppConfig.joinRecruitmentPath(recruitmentId));
      return handleResponse(response, (data) => SessionBookingDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> cancelRecruitmentBooking(String recruitmentId) async {
    try {
      await dio.delete(AppConfig.cancelRecruitmentPath(recruitmentId));
    } catch (e) {
      throw handleError(e);
    }
  }
}
