import '../../entities/court.dart';
import '../../entities/paged_response.dart';
import '../../repositories/court_repository.dart';

class GetCourtsUseCase {
  final CourtRepository repository;
  GetCourtsUseCase(this.repository);

  Future<PagedResponse<Court>> execute({
    String? venueId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return repository.getCourts(
      venueId: venueId,
      isAvailable: isAvailable,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
