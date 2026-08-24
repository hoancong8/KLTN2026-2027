import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/venue_schedule/venue_schedule_request_dto.dart';
import '../../../dto/venue_schedule/venue_schedule_response_dto.dart';
import '../abstract/venue_schedule_remote_datasource.dart';
import '../base_remote_datasource.dart';

class VenueScheduleRemoteDatasourceImpl extends BaseRemoteDatasource implements VenueScheduleRemoteDatasource {
  final Dio dio;

  VenueScheduleRemoteDatasourceImpl(this.dio);

  @override
  Future<PagedResultDto<VenueScheduleResponseDto>> getVenueSchedules({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await dio.get(
        AppConfig.venueSchedulesPath,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (venueId != null && venueId.isNotEmpty) 'venueId': venueId,
        },
      );
      return handleResponse(
        response,
        (data) => PagedResultDto.fromJson(data, (item) => VenueScheduleResponseDto.fromJson(item)),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> createVenueSchedule(VenueScheduleCreateRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.venueSchedulesPath,
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateVenueSchedule(String id, VenueScheduleUpdateRequestDto request) async {
    try {
      final response = await dio.put(
        '${AppConfig.venueSchedulesPath}/$id',
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteVenueSchedule(String id) async {
    try {
      final response = await dio.delete('${AppConfig.venueSchedulesPath}/$id');
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }
}
