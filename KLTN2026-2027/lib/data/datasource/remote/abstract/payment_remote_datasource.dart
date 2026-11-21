import '../../../dto/payment/payment_dto.dart';

abstract class PaymentRemoteDatasource {
  Future<PersonalFeePageDto> getMyFees({
    required int page,
    required int pageSize,
    String? paymentStatus,
    String? sessionId,
  });

  Future<PersonalFeeDto> getMyFee(String feeId);
  Future<PersonalFeeDto> prepareBankTransfer(String feeId);
  Future<List<int>> getQrImage(String imagePath);
  Future<PersonalFeeDto> reportTransfer(String feeId);
  Future<PersonalFeeDto> requestCash(String feeId);
  Future<PaymentBankAccountDto?> getClubBankAccount(String clubId);
  Future<PaymentBankAccountDto> updateClubBankAccount({
    required String clubId,
    required String bankBin,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  });
}
