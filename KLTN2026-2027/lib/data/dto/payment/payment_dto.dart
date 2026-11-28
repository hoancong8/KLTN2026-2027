class PersonalFeePageDto {
  final List<PersonalFeeDto> items;
  final int total;
  final int page;
  final int pageSize;

  const PersonalFeePageDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PersonalFeePageDto.fromJson(dynamic json) {
    if (json is! Map) throw const FormatException('Invalid fee page response');
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('Fee page is missing items');
    }
    return PersonalFeePageDto(
      items: rawItems.map(PersonalFeeDto.fromJson).toList(),
      total: _asInt(json['total']) ?? 0,
      page: _asInt(json['page']) ?? 1,
      pageSize: _asInt(json['pageSize']) ?? rawItems.length,
    );
  }
}

class PersonalFeeDto {
  final String feeId;
  final String sessionId;
  final String groupId;
  final String groupName;
  final DateTime? sessionStart;
  final String publicationState;
  final num? amount;
  final String currency;
  final String paymentCode;
  final String paymentStatus;
  final num advanceApplied;
  final bool advancePending;
  final String? paymentProgress;
  final String? paymentMethod;
  final DateTime? paymentRequestedAt;
  final DateTime? transferReportedAt;
  final Map<String, dynamic>? breakdown;
  final List<String> availableActions;
  final Map<String, dynamic>? paymentInstructions;
  final Map<String, dynamic>? receipt;

  const PersonalFeeDto({
    required this.feeId,
    required this.sessionId,
    required this.groupId,
    required this.groupName,
    required this.sessionStart,
    required this.publicationState,
    required this.amount,
    required this.currency,
    required this.paymentCode,
    required this.paymentStatus,
    this.advanceApplied = 0,
    this.advancePending = false,
    required this.paymentProgress,
    required this.paymentMethod,
    required this.paymentRequestedAt,
    required this.transferReportedAt,
    required this.breakdown,
    required this.availableActions,
    required this.paymentInstructions,
    required this.receipt,
  });

  factory PersonalFeeDto.fromJson(dynamic value) {
    if (value is! Map) throw const FormatException('Invalid fee response');
    final json = Map<String, dynamic>.from(value);
    return PersonalFeeDto(
      feeId: _asString(json['feeId']),
      sessionId: _asString(json['sessionId']),
      groupId: _asString(json['groupId']),
      groupName: _asString(json['groupName']),
      sessionStart: _asDate(json['sessionStart']),
      publicationState: _asString(json['publicationState']),
      amount: _asNum(json['amount']),
      currency: _asString(json['currency']),
      paymentCode: _asString(json['paymentCode']),
      paymentStatus: _asString(json['paymentStatus']),
      advanceApplied: num.tryParse(json['advanceApplied']?.toString() ?? '') ?? 0,
      advancePending: json['advancePending'] == true,
      paymentProgress: _asNullableString(json['paymentProgress']),
      paymentMethod: _asNullableString(json['paymentMethod']),
      paymentRequestedAt: _asDate(json['paymentRequestedAt']),
      transferReportedAt: _asDate(json['transferReportedAt']),
      breakdown: _asMap(json['breakdown']),
      availableActions: json['availableActions'] is List
          ? (json['availableActions'] as List).whereType<String>().toList(
              growable: false,
            )
          : const [],
      paymentInstructions: _asMap(json['paymentInstructions']),
      receipt: _asMap(json['receipt']),
    );
  }
}

class PaymentBankAccountDto {
  final String? bankBin;
  final String bankName;
  final String accountNumber;
  final String accountHolder;

  const PaymentBankAccountDto({
    required this.bankBin,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  factory PaymentBankAccountDto.fromJson(dynamic value) {
    if (value is! Map) throw const FormatException('Invalid bank account');
    final json = Map<String, dynamic>.from(value);
    return PaymentBankAccountDto(
      bankBin: _asNullableString(json['bankBin']),
      bankName: _asString(json['bankName']),
      accountNumber: _asString(json['accountNumber']),
      accountHolder: _asString(json['accountHolder']),
    );
  }
}

String _asString(dynamic value) => value is String ? value : '';
String? _asNullableString(dynamic value) => value is String ? value : null;
num? _asNum(dynamic value) => value is num ? value : null;
int? _asInt(dynamic value) => value is int ? value : null;
DateTime? _asDate(dynamic value) =>
    value is String ? DateTime.tryParse(value) : null;
Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
