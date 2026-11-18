import '../../domain/entities/payment/personal_fee.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasource/remote/abstract/payment_remote_datasource.dart';
import '../mapper/payment_mapper.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource remote;

  const PaymentRepositoryImpl(this.remote);

  @override
  Future<PersonalFeePage> getMyFees({
    required int page,
    required int pageSize,
    String? paymentStatus,
    String? sessionId,
  }) async => PaymentMapper.toPage(
    await remote.getMyFees(
      page: page,
      pageSize: pageSize,
      paymentStatus: paymentStatus,
      sessionId: sessionId,
    ),
  );

  @override
  Future<PersonalFee> getMyFee(String feeId) async =>
      PaymentMapper.toFee(await remote.getMyFee(feeId));

  @override
  Future<PersonalFee> prepareBankTransfer(String feeId) async =>
      PaymentMapper.toFee(await remote.prepareBankTransfer(feeId));

  @override
  Future<List<int>> getQrImage(String imagePath) =>
      remote.getQrImage(imagePath);

  @override
  Future<PersonalFee> reportTransfer(String feeId) async =>
      PaymentMapper.toFee(await remote.reportTransfer(feeId));

  @override
  Future<PersonalFee> requestCash(String feeId) async =>
      PaymentMapper.toFee(await remote.requestCash(feeId));

  @override
  Future<PaymentBankAccount?> getClubBankAccount(String clubId) async {
    final dto = await remote.getClubBankAccount(clubId);
    return dto == null ? null : PaymentMapper.toBankAccount(dto);
  }

  @override
  Future<PaymentBankAccount> updateClubBankAccount({
    required String clubId,
    required String bankBin,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  }) async => PaymentMapper.toBankAccount(
    await remote.updateClubBankAccount(
      clubId: clubId,
      bankBin: bankBin,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolder: accountHolder,
    ),
  );
}
