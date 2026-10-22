import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/club/explore_club.dart';
import '../../../../domain/enums/session_enums.dart';

class ClubExploreCard extends StatelessWidget {
  final ExploreClub club;
  final VoidCallback onTap;

  const ClubExploreCard({
    super.key,
    required this.club,
    required this.onTap,
  });

  Color _getSkillColor(SkillLevel? level) {
    if (level == null) return AppColors.neutral500;
    switch (level) {
      case SkillLevel.nb:
        return AppColors.skillBeginner;
      case SkillLevel.y:
        return AppColors.skillElementary;
      case SkillLevel.tby:
        return AppColors.skillIntermediate;
      case SkillLevel.tb:
        return AppColors.skillUpperIntermediate;
      case SkillLevel.tbk:
        return AppColors.skillAdvanced;
      case SkillLevel.k:
        return AppColors.skillSemiPro;
      case SkillLevel.g:
        return AppColors.skillPro;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar, Name, Code, Distance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Club Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                            ? Image.network(
                                club.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.sports_tennis_rounded,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                              )
                            : const Icon(
                                Icons.sports_tennis_rounded,
                                color: AppColors.primary,
                                size: 26,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name & Code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.groupName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                club.code,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Rating
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                                  const SizedBox(width: 2),
                                  Text(
                                    club.qualityScore.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.roleTreasurer,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Distance Chip (if GPS available)
                    if (club.distanceKm != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.infoBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.near_me_rounded, size: 12, color: AppColors.roleDeputy),
                            const SizedBox(width: 4),
                            Text(
                              '${club.distanceKm!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.roleDeputy,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Venue & Address
                if (club.fixedVenueName != null && club.fixedVenueName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 15, color: AppColors.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            club.fixedAddress != null && club.fixedAddress!.isNotEmpty
                                ? '${club.fixedVenueName!} - ${club.fixedAddress!}'
                                : club.fixedVenueName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral700,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Schedules summary
                if (club.schedulesSummary != null && club.schedulesSummary!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 15, color: AppColors.roleSky),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            club.schedulesSummary!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.roleSky,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 14),

                // Bottom row: Skill range, Recruitment badge, Members count
                Row(
                  children: [
                    // Skill range badge
                    if (club.minSkillLevel != null || club.maxSkillLevel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getSkillColor(club.minSkillLevel).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Trình độ: ${club.minSkillLevel?.code ?? "NB"} - ${club.maxSkillLevel?.code ?? "G"}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getSkillColor(club.minSkillLevel),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),

                    // Recruiting badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: club.isRecruiting
                            ? AppColors.successLight
                            : colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        club.isRecruiting ? 'Đang tuyển quân' : 'Đủ thành viên',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: club.isRecruiting
                              ? AppColors.roleMember
                              : colors.textMuted,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Member count
                    Row(
                      children: [
                        Icon(Icons.group_outlined, size: 14, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${club.memberCount} TV',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
