// lib/ui/screen/home/tab/club/my_clubs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/consts/app_color.dart';
import '../../../../../app/consts/app_config.dart';
import '../../../../../domain/entities/club/my_club.dart';
import '../../../../../domain/enums/club_role.dart';
import '../../../club/club_management_vm/club_members_vm.dart';
import '../../../club/club_vm/club_context_state.dart';
import '../../../club/club_vm/club_context_vm.dart';
import 'widgets/club_create_dialog.dart';
import 'widgets/club_detail_view.dart';
import 'widgets/discord_server_rail.dart';

class MyClubsPage extends ConsumerStatefulWidget {
  const MyClubsPage({super.key});

  @override
  ConsumerState<MyClubsPage> createState() => _MyClubsPageState();
}

class _MyClubsPageState extends ConsumerState<MyClubsPage> {
  String? _selectedClubId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clubContextViewModelProvider.notifier).loadMyClubs();
    });
  }

  Future<void> _switchSelectedClub(String clubId, ClubContextViewModel vm) async {
    setState(() => _selectedClubId = clubId);
    final ok = await vm.switchClub(clubId);
    if (ok && mounted) {
      ref.read(clubMembersViewModelProvider.notifier).loadForClub(clubId);
    }
  }

  void _showAddOrJoinSheet(BuildContext context, ClubContextViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tham Gia Hoặc Tạo Câu Lạc Bộ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.cTitle,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Kết nối cùng đồng đội và tham gia các buổi tập sôi động',
                style: TextStyle(fontSize: 13, color: AppColor.cMuted),
              ),
              const SizedBox(height: 20),

              // Action 1: Create Club
              _buildBottomSheetActionTile(
                icon: Icons.add_business_rounded,
                iconColor: AppColor.cMain,
                iconBgColor: AppColor.cMain.withValues(alpha: 0.12),
                title: 'Tạo câu lạc bộ mới',
                subtitle: 'Bạn sẽ là Chủ nhóm (Host) quản lý lịch chơi, thu quỹ và duyệt đơn',
                onTap: () {
                  Navigator.of(ctx).pop();
                  ClubCreateDialog.show(context);
                },
              ),

              const SizedBox(height: 12),

              // Action 2: Join with Code
              _buildBottomSheetActionTile(
                icon: Icons.tag_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBgColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                title: 'Tham gia bằng mã Code',
                subtitle: 'Nhập mã Code được Host chia sẻ để vào nhóm ngay',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showJoinClubDialog(context, vm);
                },
              ),

              const SizedBox(height: 12),

              // Action 3: Radar GPS Explore
              _buildBottomSheetActionTile(
                icon: Icons.radar_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                title: 'Quét tìm CLB quanh đây (Radar GPS)',
                subtitle: 'Tìm các câu lạc bộ cầu lông đang hoạt động trong khu vực của bạn',
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push(AppConfig.exploreClubsScreenPath);
                },
              ),
              const SizedBox(height: 12),

              // Action 4: My Bookings
              _buildBottomSheetActionTile(
                icon: Icons.event_available_rounded,
                iconColor: const Color(0xFF059669),
                iconBgColor: const Color(0xFF059669).withValues(alpha: 0.12),
                title: 'Lịch chơi tôi đã đăng ký',
                subtitle: 'Xem toàn bộ vé tham gia, buổi tập và trạng thái điểm danh',
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push(AppConfig.myBookingsRoutePath);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColor.cTitle,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColor.cMuted, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColor.cMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showClubSwitcherSheet(
    BuildContext context,
    List<MyClub> clubs,
    String? activeId,
    ClubContextViewModel vm,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Danh sách Câu lạc bộ của bạn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.cTitle),
              ),
              const SizedBox(height: 4),
              const Text('Chọn nhóm để xem buổi tập và quản lý', style: TextStyle(fontSize: 13, color: AppColor.cMuted)),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: clubs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final club = clubs[i];
                    final isSelected = club.clubId == _selectedClubId;
                    final isActive = club.clubId == activeId;
                    return Material(
                      color: isSelected ? AppColor.cMain.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _switchSelectedClub(club.clubId, vm);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColor.cMain.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  image: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                                      ? DecorationImage(image: NetworkImage(club.avatarUrl!), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: club.avatarUrl == null || club.avatarUrl!.isEmpty
                                    ? const Center(child: Icon(Icons.sports_tennis_rounded, color: AppColor.cMain, size: 22))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      club.clubName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? AppColor.cMain : AppColor.cTitle,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          club.role.displayName,
                                          style: const TextStyle(fontSize: 12, color: AppColor.cMuted),
                                        ),
                                        if (isActive) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Kích hoạt',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColor.cMain, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColor.cMain),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_rounded, color: AppColor.cMain),
                  label: const Text('Thêm hoặc tham gia nhóm khác', style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.cMain)),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showAddOrJoinSheet(context, vm);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinClubDialog(BuildContext context, ClubContextViewModel vm) {
    final codeController = TextEditingController();
    final nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.tag_rounded, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('Tham Gia Bằng Mã Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.how_to_reg_rounded, color: Color(0xFF16A34A), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Yêu cầu của bạn sẽ được gửi vào danh sách duyệt đơn của Host và Ban quản trị. Sau khi được duyệt, bạn sẽ là Thành viên chính thức của nhóm.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF15803D), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Mã câu lạc bộ (Code) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.tag_rounded, color: AppColor.cMuted),
                  hintText: 'Ví dụ: CLB-E22A0E',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Biệt danh thi đấu (Nickname)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: nicknameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColor.cMuted),
                  hintText: 'Tùy chọn (ví dụ: Hoàng Smash)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: AppColor.cMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isEmpty) return;
              Navigator.of(ctx).pop();
              final ok = await vm.joinClub(
                clubCode: code,
                role: ClubRole.member,
                nickname: nicknameController.text.trim().isNotEmpty ? nicknameController.text.trim() : null,
              );
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi yêu cầu tham gia thành công! Vui lòng chờ Ban quản trị duyệt đơn.'),
                    backgroundColor: AppColor.cGreen,
                  ),
                );
              }
            },
            child: const Text('Gửi đơn xin gia nhập', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubContextViewModelProvider);
    final vm = ref.read(clubContextViewModelProvider.notifier);
    final clubs = state.myClubs;
    final activeId = state.activeContext?.clubId;
    final isTablet = MediaQuery.of(context).size.width >= 700;

    // Chọn CLB active hoặc CLB đầu tiên nếu chưa chọn và tự động switch context
    if (_selectedClubId == null && clubs.isNotEmpty) {
      final activeClub = clubs.where((c) => c.clubId == activeId).firstOrNull;
      final targetClub = activeClub ?? clubs.first;
      _selectedClubId = targetClub.clubId;
      if (activeId != targetClub.clubId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _switchSelectedClub(targetClub.clubId, vm);
        });
      }
    }

    final selectedClub = clubs.where((c) => c.clubId == _selectedClubId).firstOrNull ??
        (clubs.isNotEmpty ? clubs.first : null);

    // 1. Phân chia giao diện Tablet / Mobile
    if (isTablet) {
      return _buildTabletLayout(context, state, vm, clubs, activeId, selectedClub);
    }

    return _buildMobileLayout(context, state, vm, clubs, activeId, selectedClub);
  }

  /// GIAO DIỆN MOBILE: Trực quan, full chiều rộng, không bị bóp nghẹt
  Widget _buildMobileLayout(
    BuildContext context,
    ClubContextState state,
    ClubContextViewModel vm,
    List<MyClub> clubs,
    String? activeId,
    MyClub? selectedClub,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: clubs.isEmpty
            ? const Text(
                'Câu Lạc Bộ Của Tôi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.cTitle),
              )
            : InkWell(
                onTap: () => _showClubSwitcherSheet(context, clubs, activeId, vm),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          selectedClub?.clubName ?? 'Câu Lạc Bộ',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColor.cTitle),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more_rounded, color: AppColor.cMuted, size: 20),
                    ],
                  ),
                ),
              ),
        actions: [
          IconButton(
            tooltip: 'Lịch tôi đã đăng ký',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_available_rounded, color: AppColor.cMain, size: 20),
            ),
            onPressed: () => context.push(AppConfig.myBookingsRoutePath),
          ),
          IconButton(
            tooltip: 'Thêm / Tham gia nhóm',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColor.cMain.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColor.cMain, size: 22),
            ),
            onPressed: () => _showAddOrJoinSheet(context, vm),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(clubs.length > 1 ? 64 : 1),
          child: Column(
            children: [
              if (clubs.length > 1) _buildHorizontalClubStrip(clubs, activeId, vm),
              Container(height: 1, color: const Color(0xFFE2E8F0)),
            ],
          ),
        ),
      ),
      body: state.isLoading && clubs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColor.cMain))
          : selectedClub != null
              ? ClubDetailView(
                  key: ValueKey(selectedClub.clubId),
                  club: selectedClub,
                  isActiveContext: selectedClub.clubId == activeId,
                )
              : _buildEmptyClubsState(context, vm),
    );
  }

  /// Dải avatar ngang khi user tham gia nhiều hơn 1 CLB
  Widget _buildHorizontalClubStrip(List<MyClub> clubs, String? activeId, ClubContextViewModel vm) {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: clubs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final club = clubs[index];
          final isSelected = club.clubId == _selectedClubId;
          final isActive = club.clubId == activeId;
          final initials = club.clubName.isNotEmpty
              ? club.clubName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
              : 'CLB';

          return GestureDetector(
            onTap: () => _switchSelectedClub(club.clubId, vm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.cMain.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColor.cMain : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.cMain : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    club.clubName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColor.cMain : AppColor.cTitle,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle_rounded, color: AppColor.cGreen, size: 14),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// GIAO DIỆN TABLET: Hai cột (Rail bên trái + Nội dung bên phải)
  Widget _buildTabletLayout(
    BuildContext context,
    ClubContextState state,
    ClubContextViewModel vm,
    List<MyClub> clubs,
    String? activeId,
    MyClub? selectedClub,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Row(
          children: [
            DiscordServerRail(
              clubs: clubs,
              selectedClubId: _selectedClubId,
              activeClubId: activeId,
              onClubSelected: (club) => _switchSelectedClub(club.clubId, vm),
              onAddClubPressed: () => _showAddOrJoinSheet(context, vm),
            ),
            Expanded(
              child: state.isLoading && clubs.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColor.cMain))
                  : selectedClub != null
                      ? ClubDetailView(
                          key: ValueKey(selectedClub.clubId),
                          club: selectedClub,
                          isActiveContext: selectedClub.clubId == activeId,
                        )
                      : _buildEmptyClubsState(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State tuyệt đẹp, full màn hình, không bao giờ bị overflow
  Widget _buildEmptyClubsState(BuildContext context, ClubContextViewModel vm) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero Visual Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.cMain.withValues(alpha: 0.15),
                    const Color(0xFF0284C7).withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                size: 64,
                color: AppColor.cMain,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Chưa tham gia Câu lạc bộ nào',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.cTitle,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tham gia hoặc tạo câu lạc bộ để lên lịch thi đấu, bình chọn slot buổi tập, theo dõi hàng chờ và giao lưu cùng đồng đội.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColor.cMuted,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Card 1: Tạo CLB Mới (Primary Action)
            _buildActionCard(
              title: 'Tạo Câu Lạc Bộ Mới',
              description: 'Bạn là Chủ nhóm (Host) lên lịch buổi chơi, quản lý quỹ và duyệt thành viên',
              icon: Icons.add_business_rounded,
              accentColor: AppColor.cMain,
              onTap: () => ClubCreateDialog.show(context),
            ),

            const SizedBox(height: 14),

            // Card 2: Nhập Mã Code
            _buildActionCard(
              title: 'Tham Gia Bằng Mã Code',
              description: 'Nhập mã Code được Host chia sẻ để gia nhập nhóm bạn bè ngay lập tức',
              icon: Icons.tag_rounded,
              accentColor: const Color(0xFF0284C7),
              onTap: () => _showJoinClubDialog(context, vm),
            ),

            const SizedBox(height: 14),

            // Card 3: Khám Phá CLB Quanh Đây (FR06)
            _buildActionCard(
              title: 'Tìm CLB Quanh Đây (Radar GPS)',
              description: 'Quét bán kính xung quanh tìm các CLB cầu lông đang hoạt động và tuyển quân',
              icon: Icons.radar_rounded,
              accentColor: const Color(0xFF7C3AED),
              onTap: () => context.push(AppConfig.exploreClubsScreenPath),
            ),

            const SizedBox(height: 14),

            // Card 4: Khám Phá Kèo Giao Lưu (FR12)
            _buildActionCard(
              title: 'Tìm Kèo Giao Lưu Gần Bạn',
              description: 'Quét radar tìm kiếm các buổi tập đang tuyển người vãng lai trong khu vực',
              icon: Icons.sports_tennis_rounded,
              accentColor: const Color(0xFFF59E0B),
              onTap: () => context.push(AppConfig.exploreRecruitmentsScreenPath),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColor.cTitle,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.cMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
