import 'chat_friend_dto.dart';

class ChatFriendsResponseDto {
  final String serverTime;
  final List<ChatFriendDto> friends;

  ChatFriendsResponseDto({
    required this.serverTime,
    required this.friends,
  });

  factory ChatFriendsResponseDto.fromJson(Map<String, dynamic> json) {
    return ChatFriendsResponseDto(
      serverTime: json['serverTime'] as String,
      friends: (json['friends'] as List)
          .map((e) => ChatFriendDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}