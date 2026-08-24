import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/court_pricing/court_pricing_request_dto.dart';
import '../../../dto/court_pricing/court_pricing_response_dto.dart';

abstract class CourtPricingRemoteDatasource {
  Future<PagedResultDto<CourtPricingResponseDto>> getCourtPricings({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  });
  Future<void> createCourtPricing(CourtPricingCreateRequestDto request);
  Future<void> updateCourtPricing(String id, CourtPricingUpdateRequestDto request);
  Future<void> deleteCourtPricing(String id);
}
