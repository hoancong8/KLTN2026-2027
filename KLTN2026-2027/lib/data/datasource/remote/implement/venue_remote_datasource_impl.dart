import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/venue/venue_request_dto.dart';
import '../../../dto/venue/venue_response_dto.dart';
import '../abstract/venue_remote_datasource.dart';
import '../base_remote_datasource.dart';

class VenueRemoteDatasourceImpl extends BaseRemoteDatasource implements VenueRemoteDatasource {
  final Dio dio;

  VenueRemoteDatasourceImpl(this.dio);

  @override
  Future<PagedResultDto<VenueResponseDto>> getVenues({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    bool? isActive,
  }) async {
    try {
      final response = await dio.get(
        AppConfig.venuesPath,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (searchTerm != null && searchTerm.isNotEmpty) 'searchTerm': searchTerm,
          'isActive': ?isActive,
        },
      );
      return handleResponse(
        response,
        (data) => PagedResultDto.fromJson(data, (item) => VenueResponseDto.fromJson(item)),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<VenueResponseDto> getVenueById(String id) async {
    try {
      final response = await dio.get('${AppConfig.venuesPath}/$id');
      return handleResponse(response, (data) => VenueResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<String> createVenue(VenueRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.venuesPath,
        data: request.toJson(),
      );
      return handleResponse(response, (data) => data.toString());
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateVenue(String id, VenueRequestDto request) async {
    try {
      final response = await dio.put(
        '${AppConfig.venuesPath}/$id',
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteVenue(String id) async {
    try {
      final response = await dio.delete('${AppConfig.venuesPath}/$id');
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }
}
