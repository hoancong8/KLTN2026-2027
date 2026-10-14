// lib/domain/usecases/club/get_my_clubs_usecase.dart

import '../../../app/usecase.dart';
import '../../entities/club/my_club.dart';
import '../../repositories/club_repository.dart';

class GetMyClubsUseCase implements UseCase<List<MyClub>> {
  final ClubRepository repository;

  GetMyClubsUseCase(this.repository);

  @override
  Future<List<MyClub>> execute() => repository.getMyClubs();
}
