import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/datasource/remote/implement/reputation_remote_datasource.dart';
import '../../data/repositories/reputation_repository_impl.dart';
import '../../domain/entities/reputation/reputation.dart';
import '../../domain/exceptions/app_exception.dart';
import '../../domain/repositories/reputation_repository.dart';
import '../../domain/usecases/reputation/submit_session_review_use_case.dart';
import '../provider.dart';

final reputationRepositoryProvider = Provider<ReputationRepository>((ref) =>
    ReputationRepositoryImpl(ReputationRemoteDatasource(ref.watch(dioProvider))));

final submitSessionReviewProvider = Provider<SubmitSessionReviewUseCase>((ref) =>
    SubmitSessionReviewUseCase(ref.watch(reputationRepositoryProvider)));

final reputationRevisionProvider = StateProvider<int>((ref) => 0);

final reputationInvitationsProvider = FutureProvider.autoDispose
    .family<ReputationPage<ReviewInvitation>, ({int page, String? sessionId})>((ref, query) {
  ref.watch(reputationRevisionProvider);
  if (ref.watch(authTokenProvider) == null) {
    return Future.value(ReputationPage(const [], query.page, 20, 0));
  }
  return ref.watch(reputationRepositoryProvider).invitations(query.page, sessionId: query.sessionId);
});

final playerReputationProvider = FutureProvider.autoDispose.family<PlayerReputation, String>((ref, id) {
  ref.watch(reputationRevisionProvider);
  if (ref.watch(authTokenProvider) == null) throw const ForbiddenException();
  return ref.watch(reputationRepositoryProvider).player(id);
});

final reputationEntriesProvider = FutureProvider.autoDispose.family<ReputationPage<ReputationEntry>, int>((ref, page) {
  ref.watch(reputationRevisionProvider);
  if (ref.watch(authTokenProvider) == null) throw const ForbiddenException();
  return ref.watch(reputationRepositoryProvider).entries(page);
});

final groupQualityProvider = FutureProvider.autoDispose.family<GroupQuality, String>((ref, groupId) {
  ref.watch(reputationRevisionProvider);
  if (ref.watch(authTokenProvider) == null) throw const ForbiddenException();
  return ref.watch(reputationRepositoryProvider).quality(groupId);
});

const reputationAuditPermission = 'OPERATIONS.SESSION.UPDATE';

final reputationAuditProvider = FutureProvider.autoDispose
    .family<SessionReputationAudit, ({String clubId, String sessionId, int page})>((ref, query) {
  ref.watch(reputationRevisionProvider);
  if (ref.watch(authTokenProvider) == null ||
      ref.watch(activeClubContextProvider)?.clubId != query.clubId ||
      !ref.watch(hasClubPermissionProvider(reputationAuditPermission))) {
    throw const ForbiddenException();
  }
  return ref.watch(reputationRepositoryProvider).audit(query.clubId, query.sessionId, query.page);
});
