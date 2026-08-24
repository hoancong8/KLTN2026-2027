import '../../entities/paged_response.dart';
import '../../entities/user_profile.dart';
import '../../repositories/user_repository.dart';

class GetUsersUseCase {
  final UserRepository repository;
  GetUsersUseCase(this.repository);

  Future<PagedResponse<UserProfile>> execute({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
  }) {
    return repository.getUsers(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchTerm: searchTerm,
    );
  }
}
