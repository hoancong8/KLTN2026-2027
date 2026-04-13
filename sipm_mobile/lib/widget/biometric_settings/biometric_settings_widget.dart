import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/l10n/flutter_app_messages.dart';
import '../../app/provider.dart';
import '../../app/provider/localization_provider.dart';

class BiometricSettingsWidget extends ConsumerStatefulWidget {
  const BiometricSettingsWidget({super.key});

  @override
  ConsumerState<BiometricSettingsWidget> createState() => _BiometricSettingsWidgetState();
}

class _BiometricSettingsWidgetState extends ConsumerState<BiometricSettingsWidget> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final biometricService = ref.read(biometricServiceProvider);
    final available = await biometricService.canCheckBiometrics();
    final enabled = await biometricService.isBiometricSetup();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final l10n = context.l10n;
    final messages = FlutterAppMessages(l10n);
    final biometricService = ref.read(biometricServiceProvider);
    if (value) {
      final success = await biometricService.setupBiometric(
        messages: messages,
        pin: '',
      );
      if (success && mounted) {
        setState(() => _biometricEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.auth_biometric_setup_success), backgroundColor: Colors.green),
        );
      }
    } else {
      await biometricService.clearCredentials();
      setState(() => _biometricEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.auth_biometric_disabled_success)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_loading) {
      return ListTile(
        leading: const Icon(Icons.fingerprint),
        title: Text(l10n.auth_biometric_title),
        trailing: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (!_biometricAvailable) {
      return ListTile(
        leading: const Icon(Icons.fingerprint, color: Colors.grey),
        title: Text(l10n.auth_biometric_title),
        subtitle: Text(l10n.auth_biometric_subtitle_unavailable),
        enabled: false,
      );
    }

    return ListTile(
      leading: const Icon(Icons.fingerprint),
      title: Text(l10n.auth_biometric_title),
      subtitle: Text(_biometricEnabled ? l10n.auth_biometric_subtitle_enabled : l10n.auth_biometric_subtitle_disabled),
      trailing: Switch(value: _biometricEnabled, onChanged: _toggleBiometric),
    );
  }
}