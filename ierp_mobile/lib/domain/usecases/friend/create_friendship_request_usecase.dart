import '../../repositories/chat_repository.dart';

class CreateFriendshipRequestUseCase {
  final ChatRepository repository;

  CreateFriendshipRequestUseCase(this.repository);

  Future<void> execute(int userId, int? tenantId) async {
    await repository.createFriendshipRequest(userId, tenantId);
  }
}