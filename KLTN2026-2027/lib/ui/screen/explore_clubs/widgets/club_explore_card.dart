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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.cardBorder, width: 1),
      ),
      color: colors.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Avatar, Name, Code, Distance
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Club Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      color: colors.primaryContainer,
                      child: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                          ? Image.network(
                              club.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  club.groupName.isNotEmpty ? club.groupName[0].toUpperCase() : 'C',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                club.groupName.isNotEmpty ? club.groupName[0].toUpperCase() : 'C',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
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
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
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
                                fontSize: 11.5,
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
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
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
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.near_me_rounded, size: 11, color: colors.primary),
                          const SizedBox(width: 3),
                          Text(
                            'Cách ${club.distanceKm!.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: colors.cardBorder),
              const SizedBox(height: 10),

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
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textPrimary,
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
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded, size: 15, color: colors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          club.schedulesSummary!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 6),
              Divider(height: 1, color: colors.cardBorder),
              const SizedBox(height: 10),

              // Bottom row: Skill range, Recruitment badge, Members count
              Row(
                children: [
                  // Skill range badge
                  if (club.minSkillLevel != null || club.maxSkillLevel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: _getSkillColor(club.minSkillLevel).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Trình độ: ${club.minSkillLevel?.code ?? "NB"} - ${club.maxSkillLevel?.code ?? "G"}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getSkillColor(club.minSkillLevel),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),

                  // Recruiting badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: club.isRecruiting
                          ? AppColors.successLight
                          : colors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: club.isRecruiting ? AppColors.success.withValues(alpha: 0.3) : colors.cardBorder,
                      ),
                    ),
                    child: Text(
                      club.isRecruiting ? 'Đang tuyển quân' : 'Đủ thành viên',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: club.isRecruiting
                            ? AppColors.success
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
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, size: 18, color: colors.textMuted),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
