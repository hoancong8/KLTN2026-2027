// lib/domain/usecases/club/get_club_by_id_usecase.dart

import '../../../app/usecase.dart';
import '../../entities/club/club.dart';
import '../../repositories/club_repository.dart';

class GetClubByIdUseCase implements UseCaseWithParams<Club, String> {
  final ClubRepository repository;

  GetClubByIdUseCase(this.repository);

  @override
  Future<Club> execute(String clubId) => repository.getClubById(clubId);
}
