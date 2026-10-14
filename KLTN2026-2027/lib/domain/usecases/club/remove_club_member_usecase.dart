// lib/domain/usecases/club/remove_club_member_usecase.dart

import '../../repositories/club_repository.dart';

class RemoveClubMemberParams {
  final String clubId;
  final String userId;

  const RemoveClubMemberParams({
    required this.clubId,
    required this.userId,
  });
}

class RemoveClubMemberUseCase {
  final ClubRepository repository;

  RemoveClubMemberUseCase(this.repository);

  Future<bool> execute(RemoveClubMemberParams params) {
    return repository.removeMember(
      clubId: params.clubId,
      userId: params.userId,
    );
  }
}
