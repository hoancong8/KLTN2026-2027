import '../../domain/entities/reputation/reputation.dart';
import '../../domain/repositories/reputation_repository.dart';
import '../datasource/remote/implement/reputation_remote_datasource.dart';
import '../mapper/reputation_mapper.dart';

class ReputationRepositoryImpl implements ReputationRepository {
  const ReputationRepositoryImpl(this._source);

  final ReputationRemoteDatasource _source;

  @override
  Future<ReputationPage<ReviewInvitation>> invitations(int page, {String? sessionId}) async =>
      ReputationMapper.page(await _source.invitations(page, sessionId), ReputationMapper.invitation);

  @override
  Future<SessionRating> submitReview(String sessionId, int rating, String? comment) async {
    final note = comment?.trim();
    return ReputationMapper.review(await _source.submit(sessionId, rating, note?.isEmpty == true ? null : note));
  }

  @override
  Future<PlayerReputation> player(String userId) async => ReputationMapper.player(await _source.player(userId));

  @override
  Future<ReputationPage<ReputationEntry>> entries(int page) async =>
      ReputationMapper.page(await _source.entries(page), ReputationMapper.entry);

  @override
  Future<GroupQuality> quality(String groupId) async => ReputationMapper.quality(await _source.quality(groupId));

  @override
  Future<SessionReputationAudit> audit(String clubId, String sessionId, int page) async =>
      ReputationMapper.audit(await _source.audit(clubId, sessionId, page));
}
