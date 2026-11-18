import '../entities/payment/personal_fee.dart';

abstract class PaymentRepository {
  Future<PersonalFeePage> getMyFees({
    required int page,
    required int pageSize,
    String? paymentStatus,
    String? sessionId,
  });

  Future<PersonalFee> getMyFee(String feeId);
  Future<PersonalFee> prepareBankTransfer(String feeId);
  Future<List<int>> getQrImage(String imagePath);
  Future<PersonalFee> reportTransfer(String feeId);
  Future<PersonalFee> requestCash(String feeId);
  Future<PaymentBankAccount?> getClubBankAccount(String clubId);
  Future<PaymentBankAccount> updateClubBankAccount({
    required String clubId,
    required String bankBin,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  });
}
