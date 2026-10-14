import '../../entities/club/club_detail.dart';
import '../../repositories/club_repository.dart';

class GetClubDetailUseCase {
  final ClubRepository repository;
  GetClubDetailUseCase(this.repository);

  Future<ClubDetail> execute(String clubId) => repository.getClubDetail(clubId);
}
