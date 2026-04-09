// ui/login/login_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/app/consts/app_log.dart';
import '../../../../app/provider.dart';
import '../../../../app/services/secure_storage_service.dart';
import '../../../../domain/exceptions/auth_exceptions.dart';
import '../../../../domain/usecases/auth/login_usecase.dart';
import '../../../../domain/usecases/auth/register_device_token_usecase.dart';
import '../../../../domain/usecases/auth/biometric_usecase.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../app/utils/app_exception_handler.dart';
import 'login_state.dart';

//Provider for LoginViewModel
final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>((ref) {
      return LoginViewModel(
        ref,
        ref.watch(loginUseCaseProvider),
        ref.watch(registerDeviceTokenUseCaseProvider),
        ref.watch(biometricUseCaseProvider),
      );
    });

final loginUsernameProvider = StateProvider<String>((ref) => '');

final loginPasswordProvider = StateProvider<String>((ref) => '');

//LoginViewModel
class LoginViewModel extends StateNotifier<LoginState> {
  final Ref ref;
  final LoginUseCase loginUseCase;
  final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  final BiometricUseCase biometricUseCase;

  LoginViewModel(
    this.ref,
    this.loginUseCase,
    this.registerDeviceTokenUseCase,
    this.biometricUseCase,
  ) : super(const LoginState()) {
    _checkBiometricSetup();
  }

  Future<void> _checkBiometricSetup() async {
    final isSetup = await biometricUseCase.checkBiometricSetup();
    state = state.copyWith(biometricSetup: isSetup);
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final token = await loginUseCase.execute(
        username: username,
        password: password,
      );

      // Lưu auth token vào provider toàn cục
      ref.read(authTokenProvider.notifier).state = token;

      // Lưu last login credentials để tự điền hoặc dùng cho sinh trắc
      if (username.trim().isNotEmpty && password.isNotEmpty) {
        await SecureStorageService.instance.saveLastLoginCredentials(
          username.trim(),
          password,
        );
      }

      // Lưu credentials cho biometric nếu đã thiết lập
      final biometricService = ref.read(biometricServiceProvider);
      final isBiometricSetup = await biometricService.isBiometricSetup();

      if (isBiometricSetup &&
          username.trim().isNotEmpty &&
          password.isNotEmpty) {
        await biometricService.saveCurrentUserCredentials(
          username.trim(),
          password,
        );
      }

      state = state.copyWith(
        isLoading: false,
        token: token,
        required2FA: false,
        isSuccess: true,
      );

      // Register device token sau khi login thành công
      try {
        await registerDeviceTokenUseCase.execute();
      } catch (e) {
        AppLog.info('[LoginViewModel] Failed to register device token: $e');
      }
    } on RequiresTwoFactorException {
      state = state.copyWith(isLoading: false, required2FA: true);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppExceptionHandler.handle(e),
      );
    }
  }

  Future<void> authenticateWithBiometric() async {
    state = state.copyWith(biometricLoading: true, biometricError: null);

    try {
      final credentials = await biometricUseCase.authenticateWithBiometric();

      if (credentials != null) {
        await login(
          username: credentials['username']!,
          password: credentials['password']!,
        );
      }

      state = state.copyWith(biometricLoading: false);
    } on BiometricException catch (e) {
      state = state.copyWith(
        biometricLoading: false,
        biometricError: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        biometricLoading: false,
        biometricError: 'Lỗi xác thực sinh trắc học: $e',
      );
    }
  }
}
