import '../../entities/court.dart';
import '../../repositories/court_repository.dart';

class ManageCourtUseCase {
  final CourtRepository repository;
  ManageCourtUseCase(this.repository);

  Future<void> create(Court court) => repository.createCourt(court);
  Future<void> update(String id, Court court) => repository.updateCourt(id, court);
  Future<void> delete(String id) => repository.deleteCourt(id);
}
