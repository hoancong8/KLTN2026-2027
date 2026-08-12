import '../../repositories/chat_repository.dart';

class BlockUserUseCase {
  final ChatRepository repository;

  BlockUserUseCase(this.repository);

  Future<void> execute(int userId, int? tenantId) async {
    await repository.blockUser(userId, tenantId);
  }
}
