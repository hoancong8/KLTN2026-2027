class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto({
    required this.email,
    required this.password,
  });

  static String _resolveIdentifier(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.contains('@') || RegExp(r'^\+?[0-9]{8,15}$').hasMatch(trimmed)) {
      return trimmed;
    }
    // Hỗ trợ alias username mặc định trong seed database (user1, user2, user3)
    if (trimmed.startsWith('user')) {
      return '$trimmed@l7ungdz.id.vn';
    }
    return trimmed;
  }

  Map<String, dynamic> toJson() {
    final identifier = _resolveIdentifier(email);
    return {
      'identifier': identifier,
      'email': identifier,
      'password': password,
    };
  }
}
