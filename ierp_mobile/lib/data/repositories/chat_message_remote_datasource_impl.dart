import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_message_repository.dart';
import '../datasource/remote/abstract/chat_message_remote_datasource.dart';
import '../mapper/chat_message_mapper.dart';

class ChatMessageRepositoryImpl implements ChatMessageRepository {
  final ChatMessageRemoteDatasource remoteDatasource;

  ChatMessageRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ChatMessage>> getUserChatMessages({
    required int userId,
    int? tenantId,
    int? minMessageId,
  }) async {
    final dtos = await remoteDatasource.getUserChatMessages(
      userId: userId,
      tenantId: tenantId,
      minMessageId: minMessageId,
    );
    return dtos.map((dto) => ChatMessageMapper.toEntity(dto)).toList();
  }

  @override
  Future<void> sendMessage({
    required int userId,
    int? tenantId,
    required String message,
  }) async {
    throw UnimplementedError('Use SignalR service directly');
  }

  @override
  Future<void> markAllUnreadMessagesAsRead({
    required int userId,
    int? tenantId,
  }) async {
    await remoteDatasource.markAllUnreadMessagesAsRead(
      userId: userId,
      tenantId: tenantId,
    );
  }
}