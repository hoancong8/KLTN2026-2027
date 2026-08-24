import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/venue_schedule/venue_schedule_request_dto.dart';
import '../../../dto/venue_schedule/venue_schedule_response_dto.dart';

abstract class VenueScheduleRemoteDatasource {
  Future<PagedResultDto<VenueScheduleResponseDto>> getVenueSchedules({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  });
  Future<void> createVenueSchedule(VenueScheduleCreateRequestDto request);
  Future<void> updateVenueSchedule(String id, VenueScheduleUpdateRequestDto request);
  Future<void> deleteVenueSchedule(String id);
}
