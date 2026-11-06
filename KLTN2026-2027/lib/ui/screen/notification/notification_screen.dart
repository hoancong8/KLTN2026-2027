import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widget/responsive_layout.dart';
import 'notification_vm/notification_vm.dart';
import 'widgets/notification_mobile.dart';
import 'widgets/notification_tablet.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationViewModelProvider);
    final vm = ref.read(notificationViewModelProvider.notifier);

    return ResponsiveLayout(
      mobile: NotificationMobile(state: state, vm: vm),
      tablet: NotificationTablet(state: state, vm: vm),
    );
  }
}

