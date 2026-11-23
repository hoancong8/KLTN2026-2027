import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/consts/app_config.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../club/club_vm/club_context_vm.dart';

Future<void> openLedgerFromNotification(
  BuildContext context,
  WidgetRef ref,
  String clubId,
) async {
  final previousClubId = ref.read(activeClubContextProvider)?.clubId;
  await context.push(AppConfig.clubLedgerScreenPath(clubId));
  if (!context.mounted || previousClubId == null ||
      previousClubId == clubId ||
      ref.read(activeClubContextProvider)?.clubId != clubId) {
    return;
  }
  final restored = await ref
      .read(clubContextViewModelProvider.notifier)
      .switchClub(previousClubId);
  if (!restored && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.ledger_switch_failed)),
    );
  }
}
