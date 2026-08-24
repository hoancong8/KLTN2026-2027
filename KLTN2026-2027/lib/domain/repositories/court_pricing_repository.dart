import '../entities/court_pricing.dart';
import '../entities/paged_response.dart';

abstract class CourtPricingRepository {
  Future<PagedResponse<CourtPricing>> getCourtPricings({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  });
  Future<void> createCourtPricing(CourtPricing pricing);
  Future<void> updateCourtPricing(String id, CourtPricing pricing);
  Future<void> deleteCourtPricing(String id);
}
