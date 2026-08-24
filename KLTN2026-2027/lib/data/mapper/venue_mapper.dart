import '../../domain/entities/paged_response.dart';
import '../../domain/entities/venue.dart';
import '../dto/common/paged_result_dto.dart';
import '../dto/venue/venue_request_dto.dart';
import '../dto/venue/venue_response_dto.dart';

class VenueMapper {
  static Venue toEntity(VenueResponseDto dto) {
    return Venue(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      address: dto.address,
      latitude: dto.latitude,
      longitude: dto.longitude,
      openTime: dto.openTime,
      closeTime: dto.closeTime,
      isActive: dto.isActive,
    );
  }

  static VenueRequestDto toDto(Venue entity) {
    return VenueRequestDto(
      name: entity.name,
      description: entity.description,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      openTime: entity.openTime,
      closeTime: entity.closeTime,
    );
  }

  static PagedResponse<Venue> toPagedEntity(PagedResultDto<VenueResponseDto> dto) {
    return PagedResponse<Venue>(
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
