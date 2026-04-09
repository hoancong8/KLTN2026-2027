import 'package:sipm_mobile/app/consts/app_log.dart';
import 'package:sipm_mobile/domain/usecases/auth/register_device_token_usecase.dart';
import 'package:sipm_mobile/ui/screen/otp/otp_state.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../app/provider.dart';
import '../../../domain/usecases/auth/login_with_otp_usecase.dart';

//Provider for otpViewmodel
final otpViewModelProvider =
    StateNotifierProvider.autoDispose<OtpViewmodel, OtpState>((ref) {
      return OtpViewmodel(
        ref.watch(loginWithOtpUseCaseProvider),
        ref.watch(registerDeviceTokenUseCaseProvider),
      );
    });

final otpCodeProvider = StateProvider.autoDispose<String>((ref) => '');

//OtpViewmodel
class OtpViewmodel extends StateNotifier<OtpState> {
  OtpViewmodel(this._loginWithOtpUseCase, this._registerDeviceTokenUseCase)
    : super(const OtpState());

  final LoginWithOtpUseCase _loginWithOtpUseCase;
  final RegisterDeviceTokenUseCase _registerDeviceTokenUseCase;

  Future<void> verifyOtp({
    required String username,
    required String password,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _loginWithOtpUseCase.execute(
        username: username,
        password: password,
        code: code,
      );

      state = state.copyWith(isLoading: false, token: token);

      // Register device token sau khi OTP login thành công
      try {
        await _registerDeviceTokenUseCase.execute();
      } catch (e) {
        AppLog.info('[OtpViewModel] Failed to register device token: $e');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
