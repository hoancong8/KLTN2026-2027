import '../../domain/entities/ledger/ledger.dart';
import '../dto/ledger/ledger_dto.dart';

const ledgerCategories = {
  LedgerCategory.sessionFee: 'SESSION_FEE',
  LedgerCategory.courtRent: 'COURT_RENT',
  LedgerCategory.shuttleExpense: 'SHUTTLE_EXPENSE',
  LedgerCategory.monthlyFund: 'MONTHLY_FUND',
  LedgerCategory.sessionAdvance: 'SESSION_ADVANCE',
  LedgerCategory.sessionAdvanceRefund: 'SESSION_ADVANCE_REFUND',
  LedgerCategory.other: 'OTHER',
};

String ledgerDebtType(LedgerDebtType type) =>
    type == LedgerDebtType.sessionFee ? 'SESSION_FEE' : 'MONTHLY_FUND';

String ledgerDirection(LedgerDirection direction) =>
    direction == LedgerDirection.inflow ? 'INFLOW' : 'OUTFLOW';

extension LedgerMapper on LedgerDto {
  LedgerMoney? _optionalMoney(String key) {
    final input = optionalText(key);
    if (input == null) return null;
    return LedgerMoney.tryParse(input) ??
        (throw FormatException('Invalid ledger amount $key'));
  }

  LedgerMoney _money(String key) =>
      _optionalMoney(key) ??
      (throw FormatException('Missing ledger amount $key'));

  LedgerOverview toOverview() {
    final capabilities = child('capabilities');
    return (
      balance: _money('availableBalance'),
      heldAdvance: _optionalMoney('heldAdvanceBalance') ?? LedgerMoney(BigInt.zero),
      inflow: _money('totalInflow'),
      outflow: _money('totalOutflow'),
      sessionDebt: _money('sessionDebtTotal'),
      monthlyDebt: _money('monthlyDebtTotal'),
      debt: _money('debtTotal'),
      asOf: date('asOfUtc'),
      canView: capabilities.flag('canView'),
      canManage: capabilities.flag('canManage'),
      canWrite: capabilities.flag('canWrite'),
    );
  }

  LedgerTransaction toTransaction() => (
    id: text('ledgerId'),
    direction: switch (text('transactionType')) {
      'INFLOW' => LedgerDirection.inflow,
      'OUTFLOW' => LedgerDirection.outflow,
      _ => throw const FormatException('Unknown ledger direction'),
    },
    category:
        ledgerCategories.entries
            .where((entry) => entry.value == optionalText('category'))
            .firstOrNull
            ?.key ??
        LedgerCategory.unknown,
    amount: _money('amount'),
    description: optionalText('description') ?? '',
    createdAt: date('createdAt'),
    hasInvoice: flag('hasAttachment'),
  );

  LedgerDebt toDebt() => (
    sourceId: text('sourceId'),
    type: switch (text('debtType')) {
      'SESSION_FEE' => LedgerDebtType.sessionFee,
      'MONTHLY_FUND' => LedgerDebtType.monthlyFund,
      _ => throw const FormatException('Unknown ledger debt type'),
    },
    userId: optionalText('userId'),
    sessionId: optionalText('sessionId'),
    name: optionalText('displayName'),
    month: optionalText('contributionMonth'),
    amount: _money('amountDue'),
  );

  LedgerCandidate toCandidate() => (
    userId: text('userId'),
    name: optionalText('displayName'),
    month: text('contributionMonth'),
    expiry: optionalDate('monthlyExpiryDate'),
    contributionId: optionalText('monthlyContributionId'),
    status: switch (optionalText('status')) {
      'NOT_ISSUED' => LedgerContributionStatus.notIssued,
      'UNPAID' => LedgerContributionStatus.unpaid,
      'PAID' => LedgerContributionStatus.paid,
      _ => LedgerContributionStatus.unknown,
    },
    amount: _optionalMoney('amountDue'),
    canIssue: flag('canIssue'),
    canCollect: flag('canCollect'),
    reason: optionalText('reason'),
  );

  LedgerPage<T> toPage<T>(T Function(LedgerDto) map) => (
    items: List.unmodifiable(rows('items').map(map)),
    total: integer('total'),
    page: integer('page'),
  );
}
