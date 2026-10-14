import 'package:kltn2026_2027/domain/entities/auth_token.dart';
import '../../../../domain/exceptions/app_exception.dart';

class LoginState {
  final bool isLoading;
  final AuthToken? token;
  final AppException? error;
  final bool biometricSetup;
  final bool biometricLoading;
  final String? biometricError;
  final bool isSuccess;

  const LoginState({
    this.isLoading = false,
    this.token,
    this.error,
    this.biometricSetup = false,
    this.biometricLoading = false,
    this.biometricError,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    AuthToken? token,
    AppException? error,
    bool? biometricSetup,
    bool? biometricLoading,
    String? biometricError,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: error,
      biometricSetup: biometricSetup ?? this.biometricSetup,
      biometricLoading: biometricLoading ?? this.biometricLoading,
      biometricError: biometricError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
