// lib/data/mapper/club_role_mapper.dart

import '../../domain/entities/club/club_role_item.dart';
import '../dto/club/club_role_response_dto.dart';

class ClubRoleMapper {
  static ClubRoleItem toEntity(ClubRoleResponseDto dto) {
    return ClubRoleItem(
      id: dto.id,
      clubId: dto.clubId,
      roleName: dto.roleName,
      description: dto.description,
      isDefault: dto.isDefault,
      isHostRole: dto.isHostRole,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      permissions: dto.permissions
          .map((p) => ClubRolePermission(
                id: p.id,
                code: p.code,
                name: p.name,
                moduleGroup: p.moduleGroup,
                description: p.description,
              ))
          .toList(),
    );
  }
}
