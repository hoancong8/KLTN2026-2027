import '../../domain/entities/permission_group.dart';
import '../dto/user/permission_group_response_dto.dart';

class PermissionGroupMapper {
  static PermissionItem toItemEntity(PermissionItemResponseDto dto) {
    return PermissionItem(
      name: dto.name,
      displayName: dto.displayName,
    );
  }

  static PermissionGroup toGroupEntity(PermissionGroupResponseDto dto) {
    return PermissionGroup(
      name: dto.name,
      displayName: dto.displayName,
      children: dto.children.map((c) => toGroupEntity(c)).toList(),
      permissions: dto.permissions.map((e) => toItemEntity(e)).toList(),
    );
  }
}
