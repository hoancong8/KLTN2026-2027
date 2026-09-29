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
    String? email,
    String? userName,
    String? sortColumn,
    int sortDirection = 1,
  }) {
    return repository.getUsers(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchTerm: searchTerm,
      email: email,
      userName: userName,
      sortColumn: sortColumn,
      sortDirection: sortDirection,
    );
  }
}
