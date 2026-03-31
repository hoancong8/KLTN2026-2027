import 'package:sipm_mobile/domain/entities/auth_token.dart';

class LoginState {
  final bool isLoading;
  final bool required2FA;
  final AuthToken? token;
  final String? error;
  final bool biometricSetup;
  final bool biometricLoading;
  final String? biometricError;
  final bool isSuccess;

  const LoginState({
    this.isLoading = false,
    this.required2FA = false,
    this.token,
    this.error,
    this.biometricSetup = false,
    this.biometricLoading = false,
    this.biometricError,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? required2FA,
    AuthToken? token,
    String? error,
    bool? biometricSetup,
    bool? biometricLoading,
    String? biometricError,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      required2FA: required2FA ?? this.required2FA,
      token: token ?? this.token,
      error: error,
      biometricSetup: biometricSetup ?? this.biometricSetup,
      biometricLoading: biometricLoading ?? this.biometricLoading,
      biometricError: biometricError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
