import '../../entities/chat_message.dart';
import '../../repositories/chat_message_repository.dart';

class GetChatMessagesUseCase {
  final ChatMessageRepository repository;

  GetChatMessagesUseCase(this.repository);

  Future<List<ChatMessage>> execute({
    required int userId,
    int? tenantId,
    int? minMessageId,
  }) {
    return repository.getUserChatMessages(
      userId: userId,
      tenantId: tenantId,
      minMessageId: minMessageId,
    );
  }
}