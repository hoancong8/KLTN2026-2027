class LoginRequestDto {
  final String email;
  final String password;
  final String? deviceToken;
  final String? platform;

  LoginRequestDto({
    required this.email,
    required this.password,
    this.deviceToken,
    this.platform,
  });

  static String _resolveIdentifier(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.contains('@') || RegExp(r'^\+?[0-9]{8,15}$').hasMatch(trimmed)) {
      return trimmed;
    }
    // Ho tro alias username mac dinh trong seed database (user1, user2, user3)
    if (trimmed.startsWith('user')) {
      return '$trimmed@l7ungdz.id.vn';
    }
    return trimmed;
  }

  Map<String, dynamic> toJson() {
    final identifier = _resolveIdentifier(email);
    final map = <String, dynamic>{
      'identifier': identifier,
      'email': identifier,
      'password': password,
    };
    if (deviceToken != null && deviceToken!.trim().isNotEmpty) {
      map['deviceToken'] = deviceToken!.trim();
    }
    if (platform != null && platform!.trim().isNotEmpty) {
      map['platform'] = platform!.trim();
    }
    return map;
  }
}
