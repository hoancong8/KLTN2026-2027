// lib/domain/usecases/club/update_member_role_usecase.dart

import '../../enums/club_role.dart';
import '../../repositories/club_repository.dart';

class UpdateMemberRoleParams {
  final String clubId;
  final String userId;
  final ClubRole role;

  const UpdateMemberRoleParams({
    required this.clubId,
    required this.userId,
    required this.role,
  });
}

class UpdateMemberRoleUseCase {
  final ClubRepository repository;

  UpdateMemberRoleUseCase(this.repository);

  Future<bool> execute(UpdateMemberRoleParams params) {
    return repository.updateMemberRole(
      clubId: params.clubId,
      userId: params.userId,
      role: params.role,
    );
  }
}
