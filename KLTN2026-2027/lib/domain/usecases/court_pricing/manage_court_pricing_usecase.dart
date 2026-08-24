import '../../entities/court_pricing.dart';
import '../../repositories/court_pricing_repository.dart';

class ManageCourtPricingUseCase {
  final CourtPricingRepository repository;
  ManageCourtPricingUseCase(this.repository);

  Future<void> create(CourtPricing pricing) => repository.createCourtPricing(pricing);
  Future<void> update(String id, CourtPricing pricing) => repository.updateCourtPricing(id, pricing);
  Future<void> delete(String id) => repository.deleteCourtPricing(id);
}
