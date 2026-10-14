// lib/domain/usecases/club/switch_club_context_usecase.dart

import '../../../app/usecase.dart';
import '../../entities/club/active_club_context.dart';
import '../../repositories/club_repository.dart';

class SwitchClubContextUseCase implements UseCaseWithParams<ActiveClubContext, String> {
  final ClubRepository repository;

  SwitchClubContextUseCase(this.repository);

  @override
  Future<ActiveClubContext> execute(String clubId) => repository.switchClubContext(clubId);
}
