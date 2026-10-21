// lib/ui/screen/home/tab/club/my_clubs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/consts/app_config.dart';
import '../../../../../app/theme/theme.dart';
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

  void _showAddOrJoinSheet(BuildContext context, ClubContextViewModel vm) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.bottomSheet,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderXs,
                ),
              ),
              AppSpacing.gapH16,
              Text(
                'Tham Gia Hoặc Tạo Câu Lạc Bộ',
                style: AppTypography.titleLarge.bold.colored(AppColors.textPrimary),
              ),
              AppSpacing.gapH8,
              Text(
                'Kết nối cùng đồng đội và tham gia các buổi tập sôi động',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.colored(AppColors.textMuted),
              ),
              AppSpacing.gapH20,

              // Action 1: Create Club
              _buildBottomSheetActionTile(
                icon: Icons.add_business_rounded,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primaryContainer,
                title: 'Tạo câu lạc bộ mới',
                subtitle: 'Bạn sẽ là Chủ nhóm (Host) quản lý lịch chơi, thu quỹ và duyệt đơn',
                onTap: () => Navigator.of(ctx).pop('create'),
              ),

              AppSpacing.gapH12,

              // Action 2: Join with Code
              _buildBottomSheetActionTile(
                icon: Icons.tag_rounded,
                iconColor: AppColors.roleSky,
                iconBgColor: AppColors.secondaryContainer,
                title: 'Tham gia bằng mã Code',
                subtitle: 'Nhập mã Code được Host chia sẻ để vào nhóm ngay',
                onTap: () => Navigator.of(ctx).pop('join'),
              ),

              AppSpacing.gapH12,

              // Action 3: Radar GPS Explore
              _buildBottomSheetActionTile(
                icon: Icons.radar_rounded,
                iconColor: AppColors.roleViolet,
                iconBgColor: AppColors.violetLight,
                title: 'Quét tìm CLB quanh đây (Radar GPS)',
                subtitle: 'Tìm các câu lạc bộ cầu lông đang hoạt động trong khu vực của bạn',
                onTap: () => Navigator.of(ctx).pop('explore'),
              ),
              AppSpacing.gapH12,

              // Action 4: My Bookings
              _buildBottomSheetActionTile(
                icon: Icons.event_available_rounded,
                iconColor: AppColors.primaryDark,
                iconBgColor: AppColors.primaryContainer,
                title: 'Lịch chơi tôi đã đăng ký',
                subtitle: 'Xem toàn bộ vé tham gia, buổi tập và trạng thái điểm danh',
                onTap: () => Navigator.of(ctx).pop('bookings'),
              ),
              AppSpacing.gapH8,
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || action == null) return;
    if (action == 'create') {
      final newClubId = await ClubCreateDialog.show(context);
      if (newClubId != null && newClubId.isNotEmpty && context.mounted) {
        context.push('/club/$newClubId');
      }
    } else if (action == 'join') {
      _showJoinClubDialog(context, vm);
    } else if (action == 'explore') {
      context.push(AppConfig.exploreClubsScreenPath);
    } else if (action == 'bookings') {
      context.push(AppConfig.myBookingsRoutePath);
    }
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
      color: AppColors.background,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: AppSpacing.iconMd),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                    ),
                    AppSpacing.gapH4,
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.colored(AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: AppSpacing.iconSm),
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
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.bottomSheet,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.borderXs,
                  ),
                ),
              ),
              AppSpacing.gapH16,
              Text(
                'Danh sách Câu lạc bộ của bạn',
                style: AppTypography.titleLarge.bold.colored(AppColors.textPrimary),
              ),
              AppSpacing.gapH4,
              Text(
                'Chọn nhóm để xem buổi tập và quản lý',
                style: AppTypography.bodySmall.colored(AppColors.textMuted),
              ),
              AppSpacing.gapH16,
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: clubs.length,
                  separatorBuilder: (_, _) => AppSpacing.gapH8,
                  itemBuilder: (ctx, i) {
                    final club = clubs[i];
                    final isSelected = club.clubId == _selectedClubId;
                    final isActive = club.clubId == activeId;
                    return Material(
                      color: isSelected ? AppColors.primaryContainer : AppColors.background,
                      borderRadius: AppRadius.borderMd,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _switchSelectedClub(club.clubId, vm);
                        },
                        borderRadius: AppRadius.borderMd,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: AppRadius.borderMd,
                                  image: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                                      ? DecorationImage(image: NetworkImage(club.avatarUrl!), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: club.avatarUrl == null || club.avatarUrl!.isEmpty
                                    ? const Center(child: Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 22))
                                    : null,
                              ),
                              AppSpacing.gapW12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      club.clubName,
                                      style: AppTypography.titleSmall.colored(
                                        isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600),
                                    ),
                                    AppSpacing.gapH4,
                                    Row(
                                      children: [
                                        Text(
                                          club.role.displayName,
                                          style: AppTypography.labelSmall.colored(AppColors.textMuted),
                                        ),
                                        if (isActive) ...[
                                          AppSpacing.gapW8,
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: const BoxDecoration(
                                              color: AppColors.successContainer,
                                              borderRadius: AppRadius.borderXs,
                                            ),
                                            child: Text(
                                              'Kích hoạt',
                                              style: AppTypography.labelSmall.bold.colored(AppColors.onSuccess),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              AppSpacing.gapH16,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: AppSpacing.verticalMd,
                        side: const BorderSide(color: AppColors.primary),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      icon: const Icon(Icons.tag_rounded, color: AppColors.primary, size: AppSpacing.iconSm),
                      label: Text('Nhập mã Code', style: AppTypography.labelLarge.bold.colored(AppColors.primary)),
                      onPressed: () => Navigator.of(ctx).pop('join'),
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        padding: AppSpacing.verticalMd,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      icon: const Icon(Icons.add_rounded, size: AppSpacing.iconSm),
                      label: Text('Tạo CLB mới', style: AppTypography.labelLarge.bold.colored(AppColors.onPrimary)),
                      onPressed: () => Navigator.of(ctx).pop('create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || action == null) return;
    if (action == 'create') {
      final newClubId = await ClubCreateDialog.show(context);
      if (newClubId != null && newClubId.isNotEmpty && context.mounted) {
        context.push('/club/$newClubId');
      }
    } else if (action == 'join') {
      _showJoinClubDialog(context, vm);
    }
  }

  void _showJoinClubDialog(BuildContext context, ClubContextViewModel vm) {
    final codeController = TextEditingController();
    final nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            const Icon(Icons.tag_rounded, color: AppColors.roleSky),
            AppSpacing.gapW8,
            Text('Tham Gia Bằng Mã Code', style: AppTypography.titleLarge.bold),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppSpacing.allMd,
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: AppColors.successBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.how_to_reg_rounded, color: AppColors.success, size: 20),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Text(
                        'Yêu cầu của bạn sẽ được gửi vào danh sách duyệt đơn của Host và Ban quản trị. Sau khi được duyệt, bạn sẽ là Thành viên chính thức của nhóm.',
                        style: AppTypography.bodySmall.colored(AppColors.onSuccess),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH16,
              Text('Mã câu lạc bộ (Code) *', style: AppTypography.labelMedium.semiBold.colored(AppColors.textPrimary)),
              AppSpacing.gapH8,
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.tag_rounded, color: AppColors.textMuted),
                  hintText: 'Ví dụ: CLB-E22A0E',
                  border: OutlineInputBorder(borderRadius: AppRadius.input),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                ),
              ),
              AppSpacing.gapH16,
              Text('Biệt danh thi đấu (Nickname)', style: AppTypography.labelMedium.semiBold.colored(AppColors.textPrimary)),
              AppSpacing.gapH8,
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
                  hintText: 'Tùy chọn (ví dụ: Hoàng Smash)',
                  border: OutlineInputBorder(borderRadius: AppRadius.input),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: AppTypography.labelLarge.colored(AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roleSky,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
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
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text('Gửi đơn xin gia nhập', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: clubs.isEmpty
            ? Text(
                'Câu Lạc Bộ Của Tôi',
                style: AppTypography.titleLarge.bold.colored(AppColors.textPrimary),
              )
            : InkWell(
                onTap: () => _showClubSwitcherSheet(context, clubs, activeId, vm),
                borderRadius: AppRadius.borderSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          selectedClub?.clubName ?? 'Câu Lạc Bộ',
                          style: AppTypography.titleMedium.bold.colored(AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppSpacing.gapW4,
                      const Icon(Icons.expand_more_rounded, color: AppColors.textMuted, size: AppSpacing.iconSm),
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
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
            ),
            onPressed: () => context.push(AppConfig.myBookingsRoutePath),
          ),
          IconButton(
            tooltip: 'Thêm / Tham gia nhóm',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
            ),
            onPressed: () => _showAddOrJoinSheet(context, vm),
          ),
          AppSpacing.gapW8,
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(clubs.length > 1 ? 64 : 1),
          child: Column(
            children: [
              if (clubs.length > 1) _buildHorizontalClubStrip(clubs, activeId, vm),
              Container(height: 1, color: AppColors.border),
            ],
          ),
        ),
      ),
      body: state.isLoading && clubs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 6),
        itemCount: clubs.length + 1,
        separatorBuilder: (_, _) => AppSpacing.gapW8,
        itemBuilder: (context, index) {
          if (index == clubs.length) {
            return InkWell(
              onTap: () async {
                final newClubId = await ClubCreateDialog.show(context);
                if (newClubId != null && newClubId.isNotEmpty && context.mounted) {
                  context.push('/club/$newClubId');
                }
              },
              borderRadius: AppRadius.borderFull,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: AppSpacing.iconSm, color: AppColors.primary),
                    AppSpacing.gapW4,
                    Text(
                      'Tạo CLB mới',
                      style: AppTypography.labelSmall.bold.colored(AppColors.primary),
                    ),
                  ],
                ),
              ),
            );
          }
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceSubtle,
                borderRadius: AppRadius.borderFull,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
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
                      color: isSelected ? AppColors.primary : AppColors.neutral400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: AppTypography.labelSmall.bold.colored(AppColors.white),
                      ),
                    ),
                  ),
                  AppSpacing.gapW8,
                  Text(
                    club.clubName,
                    style: AppTypography.bodySmall.colored(
                      isSelected ? AppColors.primary : AppColors.textPrimary,
                    ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                  ),
                  if (isActive) ...[
                    AppSpacing.gapW4,
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
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
      backgroundColor: AppColors.background,
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
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero Visual Card
            Container(
              padding: AppSpacing.allXl,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),

            AppSpacing.gapH24,

            Text(
              'Chưa tham gia Câu lạc bộ nào',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.bold.colored(AppColors.textPrimary),
            ),

            AppSpacing.gapH8,

            Padding(
              padding: AppSpacing.horizontalBase,
              child: Text(
                'Tham gia hoặc tạo câu lạc bộ để lên lịch thi đấu, bình chọn slot buổi tập, theo dõi hàng chờ và giao lưu cùng đồng đội.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.colored(AppColors.textMuted),
              ),
            ),

            AppSpacing.gapH32,

            // Card 1: Tạo CLB Mới (Primary Action)
            _buildActionCard(
              title: 'Tạo Câu Lạc Bộ Mới',
              description: 'Bạn là Chủ nhóm (Host) lên lịch buổi chơi, quản lý quỹ và duyệt thành viên',
              icon: Icons.add_business_rounded,
              accentColor: AppColors.primary,
              onTap: () async {
                final newClubId = await ClubCreateDialog.show(context);
                if (newClubId != null && newClubId.isNotEmpty && context.mounted) {
                  context.push('/club/$newClubId');
                }
              },
            ),

            AppSpacing.gapH12,

            // Card 2: Nhập Mã Code
            _buildActionCard(
              title: 'Tham Gia Bằng Mã Code',
              description: 'Nhập mã Code được Host chia sẻ để gia nhập nhóm bạn bè ngay lập tức',
              icon: Icons.tag_rounded,
              accentColor: AppColors.roleSky,
              onTap: () => _showJoinClubDialog(context, vm),
            ),

            AppSpacing.gapH12,

            // Card 3: Khám Phá CLB Quanh Đây (FR06)
            _buildActionCard(
              title: 'Tìm CLB Quanh Đây (Radar GPS)',
              description: 'Quét bán kính xung quanh tìm các CLB cầu lông đang hoạt động và tuyển quân',
              icon: Icons.radar_rounded,
              accentColor: AppColors.roleViolet,
              onTap: () => context.push(AppConfig.exploreClubsScreenPath),
            ),

            AppSpacing.gapH12,

            // Card 4: Khám Phá Kèo Giao Lưu (FR12)
            _buildActionCard(
              title: 'Tìm Kèo Giao Lưu Gần Bạn',
              description: 'Quét radar tìm kiếm các buổi tập đang tuyển người vãng lai trong khu vực',
              icon: Icons.sports_tennis_rounded,
              accentColor: AppColors.warning,
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
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.card,
          child: Padding(
            padding: AppSpacing.card,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(icon, color: accentColor, size: AppSpacing.iconMd),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                      ),
                      AppSpacing.gapH4,
                      Text(
                        description,
                        style: AppTypography.bodySmall.colored(AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapW8,
                Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: AppSpacing.iconSm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
