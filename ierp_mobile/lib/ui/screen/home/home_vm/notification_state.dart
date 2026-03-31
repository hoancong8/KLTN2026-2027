class NotificationState {
  final int unreadCount;

  const NotificationState({
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    int? unreadCount,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}