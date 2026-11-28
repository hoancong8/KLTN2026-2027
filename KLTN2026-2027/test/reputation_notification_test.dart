import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/services/reputation_notification_coordinator.dart';

void main() {
  test('deduplicates the same invitation received by FCM and SignalR', () {
    final coordinator = ReputationNotificationCoordinator();
    final payload = {
      'eventId': 'invite-event',
      'sessionId': 'session-1',
      'kind': 'ReviewInvitationPush',
    };
    final fcm = ReputationNotice.fromData(payload)!;
    final signalR = ReputationNotice.fromData({...payload, 'recipientId': 'user-1'})!;

    expect(coordinator.claim(signalR, 'user-2'), isFalse);
    expect(coordinator.claim(fcm, 'user-1'), isTrue);
    expect(coordinator.claim(signalR, 'user-1'), isFalse);
    expect(signalR.route, AppConfig.reviewsRoute(sessionId: 'session-1'));

    final update = ReputationNotice.fromData({
      ...payload, 'eventId': 'update-event', 'kind': 'ReputationUpdatedPush',
    })!;
    expect(coordinator.claim(update, 'user-1'), isTrue);
    expect(update.isInvitation, isFalse);
  });
}
