import '../../../domain/entities/auth_token.dart';

class OtpState {
  final bool isLoading;
  final String? error;
  final AuthToken? token;

  const OtpState({
    this.isLoading = false,
    this.error,
    this.token,
  });

  OtpState copyWith({
    bool? isLoading,
    String? error,
    AuthToken? token,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
    );
  }
}