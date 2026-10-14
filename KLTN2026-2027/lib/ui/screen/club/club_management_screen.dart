// lib/ui/screen/club/club_management_screen.dart

import 'package:flutter/material.dart';
import '../../../widget/responsive_layout.dart';
import 'widgets/club_management_mobile.dart';
import 'widgets/club_management_tablet.dart';

class ClubManagementScreen extends StatelessWidget {
  const ClubManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: ClubManagementMobile(),
      tablet: ClubManagementTablet(),
    );
  }
}
