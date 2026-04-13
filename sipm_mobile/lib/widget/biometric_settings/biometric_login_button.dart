import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sipm_mobile/domain/services/i_biometric_service.dart';
import '../../app/provider.dart';

class BiometricLoginButton extends ConsumerStatefulWidget {
  final VoidCallback? onPressed;

  const BiometricLoginButton({super.key, required this.onPressed});

  @override
  ConsumerState<BiometricLoginButton> createState() => _BiometricLoginButtonState();
}

class _BiometricLoginButtonState extends ConsumerState<BiometricLoginButton> {
  bool _hasFaceId = false;
  bool _hasFingerprint = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricTypes();
  }

  Future<void> _checkBiometricTypes() async {
    final biometricService = ref.read(biometricServiceProvider);
    final biometrics = await biometricService.getAvailableBiometrics();
    if (mounted) {
      setState(() {
        _hasFaceId = biometrics.contains(AppBiometricType.face);
        _hasFingerprint = biometrics.contains(AppBiometricType.fingerprint);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String text;
    
    if (_hasFaceId) {
      icon = Icons.face;
      text = 'Đăng nhập bằng Face ID';
    } else if (_hasFingerprint) {
      icon = Icons.fingerprint;
      text = 'Đăng nhập bằng vân tay';
    } else {
      icon = Icons.security;
      text = 'Đăng nhập bằng sinh trắc học';
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: Color(0xFF2563EB)),
        ),
        icon: Icon(
          icon,
          color: const Color(0xFF2563EB),
          size: 24,
        ),
        label: Text(
          text,
          style: const TextStyle(color: Color(0xFF2563EB)),
        ),
      ),
    );
  }
}
