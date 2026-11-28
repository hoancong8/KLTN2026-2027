import 'package:dio/dio.dart';

import '../../../../app/consts/app_config.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../dto/reputation/reputation_dto.dart';
import '../base_remote_datasource.dart';

class ReputationRemoteDatasource extends BaseRemoteDatasource {
  ReputationRemoteDatasource(this._dio);

  final Dio _dio;

  Future<ReputationDto> invitations(int page, String? sessionId) =>
      _get(AppConfig.reviewInvitationsPath, {
        'page': page,
        'sessionId': ?sessionId,
      });

  Future<ReputationDto> entries(int page) =>
      _get(AppConfig.reputationEntriesPath, {'page': page});

  Future<ReputationDto> player(String userId) =>
      _get(AppConfig.playerReputationPath(userId));

  Future<ReputationDto> quality(String groupId) =>
      _get(AppConfig.groupQualityPath, {'groupId': groupId});

  Future<ReputationDto> audit(String clubId, String sessionId, int page) =>
      _get(AppConfig.reputationAuditPath(clubId, sessionId), {'page': page});

  Future<ReputationDto> submit(String sessionId, int rating, String? comment) async {
    try {
      final response = await _dio.post(AppConfig.reviewsPath, data: {
        'sessionId': sessionId,
        'rating': rating,
        'comment': comment,
      });
      return handleResponse<ReputationDto>(response, ReputationDto.fromJson);
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) throw const ReviewConflictException();
      throw handleError(error);
    } catch (error) {
      throw handleError(error);
    }
  }

  Future<ReputationDto> _get(String path, [Map<String, dynamic>? query]) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return handleResponse<ReputationDto>(response, ReputationDto.fromJson);
    } catch (error) {
      throw handleError(error);
    }
  }
}
