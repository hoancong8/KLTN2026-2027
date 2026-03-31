import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/app/provider.dart';

class BiometricSettingsItem extends ConsumerStatefulWidget {
  const BiometricSettingsItem({super.key});

  @override
  ConsumerState<BiometricSettingsItem> createState() => _BiometricSettingsItemState();
}

class _BiometricSettingsItemState extends ConsumerState<BiometricSettingsItem> {
  bool _biometricEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final biometricService = ref.read(biometricServiceProvider);
    final enabled = await biometricService.isBiometricSetup();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _showPinDialog() async {
    final biometricService = ref.read(biometricServiceProvider);
    
    // Kiểm tra user có đang đăng nhập không
    final authToken = ref.read(authTokenProvider);
    if (authToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đăng nhập để thiết lập sinh trắc học'),
          backgroundColor: AppColor.cNeedCheck,
        ),
      );
      return;
    }

    final pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.cMain.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.pin_outlined, color: AppColor.cMain, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Nhập mã PIN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColor.cTitle,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhập mã PIN để bảo mật sinh trắc học:',
              style: TextStyle(color: AppColor.cMuted, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: AppColor.cTitle, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Mã PIN (4-6 số)',
                labelStyle: TextStyle(color: AppColor.cMuted),
                prefixIcon: Icon(Icons.lock_outline, color: AppColor.cMuted),
                filled: true,
                fillColor: AppColor.cGray_50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.cDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.cMain, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColor.cMuted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length >= 4) {
                final success = await biometricService.setupBiometricWithLastLogin(pinController.text);
                if (context.mounted) {
                  Navigator.pop(context, success);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cMain,
              foregroundColor: AppColor.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _biometricEnabled = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã thiết lập sinh trắc học thành công!'),
            backgroundColor: AppColor.cMain,
          ),
        );
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final biometricService = ref.read(biometricServiceProvider);
    if (value) {
      final canCheck = await biometricService.canCheckBiometrics();
      if (!canCheck) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sinh trắc học không khả dụng trên thiết bị này'),
            backgroundColor: AppColor.cError,
          ),
        );
        return;
      }
      await _showPinDialog();
    } else {
      await biometricService.clearCredentials();
      setState(() => _biometricEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã tắt sinh trắc học'),
            backgroundColor: AppColor.cMuted,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.cMain.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.fingerprint, color: AppColor.cMain, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sinh trắc học',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColor.cTitle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đang kiểm tra...',
                    style: TextStyle(fontSize: 13, color: AppColor.cMuted),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.cMain),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.cMain.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fingerprint, color: AppColor.cMain, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinh trắc học',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColor.cTitle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _biometricEnabled
                      ? 'Đăng nhập bằng vân tay/Face ID'
                      : 'Thiết lập đăng nhập sinh trắc học',
                  style: TextStyle(fontSize: 13, color: AppColor.cMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: _biometricEnabled,
            onChanged: _toggleBiometric,
            activeThumbColor: AppColor.cMain,
            activeTrackColor: AppColor.cMain.withValues(alpha: 0.3),
            inactiveThumbColor: AppColor.cMuted,
            inactiveTrackColor: AppColor.cDivider,
          ),
        ],
      ),
    );
  }
}
