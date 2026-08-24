import '../../domain/entities/court_pricing.dart';
import '../../domain/entities/paged_response.dart';
import '../../domain/repositories/court_pricing_repository.dart';
import '../datasource/remote/abstract/court_pricing_remote_datasource.dart';
import '../mapper/court_pricing_mapper.dart';

class CourtPricingRepositoryImpl implements CourtPricingRepository {
  final CourtPricingRemoteDatasource remoteDatasource;

  CourtPricingRepositoryImpl(this.remoteDatasource);

  @override
  Future<PagedResponse<CourtPricing>> getCourtPricings({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final dto = await remoteDatasource.getCourtPricings(
      venueId: venueId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return CourtPricingMapper.toPagedEntity(dto);
  }

  @override
  Future<void> createCourtPricing(CourtPricing pricing) async {
    final dto = CourtPricingMapper.toCreateDto(pricing);
    await remoteDatasource.createCourtPricing(dto);
  }

  @override
  Future<void> updateCourtPricing(String id, CourtPricing pricing) async {
    final dto = CourtPricingMapper.toUpdateDto(pricing);
    await remoteDatasource.updateCourtPricing(id, dto);
  }

  @override
  Future<void> deleteCourtPricing(String id) async {
    await remoteDatasource.deleteCourtPricing(id);
  }
}
