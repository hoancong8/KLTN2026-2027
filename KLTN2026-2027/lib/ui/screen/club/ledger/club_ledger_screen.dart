import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/consts/permissions.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/localization_provider.dart';
import '../club_vm/club_context_vm.dart';
import 'widgets/ledger_content.dart';
import 'widgets/ledger_ui.dart';

class ClubLedgerScreen extends StatelessWidget {
  final String clubId;
  const ClubLedgerScreen({super.key, required this.clubId});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.ledger_title)),
    body: SafeArea(child: ClubLedgerBody(clubId: clubId)),
  );
}

class ClubLedgerBody extends ConsumerWidget {
  final String clubId;
  const ClubLedgerBody({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeClubContextProvider);
    final token = ref.watch(authTokenProvider);
    final userId = token?.userId ?? ref.watch(currentUserProfileProvider)?.id;
    if (token == null || userId == null) {
      return LedgerNotice(message: context.l10n.auth_forbidden);
    }
    if (active?.clubId != clubId) {
      final clubState = ref.watch(clubContextViewModelProvider);
      return LedgerNotice(
        message: context.l10n.ledger_switch_context,
        busy: clubState.isSwitching,
        action: () async {
          final ok = await ref
              .read(clubContextViewModelProvider.notifier)
              .switchClub(clubId);
          if (!ok && context.mounted) {
            showLedgerFeedback(context, context.l10n.ledger_switch_failed);
          }
        },
        actionLabel: context.l10n.ledger_switch_action,
      );
    }
    if (!active!.hasPermission(ClubPermissions.ledgerView)) {
      return LedgerNotice(message: context.l10n.auth_forbidden);
    }
    final scope = (clubId: clubId, userId: userId);
    return LedgerContent(key: ValueKey(scope), scope: scope);
  }
}
