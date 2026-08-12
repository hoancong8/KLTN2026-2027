import '../../repositories/chat_repository.dart';

class UnblockUserUseCase {
  final ChatRepository repository;

  UnblockUserUseCase(this.repository);

  Future<void> execute(int userId, int? tenantId) async {
    await repository.unblockUser(userId, tenantId);
  }
}
