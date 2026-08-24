import '../../entities/paged_response.dart';
import '../../entities/venue.dart';
import '../../repositories/venue_repository.dart';

class GetVenuesUseCase {
  final VenueRepository repository;
  GetVenuesUseCase(this.repository);

  Future<PagedResponse<Venue>> execute({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    bool? isActive,
  }) {
    return repository.getVenues(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchTerm: searchTerm,
      isActive: isActive,
    );
  }
}
