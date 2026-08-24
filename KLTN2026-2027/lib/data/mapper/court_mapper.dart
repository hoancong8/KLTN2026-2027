import '../../domain/entities/court.dart';
import '../../domain/entities/paged_response.dart';
import '../dto/common/paged_result_dto.dart';
import '../dto/court/court_request_dto.dart';
import '../dto/court/court_response_dto.dart';

class CourtMapper {
  static Court toEntity(CourtResponseDto dto) {
    return Court(
      id: dto.id,
      venueId: dto.venueId,
      name: dto.name,
      description: dto.description,
      pricePerHour: dto.pricePerHour,
      isAvailable: dto.isAvailable,
    );
  }

  static CourtCreateRequestDto toCreateDto(Court entity) {
    return CourtCreateRequestDto(
      name: entity.name,
      description: entity.description,
      pricePerHour: entity.pricePerHour,
    );
  }

  static CourtUpdateRequestDto toUpdateDto(Court entity) {
    return CourtUpdateRequestDto(
      name: entity.name,
      description: entity.description,
      pricePerHour: entity.pricePerHour,
      isAvailable: entity.isAvailable,
    );
  }

  static PagedResponse<Court> toPagedEntity(PagedResultDto<CourtResponseDto> dto) {
    return PagedResponse<Court>(
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
