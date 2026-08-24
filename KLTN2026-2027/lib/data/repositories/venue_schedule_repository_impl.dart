import '../../domain/entities/paged_response.dart';
import '../../domain/entities/venue_schedule.dart';
import '../../domain/repositories/venue_schedule_repository.dart';
import '../datasource/remote/abstract/venue_schedule_remote_datasource.dart';
import '../dto/venue_schedule/venue_schedule_request_dto.dart';
import '../mapper/venue_schedule_mapper.dart';

class VenueScheduleRepositoryImpl implements VenueScheduleRepository {
  final VenueScheduleRemoteDatasource remoteDatasource;

  VenueScheduleRepositoryImpl(this.remoteDatasource);

  @override
  Future<PagedResponse<VenueSchedule>> getVenueSchedules({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final dto = await remoteDatasource.getVenueSchedules(
      venueId: venueId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return VenueScheduleMapper.toPagedEntity(dto);
  }

  @override
  Future<void> createVenueSchedule(VenueSchedule schedule) async {
    final dto = VenueScheduleMapper.toCreateDto(schedule);
    await remoteDatasource.createVenueSchedule(dto);
  }

  @override
  Future<void> updateVenueSchedule(
    String id,
    String openTime,
    String closeTime,
    bool isClosed,
  ) async {
    final dto = VenueScheduleUpdateRequestDto(
      openTime: openTime,
      closeTime: closeTime,
      isClosed: isClosed,
    );
    await remoteDatasource.updateVenueSchedule(id, dto);
  }

  @override
  Future<void> deleteVenueSchedule(String id) async {
    await remoteDatasource.deleteVenueSchedule(id);
  }
}
