import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/chat/chat_friend_response_dto.dart';
import '../../../dto/chat/chat_upload_response_dto.dart';
import '../../../dto/chat/find_users_response_dto.dart';
import '../abstract/chat_remote_datasource.dart';
import '../base_remote_datasource.dart';

class ChatRemoteDatasourceImpl extends BaseRemoteDatasource
    implements ChatRemoteDatasource {
  final Dio dio;

  ChatRemoteDatasourceImpl(this.dio);

  @override
  Future<ChatFriendsResponseDto> getChatFriends() async {
    try {
      final res = await dio.get(AppConfig.getUserChatFriendsWithSettings);
      return handleResponse(
        res,
            (e) => ChatFriendsResponseDto.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> blockUser(int userId, int? tenantId) async {
    try {
      await dio.post(AppConfig.blockUser, data: {'userId': userId, 'tenantId': tenantId});
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> unblockUser(int userId, int? tenantId) async {
    try {
      await dio.post(AppConfig.unblockUser, data: {'userId': userId, 'tenantId': tenantId});
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<ChatUploadResultDto> uploadFile(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final res = await dio.post(AppConfig.uploadChatFile, data: formData);
      return handleResponse(
        res,
            (e) => ChatUploadResultDto.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<FindUsersResultDto> findUsers(
      String filter,
      int maxResultCount,
      int skipCount,
      ) async {
    try {
      final res = await dio.post(
        AppConfig.findUsers,
        data: {
          'filter': filter,
          'maxResultCount': maxResultCount,
          'skipCount': skipCount,
          'excludeCurrentUser': true,
        },
      );
      return handleResponse(
        res,
            (e) => FindUsersResultDto.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> createFriendshipRequest(int userId, int? tenantId) async {
    try {
      await dio.post(
        AppConfig.createFriendshipRequest,
        data: {'userId': userId, 'tenantId': tenantId},
      );
    } catch (e) {
      throw handleError(e);
    }
  }
}
