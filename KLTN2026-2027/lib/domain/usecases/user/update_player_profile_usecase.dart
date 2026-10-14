import '../../enums/session_enums.dart';
import '../../repositories/user_repository.dart';

class UpdatePlayerProfileParams {
  final String fullName;
  final int gender;
  final String? avatarUrl;
  final SkillLevel skillLevel;
  final bool isOpenForGuest;

  const UpdatePlayerProfileParams({
    required this.fullName,
    required this.gender,
    this.avatarUrl,
    required this.skillLevel,
    required this.isOpenForGuest,
  });
}

class UpdatePlayerProfileUseCase {
  final UserRepository repository;
  UpdatePlayerProfileUseCase(this.repository);

  Future<void> execute(UpdatePlayerProfileParams params) {
    return repository.updateMyProfile(
      fullName: params.fullName,
      gender: params.gender,
      avatarUrl: params.avatarUrl,
      skillLevel: params.skillLevel,
      isOpenForGuest: params.isOpenForGuest,
    );
  }
}
