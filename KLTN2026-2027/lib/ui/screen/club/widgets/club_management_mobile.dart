// lib/ui/screen/club/widgets/club_management_mobile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/consts/app_color.dart';
import '../../../../domain/enums/club_role.dart';
import '../../../../widget/club_switcher_dialog.dart';
import '../club_management_vm/club_members_vm.dart';
import '../club_vm/club_context_vm.dart';
import '../role_management/club_role_management_screen.dart';
import 'member_card.dart';

class ClubManagementMobile extends ConsumerWidget {
  const ClubManagementMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubContext = ref.watch(clubContextViewModelProvider);
    final clubMembersState = ref.watch(clubMembersViewModelProvider);
    final vm = ref.read(clubMembersViewModelProvider.notifier);
    final activeContext = clubContext.activeContext;

    if (activeContext == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('Quản lý Câu lạc bộ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          backgroundColor: AppColor.white,
          foregroundColor: AppColor.cTitle,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_tennis_rounded, size: 64, color: AppColor.cMuted.withAlpha(120)),
              const SizedBox(height: 16),
              const Text('Chưa chọn Câu lạc bộ hoạt động', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Vui lòng chọn một câu lạc bộ để xem thông tin.', style: TextStyle(color: AppColor.cMuted)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Chọn Câu lạc bộ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cMain,
                  foregroundColor: Colors.white,
                ),
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(activeContext.clubName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.cTitle,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Đổi câu lạc bộ',
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColor.cMain),
            onPressed: () => ClubSwitcherDialog.show(context),
          ),
        ],
      ),
      body: clubMembersState.isLoading && club == null
          ? const Center(child: CircularProgressIndicator(color: AppColor.cMain))
          : RefreshIndicator(
              onRefresh: () => vm.loadData(),
              color: AppColor.cMain,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Club Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F1E36), Color(0xFF1E3A5F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F1E36).withAlpha(40),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeContext.clubName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        'Mã: ${club?.code ?? ""}',
                                        style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () {
                                          if (club != null) {
                                            Clipboard.setData(ClipboardData(text: club.code));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Đã sao chép mã nhóm!'),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        },
                                        child: Icon(Icons.copy_rounded, size: 14, color: Colors.white.withAlpha(200)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // User's Role in this club
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activeContext.role.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (club?.description != null && club!.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            club.description!,
                            style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 12.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Host Role & Permission Management Action
                  if (activeContext.role == ClubRole.host ||
                      activeContext.role.displayName.toLowerCase().contains('host'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => ClubRoleManagementScreen.show(context, clubId: activeContext.clubId),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFFF3E8FF),
                                child: Icon(Icons.shield_rounded, color: Color(0xFF9333EA), size: 20),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vai trò & Phân quyền (FR03)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.cTitle,
                                      ),
                                    ),
                                    Text(
                                      'Quản lý danh sách vai trò và phân quyền Discord-style',
                                      style: TextStyle(fontSize: 11.5, color: AppColor.cMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColor.cMuted),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 2. Members Section Header & Search
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thành viên (${clubMembersState.members.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.cTitle,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                        label: const Text('Đổi CLB', style: TextStyle(fontSize: 12)),
                        onPressed: () => ClubSwitcherDialog.show(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Search Field
                  TextField(
                    onChanged: (val) => vm.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên, email, vai trò...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColor.cMuted),
                      filled: true,
                      fillColor: AppColor.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cDivider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cDivider),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Members List
                  if (members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Không tìm thấy thành viên nào',
                          style: TextStyle(color: AppColor.cMuted),
                        ),
                      ),
                    )
                  else
                    ...members.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MemberCard(member: m),
                        )),

                  const SizedBox(height: 20),

                  // 4. Leave Club Button
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, size: 18, color: AppColor.cAlert),
                      label: const Text('Rời khỏi câu lạc bộ này', style: TextStyle(color: AppColor.cAlert)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColor.cAlert.withAlpha(100)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        _showLeaveClubDialog(context, ref, activeContext.clubId, activeContext.clubName);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  void _showLeaveClubDialog(BuildContext context, WidgetRef ref, String clubId, String clubName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rời khỏi câu lạc bộ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Bạn có chắc chắn muốn rời khỏi "$clubName"? Bạn sẽ mất quyền truy cập vào nhóm này.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cAlert,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(clubContextViewModelProvider.notifier).leaveClub(clubId);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rời nhóm'),
          ),
        ],
      ),
    );
  }
}
