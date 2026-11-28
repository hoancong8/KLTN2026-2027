import '../../entities/reputation/reputation.dart';
import '../../repositories/reputation_repository.dart';

class SubmitSessionReviewUseCase {
  const SubmitSessionReviewUseCase(this._repository);

  final ReputationRepository _repository;

  Future<SessionRating> call(String sessionId, int rating, String comment) =>
      _repository.submitReview(sessionId, rating, comment);
}
