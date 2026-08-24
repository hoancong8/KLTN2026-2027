import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/court/court_request_dto.dart';
import '../../../dto/court/court_response_dto.dart';

abstract class CourtRemoteDatasource {
  Future<PagedResultDto<CourtResponseDto>> getCourts({
    String? venueId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 10,
  });
  Future<void> createCourt(CourtCreateRequestDto request);
  Future<void> updateCourt(String id, CourtUpdateRequestDto request);
  Future<void> deleteCourt(String id);
}
