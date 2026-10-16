// lib/ui/screen/club/role_management/widgets/club_role_color_helper.dart

import 'package:flutter/material.dart';

class ClubRoleColorHelper {
  static const List<Color> palette = [
    Color(0xFF9333EA), // Purple / Host
    Color(0xFF2563EB), // Blue / Deputy
    Color(0xFFD97706), // Amber / Treasurer
    Color(0xFF16A34A), // Green / Member
    Color(0xFF0284C7), // Sky Blue
    Color(0xFFE11D48), // Rose / Red
    Color(0xFF0D9488), // Teal
    Color(0xFF7C3AED), // Violet
    Color(0xFFEA580C), // Orange
    Color(0xFF6B7280), // Gray / Guest
  ];

  static Color getRoleColor(String roleName, {bool isHost = false}) {
    if (isHost) return const Color(0xFF9333EA);
    final rn = roleName.trim().toLowerCase();
    if (rn.contains('host') || rn.contains('chủ')) return const Color(0xFF9333EA);
    if (rn.contains('phó') || rn.contains('deputy')) return const Color(0xFF2563EB);
    if (rn.contains('quỹ') || rn.contains('treasurer')) return const Color(0xFFD97706);
    if (rn.contains('khách') || rn.contains('guest')) return const Color(0xFF6B7280);
    if (rn.contains('thành viên') || rn.contains('member')) return const Color(0xFF16A34A);
    if (rn.contains('frontend') || rn.contains('fe')) return const Color(0xFF0D9488);
    if (rn.contains('backend') || rn.contains('be')) return const Color(0xFF7C3AED);

    // Dynamic hash based on role name
    int hash = 0;
    for (int i = 0; i < roleName.length; i++) {
      hash = roleName.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return palette[hash.abs() % palette.length];
  }
}
