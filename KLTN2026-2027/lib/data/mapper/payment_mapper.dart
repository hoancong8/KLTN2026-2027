import '../../data/dto/payment/payment_dto.dart';
import '../../domain/entities/payment/personal_fee.dart';

class PaymentMapper {
  static PersonalFeePage toPage(PersonalFeePageDto dto) => PersonalFeePage(
    items: dto.items.map(toFee).toList(growable: false),
    total: dto.total,
    page: dto.page,
    pageSize: dto.pageSize,
  );

  static PersonalFee toFee(PersonalFeeDto dto) {
    final breakdown = dto.breakdown;
    final instructions = dto.paymentInstructions;
    final bank = instructions?['bank'];
    final receipt = dto.receipt;
    final receiptPaidAt = _date(receipt?['paidAt']);
    final receiptMethod = _stringOrNull(receipt?['method']);
    return PersonalFee(
      feeId: dto.feeId,
      sessionId: dto.sessionId,
      groupId: dto.groupId,
      groupName: dto.groupName,
      sessionStart: dto.sessionStart,
      publicationState: dto.publicationState,
      amount: dto.amount,
      currency: dto.currency,
      paymentCode: dto.paymentCode,
      paymentStatus: dto.paymentStatus,
      advanceApplied: dto.advanceApplied,
      advancePending: dto.advancePending,
      paymentProgress: dto.paymentProgress,
      paymentMethod: dto.paymentMethod,
      paymentRequestedAt: dto.paymentRequestedAt,
      transferReportedAt: dto.transferReportedAt,
      breakdown: breakdown == null
          ? null
          : PersonalFeeBreakdown(
              courtShare: _num(breakdown['courtShare']),
              shuttleShare: _num(breakdown['shuttleShare']),
              extraShare: _num(breakdown['extraShare']),
              discountApplied: _num(breakdown['discountApplied']),
              monthlyFundCovered: _num(breakdown['monthlyFundCovered']),
              baseAmount: _num(breakdown['baseAmount']),
              calculatedAmount: _num(breakdown['calculatedAmount']),
              roundingDelta: _num(breakdown['roundingDelta']),
              adjustmentDelta: _num(breakdown['adjustmentDelta']),
              adjustmentReason: _stringOrNull(breakdown['adjustmentReason']),
            ),
      availableActions: dto.availableActions,
      paymentInstructions: instructions == null
          ? null
          : PaymentInstructions(
              payload: _string(instructions['payload']),
              bank: PaymentBankSnapshot(
                bankBin: bank is Map ? _stringOrNull(bank['bankBin']) : null,
                bankName: bank is Map ? _string(bank['bankName']) : '',
                accountNumber: bank is Map
                    ? _string(bank['accountNumber'])
                    : '',
                accountHolder: bank is Map
                    ? _string(bank['accountHolder'])
                    : '',
              ),
              imagePath: _string(instructions['imagePath']),
            ),
      receipt: receipt == null
          ? null
          : PaymentReceipt(
              receiptId: _string(receipt['receiptId']),
              amount: _num(receipt['amount']),
              paymentCode: _string(receipt['paymentCode']),
              paidAt: receiptPaidAt,
              method: receiptMethod,
              cashCollectedBy: _stringOrNull(receipt['cashCollectedBy']),
              metadataIncomplete: receipt['metadataIncomplete'] is bool
                  ? receipt['metadataIncomplete'] as bool
                  : receiptPaidAt == null || receiptMethod?.isNotEmpty != true,
            ),
    );
  }

  static PaymentBankAccount toBankAccount(PaymentBankAccountDto dto) =>
      PaymentBankAccount(
        bankBin: dto.bankBin,
        bankName: dto.bankName,
        accountNumber: dto.accountNumber,
        accountHolder: dto.accountHolder,
      );

  static num? _num(dynamic value) => value is num ? value : null;
  static String _string(dynamic value) => value is String ? value : '';
  static String? _stringOrNull(dynamic value) => value is String ? value : null;
  static DateTime? _date(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;
}
