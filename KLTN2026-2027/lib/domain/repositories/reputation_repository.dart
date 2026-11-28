import '../entities/reputation/reputation.dart';

abstract interface class ReputationRepository {
  Future<ReputationPage<ReviewInvitation>> invitations(int page, {String? sessionId});
  Future<SessionRating> submitReview(String sessionId, int rating, String? comment);
  Future<PlayerReputation> player(String userId);
  Future<ReputationPage<ReputationEntry>> entries(int page);
  Future<GroupQuality> quality(String groupId);
  Future<SessionReputationAudit> audit(String clubId, String sessionId, int page);
}
