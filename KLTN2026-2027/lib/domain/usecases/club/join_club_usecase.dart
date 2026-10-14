// lib/domain/usecases/club/join_club_usecase.dart

import '../../enums/club_role.dart';
import '../../repositories/club_repository.dart';

class JoinClubParams {
  final String clubCode;
  final ClubRole role;
  final String? nickname;

  const JoinClubParams({
    required this.clubCode,
    this.role = ClubRole.member,
    this.nickname,
  });
}

class JoinClubUseCase {
  final ClubRepository repository;

  JoinClubUseCase(this.repository);

  Future<String> execute(JoinClubParams params) {
    return repository.joinClub(
      clubCode: params.clubCode,
      role: params.role,
      nickname: params.nickname,
    );
  }
}
