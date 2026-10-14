// lib/domain/usecases/club/club_role_usecases.dart

import '../../entities/club/club_role_item.dart';
import '../../repositories/club_repository.dart';

class GetClubRolesUseCase {
  final ClubRepository repository;
  GetClubRolesUseCase(this.repository);

  Future<List<ClubRoleItem>> execute(String clubId) => repository.getClubRoles(clubId);
}

class CreateClubRoleParams {
  final String clubId;
  final String roleName;
  final String? description;
  final List<String> permissionIds;
  final bool isDefault;

  const CreateClubRoleParams({
    required this.clubId,
    required this.roleName,
    this.description,
    this.permissionIds = const [],
    this.isDefault = false,
  });
}

class CreateClubRoleUseCase {
  final ClubRepository repository;
  CreateClubRoleUseCase(this.repository);

  Future<String> execute(CreateClubRoleParams params) {
    return repository.createClubRole(
      clubId: params.clubId,
      roleName: params.roleName,
      description: params.description,
      permissionIds: params.permissionIds,
      isDefault: params.isDefault,
    );
  }
}

class UpdateClubRolePermissionsUseCase {
  final ClubRepository repository;
  UpdateClubRolePermissionsUseCase(this.repository);

  Future<bool> execute(String clubId, String roleId, List<String> permissionIds) =>
      repository.updateClubRolePermissions(
        clubId: clubId,
        roleId: roleId,
        permissionIds: permissionIds,
      );
}

class DeleteClubRoleUseCase {
  final ClubRepository repository;
  DeleteClubRoleUseCase(this.repository);

  Future<bool> execute(String clubId, String roleId) =>
      repository.deleteClubRole(clubId: clubId, roleId: roleId);
}
