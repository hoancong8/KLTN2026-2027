import '../../entities/payment/personal_fee.dart';
import '../../repositories/payment_repository.dart';

class GetMyFeesUseCase {
  final PaymentRepository repository;
  const GetMyFeesUseCase(this.repository);

  Future<PersonalFeePage> execute({
    required int page,
    required int pageSize,
    String? paymentStatus,
    String? sessionId,
  }) => repository.getMyFees(
    page: page,
    pageSize: pageSize,
    paymentStatus: paymentStatus,
    sessionId: sessionId,
  );
}

class GetMyFeeUseCase {
  final PaymentRepository repository;
  const GetMyFeeUseCase(this.repository);
  Future<PersonalFee> execute(String feeId) => repository.getMyFee(feeId);
}

class PrepareBankTransferUseCase {
  final PaymentRepository repository;
  const PrepareBankTransferUseCase(this.repository);
  Future<PersonalFee> execute(String feeId) =>
      repository.prepareBankTransfer(feeId);
}

class GetFeeQrImageUseCase {
  final PaymentRepository repository;
  const GetFeeQrImageUseCase(this.repository);
  Future<List<int>> execute(String imagePath) =>
      repository.getQrImage(imagePath);
}

class ReportFeeTransferUseCase {
  final PaymentRepository repository;
  const ReportFeeTransferUseCase(this.repository);
  Future<PersonalFee> execute(String feeId) => repository.reportTransfer(feeId);
}

class RequestCashPaymentUseCase {
  final PaymentRepository repository;
  const RequestCashPaymentUseCase(this.repository);
  Future<PersonalFee> execute(String feeId) => repository.requestCash(feeId);
}

class GetClubPaymentBankUseCase {
  final PaymentRepository repository;
  const GetClubPaymentBankUseCase(this.repository);
  Future<PaymentBankAccount?> execute(String clubId) =>
      repository.getClubBankAccount(clubId);
}

class UpdateClubPaymentBankUseCase {
  final PaymentRepository repository;
  const UpdateClubPaymentBankUseCase(this.repository);

  Future<PaymentBankAccount> execute({
    required String clubId,
    required String bankBin,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  }) => repository.updateClubBankAccount(
    clubId: clubId,
    bankBin: bankBin,
    bankName: bankName,
    accountNumber: accountNumber,
    accountHolder: accountHolder,
  );
}
