import 'package:sipm_mobile/data/dto/profile/change_profile_request_dto.dart';
import 'package:sipm_mobile/data/dto/profile/change_profile_response_dto.dart';
import 'package:sipm_mobile/domain/entities/employee.dart';

class ProfileMapper {
  static Employee toEntity(ChangeProfileResponseDto dto) {
    return Employee(
      id: dto.id,
      tenantId: dto.tenantId,
      code: dto.code,
      fullName: dto.fullName,
      avatar: dto.avatar,
      doB: dto.doB != null ? DateTime.tryParse(dto.doB!) : null,
      gender: dto.gender,
      email: dto.email,
      phone: dto.phone,
      address: dto.address,
      hometown: dto.hometown,
      isActive: dto.isActive,
      textSearch: dto.textSearch,
      workDepartmentId: dto.workDepartmentId,
      workDepartmentName: dto.workDepartmentName,
      workDepartmentCode: dto.workDepartmentCode,
      workPositionId: dto.workPositionId,
      workPositionName: dto.workPositionName,
      workPositionCode: dto.workPositionCode,
      userId: dto.userId,
      roleId: dto.roleId,
      roleName: dto.roleName,
      userName: dto.userName,
    );
  }

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  static ChangeProfileRequestDto toDto(Employee entity) {
    return ChangeProfileRequestDto(
      id: entity.id,
      tenantId: entity.tenantId,
      code: entity.code,
      fullName: entity.fullName,
      avatar: entity.avatar,
      doB: _formatDate(entity.doB),
      gender: entity.gender,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      hometown: entity.hometown,
      isActive: entity.isActive,
      textSearch: entity.textSearch,
      workDepartmentId: entity.workDepartmentId,
      workDepartmentName: entity.workDepartmentName,
      workDepartmentCode: entity.workDepartmentCode,
      workPositionId: entity.workPositionId,
      workPositionName: entity.workPositionName,
      workPositionCode: entity.workPositionCode,
      userId: entity.userId,
      roleId: entity.roleId,
      roleName: entity.roleName,
      userName: entity.userName,
      password: entity.password,
      log: entity.log,
    );
  }
}
