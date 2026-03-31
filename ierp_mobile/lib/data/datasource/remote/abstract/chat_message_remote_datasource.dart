import '../../../dto/chat/chat_message_dto.dart';

abstract class ChatMessageRemoteDatasource {
  Future<List<ChatMessageDto>> getUserChatMessages({
    required int userId,
    int? tenantId,
    int? minMessageId,
  });

  Future<void> markAllUnreadMessagesAsRead({
    required int userId,
    int? tenantId,
  });
}