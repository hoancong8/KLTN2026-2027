import '../../entities/venue.dart';
import '../../repositories/venue_repository.dart';

class ManageVenueUseCase {
  final VenueRepository repository;
  ManageVenueUseCase(this.repository);

  Future<Venue> getById(String id) => repository.getVenueById(id);
  Future<String> create(Venue venue) => repository.createVenue(venue);
  Future<void> update(String id, Venue venue) => repository.updateVenue(id, venue);
  Future<void> delete(String id) => repository.deleteVenue(id);
}
