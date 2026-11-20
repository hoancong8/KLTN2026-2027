class SepayApplicationDto {
  final String clientId;
  final bool hasClientSecret;
  final String publicApiBaseUrl;
  final String frontendBaseUrl;
  final String callbackUrl;
  final bool enabled;
  final String? revision;
  final bool webhookEnabled;

  const SepayApplicationDto({
    required this.clientId,
    required this.hasClientSecret,
    required this.publicApiBaseUrl,
    required this.frontendBaseUrl,
    required this.callbackUrl,
    required this.enabled,
    required this.revision,
    required this.webhookEnabled,
  });

  factory SepayApplicationDto.fromJson(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Invalid SepayApplication response');
    }
    final json = Map<String, dynamic>.from(value);
    return SepayApplicationDto(
      clientId: _asString(json['clientId'] ?? json['ClientId']),
      hasClientSecret: _asBool(json['hasClientSecret'] ?? json['HasClientSecret']),
      publicApiBaseUrl: _asString(json['publicApiBaseUrl'] ?? json['PublicApiBaseUrl']),
      frontendBaseUrl: _asString(json['frontendBaseUrl'] ?? json['FrontendBaseUrl']),
      callbackUrl: _asString(json['callbackUrl'] ?? json['CallbackUrl']),
      enabled: _asBool(json['enabled'] ?? json['Enabled']),
      revision: _asNullableString(json['revision'] ?? json['Revision']),
      webhookEnabled: _asBool(json['webhookEnabled'] ?? json['WebhookEnabled']),
    );
  }
}

class SepayConnectionDto {
  final String? connectionId;
  final String? bankAccountId;
  final String status;
  final int? companyId;
  final String? gateway;
  final DateTime? connectedAt;
  final bool applicationReady;
  final bool webhookEnabled;

  const SepayConnectionDto({
    this.connectionId,
    this.bankAccountId,
    required this.status,
    this.companyId,
    this.gateway,
    this.connectedAt,
    required this.applicationReady,
    required this.webhookEnabled,
  });

  factory SepayConnectionDto.fromJson(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Invalid SepayConnection response');
    }
    final json = Map<String, dynamic>.from(value);
    return SepayConnectionDto(
      connectionId: _asNullableString(json['connectionId'] ?? json['ConnectionId']),
      bankAccountId: _asNullableString(json['bankAccountId'] ?? json['BankAccountId']),
      status: _asString(json['status'] ?? json['Status'], defaultValue: 'DISCONNECTED'),
      companyId: _asInt(json['companyId'] ?? json['CompanyId']),
      gateway: _asNullableString(json['gateway'] ?? json['Gateway']),
      connectedAt: _asDate(json['connectedAt'] ?? json['ConnectedAt']),
      applicationReady: _asBool(json['applicationReady'] ?? json['ApplicationReady']),
      webhookEnabled: _asBool(json['webhookEnabled'] ?? json['WebhookEnabled']),
    );
  }
}

class SepayAuthorizationDto {
  final String authorizationUrl;

  const SepayAuthorizationDto({required this.authorizationUrl});

  factory SepayAuthorizationDto.fromJson(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Invalid SepayAuthorization response');
    }
    final json = Map<String, dynamic>.from(value);
    return SepayAuthorizationDto(
      authorizationUrl: _asString(json['authorizationUrl'] ?? json['AuthorizationUrl']),
    );
  }
}

class SepayProviderAccountDto {
  final int id;
  final String accountNumber;
  final String accountHolder;
  final String bankBin;
  final String gateway;
  final bool active;
  final bool matchesClubBank;

  const SepayProviderAccountDto({
    required this.id,
    required this.accountNumber,
    required this.accountHolder,
    required this.bankBin,
    required this.gateway,
    required this.active,
    required this.matchesClubBank,
  });

  factory SepayProviderAccountDto.fromJson(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Invalid SepayProviderAccount response');
    }
    final json = Map<String, dynamic>.from(value);
    return SepayProviderAccountDto(
      id: _asInt(json['id'] ?? json['Id']) ?? 0,
      accountNumber: _asString(json['accountNumber'] ?? json['AccountNumber']),
      accountHolder: _asString(json['accountHolder'] ?? json['AccountHolder']),
      bankBin: _asString(json['bankBin'] ?? json['BankBin']),
      gateway: _asString(json['gateway'] ?? json['Gateway']),
      active: _asBool(json['active'] ?? json['Active']),
      matchesClubBank: _asBool(json['matchesClubBank'] ?? json['MatchesClubBank']),
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

bool _asBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return defaultValue;
}

DateTime? _asDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value)?.toLocal();
  return null;
}
