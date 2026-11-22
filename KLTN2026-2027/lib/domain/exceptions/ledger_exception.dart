import 'app_exception.dart';

class LedgerException extends AppException {
  final int? status;
  final String? code;

  const LedgerException({this.status, this.code, super.message});

  bool get isUncertain =>
      status == null ||
      (status ?? 0) >= 500 &&
          code != 'Ledger.Disabled' &&
          code != 'Ledger.WritesDisabled' ||
      code == 'Ledger.Busy';
}
