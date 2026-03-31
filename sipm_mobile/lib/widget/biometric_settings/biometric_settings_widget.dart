import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/provider.dart';

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
    final biometricService = ref.read(biometricServiceProvider);
    if (value) {
      final authenticated = await biometricService.authenticate(
        reason: 'Xác thực để bật đăng nhập sinh trắc học',
      );
      
      if (authenticated) {
        await biometricService.setBiometricSetup(true);
        setState(() => _biometricEnabled = true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã bật đăng nhập sinh trắc học'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      await biometricService.clearCredentials();
      setState(() => _biometricEnabled = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tắt đăng nhập sinh trắc học'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ListTile(
        leading: Icon(Icons.fingerprint),
        title: Text('Đăng nhập sinh trắc học'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!_biometricAvailable) {
      return const ListTile(
        leading: Icon(Icons.fingerprint, color: Colors.grey),
        title: Text('Đăng nhập sinh trắc học'),
        subtitle: Text('Không khả dụng trên thiết bị này'),
        enabled: false,
      );
    }

    return ListTile(
      leading: const Icon(Icons.fingerprint),
      title: const Text('Đăng nhập sinh trắc học'),
      subtitle: Text(_biometricEnabled 
        ? 'Đã bật - Sử dụng vân tay/Face ID để đăng nhập'
        : 'Đăng nhập nhanh bằng vân tay hoặc Face ID'
      ),
      trailing: Switch(
        value: _biometricEnabled,
        onChanged: _toggleBiometric,
      ),
    );
  }
}
