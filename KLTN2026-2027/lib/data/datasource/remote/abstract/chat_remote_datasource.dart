import '../../../dto/chat/chat_friend_response_dto.dart';
import '../../../dto/chat/chat_upload_response_dto.dart';
import '../../../dto/chat/find_users_response_dto.dart';

abstract class ChatRemoteDatasource {
  Future<ChatFriendsResponseDto> getChatFriends();
  Future<void> blockUser(int userId, int? tenantId);
  Future<void> unblockUser(int userId, int? tenantId);
  Future<ChatUploadResultDto> uploadFile(String filePath, String fileName);
  Future<FindUsersResultDto> findUsers(
      String filter,
      int maxResultCount,
      int skipCount,
      );
  Future<void> createFriendshipRequest(int userId, int? tenantId);
}
