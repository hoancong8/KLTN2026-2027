import 'package:dio/dio.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import '../../../dto/chat/chat_friend_response_dto.dart';
import '../../../dto/chat/chat_upload_response_dto.dart';
import '../../../dto/chat/find_users_response_dto.dart';
import '../abstract/chat_remote_datasource.dart';

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final Dio dio;

  ChatRemoteDatasourceImpl(this.dio);

  @override
  Future<ChatFriendsResponseDto> getChatFriends() async {
    final res = await dio.get(AppConfig.getUserChatFriendsWithSettings);
    return ChatFriendsResponseDto.fromJson(res.data);
  }

  @override
  Future<void> blockUser(int userId, int? tenantId) async {
    await dio.post(
      AppConfig.blockUser,
      data: {'userId': userId, 'tenantId': tenantId},
    );
  }

  @override
  Future<void> unblockUser(int userId, int? tenantId) async {
    await dio.post(
      AppConfig.unblockUser,
      data: {'userId': userId, 'tenantId': tenantId},
    );
  }

  @override
  Future<ChatUploadResponseDto> uploadFile(
      String filePath,
      String fileName,
      ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final res = await dio.post(AppConfig.uploadChatFile, data: formData);
    return ChatUploadResponseDto.fromJson(res.data);
  }

  @override
  Future<FindUsersResponseDto> findUsers(
      String filter,
      int maxResultCount,
      int skipCount,
      ) async {
    final res = await dio.post(
      AppConfig.findUsers,
      data: {
        'filter': filter,
        'maxResultCount': maxResultCount,
        'skipCount': skipCount,
        'excludeCurrentUser': true,
      },
    );
    return FindUsersResponseDto.fromJson(res.data);
  }

  @override
  Future<void> createFriendshipRequest(int userId, int? tenantId) async {
    await dio.post(
      AppConfig.createFriendshipRequest,
      data: {'userId': userId, 'tenantId': tenantId},
    );
  }
}
