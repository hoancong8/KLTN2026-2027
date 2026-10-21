// lib/ui/screen/club/widgets/club_management_tablet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../domain/enums/club_role.dart';
import '../../../../widget/club_switcher_dialog.dart';
import '../club_management_vm/club_members_vm.dart';
import '../club_vm/club_context_vm.dart';
import '../role_management/club_role_management_screen.dart';
import 'member_card.dart';

class ClubManagementTablet extends ConsumerWidget {
  const ClubManagementTablet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubContext = ref.watch(clubContextViewModelProvider);
    final clubMembersState = ref.watch(clubMembersViewModelProvider);
    final vm = ref.read(clubMembersViewModelProvider.notifier);
    final activeContext = clubContext.activeContext;

    if (activeContext == null) {
      return Scaffold(
        backgroundColor: AppColors.neutral50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_tennis_rounded, size: 72, color: AppColors.textMuted.withAlpha(120)),
              const SizedBox(height: 16),
              const Text('Chưa chọn Câu lạc bộ hoạt động', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Vui lòng chọn hoặc tham gia một câu lạc bộ.', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Chọn Câu lạc bộ'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () => ClubSwitcherDialog.show(context),
              ),
            ],
          ),
        ),
      );
    }

    final club = clubMembersState.club;
    final members = clubMembersState.filteredMembers;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Quản lý Câu lạc bộ & Thành viên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Đổi CLB'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            onPressed: () => ClubSwitcherDialog.show(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: clubMembersState.isLoading && club == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Club Info & Stats
                  SizedBox(
                    width: 320,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: AppColors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 30),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              activeContext.clubName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('Mã nhóm: ${club?.code ?? ""}', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    if (club != null) {
                                      Clipboard.setData(ClipboardData(text: club.code));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã sao chép mã nhóm!'), duration: Duration(seconds: 1)),
                                      );
                                    }
                                  },
                                  child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.border),
                            const SizedBox(height: 12),
                            const Text('Vai trò của bạn trong nhóm:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withAlpha(60)),
                              ),
                              child: Text(
                                activeContext.role.displayName,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (club?.description != null && club!.description!.isNotEmpty) ...[
                              const Text('Mô tả nhóm:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(club.description!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                              const SizedBox(height: 16),
                            ],
                            const Spacer(),
                            if (activeContext.role == ClubRole.host ||
                                activeContext.role.displayName.toLowerCase().contains('host')) ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.shield_rounded, size: 18),
                                  label: const Text('Vai trò & Phân quyền', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.roleHost,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => ClubRoleManagementScreen.show(context, clubId: activeContext.clubId),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                                label: const Text('Rời khỏi câu lạc bộ', style: TextStyle(color: AppColors.error)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.error.withAlpha(100)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Rời khỏi CLB'),
                                      content: Text('Bạn có chắc muốn rời khỏi "${activeContext.clubName}"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: const Text('Rời nhóm'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await ref.read(clubContextViewModelProvider.notifier).leaveClub(activeContext.clubId);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right Column: Members List
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: AppColors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Danh sách Thành viên (${clubMembersState.members.length})',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: TextField(
                                    onChanged: (val) => vm.setSearchQuery(val),
                                    decoration: InputDecoration(
                                      hintText: 'Tìm theo tên, email, vai trò...',
                                      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                                      filled: true,
                                      fillColor: AppColors.neutral50,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.border),
                            const SizedBox(height: 8),
                            Expanded(
                              child: members.isEmpty
                                  ? const Center(child: Text('Không tìm thấy thành viên nào', style: TextStyle(color: AppColors.textMuted)))
                                  : ListView.separated(
                                      itemCount: members.length,
                                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                                      itemBuilder: (_, index) => MemberCard(member: members[index]),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
