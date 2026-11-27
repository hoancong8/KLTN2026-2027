import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/reconciliation/reconciliation_dto.dart';
import '../abstract/reconciliation_remote_datasource.dart';
import '../base_remote_datasource.dart';

class ReconciliationRemoteDatasourceImpl extends BaseRemoteDatasource
    implements ReconciliationRemoteDatasource {
  final Dio dio;

  ReconciliationRemoteDatasourceImpl(this.dio);

  @override
  Future<ReconciliationPageDto> getReconciliations(
    String clubId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }

      final response = await dio.get(
        AppConfig.clubReconciliationsEndpoint(clubId),
        queryParameters: query,
      );
      return await handleResponse(response, ReconciliationPageDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<ReconciliationTransactionDto> getReconciliationDetail(
    String clubId,
    String transactionId,
  ) async {
    try {
      final response = await dio.get(
        AppConfig.clubReconciliationDetailEndpoint(clubId, transactionId),
      );
      return await handleResponse(response, ReconciliationTransactionDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<ReconciliationTransactionDto> confirmManualReconciliation(
    String clubId,
    String transactionId, {
    required String feeId,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        AppConfig.clubReconciliationConfirmEndpoint(clubId, transactionId),
        data: {
          'feeId': feeId,
          'reason': reason,
        },
      );
      return await handleResponse(response, ReconciliationTransactionDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }
}
