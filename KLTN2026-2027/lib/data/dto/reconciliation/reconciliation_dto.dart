class ReconciliationPageDto {
  final List<ReconciliationTransactionDto> items;
  final int total;
  final int page;
  final int pageSize;

  const ReconciliationPageDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ReconciliationPageDto.fromJson(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Invalid reconciliation page response');
    }
    final json = Map<String, dynamic>.from(value);
    final rawItems = json['items'] ?? json['Items'];
    if (rawItems is! List) {
      throw const FormatException('Reconciliation page is missing items');
    }
    return ReconciliationPageDto(
      items: rawItems.map(ReconciliationTransactionDto.fromJson).toList(),
      total: _asInt(json['total'] ?? json['Total']) ?? 0,
      page: _asInt(json['page'] ?? json['Page']) ?? 1,
      pageSize: _asInt(json['pageSize'] ?? json['PageSize']) ?? rawItems.length,
    );
  }
}

class ReconciliationTransactionDto {
  final String transactionId;
  final int? providerTransactionId;
  final String? bankAccountId;
  final String? feeId;
  final String? referenceCode;
  final num amountReceived;
  final String transferContent;
  final DateTime transactionTime;
  final String status;
  final String? reasonCode;
  final String? reconciledBy;
  final DateTime? reconciledAt;
  final String? note;

  const ReconciliationTransactionDto({
    required this.transactionId,
    this.providerTransactionId,
    this.bankAccountId,
    this.feeId,
    this.referenceCode,
    required this.amountReceived,
    required this.transferContent,
    required this.transactionTime,
    required this.status,
    this.reasonCode,
    this.reconciledBy,
    this.reconciledAt,
    this.note,
  });

  factory ReconciliationTransactionDto.fromJson(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Invalid reconciliation transaction response');
    }
    final json = Map<String, dynamic>.from(value);
    return ReconciliationTransactionDto(
      transactionId: _asString(json['transactionId'] ?? json['TransactionId']),
      providerTransactionId:
          _asInt(json['providerTransactionId'] ?? json['ProviderTransactionId']),
      bankAccountId:
          _asNullableString(json['bankAccountId'] ?? json['BankAccountId']),
      feeId: _asNullableString(json['feeId'] ?? json['FeeId']),
      referenceCode:
          _asNullableString(json['referenceCode'] ?? json['ReferenceCode']),
      amountReceived: _asNum(json['amountReceived'] ?? json['AmountReceived']),
      transferContent: _asString(
          json['transferContent'] ?? json['TransferContent'],
          defaultValue: ''),
      transactionTime: _asDate(json['transactionTime'] ?? json['TransactionTime']) ??
          DateTime.now(),
      status: _asString(json['status'] ?? json['Status'], defaultValue: 'MANUAL_CHECK'),
      reasonCode: _asNullableString(json['reasonCode'] ?? json['ReasonCode']),
      reconciledBy:
          _asNullableString(json['reconciledBy'] ?? json['ReconciledBy']),
      reconciledAt: _asDate(json['reconciledAt'] ?? json['ReconciledAt']),
      note: _asNullableString(json['note'] ?? json['Note'] ?? json['reconciliationNote']),
    );
  }
}

String _asString(dynamic value, {String defaultValue = ''}) =>
    value is String ? value : (value?.toString() ?? defaultValue);

String? _asNullableString(dynamic value) =>
    value is String ? (value.isEmpty ? null : value) : value?.toString();

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

num _asNum(dynamic value, {num defaultValue = 0}) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? defaultValue;
  return defaultValue;
}

DateTime? _asDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value)?.toLocal();
  return null;
}
