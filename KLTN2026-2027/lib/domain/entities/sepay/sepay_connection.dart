import 'package:equatable/equatable.dart';

class SepayConnection extends Equatable {
  final String? connectionId;
  final String? bankAccountId;
  final String status;
  final int? companyId;
  final String? gateway;
  final DateTime? connectedAt;
  final bool applicationReady;
  final bool webhookEnabled;

  const SepayConnection({
    this.connectionId,
    this.bankAccountId,
    required this.status,
    this.companyId,
    this.gateway,
    this.connectedAt,
    required this.applicationReady,
    required this.webhookEnabled,
  });

  bool get isBankRequired => status == 'BANK_REQUIRED';
  bool get isDisconnected => status == 'DISCONNECTED';
  bool get isAuthorized => status == 'AUTHORIZED';
  bool get isProvisioning => status == 'PROVISIONING';
  bool get isConnected => status == 'CONNECTED';
  bool get isDisconnecting => status == 'DISCONNECTING';

  SepayConnection copyWith({
    String? connectionId,
    String? bankAccountId,
    String? status,
    int? companyId,
    String? gateway,
    DateTime? connectedAt,
    bool? applicationReady,
    bool? webhookEnabled,
  }) {
    return SepayConnection(
      connectionId: connectionId ?? this.connectionId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      status: status ?? this.status,
      companyId: companyId ?? this.companyId,
      gateway: gateway ?? this.gateway,
      connectedAt: connectedAt ?? this.connectedAt,
      applicationReady: applicationReady ?? this.applicationReady,
      webhookEnabled: webhookEnabled ?? this.webhookEnabled,
    );
  }

  @override
  List<Object?> get props => [
        connectionId,
        bankAccountId,
        status,
        companyId,
        gateway,
        connectedAt,
        applicationReady,
        webhookEnabled,
      ];
}
