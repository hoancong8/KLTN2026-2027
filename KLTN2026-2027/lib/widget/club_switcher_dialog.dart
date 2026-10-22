// lib/widget/club_switcher_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../domain/entities/club/my_club.dart';
import '../domain/enums/club_role.dart';
import '../ui/screen/club/club_vm/club_context_vm.dart';

/// Hộp thoại / BottomSheet chuyển đổi Câu lạc bộ đang hoạt động
class ClubSwitcherDialog extends ConsumerWidget {
  const ClubSwitcherDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => const ClubSwitcherDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clubContextViewModelProvider);
    final vm = ref.read(clubContextViewModelProvider.notifier);
    final activeId = state.currentClubId;
    final colors = context.colors;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.divider)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 22),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.club_my_clubs,
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.gapH4,
                      Text(
                        context.l10n.club_switch,
                        style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Feedback Message
          if (state.error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: colors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: colors.error, size: 18),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      state.error!.message ?? context.l10n.error_occurred,
                      style: AppTypography.bodySmall.copyWith(color: colors.error),
                    ),
                  ),
                ],
              ),
            ),

          // List of clubs
          Flexible(
            child: state.isLoading && state.myClubs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator(color: colors.primary)),
                  )
                : state.myClubs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Column(
                          children: [
                            Icon(Icons.group_off_outlined, size: 56, color: colors.textMuted),
                            AppSpacing.gapH12,
                            Text(
                              context.l10n.club_no_clubs,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            AppSpacing.gapH8,
                            Text(
                              context.l10n.club_description_hint,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.myClubs.length,
                        separatorBuilder: (_, _) => AppSpacing.gapH8,
                        itemBuilder: (context, index) {
                          final club = state.myClubs[index];
                          final isActive = club.clubId == activeId;

                          return _ClubItemCard(
                            club: club,
                            isActive: isActive,
                            isSwitching: state.isSwitching,
                            onTap: () async {
                              if (!isActive && !state.isSwitching) {
                                final success = await vm.switchClub(club.clubId);
                                if (success && context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(club.clubName),
                                      backgroundColor: colors.primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              border: Border(top: BorderSide(color: colors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_rounded, size: 18),
                    label: Text(context.l10n.club_join),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    onPressed: () {
                      _showJoinClubDialog(context, vm);
                    },
                  ),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(context.l10n.club_create),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/club/create');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinClubDialog(BuildContext context, ClubContextViewModel vm) {
    final colors = context.colors;
    final codeController = TextEditingController();
    final nicknameController = TextEditingController();
    ClubRole selectedRole = ClubRole.member;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: colors.cardBackground,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
          title: Text(
            context.l10n.club_join,
            style: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.club_join_request} *',
                  style: AppTypography.titleSmall.copyWith(color: colors.textPrimary),
                ),
                AppSpacing.gapH8,
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Code (e.g. BADMINTON-A)',
                    hintStyle: AppTypography.bodyMedium.copyWith(color: colors.textPlaceholder),
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                AppSpacing.gapH16,
                Text(
                  context.l10n.prof_full_name,
                  style: AppTypography.titleSmall.copyWith(color: colors.textPrimary),
                ),
                AppSpacing.gapH8,
                TextField(
                  controller: nicknameController,
                  style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: context.l10n.prof_enter_name_hint,
                    hintStyle: AppTypography.bodyMedium.copyWith(color: colors.textPlaceholder),
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                AppSpacing.gapH16,
                Text(
                  context.l10n.club_roles,
                  style: AppTypography.titleSmall.copyWith(color: colors.textPrimary),
                ),
                AppSpacing.gapH8,
                DropdownButtonFormField<ClubRole>(
                  initialValue: selectedRole,
                  dropdownColor: colors.cardBackground,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [ClubRole.member, ClubRole.guest].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(
                        role.displayName,
                        style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.com_cancel, style: TextStyle(color: colors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.isEmpty) return;
                Navigator.of(ctx).pop();
                final ok = await vm.joinClub(
                  clubCode: code,
                  role: selectedRole,
                  nickname: nicknameController.text.trim().isNotEmpty ? nicknameController.text.trim() : null,
                );
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.club_join_request_sent),
                      backgroundColor: colors.primary,
                    ),
                  );
                }
              },
              child: Text(context.l10n.club_join),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubItemCard extends StatelessWidget {
  final MyClub club;
  final bool isActive;
  final bool isSwitching;
  final VoidCallback onTap;

  const _ClubItemCard({
    required this.club,
    required this.isActive,
    required this.isSwitching,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final roleColor = _getRoleColor(club.role);

    return InkWell(
      onTap: isSwitching ? null : onTap,
      borderRadius: AppRadius.card,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? colors.primary.withValues(alpha: 0.12) : colors.surfaceSubtle,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isActive ? colors.primary : colors.cardBorder,
            width: isActive ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive ? colors.primary : colors.border,
                borderRadius: AppRadius.borderSm,
              ),
              child: Center(
                child: Icon(
                  Icons.sports_tennis_rounded,
                  color: isActive ? AppColors.white : colors.textSecondary,
                  size: 22,
                ),
              ),
            ),
            AppSpacing.gapW12,

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          club.clubName,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isActive ? colors.primary : colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppSpacing.gapW8,
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.15),
                          borderRadius: AppRadius.tag,
                          border: Border.all(color: roleColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          club.role.displayName,
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapH4,
                  Row(
                    children: [
                      Text(
                        'Code: ${club.clubCode}',
                        style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                      ),
                      if (club.description != null && club.description!.isNotEmpty) ...[
                        Text(' • ', style: AppTypography.bodySmall.copyWith(color: colors.textMuted)),
                        Expanded(
                          child: Text(
                            club.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.gapW8,

            // Active Checkmark or Radio
            if (isActive)
              Icon(Icons.check_circle_rounded, color: colors.primary, size: 22)
            else
              Icon(Icons.radio_button_unchecked_rounded, color: colors.borderStrong, size: 20),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(ClubRole role) {
    switch (role) {
      case ClubRole.host:
        return AppColors.roleHost;
      case ClubRole.deputy:
        return AppColors.roleDeputy;
      case ClubRole.treasurer:
        return AppColors.roleTreasurer;
      case ClubRole.member:
        return AppColors.roleMember;
      case ClubRole.guest:
        return AppColors.roleGuest;
    }
  }
}
