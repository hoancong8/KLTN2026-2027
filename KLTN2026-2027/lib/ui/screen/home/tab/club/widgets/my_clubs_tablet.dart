// lib/ui/screen/home/tab/club/widgets/my_clubs_tablet.dart

import 'package:flutter/material.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../club/club_vm/club_context_state.dart';
import 'club_action_sheet.dart';
import 'club_detail_view.dart';
import 'club_empty_state.dart';
import 'discord_server_rail.dart';

class MyClubsTablet extends StatelessWidget {
  final ClubContextState state;
  final String? selectedClubId;
  final ValueChanged<String> onSwitchClub;

  const MyClubsTablet({
    super.key,
    required this.state,
    required this.selectedClubId,
    required this.onSwitchClub,
  });

  @override
  Widget build(BuildContext context) {
    final clubs = state.myClubs;
    final activeId = state.activeContext?.clubId;
    final selectedClub = clubs.where((c) => c.clubId == selectedClubId).firstOrNull ??
        (clubs.isNotEmpty ? clubs.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Row(
          children: [
            DiscordServerRail(
              clubs: clubs,
              selectedClubId: selectedClubId,
              activeClubId: activeId,
              onClubSelected: (club) => onSwitchClub(club.clubId),
              onAddClubPressed: () => ClubActionSheet.show(context),
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
                      : const ClubEmptyState(),
            ),
          ],
        ),
      ),
    );
  }
}
