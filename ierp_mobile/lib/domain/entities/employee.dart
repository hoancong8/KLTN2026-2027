class Employee {
  final int id;
  final int? tenantId;
  final String? code;
  final String? fullName;
  final String? avatar;
  final DateTime? doB;
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

  const Employee({
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

  Employee copyWith({
    int? id,
    int? tenantId,
    String? code,
    String? fullName,
    String? avatar,
    DateTime? doB,
    int? gender,
    String? email,
    String? phone,
    String? address,
    String? hometown,
    bool? isActive,
    String? textSearch,
    int? workDepartmentId,
    String? workDepartmentName,
    String? workDepartmentCode,
    int? workPositionId,
    String? workPositionName,
    String? workPositionCode,
    int? userId,
    int? roleId,
    String? roleName,
    String? userName,
    String? password,
    String? log,
  }) {
    return Employee(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      code: code ?? this.code,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      doB: doB ?? this.doB,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      hometown: hometown ?? this.hometown,
      isActive: isActive ?? this.isActive,
      textSearch: textSearch ?? this.textSearch,
      workDepartmentId: workDepartmentId ?? this.workDepartmentId,
      workDepartmentName: workDepartmentName ?? this.workDepartmentName,
      workDepartmentCode: workDepartmentCode ?? this.workDepartmentCode,
      workPositionId: workPositionId ?? this.workPositionId,
      workPositionName: workPositionName ?? this.workPositionName,
      workPositionCode: workPositionCode ?? this.workPositionCode,
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      log: log ?? this.log,
    );
  }
}
