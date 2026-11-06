import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/data/dto/auth/login_request_dto.dart';
import 'package:kltn2026_2027/data/dto/notification/notification_dto.dart';
import 'package:kltn2026_2027/data/mapper/notification_mapper.dart';
import 'package:kltn2026_2027/domain/entities/app_notification.dart';
import 'package:kltn2026_2027/ui/screen/notification/notification_vm/notification_state.dart';

void main() {
  group('Notification Feature Tests', () {
    test('LoginRequestDto includes deviceToken and platform in toJson', () {
      final dto = LoginRequestDto(
        email: 'test@example.com',
        password: 'Password123',
        deviceToken: 'mock_fcm_token_123',
        platform: 'ANDROID',
      );

      final json = dto.toJson();
      expect(json['email'], 'test@example.com');
      expect(json['password'], 'Password123');
      expect(json['deviceToken'], 'mock_fcm_token_123');
      expect(json['platform'], 'ANDROID');
    });

    test('NotificationDto parses json defensively', () {
      final raw = {
        'id': 'abc-123',
        'title': 'Trận đấu mới',
        'content': 'Đã đến lượt vào sân 1',
        'type': 'MATCH',
        'referenceType': 'Session',
        'referenceId': 'session-456',
        'isRead': 'true',
        'createdAt': '2026-11-06T10:00:00Z',
      };

      final dto = NotificationDto.fromJson(raw);
      expect(dto.id, 'abc-123');
      expect(dto.title, 'Trận đấu mới');
      expect(dto.type, 'MATCH');
      expect(dto.isRead, true);

      final entity = NotificationMapper.toEntity(dto);
      expect(entity.id, 'abc-123');
      expect(entity.title, 'Trận đấu mới');
      expect(entity.isRead, true);
    });

    test('NotificationState calculates unreadCount and filters correctly', () {
      final now = DateTime.now();
      final notifications = [
        AppNotification(
          id: '1',
          title: 'Thu phí',
          content: 'Quyết toán buổi chơi',
          type: 'PAYMENT',
          isRead: false,
          createdAt: now,
        ),
        AppNotification(
          id: '2',
          title: 'Đến lượt',
          content: 'Vào sân 2',
          type: 'MATCH',
          isRead: true,
          createdAt: now,
        ),
      ];

      final state = NotificationState(
        notifications: notifications,
        activeFilter: 'ALL',
      );

      expect(state.unreadCount, 1);
      expect(state.filteredNotifications.length, 2);

      final unreadState = state.copyWith(activeFilter: 'UNREAD');
      expect(unreadState.filteredNotifications.length, 1);
      expect(unreadState.filteredNotifications.first.id, '1');

      final matchState = state.copyWith(activeFilter: 'MATCH');
      expect(matchState.filteredNotifications.length, 1);
      expect(matchState.filteredNotifications.first.id, '2');
    });
  });
}

