import '../../repositories/club_repository.dart';

class UpdateMemberFeePlanUseCase {
  final ClubRepository repository;
  const UpdateMemberFeePlanUseCase(this.repository);

  Future<bool> execute(String clubId, String userId, String memberType) =>
      repository.updateMemberFeePlan(
        clubId: clubId,
        userId: userId,
        memberType: memberType,
      );
}
