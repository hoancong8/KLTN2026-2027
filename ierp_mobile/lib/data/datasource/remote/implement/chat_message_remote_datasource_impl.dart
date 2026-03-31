import 'package:dio/dio.dart';
import 'package:ierp_mobile/app/consts/app_config.dart';
import 'package:ierp_mobile/data/dto/chat/chat_message_dto.dart';

import '../abstract/chat_message_remote_datasource.dart';

class ChatMessageRemoteDatasourceImpl implements ChatMessageRemoteDatasource {
  final Dio dio;
  ChatMessageRemoteDatasourceImpl(this.dio);

  @override
  Future<List<ChatMessageDto>> getUserChatMessages({required int userId, int? tenantId, int? minMessageId}) async{
    // TODO: implement getUserChatMessages
    try{
      final res = await dio.get(
        AppConfig.getUserChatMessages,
        queryParameters: {
          'userId': userId,
          if (tenantId != null) 'tenantId': tenantId,
          if (minMessageId != null) 'minMessageId': minMessageId,
        }
      );

      final items = res.data['result']['items'] as List;
      return items.map((json) => ChatMessageDto.fromJson(json)).toList();
    }catch(e){
      rethrow;
    }
  }

  @override
  Future<void> markAllUnreadMessagesAsRead({required int userId, int? tenantId}) async{
    // TODO: implement markAllUnreadMessagesAsRead
    await dio.post(AppConfig.markAllUnreadMessagesOfUserAsRead, data: {
      'userId': userId,
      if (tenantId != null) 'tenantId': tenantId,
    });
  }
  
}