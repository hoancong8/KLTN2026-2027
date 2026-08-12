import '../../../domain/entities/chat_message.dart';
import '../dto/chat/chat_message_dto.dart';

class ChatMessageMapper {
  static ChatMessage toEntity(ChatMessageDto dto) {
    return ChatMessage(
      id: dto.id,
      userId: dto.userId,
      tenantId: dto.tenantId,
      targetUserId: dto.targetUserId,
      targetTenantId: dto.targetTenantId,
      side: dto.side,
      readState: dto.readState,
      receiverReadState: dto.receiverReadState,
      message: dto.message,
      creationTime: DateTime.parse(dto.creationTime),
      sharedMessageId: dto.sharedMessageId,
    );
  }
}
