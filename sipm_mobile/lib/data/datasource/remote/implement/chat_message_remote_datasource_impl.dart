import 'package:dio/dio.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/data/dto/chat/chat_message_dto.dart';

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

      return handleListResponse(res, (json) => ChatMessageDto.fromJson(json));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> markAllUnreadMessagesAsRead({
    required int userId,
    int? tenantId,
    // TODO: implement markAllUnreadMessagesAsRead
  }) async {
    try {
      final res = await dio.post(
        AppConfig.markAllUnreadMessagesOfUserAsRead,
        data: {
          'userId': userId,
          if (tenantId != null) 'tenantId': tenantId,
        },
      );

    } catch (e) {
      throw handleError(e);
    }
  }
}
