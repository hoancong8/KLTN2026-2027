class SessionInfo {
  final SessionUser? user;
  final SessionEmployee? employee;
  final SessionTenant? tenant;

  SessionInfo({this.user, this.employee, this.tenant});
}

class SessionUser {
  final int id;
  final String? name;
  final String? surname;
  final String? userName;
  final String? emailAddress;

  SessionUser({
    required this.id,
    this.name,
    this.surname,
    this.userName,
    this.emailAddress,
  });
}

class SessionEmployee {
  final int id;
  final String? code;
  final String? fullName;
  final String? avatar;
  final int? roleId;
  final String? roleName;
  final int? workDepartmentId;
  final String? workDepartmentName;
  final int? workPositionId;
  final String? workPositionName;

  SessionEmployee({
    required this.id,
    this.code,
    this.fullName,
    this.avatar,
    this.roleId,
    this.roleName,
    this.workDepartmentId,
    this.workDepartmentName,
    this.workPositionId,
    this.workPositionName,
  });
}

class SessionTenant {
  final int id;
  final String? tenancyName;
  final String? name;

  SessionTenant({required this.id, this.tenancyName, this.name});
}