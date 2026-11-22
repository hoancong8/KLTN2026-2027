import 'package:flutter/widgets.dart';

import '../../../../club/ledger/club_ledger_screen.dart';

class ClubLedgerTab extends StatelessWidget {
  final String clubId;
  const ClubLedgerTab({super.key, required this.clubId});

  @override
  Widget build(BuildContext context) => ClubLedgerBody(clubId: clubId);
}
