import 'package:dio/dio.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/data/datasource/remote/base_remote_datasource.dart';
import 'package:kltn2026_2027/data/dto/chat/chat_message_dto.dart';

import '../abstract/chat_message_remote_datasource.dart';
import '../base_remote_datasource.dart';

class ChatMessageRemoteDatasourceImpl extends BaseRemoteDatasource
    implements ChatMessageRemoteDatasource {
  final Dio dio;
  ChatMessageRemoteDatasourceImpl(this.dio);

  @override
  Future<List<ChatMessageDto>> getUserChatMessages({
    required int userId,
    int? tenantId,
    int? minMessageId,
    // TODO: implement getUserChatMessages
  }) async {
    try {
      final res = await dio.get(
        AppConfig.getUserChatMessages,
        queryParameters: {
          'userId': userId,
          if (tenantId != null) 'tenantId': tenantId,
          if (minMessageId != null) 'minMessageId': minMessageId,
        },
      );
      return handleListResponse(res, (data) => ChatMessageDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> markAllUnreadMessagesAsRead({
    required int userId,
    int? tenantId,
  }) async {
    try {
      final res = await dio.post(
        AppConfig.markAllUnreadMessagesOfUserAsRead,
        data: {'userId': userId, if (tenantId != null) 'tenantId': tenantId},
      );
    } catch (e) {
      throw handleError(e);
    }
  }
}
