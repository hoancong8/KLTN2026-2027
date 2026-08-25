class RoleCreateUpdateRequestDto {
  final String name;
  final String description;

  RoleCreateUpdateRequestDto({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

class AssignRolePermissionsRequestDto {
  final List<String> permissions;

  AssignRolePermissionsRequestDto({
    required this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'permissions': permissions,
    };
  }
}
