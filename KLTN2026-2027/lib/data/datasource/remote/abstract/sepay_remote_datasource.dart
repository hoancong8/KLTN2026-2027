import '../../../dto/sepay/sepay_dto.dart';

abstract class SepayRemoteDatasource {
  Future<SepayApplicationDto> getSepayApplication();

  Future<SepayApplicationDto> configureSepayApplication({
    required String clientId,
    String? clientSecret,
    required String publicApiBaseUrl,
    required String frontendBaseUrl,
    required bool enabled,
    String? revision,
  });

  Future<SepayConnectionDto> getClubSepayConnection(String clubId);

  Future<String> startClubSepayConnection(String clubId);

  Future<SepayConnectionDto> completeClubSepayConnection(
    String clubId,
    String ticket,
  );

  Future<List<SepayProviderAccountDto>> getClubSepayBankAccounts(String clubId);

  Future<SepayConnectionDto> selectClubSepayBankAccount(
    String clubId,
    int providerBankId,
  );

  Future<SepayConnectionDto> activateClubSepayConnection(String clubId);

  Future<List<SepayConnectionDto>> listClubSepayConnections(String clubId);

  Future<SepayConnectionDto> disconnectClubSepayConnection(
    String clubId, {
    String? connectionId,
  });
}
