import '../../domain/entities/paged_response.dart';
import '../../domain/entities/venue.dart';
import '../../domain/entities/venue_recommendation.dart';
import '../../domain/repositories/venue_repository.dart';
import '../datasource/remote/abstract/venue_remote_datasource.dart';
import '../mapper/venue_mapper.dart';

class VenueRepositoryImpl implements VenueRepository {
  final VenueRemoteDatasource remoteDatasource;

  VenueRepositoryImpl(this.remoteDatasource);

  @override
  Future<PagedResponse<Venue>> getVenues({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    bool? isActive,
  }) async {
    final dto = await remoteDatasource.getVenues(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchTerm: searchTerm,
      isActive: isActive,
    );
    return VenueMapper.toPagedEntity(dto);
  }

  @override
  Future<Venue> getVenueById(String id) async {
    final dto = await remoteDatasource.getVenueById(id);
    return VenueMapper.toEntity(dto);
  }

  @override
  Future<String> createVenue(Venue venue) async {
    final dto = VenueMapper.toDto(venue);
    return await remoteDatasource.createVenue(dto);
  }

  @override
  Future<void> updateVenue(String id, Venue venue) async {
    final dto = VenueMapper.toDto(venue);
    await remoteDatasource.updateVenue(id, dto);
  }

  @override
  Future<void> deleteVenue(String id) async {
    await remoteDatasource.deleteVenue(id);
  }

  @override
  Future<PagedResponse<VenueRecommendation>> getVenueRecommendations({
    double? latitude,
    double? longitude,
    double maxDistanceKm = 20.0,
    String? sportTypeId,
    DateTime? date,
    String? startTime,
    String? endTime,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final dto = await remoteDatasource.getVenueRecommendations(
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
      sportTypeId: sportTypeId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return VenueMapper.toPagedRecommendationEntity(dto);
  }
}
