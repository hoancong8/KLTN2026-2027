import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/court/court_request_dto.dart';
import '../../../dto/court/court_response_dto.dart';
import '../abstract/court_remote_datasource.dart';
import '../base_remote_datasource.dart';

class CourtRemoteDatasourceImpl extends BaseRemoteDatasource implements CourtRemoteDatasource {
  final Dio dio;

  CourtRemoteDatasourceImpl(this.dio);

  @override
  Future<PagedResultDto<CourtResponseDto>> getCourts({
    String? venueId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await dio.get(
        AppConfig.courtsPath,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (venueId != null && venueId.isNotEmpty) 'venueId': venueId,
          'isAvailable': ?isAvailable,
        },
      );
      return handleResponse(
        response,
        (data) => PagedResultDto.fromJson(data, (item) => CourtResponseDto.fromJson(item)),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> createCourt(CourtCreateRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.courtsPath,
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateCourt(String id, CourtUpdateRequestDto request) async {
    try {
      final response = await dio.put(
        '${AppConfig.courtsPath}/$id',
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteCourt(String id) async {
    try {
      final response = await dio.delete('${AppConfig.courtsPath}/$id');
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }
}
