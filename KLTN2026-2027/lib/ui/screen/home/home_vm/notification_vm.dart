import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/consts/app_log.dart';
import 'package:kltn2026_2027/domain/entities/notification_message.dart';
import 'package:kltn2026_2027/domain/repositories/notification_repository.dart';
import '../../../../app/provider.dart';
import 'notification_state.dart';

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      return NotificationViewModel(ref.watch(notificationRepositoryProvider));
    });

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository repository;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _messageOpenedSubscription;

  NotificationViewModel(this.repository) : super(const NotificationState()) {
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _messageSubscription = repository.onMessageReceived.listen((message) {
      state = state.copyWith(unreadCount: state.unreadCount + 1);
    });

    _messageOpenedSubscription = repository.onMessageOpened.listen((message) {
      _handleNotificationClick(message);
    });
  }

  void _handleNotificationClick(NotificationMessage message) {
    AppLog.info('[Notification] Clicked: ${message.title}');
  }

  void markAsRead() {
    state = state.copyWith(unreadCount: 0);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
    super.dispose();
  }
}
