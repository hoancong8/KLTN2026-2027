import 'package:flutter/material.dart';
import '../../../../app/consts/app_color.dart';
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
    if (level == null) return const Color(0xFF64748B);
    switch (level) {
      case SkillLevel.nb:
        return const Color(0xFF9E9E9E);
      case SkillLevel.y:
        return const Color(0xFF8BC34A);
      case SkillLevel.tby:
        return const Color(0xFF4CAF50);
      case SkillLevel.tb:
        return const Color(0xFF0284C7);
      case SkillLevel.tbk:
        return const Color(0xFF3F51B5);
      case SkillLevel.k:
        return const Color(0xFFF59E0B);
      case SkillLevel.g:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
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
                        color: AppColor.cMain.withValues(alpha: 0.1),
                        child: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                            ? Image.network(
                                club.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.sports_tennis_rounded,
                                  color: AppColor.cMain,
                                  size: 26,
                                ),
                              )
                            : const Icon(
                                Icons.sports_tennis_rounded,
                                color: AppColor.cMain,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColor.cDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                club.code,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.cMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Rating
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 2),
                                  Text(
                                    club.qualityScore.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD97706),
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
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.near_me_rounded, size: 12, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text(
                              '${club.distanceKm!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
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
                        const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            club.fixedAddress != null && club.fixedAddress!.isNotEmpty
                                ? '${club.fixedVenueName!} - ${club.fixedAddress!}'
                                : club.fixedVenueName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF334155),
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
                        const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF0284C7)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            club.schedulesSummary!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0284C7),
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
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        club.isRecruiting ? 'Đang tuyển quân' : 'Đủ thành viên',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: club.isRecruiting
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Member count
                    Row(
                      children: [
                        const Icon(Icons.group_outlined, size: 14, color: AppColor.cMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${club.memberCount} TV',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.cMuted,
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
