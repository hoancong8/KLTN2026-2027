class ChangeProfileResponseDto {
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
  final String? log;

  const ChangeProfileResponseDto({
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
    this.log,
  });

  factory ChangeProfileResponseDto.fromJson(Map<String, dynamic> json) {
    // Handle nested structure: result.employee or result or direct
    var data = json;
    if (json.containsKey('result')) {
      data = json['result'] as Map<String, dynamic>;
      if (data.containsKey('employee')) {
        data = data['employee'] as Map<String, dynamic>;
      }
    }

    return ChangeProfileResponseDto(
      id: data['id'] as int,
      tenantId: data['tenantId'] as int?,
      code: data['code'] as String?,
      fullName: data['fullName'] as String?,
      avatar: data['avatar'] as String?,
      doB: data['doB'] as String?,
      gender: data['gender'] as int?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      hometown: data['hometown'] as String?,
      isActive: data['isActive'] as bool?,
      textSearch: data['textSearch'] as String?,
      workDepartmentId: data['workDepartmentId'] as int?,
      workDepartmentName: data['workDepartmentName'] as String?,
      workDepartmentCode: data['workDepartmentCode'] as String?,
      workPositionId: data['workPositionId'] as int?,
      workPositionName: data['workPositionName'] as String?,
      workPositionCode: data['workPositionCode'] as String?,
      userId: data['userId'] as int?,
      roleId: data['roleId'] as int?,
      roleName: data['roleName'] as String?,
      userName: data['userName'] as String?,
      log: data['log'] as String?,
    );
  }
}
