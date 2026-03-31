class ChatFriendDto {
  final int friendUserId;
  final int? friendTenantId;
  final String friendUserName;
  final String? friendTenancyName;
  final String? friendProfilePictureId;
  final int unreadMessageCount;
  final bool isOnline;
  final int state;

  ChatFriendDto({
    required this.friendUserId,
    this.friendTenantId,
    required this.friendUserName,
    this.friendTenancyName,
    this.friendProfilePictureId,
    required this.unreadMessageCount,
    required this.isOnline,
    required this.state,
  });

  factory ChatFriendDto.fromJson(Map<String, dynamic> json) {
    return ChatFriendDto(
      friendUserId: json['friendUserId'] as int,
      friendTenantId: json['friendTenantId'] as int?,
      friendUserName: json['friendUserName'] as String,
      friendTenancyName: json['friendTenancyName'] as String?,
      friendProfilePictureId: json['friendProfilePictureId'] as String?,
      unreadMessageCount: json['unreadMessageCount'] as int,
      isOnline: json['isOnline'] as bool,
      state: json['state'] as int,
    );
  }
}
