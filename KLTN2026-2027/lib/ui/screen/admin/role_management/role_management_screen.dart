import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/widget/responsive_layout.dart';
import 'role_management_vm/role_management_vm.dart';
import 'widgets/role_management_mobile.dart';
import 'widgets/role_management_tablet.dart';

class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(roleManagementViewModelProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: RoleManagementMobile(),
      tablet: RoleManagementTablet(),
    );
  }
}
