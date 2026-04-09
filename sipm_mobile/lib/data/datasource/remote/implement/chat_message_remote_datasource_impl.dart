import 'package:dio/dio.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/data/dto/chat/chat_message_dto.dart';

import '../abstract/chat_message_remote_datasource.dart';

class ChatMessageRemoteDatasourceImpl implements ChatMessageRemoteDatasource {
  final Dio dio;
  ChatMessageRemoteDatasourceImpl(this.dio);

  @override
  Future<List<ChatMessageDto>> getUserChatMessages({
    required int userId,
    int? tenantId,
    int? minMessageId,
  }) async {
    try {
      final res = await dio.get(
        AppConfig.getUserChatMessages,
        queryParameters: {
          'userId': userId,
          'tenantId': ?tenantId,
          'minMessageId': ?minMessageId,
        },
      );

      final items = res.data['result']['items'] as List;
      return items.map((json) => ChatMessageDto.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAllUnreadMessagesAsRead({
    required int userId,
    int? tenantId,
  }) async {
    await dio.post(
      AppConfig.markAllUnreadMessagesOfUserAsRead,
      data: {'userId': userId, 'tenantId': ?tenantId},
    );
  }
}
