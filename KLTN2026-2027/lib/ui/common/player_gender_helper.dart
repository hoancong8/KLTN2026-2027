import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';
import '../../domain/utils/gender_helper.dart';

class PlayerGenderHelper {
  static bool isFemale({int? explicitGender, String? genderString, String? fullName}) {
    return GenderHelper.isFemale(
      explicitGender: explicitGender,
      genderString: genderString,
      fullName: fullName,
    );
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
