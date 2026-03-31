import '../../repositories/chat_message_repository.dart';

class MarkAllUnreadMessagesAsReadUseCase {
  final ChatMessageRepository repository;

  MarkAllUnreadMessagesAsReadUseCase(this.repository);

  Future<void> execute({
    required int userId,
    int? tenantId,
  }) {
    return repository.markAllUnreadMessagesAsRead(
      userId: userId,
      tenantId: tenantId,
    );
  }
}
