import 'package:equatable/equatable.dart';

class SepayApplication extends Equatable {
  final String clientId;
  final bool hasClientSecret;
  final String publicApiBaseUrl;
  final String frontendBaseUrl;
  final String callbackUrl;
  final bool enabled;
  final String? revision;
  final bool webhookEnabled;

  const SepayApplication({
    required this.clientId,
    required this.hasClientSecret,
    required this.publicApiBaseUrl,
    required this.frontendBaseUrl,
    required this.callbackUrl,
    required this.enabled,
    this.revision,
    required this.webhookEnabled,
  });

  SepayApplication copyWith({
    String? clientId,
    bool? hasClientSecret,
    String? publicApiBaseUrl,
    String? frontendBaseUrl,
    String? callbackUrl,
    bool? enabled,
    String? revision,
    bool? webhookEnabled,
  }) {
    return SepayApplication(
      clientId: clientId ?? this.clientId,
      hasClientSecret: hasClientSecret ?? this.hasClientSecret,
      publicApiBaseUrl: publicApiBaseUrl ?? this.publicApiBaseUrl,
      frontendBaseUrl: frontendBaseUrl ?? this.frontendBaseUrl,
      callbackUrl: callbackUrl ?? this.callbackUrl,
      enabled: enabled ?? this.enabled,
      revision: revision ?? this.revision,
      webhookEnabled: webhookEnabled ?? this.webhookEnabled,
    );
  }

  @override
  List<Object?> get props => [
        clientId,
        hasClientSecret,
        publicApiBaseUrl,
        frontendBaseUrl,
        callbackUrl,
        enabled,
        revision,
        webhookEnabled,
      ];
}
