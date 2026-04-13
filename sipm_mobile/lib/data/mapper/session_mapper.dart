import '../../domain/entities/session_info.dart';
import '../dto/session/session_info_dto.dart';

class SessionMapper {
  static SessionInfo toEntity(SessionInfoDto dto) {
    return SessionInfo(
      user: dto.user != null
          ? SessionUser(
        id: dto.user!.id,
        name: dto.user!.name,
        surname: dto.user!.surname,
        userName: dto.user!.userName,
        emailAddress: dto.user!.emailAddress,
      )
          : null,
      employee: dto.employee != null
          ? SessionEmployee(
        id: dto.employee!.id,
        code: dto.employee!.code,
        fullName: dto.employee!.fullName,
        avatar: dto.employee!.avatar,
        roleId: dto.employee!.roleId,
        roleName: dto.employee!.roleName,
        workDepartmentId: dto.employee!.workDepartmentId,
        workDepartmentName: dto.employee!.workDepartmentName,
        workPositionId: dto.employee!.workPositionId,
        workPositionName: dto.employee!.workPositionName,
      )
          : null,
      tenant: dto.tenant != null
          ? SessionTenant(
        id: dto.tenant!.id,
        tenancyName: dto.tenant!.tenancyName,
        name: dto.tenant!.name,
      )
          : null,
    );
  }
}