class ChangeProfileRequestDto {
  final int id;
  final int? tenantId;
  final String? code;
  final String? fullName;
  final String? avatar;
  final String? doB;
  final int? gender;
  final String? email;
  final String? phone;
  final String? address;
  final String? hometown;
  final bool? isActive;
  final String? textSearch;
  final int? workDepartmentId;
  final String? workDepartmentName;
  final String? workDepartmentCode;
  final int? workPositionId;
  final String? workPositionName;
  final String? workPositionCode;
  final int? userId;
  final int? roleId;
  final String? roleName;
  final String? userName;
  final String? password;
  final String? log;

  const ChangeProfileRequestDto({
    required this.id,
    this.tenantId,
    this.code,
    this.fullName,
    this.avatar,
    this.doB,
    this.gender,
    this.email,
    this.phone,
    this.address,
    this.hometown,
    this.isActive,
    this.textSearch,
    this.workDepartmentId,
    this.workDepartmentName,
    this.workDepartmentCode,
    this.workPositionId,
    this.workPositionName,
    this.workPositionCode,
    this.userId,
    this.roleId,
    this.roleName,
    this.userName,
    this.password,
    this.log,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id.toString(),
    };

    // Integer fields - only send if not null
    if (userId != null) map['userId'] = userId.toString();
    if (tenantId != null) map['TenantId'] = tenantId.toString();
    if (workPositionId != null) map['WorkPositionId'] = workPositionId.toString();
    if (workDepartmentId != null) map['WorkDepartmentId'] = workDepartmentId.toString();
    if (roleId != null) map['RoleId'] = roleId.toString();
    if (gender != null) map['gender'] = gender.toString();

    // Boolean field
    if (isActive != null) map['IsActive'] = isActive.toString();

    // String fields - send empty string if null
    map['avatar'] = avatar ?? '';
    map['code'] = code ?? '';
    map['fullName'] = fullName ?? '';
    map['DoB'] = doB ?? '';
    map['phone'] = phone ?? '';
    map['email'] = email ?? '';
    map['address'] = address ?? '';

    return map;
  }
}
