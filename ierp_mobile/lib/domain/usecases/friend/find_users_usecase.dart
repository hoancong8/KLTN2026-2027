import '../../entities/user_lookup.dart';
import '../../repositories/chat_repository.dart';

class FindUsersUseCase {
  final ChatRepository repository;

  FindUsersUseCase(this.repository);

  Future<List<UserLookup>> execute(
      String filter, {
        int maxResultCount = 20,
        int skipCount = 0,
      }) async {
    return repository.findUsers(filter, maxResultCount, skipCount);
  }
}