// lib/ui/screen/home/tab/club/my_clubs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../widget/responsive_layout.dart';
import '../../../club/club_management_vm/club_members_vm.dart';
import '../../../club/club_vm/club_context_vm.dart';
import 'widgets/my_clubs_mobile.dart';
import 'widgets/my_clubs_tablet.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubContextViewModelProvider);
    final vm = ref.read(clubContextViewModelProvider.notifier);
    final clubs = state.myClubs;
    final activeId = state.activeContext?.clubId;

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

    return ResponsiveLayout(
      mobile: MyClubsMobile(
        state: state,
        selectedClubId: _selectedClubId,
        onSwitchClub: (clubId) => _switchSelectedClub(clubId, vm),
      ),
      tablet: MyClubsTablet(
        state: state,
        selectedClubId: _selectedClubId,
        onSwitchClub: (clubId) => _switchSelectedClub(clubId, vm),
      ),
    );
  }
}
