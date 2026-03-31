import '../entities/chat_message.dart';

abstract class ChatMessageRepository {
  Future<List<ChatMessage>> getUserChatMessages({
    required int userId,
    int? tenantId,
    int? minMessageId,
  });

  Future<void> markAllUnreadMessagesAsRead({
    required int userId,
    int? tenantId,
  });

  Future<void> sendMessage({
    required int userId,
    int? tenantId,
    required String message,
  });
}
