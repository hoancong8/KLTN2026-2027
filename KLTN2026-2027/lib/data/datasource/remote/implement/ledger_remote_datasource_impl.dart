import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../app/consts/app_config.dart';
import '../../../../domain/entities/ledger/ledger.dart';
import '../../../../domain/exceptions/ledger_exception.dart';
import '../../../dto/ledger/ledger_dto.dart';
import '../../../mapper/ledger_mapper.dart';
import '../abstract/ledger_remote_datasource.dart';
import '../base_remote_datasource.dart';

class LedgerRemoteDatasourceImpl extends BaseRemoteDatasource
    implements LedgerRemoteDatasource {
  final Dio _dio;
  LedgerRemoteDatasourceImpl(this._dio);

  Options _options(String clubId, {ResponseType type = ResponseType.plain}) =>
      Options(
        responseType: type,
        extra: {AppConfig.ledgerClubRequestKey: clubId},
      );

  Future<T> _request<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final body = error.response?.data;
      Object? problem = body;
      try {
        if (body is String) problem = jsonDecode(body);
        if (body is List<int>) problem = jsonDecode(utf8.decode(body));
      } on FormatException {
        problem = null;
      }
      final code = problem is Map ? problem['code'] : null;
      final detail = problem is Map ? problem['detail'] : null;
      throw LedgerException(
        status: status,
        code: code is String ? code : null,
        message:
            status == 400 &&
                detail is String &&
                code is String &&
                code.startsWith('Ledger.')
            ? detail
            : null,
      );
    } catch (error) {
      throw handleError(error);
    }
  }

  @override
  Future<LedgerDto> get(
    String clubId, {
    String suffix = '',
    Map<String, Object?>? query,
  }) => _request(() async {
    final response = await _dio.get<String>(
      '${AppConfig.clubLedgerEndpoint(clubId)}$suffix',
      queryParameters: query,
      options: _options(clubId),
    );
    final body = response.data;
    if (body == null) throw const FormatException('Empty ledger response');
    checkSecurity(body);
    final decoded = Response(
      requestOptions: response.requestOptions,
      data: decodeLedgerJson(body),
    );
    return handleResponse(decoded, LedgerDto.fromJson);
  });

  @override
  Future<void> post(String clubId, String suffix, Object data) =>
      _request(() async {
        final response = await _dio.post<String>(
          '${AppConfig.clubLedgerEndpoint(clubId)}$suffix',
          data: data,
          options: _options(clubId),
        );
        final body = response.data;
        try {
          if (body == null) throw const FormatException('Empty write result');
          LedgerDto.fromJson(decodeLedgerJson(body)).text('status');
        } on FormatException {
          throw const LedgerException();
        }
      });

  @override
  Future<void> expense(String clubId, LedgerExpense expense) {
    final invoice = expense.invoice;
    final form = FormData.fromMap({
      'requestId': expense.requestId,
      'amount': expense.amount.decimal,
      'category': ledgerCategories[expense.category],
      'description': expense.description,
      'sessionId': ?expense.sessionId,
      if (invoice != null)
        'invoice': MultipartFile.fromBytes(
          invoice.bytes,
          filename: invoice.name,
          contentType: DioMediaType.parse(invoice.mimeType),
        ),
    });
    return post(clubId, '/transactions', form);
  }

  @override
  Future<LedgerInvoice> invoice(
    String clubId,
    String ledgerId,
  ) => _request(() async {
    final response = await _dio.get<Uint8List>(
      '${AppConfig.clubLedgerEndpoint(clubId)}/transactions/$ledgerId/attachment',
      options: _options(clubId, type: ResponseType.bytes),
    );
    final bytes = response.data;
    final mimeType = response.headers.value('content-type')?.split(';').first;
    final extension = switch (mimeType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'application/pdf' => 'pdf',
      _ => null,
    };
    if (bytes == null || bytes.isEmpty || extension == null) {
      throw const FormatException('Invalid ledger invoice');
    }
    final disposition = response.headers.value('content-disposition') ?? '';
    final encoded = RegExp(
      r"filename\*=UTF-8''([^;]+)",
      caseSensitive: false,
    ).firstMatch(disposition)?.group(1);
    final original = encoded == null
        ? RegExp(r'filename="?([^";]+)').firstMatch(disposition)?.group(1)
        : Uri.decodeComponent(encoded);
    final name = original
        ?.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
        .trim();
    return (
      name: name == null || name.isEmpty
          ? 'invoice-$ledgerId.$extension'
          : name,
      mimeType: mimeType!,
      bytes: bytes,
    );
  });
}
