import '../../domain/entities/sepay/sepay_application.dart';
import '../../domain/entities/sepay/sepay_connection.dart';
import '../../domain/entities/sepay/sepay_provider_account.dart';
import '../dto/sepay/sepay_dto.dart';

extension SepayApplicationDtoMapper on SepayApplicationDto {
  SepayApplication toEntity() {
    return SepayApplication(
      clientId: clientId,
      hasClientSecret: hasClientSecret,
      publicApiBaseUrl: publicApiBaseUrl,
      frontendBaseUrl: frontendBaseUrl,
      callbackUrl: callbackUrl,
      enabled: enabled,
      revision: revision,
      webhookEnabled: webhookEnabled,
    );
  }
}

extension SepayConnectionDtoMapper on SepayConnectionDto {
  SepayConnection toEntity() {
    return SepayConnection(
      connectionId: connectionId,
      bankAccountId: bankAccountId,
      status: status,
      companyId: companyId,
      gateway: gateway,
      connectedAt: connectedAt,
      applicationReady: applicationReady,
      webhookEnabled: webhookEnabled,
    );
  }
}

extension SepayProviderAccountDtoMapper on SepayProviderAccountDto {
  SepayProviderAccount toEntity() {
    return SepayProviderAccount(
      id: id,
      accountNumber: accountNumber,
      accountHolder: accountHolder,
      bankBin: bankBin,
      gateway: gateway,
      active: active,
      matchesClubBank: matchesClubBank,
    );
  }
}
