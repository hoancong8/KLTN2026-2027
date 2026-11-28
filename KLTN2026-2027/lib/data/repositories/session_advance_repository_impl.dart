import 'package:dio/dio.dart';
import '../../domain/entities/payment/session_advance.dart';
import '../../domain/repositories/session_advance_repository.dart';
import '../datasource/remote/base_remote_datasource.dart';

class SessionAdvanceRepositoryImpl extends BaseRemoteDatasource
    implements SessionAdvanceRepository {
  SessionAdvanceRepositoryImpl(this._dio);
  final Dio _dio;

  static const _root = '/api/v1/session-advances';
  String _session(String id) => '$_root/sessions/${Uri.encodeComponent(id)}';
  String _club(String id) => '$_root/clubs/${Uri.encodeComponent(id)}';

  SessionAdvance _parse(dynamic raw) {
    final data = raw is Map ? raw : const <String, dynamic>{};
    String? str(String key) => data[key]?.toString();
    num amount(String key) => num.tryParse(str(key) ?? '') ?? 0;
    bool yes(String key) => data[key] == true;
    return SessionAdvance(
      id: str('id'),
      sessionId: str('sessionId') ?? '',
      title: str('sessionTitle') ?? '',
      status: str('status') ?? 'CLOSED',
      amount: amount('amount'),
      received: amount('received'),
      applied: amount('applied'),
      refundDue: amount('refundDue'),
      qrPayload: str('qrPayload'),
      code: str('code'),
      reason: str('refundReason'),
      bank: str('refundBank'),
      account: str('refundAccount'),
      holder: str('refundHolder'),
      reference: str('refundReference'),
      reviewTransactionId: str('reviewTransactionId'),
      canPrepare: yes('canPrepare'),
      canHandle: yes('canHandle'),
      refundClaimed: yes('refundClaimed'),
      payerName: str('payerName'),
      reviewReference: str('reviewReference'),
      reviewAmount: num.tryParse(str('reviewAmount') ?? ''),
    );
  }

  Future<SessionAdvance> _one(Future<Response<dynamic>> request) async {
    try {
      return await handleResponse(await request, _parse);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<SessionAdvance>> _list(Future<Response<dynamic>> request) async {
    try {
      return handleListResponse(await request, _parse);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SessionAdvance?> quote(String sessionId) async {
    try {
      return await handleResponse(
        await _dio.get('${_session(sessionId)}/me'),
        _parse,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw handleError(e);
    }
  }

  @override
  Future<SessionAdvance> prepare(String sessionId) =>
      _one(_dio.post('${_session(sessionId)}/prepare'));
  @override
  Future<SessionAdvance> report(String sessionId) =>
      _one(_dio.post('${_session(sessionId)}/report'));
  @override
  Future<SessionAdvance> saveAccount(
    String sessionId,
    String bank,
    String account,
    String holder,
  ) => _one(
    _dio.put(
      '${_session(sessionId)}/refund-account',
      data: {'bank': bank, 'account': account, 'holder': holder},
    ),
  );
  @override
  Future<List<SessionAdvance>> listMine() => _list(_dio.get('$_root/me'));
  @override
  Future<List<SessionAdvance>> listClub(String groupId) =>
      _list(_dio.get(_club(groupId)));
  @override
  Future<SessionAdvance> review(
    String groupId,
    String advanceId,
    String? transactionId,
  ) => _one(
    _dio.post(
      '${_club(groupId)}/$advanceId/review',
      data: {'transactionId': transactionId, 'dismiss': transactionId == null},
    ),
  );
  @override
  Future<SessionAdvance> claim(String groupId, String advanceId) => _one(
    _dio.post(
      '${_club(groupId)}/$advanceId/refund',
      data: {'claim': true, 'amount': 0},
    ),
  );
  @override
  Future<SessionAdvance> refund(
    String groupId,
    String advanceId,
    num amount,
    String reference,
    String evidence,
  ) => _one(
    _dio.post(
      '${_club(groupId)}/$advanceId/refund',
      data: {
        'claim': false,
        'amount': amount,
        'reference': reference,
        'evidence': evidence,
      },
    ),
  );
}
