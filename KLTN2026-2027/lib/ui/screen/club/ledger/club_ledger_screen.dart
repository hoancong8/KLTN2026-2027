import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/consts/permissions.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/localization_provider.dart';
import '../club_vm/club_context_vm.dart';
import 'widgets/ledger_content.dart';
import 'widgets/ledger_ui.dart';

class ClubLedgerScreen extends ConsumerStatefulWidget {
  final String clubId;
  final bool autoSwitchClub;
  const ClubLedgerScreen({
    super.key,
    required this.clubId,
    this.autoSwitchClub = false,
  });

  @override
  ConsumerState<ClubLedgerScreen> createState() => _ClubLedgerScreenState();
}

class _ClubLedgerScreenState extends ConsumerState<ClubLedgerScreen> {
  bool _attempted = false;
  bool _switchFailed = false;

  Future<void> _switchClub() async {
    final success = await ref
        .read(clubContextViewModelProvider.notifier)
        .switchClub(widget.clubId);
    if (!mounted) return;
    if (!success) {
      setState(() => _switchFailed = true);
      showLedgerFeedback(context, context.l10n.ledger_switch_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.autoSwitchClub && !_switchFailed) {
      final active = ref.watch(activeClubContextProvider);
      if (active?.clubId != widget.clubId) {
        final clubState = ref.watch(clubContextViewModelProvider);
        if (!_attempted && !clubState.isLoading && !clubState.isSwitching) {
          _attempted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _switchClub();
          });
        }
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.ledger_title)),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.ledger_title)),
      body: SafeArea(child: ClubLedgerBody(clubId: widget.clubId)),
    );
  }
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
      if (clubState.isSwitching || clubState.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

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
