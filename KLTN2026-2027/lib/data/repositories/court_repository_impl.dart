import '../../domain/entities/court.dart';
import '../../domain/entities/paged_response.dart';
import '../../domain/repositories/court_repository.dart';
import '../datasource/remote/abstract/court_remote_datasource.dart';
import '../mapper/court_mapper.dart';

class CourtRepositoryImpl implements CourtRepository {
  final CourtRemoteDatasource remoteDatasource;

  CourtRepositoryImpl(this.remoteDatasource);

  @override
  Future<PagedResponse<Court>> getCourts({
    String? venueId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final dto = await remoteDatasource.getCourts(
      venueId: venueId,
      isAvailable: isAvailable,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return CourtMapper.toPagedEntity(dto);
  }

  @override
  Future<void> createCourt(Court court) async {
    final dto = CourtMapper.toCreateDto(court);
    await remoteDatasource.createCourt(dto);
  }

  @override
  Future<void> updateCourt(String id, Court court) async {
    final dto = CourtMapper.toUpdateDto(court);
    await remoteDatasource.updateCourt(id, dto);
  }

  @override
  Future<void> deleteCourt(String id) async {
    await remoteDatasource.deleteCourt(id);
  }
}
