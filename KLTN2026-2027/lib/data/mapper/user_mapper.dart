import '../../domain/entities/user_profile.dart';
import '../../domain/entities/paged_response.dart';
import '../dto/user/user_response_dto.dart';
import '../dto/common/paged_result_dto.dart';

class UserMapper {
  static UserProfile toEntity(UserResponseDto dto) {
    return UserProfile(
      id: dto.id,
      email: dto.email,
      userName: dto.userName,
      phoneNumber: dto.phoneNumber,
      isLocked: dto.isLocked,
      lockoutEnd: dto.lockoutEnd != null ? DateTime.tryParse(dto.lockoutEnd!) : null,
      roles: dto.roles,
      permissions: dto.permissions,
    );
  }

  static PagedResponse<UserProfile> toPagedEntity(PagedResultDto<UserResponseDto> dto) {
    return PagedResponse<UserProfile>(
      items: dto.items.map((e) => toEntity(e)).toList(),
      totalCount: dto.totalCount,
      pageNumber: dto.pageNumber,
      pageSize: dto.pageSize,
      totalPages: dto.totalPages,
      hasPreviousPage: dto.hasPreviousPage,
      hasNextPage: dto.hasNextPage,
    );
  }
}
