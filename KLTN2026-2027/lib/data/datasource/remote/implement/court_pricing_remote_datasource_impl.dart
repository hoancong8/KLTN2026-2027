import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/court_pricing/court_pricing_request_dto.dart';
import '../../../dto/court_pricing/court_pricing_response_dto.dart';
import '../abstract/court_pricing_remote_datasource.dart';
import '../base_remote_datasource.dart';

class CourtPricingRemoteDatasourceImpl extends BaseRemoteDatasource implements CourtPricingRemoteDatasource {
  final Dio dio;

  CourtPricingRemoteDatasourceImpl(this.dio);

  @override
  Future<PagedResultDto<CourtPricingResponseDto>> getCourtPricings({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await dio.get(
        AppConfig.courtPricingsPath,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (venueId != null && venueId.isNotEmpty) 'venueId': venueId,
        },
      );
      return handleResponse(
        response,
        (data) => PagedResultDto.fromJson(data, (item) => CourtPricingResponseDto.fromJson(item)),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> createCourtPricing(CourtPricingCreateRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.courtPricingsPath,
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateCourtPricing(String id, CourtPricingUpdateRequestDto request) async {
    try {
      final response = await dio.put(
        '${AppConfig.courtPricingsPath}/$id',
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteCourtPricing(String id) async {
    try {
      final response = await dio.delete('${AppConfig.courtPricingsPath}/$id');
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }
}
