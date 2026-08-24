class UserLockRequestDto {
  final bool isLocked;
  final String? lockoutEnd;

  UserLockRequestDto({
    required this.isLocked,
    this.lockoutEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'isLocked': isLocked,
      if (lockoutEnd != null) 'lockoutEnd': lockoutEnd,
    };
  }
}
