import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/l10n/flutter_app_messages.dart';

class BiometricSettingsItem extends ConsumerStatefulWidget {
  const BiometricSettingsItem({super.key});

  @override
  ConsumerState<BiometricSettingsItem> createState() =>
      _BiometricSettingsItemState();
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
    final enabled = await ref.read(biometricServiceProvider).isBiometricSetup();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _showPinDialog() async {
    final l10n = context.l10n;
    final biometricService = ref.read(biometricServiceProvider);
    final authToken = ref.read(authTokenProvider);

    if (authToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.auth_biometric_login_required),
          backgroundColor: AppColor.cNeedCheck,
        ),
      );
      return;
    }

    final pinController = TextEditingController();
    final messages = FlutterAppMessages(l10n);

    bool? result;
    try {
      result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.cMain.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pin_outlined,
                  color: AppColor.cMain,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.auth_biometric_pin_title,
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
                l10n.auth_biometric_pin_subtitle,
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
                  labelText: l10n.auth_biometric_pin_label,
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
                l10n.com_cancel,
                style: TextStyle(
                  color: AppColor.cMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pinController.text.length >= 4) {
                  // Unfocus keyboard before showing biometric prompt to prevent UI conflicts
                  FocusManager.instance.primaryFocus?.unfocus();

                  // Small delay to allow keyboard animation to start/finish
                  await Future.delayed(const Duration(milliseconds: 200));

                  if (!context.mounted) return;

                  final success = await biometricService.setupBiometric(
                    messages: messages,
                    pin: pinController.text,
                  );

                  if (context.mounted) {
                    Navigator.pop(context, success);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cMain,
                foregroundColor: AppColor.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.com_confirm,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } finally {
      pinController.dispose();
    }

    if (result == true && mounted) {
      setState(() => _biometricEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.auth_biometric_setup_success),
          backgroundColor: AppColor.cMain,
        ),
      );
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final l10n = context.l10n;
    final biometricService = ref.read(biometricServiceProvider);
    if (value) {
      final canCheck = await biometricService.canCheckBiometrics();
      if (!canCheck) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.auth_biometric_unavailable),
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
            content: Text(l10n.auth_biometric_disabled_success),
            backgroundColor: AppColor.cMuted,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                    l10n.auth_biometric_title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColor.cTitle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.auth_biometric_checking,
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
                  l10n.auth_biometric_title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColor.cTitle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _biometricEnabled
                      ? l10n.auth_biometric_subtitle_enabled
                      : l10n.auth_biometric_subtitle_disabled,
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
