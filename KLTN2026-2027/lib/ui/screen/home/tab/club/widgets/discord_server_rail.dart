// lib/ui/screen/home/tab/club/widgets/discord_server_rail.dart

import 'package:flutter/material.dart';
import '../../../../../../app/consts/app_color.dart';
import '../../../../../../domain/entities/club/my_club.dart';

class DiscordServerRail extends StatelessWidget {
  final List<MyClub> clubs;
  final String? selectedClubId;
  final String? activeClubId;
  final ValueChanged<MyClub> onClubSelected;
  final VoidCallback onAddClubPressed;

  const DiscordServerRail({
    super.key,
    required this.clubs,
    required this.selectedClubId,
    required this.activeClubId,
    required this.onClubSelected,
    required this.onAddClubPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: double.infinity,
      color: const Color(0xFF1E1F22), // Discord Server Rail Dark Background
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Top Badminton / Community Hub Icon
          _buildHubIcon(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // Scrollable List of Clubs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: clubs.length,
              itemBuilder: (context, index) {
                final club = clubs[index];
                final isSelected = club.clubId == selectedClubId;
                final isActiveContext = club.clubId == activeClubId;

                return _ServerItem(
                  club: club,
                  isSelected: isSelected,
                  isActiveContext: isActiveContext,
                  onTap: () => onClubSelected(club),
                );
              },
            ),
          ),

          // Add / Join Club Button (+)
          _buildAddClubButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHubIcon() {
    return Tooltip(
      message: 'Tất cả câu lạc bộ',
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColor.cMain,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.cMain.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildAddClubButton(BuildContext context) {
    return Tooltip(
      message: 'Thêm / Tham gia nhóm mới',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAddClubPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D31),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColor.cGreen_50,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServerItem extends StatelessWidget {
  final MyClub club;
  final bool isSelected;
  final bool isActiveContext;
  final VoidCallback onTap;

  const _ServerItem({
    required this.club,
    required this.isSelected,
    required this.isActiveContext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = club.clubName.isNotEmpty
        ? club.clubName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'CLB';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 48,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Discord Left Indicator Pill
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 4,
            height: isSelected ? 36 : (isActiveContext ? 16 : 0),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.cGreen_50 : Colors.white.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
          ),

          // Server Icon Button
          Center(
            child: Tooltip(
              message: '${club.clubName} (${club.role.displayName})',
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.cMain : const Color(0xFF313338),
                    borderRadius: BorderRadius.circular(isSelected ? 16 : 24),
                    border: isActiveContext
                        ? Border.all(color: AppColor.cGreen_50, width: 2)
                        : null,
                    image: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(club.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: club.avatarUrl == null || club.avatarUrl!.isEmpty
                      ? Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFFDBDEE1),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Active Context Dot Badge (ở góc dưới bên phải)
          if (isActiveContext)
            Positioned(
              right: 12,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColor.cGreen_50,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E1F22), width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
