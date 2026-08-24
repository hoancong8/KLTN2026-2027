import '../../entities/court_pricing.dart';
import '../../entities/paged_response.dart';
import '../../repositories/court_pricing_repository.dart';

class GetCourtPricingsUseCase {
  final CourtPricingRepository repository;
  GetCourtPricingsUseCase(this.repository);

  Future<PagedResponse<CourtPricing>> execute({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return repository.getCourtPricings(
      venueId: venueId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
