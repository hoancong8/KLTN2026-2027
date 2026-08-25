import '../../domain/entities/app_role.dart';
import '../dto/role/role_response_dto.dart';
import 'permission_group_mapper.dart';

class RoleMapper {
  static AppRole toEntity(RoleResponseDto dto) {
    return AppRole(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      permissions: dto.permissions
          .map((g) => PermissionGroupMapper.toGroupEntity(g))
          .toList(),
    );
  }
}
