import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/services/secure_storage_service.dart';
import 'package:kltn2026_2027/ui/screen/otp/otp_state.dart';
import 'package:kltn2026_2027/ui/screen/otp/otp_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpScreen extends ConsumerWidget {
  const OtpScreen({super.key, required this.username, required this.password});

  final String username;
  final String password;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // implement build
    final state = ref.watch(otpViewModelProvider);
    final code = ref.watch(otpCodeProvider);
    ref.listen<OtpState>(otpViewModelProvider, (prev, next) async {
      if (prev?.token == null && next.token != null) {
        // Save token to global provider for API authentication
        ref.read(authTokenProvider.notifier).state = next.token;

        // OTP login luôn lưu token (giống như tick remember me)
        await SecureStorageService.instance.saveAuthToken(next.token!);
        await SecureStorageService.instance.setRememberMe(true);

        // SignalR và loadUsers sẽ được xử lý bởi HomeViewModel sau khi navigate
        if (!context.mounted) return;
        context.go(AppConfig.homePath);
      }

      if (prev?.error == null && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'OTP Code'),
              onChanged: (v) => ref.read(otpCodeProvider.notifier).state = v,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      ref
                          .read(otpViewModelProvider.notifier)
                          .verifyOtp(
                            username: username,
                            password: password,
                            code: code,
                          );
                    },
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('verify'),
            ),
          ],
        ),
      ),
    );
  }
}
