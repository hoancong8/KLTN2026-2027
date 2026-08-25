import '../../domain/entities/user_permissions.dart';
import '../dto/user/user_permissions_response_dto.dart';

class UserPermissionsMapper {
  static UserPermissions toEntity(UserPermissionsResponseDto dto) {
    return UserPermissions(
      userId: dto.userId,
      email: dto.email,
      roles: dto.roles,
      permissions: dto.permissions,
    );
  }
}
