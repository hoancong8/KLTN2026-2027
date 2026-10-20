// lib/widget/club_switcher_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/consts/app_color.dart';
import '../domain/entities/club/my_club.dart';
import '../domain/enums/club_role.dart';
import '../ui/screen/club/club_vm/club_context_vm.dart';
import '../ui/screen/home/tab/club/widgets/club_create_dialog.dart';

/// Hộp thoại / BottomSheet chuyển đổi Câu lạc bộ đang hoạt động
class ClubSwitcherDialog extends ConsumerWidget {
  const ClubSwitcherDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ClubSwitcherDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clubContextViewModelProvider);
    final vm = ref.read(clubContextViewModelProvider.notifier);
    final activeId = state.currentClubId;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColor.cDivider)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.cMain.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sports_tennis_rounded, color: AppColor.cMain, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh sách Nhóm Cầu Lông',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.cTitle,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Chọn câu lạc bộ để đồng bộ quyền hạn tương ứng',
                        style: TextStyle(fontSize: 12, color: AppColor.cMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColor.cMuted),
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
                color: AppColor.cAlert.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.cAlert.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColor.cAlert, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!.message ?? 'Có lỗi xảy ra',
                      style: const TextStyle(fontSize: 12, color: AppColor.cAlert),
                    ),
                  ),
                ],
              ),
            ),

          // List of clubs
          Flexible(
            child: state.isLoading && state.myClubs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator(color: AppColor.cMain)),
                  )
                : state.myClubs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Column(
                          children: [
                            Icon(Icons.group_off_outlined, size: 56, color: AppColor.cMuted.withAlpha(120)),
                            const SizedBox(height: 12),
                            const Text(
                              'Bạn chưa tham gia nhóm cầu lông nào',
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColor.cTitle),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Hãy tham gia bằng mã Code hoặc tự tạo một câu lạc bộ mới bên dưới.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColor.cMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.myClubs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                                      content: Text('Đã chuyển sang nhóm ${club.clubName}'),
                                      backgroundColor: AppColor.cGreen,
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
            decoration: const BoxDecoration(
              color: AppColors.neutral50,
              border: Border(top: BorderSide(color: AppColor.cDivider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_rounded, size: 18),
                    label: const Text('Tham gia bằng Code'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.cMain,
                      side: const BorderSide(color: AppColor.cMain),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      _showJoinClubDialog(context, vm);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tạo nhóm mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cMain,
                      foregroundColor: AppColor.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final newClubId = await ClubCreateDialog.show(context);
                      if (newClubId != null && newClubId.isNotEmpty && context.mounted) {
                        context.push('/club/$newClubId');
                      }
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
    final codeController = TextEditingController();
    final nicknameController = TextEditingController();
    ClubRole selectedRole = ClubRole.member;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tham gia Nhóm Cầu Lông', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mã tham gia (Club Code) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã Code (ví dụ: BADMINTON-A)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Biệt danh / Tên hiển thị', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    hintText: 'Biệt danh trong nhóm (tùy chọn)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Vai trò mong muốn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<ClubRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [ClubRole.member, ClubRole.guest].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
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
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cMain,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    const SnackBar(
                      content: Text('Tham gia nhóm thành công!'),
                      backgroundColor: AppColor.cGreen,
                    ),
                  );
                }
              },
              child: const Text('Tham gia'),
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
    final roleColor = _getRoleColor(club.role);

    return InkWell(
      onTap: isSwitching ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? AppColor.cMain.withAlpha(12) : AppColors.neutral50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColor.cMain : AppColor.cDivider,
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
                color: isActive ? AppColor.cMain : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.sports_tennis_rounded,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppColor.cMain : AppColor.cTitle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: roleColor.withAlpha(80)),
                        ),
                        child: Text(
                          club.role.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Mã: ${club.clubCode}',
                        style: const TextStyle(fontSize: 12, color: AppColor.cMuted),
                      ),
                      if (club.description != null && club.description!.isNotEmpty) ...[
                        const Text(' • ', style: TextStyle(color: AppColor.cMuted)),
                        Expanded(
                          child: Text(
                            club.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColor.cMuted),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Active Checkmark or Arrow
            if (isActive)
              const Icon(Icons.check_circle_rounded, color: AppColor.cMain, size: 22)
            else
              const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.neutral300, size: 20),
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
        return AppColor.cGreen;
      case ClubRole.guest:
        return AppColors.roleGuest;
    }
  }
}
