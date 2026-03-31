import '../../domain/entities/chat_friend.dart';
import '../dto/chat/chat_friend_dto.dart';

class ChatMapper {
  static ChatFriend toEntity(ChatFriendDto dto) {
    return ChatFriend(
      userId: dto.friendUserId,
      tenantId: dto.friendTenantId,
      userName: dto.friendUserName,
      tenancyName: dto.friendTenancyName,
      profilePictureId: dto.friendProfilePictureId,
      unreadMessageCount: dto.unreadMessageCount,
      isOnline: dto.isOnline,
      state: dto.state,
    );
  }

  static List<ChatFriend> toEntityList(List<ChatFriendDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }
}
