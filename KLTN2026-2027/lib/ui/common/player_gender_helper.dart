import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';

class PlayerGenderHelper {
  static const Set<String> _femaleKeywords = {
    'thị', 'thi', 'mai', 'lan', 'hương', 'huong', 'ngọc', 'ngoc', 'phương', 'phuong',
    'anh', 'linh', 'hà', 'ha', 'thảo', 'thao', 'trang', 'nga', 'hạnh', 'hanh',
    'hoa', 'hồng', 'hong', 'yến', 'yen', 'ly', 'nhi', 'oanh', 'tuyết', 'tuyet',
    'châu', 'chau', 'quỳnh', 'quynh', 'vy', 'trâm', 'tram', 'diệp', 'diep',
    'dung', 'dương', 'duong', 'uyên', 'uyen', 'vân', 'van', 'hằng', 'hang',
  };

  static bool isFemale({int? explicitGender, String? genderString, required String fullName}) {
    if (explicitGender != null) {
      if (explicitGender == 2) return true;
      if (explicitGender == 1) return false;
    }
    if (genderString != null && genderString.isNotEmpty) {
      final g = genderString.toUpperCase();
      if (g == 'FEMALE' || g == 'NU' || g == 'NỮ' || g == '2') return true;
      if (g == 'MALE' || g == 'NAM' || g == '1') return false;
    }

    final tokens = fullName.trim().toLowerCase().split(RegExp(r'\s+'));
    for (final token in tokens) {
      if (token == 'thị' || token == 'thi') return true;
    }
    if (tokens.isNotEmpty && _femaleKeywords.contains(tokens.last)) {
      return true;
    }
    return false;
  }

  static Widget buildGenderBadge({
    required bool isFemale,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
  }) {
    final color = isFemale ? AppColors.pink : AppColors.info;
    final icon = isFemale ? Icons.female_rounded : Icons.male_rounded;
    final label = isFemale ? 'Nữ' : 'Nam';

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.tag,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
