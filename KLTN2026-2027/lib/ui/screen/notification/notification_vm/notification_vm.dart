import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/notification/get_notifications_usecase.dart';
import '../../../../domain/usecases/notification/mark_all_notifications_read_usecase.dart';
import '../../../../domain/usecases/notification/mark_notification_read_usecase.dart';
import 'notification_state.dart';

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  return NotificationViewModel(
    ref.watch(getNotificationsUseCaseProvider),
    ref.watch(markNotificationReadUseCaseProvider),
    ref.watch(markAllNotificationsReadUseCaseProvider),
  );
});

class NotificationViewModel extends StateNotifier<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;

  NotificationViewModel(
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase,
  ) : super(const NotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _getNotificationsUseCase.execute();
      state = state.copyWith(
        isLoading: false,
        notifications: list,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: e.toString()),
      );
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> markAsRead(String id) async {
    final updatedList = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updatedList);

    try {
      await _markNotificationReadUseCase.execute(id);
    } catch (_) {
      // Background sync, no need to revert for read status
    }
  }

  Future<void> markAllAsRead() async {
    final updatedList = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updatedList);

    try {
      await _markAllNotificationsReadUseCase.execute();
    } catch (_) {
      // Background sync
    }
  }

  Future<void> refresh() => loadNotifications();
}
