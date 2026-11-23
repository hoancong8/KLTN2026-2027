import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../dto/payment/payment_dto.dart';
import '../abstract/payment_remote_datasource.dart';
import '../base_remote_datasource.dart';

class PaymentRemoteDatasourceImpl extends BaseRemoteDatasource
    implements PaymentRemoteDatasource {
  final Dio dio;

  PaymentRemoteDatasourceImpl(this.dio);

  @override
  Future<PersonalFeePageDto> getMyFees({
    required int page,
    required int pageSize,
    String? paymentStatus,
    String? sessionId,
  }) async {
    try {
      final response = await dio.get(
        AppConfig.myFeesEndpoint,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          ...?(paymentStatus == null ? null : {'paymentStatus': paymentStatus}),
          ...?(sessionId == null ? null : {'sessionId': sessionId}),
        },
      );
      return await _parse(response, PersonalFeePageDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<PersonalFeeDto> getMyFee(String feeId) async {
    try {
      final response = await dio.get(AppConfig.myFeePath(feeId));
      return await _parse(response, PersonalFeeDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<PersonalFeeDto> prepareBankTransfer(String feeId) async {
    try {
      final response = await dio.post(AppConfig.myFeeBankTransferPath(feeId));
      return await _parse(response, PersonalFeeDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<int>> getQrImage(String imagePath) async {
    try {
      final uri = Uri.parse(AppConfig.baseUrl).resolve(imagePath);
      final response = await dio.get<List<int>>(
        uri.toString(),
        options: Options(responseType: ResponseType.bytes),
      );
      final contentType = response.headers.value(Headers.contentTypeHeader);
      if (response.statusCode != 200 ||
          contentType?.toLowerCase().startsWith('image/png') != true ||
          response.data == null ||
          response.data!.length < 8 ||
          !_hasPngSignature(response.data!)) {
        throw InvalidResponseException(originalError: 'Invalid QR image');
      }
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<PersonalFeeDto> reportTransfer(String feeId) async {
    try {
      final response = await dio.post(AppConfig.myFeeTransferNoticePath(feeId));
      return await _parse(response, PersonalFeeDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<PersonalFeeDto> requestCash(String feeId) async {
    try {
      final response = await dio.post(AppConfig.myFeeCashRequestPath(feeId));
      return await _parse(response, PersonalFeeDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<PaymentBankAccountDto?> getClubBankAccount(String clubId) async {
    try {
      final response = await dio.get(
        AppConfig.clubPaymentBankAccountPath(clubId),
      );
      return await _parse(response, PaymentBankAccountDto.fromJson);
    } on DioException catch (e) {
      if ((e.response?.statusCode == 409 &&
          _errorCode(e.response?.data) == 'Payments.BankUnavailable') ||
          e.response?.statusCode == 404) {
        return null;
      }
      throw handleError(e);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<PaymentBankAccountDto> updateClubBankAccount({
    required String clubId,
    required String bankBin,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  }) async {
    try {
      final response = await dio.put(
        AppConfig.clubPaymentBankAccountPath(clubId),
        data: {
          'bankBin': bankBin,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'accountHolder': accountHolder,
        },
      );
      return await _parse(response, PaymentBankAccountDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  String? _errorCode(dynamic data) {
    if (data is! Map) return null;
    final direct = data['code'];
    if (direct is String) return direct;
    final error = data['error'];
    if (error is Map && error['code'] is String) {
      return error['code'] as String;
    }
    final result = data['result'];
    if (result is Map) {
      final resultError = result['error'];
      if (resultError is Map && resultError['code'] is String) {
        return resultError['code'] as String;
      }
    }
    return null;
  }

  bool _hasPngSignature(List<int> bytes) =>
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0d &&
      bytes[5] == 0x0a &&
      bytes[6] == 0x1a &&
      bytes[7] == 0x0a;

  Future<T> _parse<T>(Response response, T Function(dynamic) fromJson) =>
      Future<T>.sync(() => handleResponse(response, fromJson));
}
