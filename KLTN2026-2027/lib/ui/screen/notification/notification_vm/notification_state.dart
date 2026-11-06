import 'package:equatable/equatable.dart';
import '../../../../domain/entities/app_notification.dart';
import '../../../../domain/exceptions/app_exception.dart';

class NotificationState extends Equatable {
  final bool isLoading;
  final List<AppNotification> notifications;
  final String activeFilter; // 'ALL', 'UNREAD', 'PAYMENT', 'MATCH'
  final AppException? error;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.activeFilter = 'ALL',
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<AppNotification> get filteredNotifications {
    switch (activeFilter) {
      case 'UNREAD':
        return notifications.where((n) => !n.isRead).toList();
      case 'PAYMENT':
        return notifications.where((n) => n.type.toUpperCase() == 'PAYMENT').toList();
      case 'MATCH':
        return notifications
            .where((n) => n.type.toUpperCase() == 'MATCH' || n.type.toUpperCase() == 'ROTATION')
            .toList();
      default:
        return notifications;
    }
  }

  NotificationState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
    String? activeFilter,
    AppException? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      activeFilter: activeFilter ?? this.activeFilter,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    notifications,
    activeFilter,
    error,
  ];
}

