import '../consts/app_config.dart';

class ReputationNotice {
  const ReputationNotice(this.eventId, this.sessionId, this.recipientId, this.isInvitation);

  static ReputationNotice? fromData(Map<String, dynamic> data) {
    final kind = data['kind'];
    if (kind != 'ReviewInvitationPush' && kind != 'ReputationUpdatedPush') return null;
    final eventId = data['eventId'];
    final sessionId = data['sessionId'];
    final userId = data['recipientId'];
    if (eventId is! String || eventId.isEmpty || sessionId is! String || sessionId.isEmpty) return null;
    return ReputationNotice(eventId, sessionId, userId is String ? userId : null, kind == 'ReviewInvitationPush');
  }

  final String eventId;
  final String sessionId;
  final String? recipientId;
  final bool isInvitation;

  bool belongsTo(String userId) => recipientId == null || recipientId == userId;

  String get route => isInvitation ? AppConfig.reviewsRoute(sessionId: sessionId) : '/reputation/history';
}

class ReputationNotificationCoordinator {
  final Set<String> _seen = {};

  bool claim(ReputationNotice notice, String userId) {
    if (!notice.belongsTo(userId)) return false;
    final key = '$userId:${notice.eventId}';
    if (!_seen.add(key)) return false;
    if (_seen.length > 256) _seen.remove(_seen.first);
    return true;
  }

  void reset() => _seen.clear();
}
