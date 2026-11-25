import 'dart:typed_data';

enum LedgerCategory {
  sessionFee,
  courtRent,
  shuttleExpense,
  monthlyFund,
  other,
  unknown,
}

enum LedgerDirection { inflow, outflow }

enum LedgerDebtType { sessionFee, monthlyFund }

enum LedgerContributionStatus { notIssued, unpaid, paid, unknown }

class LedgerMoney {
  final BigInt minorUnits;
  const LedgerMoney(this.minorUnits);

  static final _decimal = RegExp(r'^(-?)(\d+)(?:\.(\d{1,2}))?$');
  static final _maximum = BigInt.parse('999999999999999999');

  static LedgerMoney? tryParse(String input) {
    final match = _decimal.firstMatch(input);
    if (match == null) return null;
    final fraction = (match[3] ?? '').padRight(2, '0');
    final units = BigInt.parse('${match[1]}${match[2]}$fraction');
    return LedgerMoney(units);
  }

  bool get isValidExpense => minorUnits > BigInt.zero && minorUnits <= _maximum;

  String get decimal {
    final digits = minorUnits.abs().toString().padLeft(3, '0');
    final sign = minorUnits.isNegative ? '-' : '';
    return '$sign${digits.substring(0, digits.length - 2)}.${digits.substring(digits.length - 2)}';
  }
}

typedef LedgerOverview = ({
  LedgerMoney balance,
  LedgerMoney inflow,
  LedgerMoney outflow,
  LedgerMoney sessionDebt,
  LedgerMoney monthlyDebt,
  LedgerMoney debt,
  DateTime asOf,
  bool canView,
  bool canManage,
  bool canWrite,
});

typedef LedgerTransaction = ({
  String id,
  LedgerDirection direction,
  LedgerCategory category,
  LedgerMoney amount,
  String description,
  DateTime createdAt,
  bool hasInvoice,
});

typedef LedgerDebt = ({
  String sourceId,
  LedgerDebtType type,
  String? userId,
  String? sessionId,
  String? name,
  String? month,
  LedgerMoney amount,
});

typedef LedgerCandidate = ({
  String userId,
  String? name,
  String month,
  DateTime? expiry,
  String? contributionId,
  LedgerContributionStatus status,
  LedgerMoney? amount,
  bool canIssue,
  bool canCollect,
  String? reason,
});

typedef LedgerPage<T> = ({List<T> items, int total, int page});
typedef LedgerDates = ({DateTime? from, DateTime? to});
typedef LedgerInvoice = ({String name, String mimeType, Uint8List bytes});
typedef LedgerExpense = ({
  String requestId,
  LedgerMoney amount,
  LedgerCategory category,
  String description,
  LedgerInvoice? invoice,
  String? sessionId,
});

class LedgerFilter {
  final LedgerDates dates;
  final bool onlyMine;
  final LedgerDirection? direction;
  final LedgerCategory? category;
  final LedgerDebtType? debtType;
  final String? month;

  const LedgerFilter({
    this.dates = (from: null, to: null),
    this.onlyMine = false,
    this.direction,
    this.category,
    this.debtType,
    this.month,
  });
}

String ledgerVietnameseMonth(DateTime now) {
  final vietnam = now.toUtc().add(const Duration(hours: 7));
  return '${vietnam.year}-${vietnam.month.toString().padLeft(2, '0')}-01';
}
