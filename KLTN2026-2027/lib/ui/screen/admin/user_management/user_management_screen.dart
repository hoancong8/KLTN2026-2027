import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/widget/responsive_layout.dart';
import 'user_management_vm/user_management_vm.dart';
import 'widgets/user_management_mobile.dart';
import 'widgets/user_management_tablet.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userManagementViewModelProvider.notifier).loadUsers();
      ref.read(userManagementViewModelProvider.notifier).loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: UserManagementMobile(),
      tablet: UserManagementTablet(),
    );
  }
}
