class ChatFriend {
  final int userId;
  final int? tenantId;
  final String userName;
  final String? tenancyName;
  final String? profilePictureId;
  final int unreadMessageCount;
  final bool isOnline;
  final int state;

  const ChatFriend({
    required this.userId,
    this.tenantId,
    required this.userName,
    this.tenancyName,
    this.profilePictureId,
    required this.unreadMessageCount,
    required this.isOnline,
    required this.state,
  });

  ChatFriend copyWith({
    int? userId,
    int? tenantId,
    String? userName,
    String? tenancyName,
    String? profilePictureId,
    int? unreadMessageCount,
    bool? isOnline,
    int? state,
  }) {
    return ChatFriend(
      userId: userId ?? this.userId,
      tenantId: tenantId ?? this.tenantId,
      userName: userName ?? this.userName,
      tenancyName: tenancyName ?? this.tenancyName,
      profilePictureId: profilePictureId ?? this.profilePictureId,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
      isOnline: isOnline ?? this.isOnline,
      state: state ?? this.state,
    );
  }
}
