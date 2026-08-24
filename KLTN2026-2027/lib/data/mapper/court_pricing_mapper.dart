import '../../domain/entities/court_pricing.dart';
import '../../domain/entities/paged_response.dart';
import '../dto/common/paged_result_dto.dart';
import '../dto/court_pricing/court_pricing_request_dto.dart';
import '../dto/court_pricing/court_pricing_response_dto.dart';

class CourtPricingMapper {
  static CourtPricing toEntity(CourtPricingResponseDto dto) {
    return CourtPricing(
      id: dto.id,
      venueId: dto.venueId,
      startTime: dto.startTime,
      endTime: dto.endTime,
      pricePerHour: dto.pricePerHour,
      dayOfWeek: dto.dayOfWeek,
      isPeakHour: dto.isPeakHour,
    );
  }

  static CourtPricingCreateRequestDto toCreateDto(CourtPricing entity) {
    return CourtPricingCreateRequestDto(
      venueId: entity.venueId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      pricePerHour: entity.pricePerHour,
      dayOfWeek: entity.dayOfWeek,
      isPeakHour: entity.isPeakHour,
    );
  }

  static CourtPricingUpdateRequestDto toUpdateDto(CourtPricing entity) {
    return CourtPricingUpdateRequestDto(
      startTime: entity.startTime,
      endTime: entity.endTime,
      pricePerHour: entity.pricePerHour,
      dayOfWeek: entity.dayOfWeek,
      isPeakHour: entity.isPeakHour,
    );
  }

  static PagedResponse<CourtPricing> toPagedEntity(PagedResultDto<CourtPricingResponseDto> dto) {
    return PagedResponse<CourtPricing>(
      items: dto.items.map((e) => toEntity(e)).toList(),
      totalCount: dto.totalCount,
      pageNumber: dto.pageNumber,
      pageSize: dto.pageSize,
      totalPages: dto.totalPages,
      hasPreviousPage: dto.hasPreviousPage,
      hasNextPage: dto.hasNextPage,
    );
  }
}
