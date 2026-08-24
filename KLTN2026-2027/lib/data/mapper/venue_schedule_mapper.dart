import '../../domain/entities/paged_response.dart';
import '../../domain/entities/venue_schedule.dart';
import '../dto/common/paged_result_dto.dart';
import '../dto/venue_schedule/venue_schedule_request_dto.dart';
import '../dto/venue_schedule/venue_schedule_response_dto.dart';

class VenueScheduleMapper {
  static VenueSchedule toEntity(VenueScheduleResponseDto dto) {
    return VenueSchedule(
      id: dto.id,
      venueId: dto.venueId,
      dayOfWeek: dto.dayOfWeek,
      openTime: dto.openTime,
      closeTime: dto.closeTime,
      isClosed: dto.isClosed,
    );
  }

  static VenueScheduleCreateRequestDto toCreateDto(VenueSchedule entity) {
    return VenueScheduleCreateRequestDto(
      venueId: entity.venueId,
      dayOfWeek: entity.dayOfWeek,
      openTime: entity.openTime,
      closeTime: entity.closeTime,
      isClosed: entity.isClosed,
    );
  }

  static PagedResponse<VenueSchedule> toPagedEntity(PagedResultDto<VenueScheduleResponseDto> dto) {
    return PagedResponse<VenueSchedule>(
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
