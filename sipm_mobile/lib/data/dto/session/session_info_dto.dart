class SessionInfoDto {
  final SessionUserDto? user;
  final SessionEmployeeDto? employee;
  final SessionTenantDto? tenant;

  SessionInfoDto({
    this.user,
    this.employee,
    this.tenant,
  });

  factory SessionInfoDto.fromJson(Map<String, dynamic> json) {
    // BaseRemoteDatasource đã bóc 'result'
    return SessionInfoDto(
      user: json['user'] != null
          ? SessionUserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      employee: json['employee'] != null
          ? SessionEmployeeDto.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      tenant: json['tenant'] != null
          ? SessionTenantDto.fromJson(json['tenant'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SessionUserDto {
  final int id;
  final String? name;
  final String? surname;
  final String? userName;
  final String? emailAddress;

  SessionUserDto({
    required this.id,
    this.name,
    this.surname,
    this.userName,
    this.emailAddress,
  });

  factory SessionUserDto.fromJson(Map<String, dynamic> json) {
    return SessionUserDto(
      id: json['id'] as int,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      userName: json['userName'] as String?,
      emailAddress: json['emailAddress'] as String?,
    );
  }
}

class SessionEmployeeDto {
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

  SessionEmployeeDto({
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

  factory SessionEmployeeDto.fromJson(Map<String, dynamic> json) {
    return SessionEmployeeDto(
      id: json['id'] as int,
      code: json['code'] as String?,
      fullName: json['fullName'] as String?,
      avatar: json['avatar'] as String?,
      roleId: json['roleId'] as int?,
      roleName: json['roleName'] as String?,
      workDepartmentId: json['workDepartmentId'] as int?,
      workDepartmentName: json['workDepartmentName'] as String?,
      workPositionId: json['workPositionId'] as int?,
      workPositionName: json['workPositionName'] as String?,
    );
  }
}

class SessionTenantDto {
  final int id;
  final String? tenancyName;
  final String? name;

  SessionTenantDto({
    required this.id,
    this.tenancyName,
    this.name,
  });

  factory SessionTenantDto.fromJson(Map<String, dynamic> json) {
    return SessionTenantDto(
      id: json['id'] as int,
      tenancyName: json['tenancyName'] as String?,
      name: json['name'] as String?,
    );
  }
}