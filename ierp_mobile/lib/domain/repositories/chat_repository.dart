import '../entities/chat_friend.dart';
import '../entities/chat_upload_result.dart';
import '../entities/user_lookup.dart';

abstract class ChatRepository {
  Future<List<ChatFriend>> getChatFriends();
  Future<void> blockUser(int userId, int? tenantId);
  Future<void> unblockUser(int userId, int? tenantId);
  Future<ChatUploadResult> uploadFile(String filePath, String fileName);
  Future<List<UserLookup>> findUsers(
      String filter,
      int maxResultCount,
      int skipCount,
      );
  Future<void> createFriendshipRequest(int userId, int? tenantId);
}