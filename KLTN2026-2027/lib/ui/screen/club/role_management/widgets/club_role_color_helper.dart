// lib/ui/screen/club/role_management/widgets/club_role_color_helper.dart

import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

class ClubRoleColorHelper {
  static const List<Color> palette = [
    AppColors.roleHost,
    AppColors.roleDeputy,
    AppColors.roleTreasurer,
    AppColors.roleMember,
    AppColors.roleSky,
    AppColors.roleRose,
    AppColors.roleTeal,
    AppColors.roleViolet,
    AppColors.roleOrange,
    AppColors.roleGuest,
  ];

  static Color getRoleColor(String roleName, {bool isHost = false}) {
    if (isHost) return AppColors.roleHost;
    final rn = roleName.trim().toLowerCase();
    if (rn.contains('host') || rn.contains('chủ')) return AppColors.roleHost;
    if (rn.contains('phó') || rn.contains('deputy')) return AppColors.roleDeputy;
    if (rn.contains('quỹ') || rn.contains('treasurer')) return AppColors.roleTreasurer;
    if (rn.contains('khách') || rn.contains('guest')) return AppColors.roleGuest;
    if (rn.contains('thành viên') || rn.contains('member')) return AppColors.roleMember;
    if (rn.contains('frontend') || rn.contains('fe')) return AppColors.roleTeal;
    if (rn.contains('backend') || rn.contains('be')) return AppColors.roleViolet;

    // Dynamic hash based on role name
    int hash = 0;
    for (int i = 0; i < roleName.length; i++) {
      hash = roleName.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return palette[hash.abs() % palette.length];
  }
}
