// lib/domain/usecases/club/get_club_members_usecase.dart

import '../../../app/usecase.dart';
import '../../entities/club/club_member.dart';
import '../../repositories/club_repository.dart';

class GetClubMembersUseCase implements UseCaseWithParams<List<ClubMember>, String> {
  final ClubRepository repository;

  GetClubMembersUseCase(this.repository);

  @override
  Future<List<ClubMember>> execute(String clubId) => repository.getClubMembers(clubId);
}
