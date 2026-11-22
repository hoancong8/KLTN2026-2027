import '../../../../domain/entities/ledger/ledger.dart';
import '../../../dto/ledger/ledger_dto.dart';

abstract class LedgerRemoteDatasource {
  Future<LedgerDto> get(
    String clubId, {
    String suffix = '',
    Map<String, Object?>? query,
  });
  Future<void> post(String clubId, String suffix, Object data);
  Future<void> expense(String clubId, LedgerExpense expense);
  Future<LedgerInvoice> invoice(String clubId, String ledgerId);
}
