import '../entities/sepay/sepay_application.dart';
import '../entities/sepay/sepay_connection.dart';
import '../entities/sepay/sepay_provider_account.dart';

abstract class SepayRepository {
  Future<SepayApplication> getSepayApplication();

  Future<SepayApplication> configureSepayApplication({
    required String clientId,
    String? clientSecret,
    required String publicApiBaseUrl,
    required String frontendBaseUrl,
    required bool enabled,
    String? revision,
  });

  Future<SepayConnection> getClubSepayConnection(String clubId);

  Future<String> startClubSepayConnection(String clubId);

  Future<SepayConnection> completeClubSepayConnection(
    String clubId,
    String ticket,
  );

  Future<List<SepayProviderAccount>> getClubSepayBankAccounts(String clubId);

  Future<SepayConnection> selectClubSepayBankAccount(
    String clubId,
    int providerBankId,
  );

  Future<SepayConnection> activateClubSepayConnection(String clubId);

  Future<List<SepayConnection>> listClubSepayConnections(String clubId);

  Future<SepayConnection> disconnectClubSepayConnection(
    String clubId, {
    String? connectionId,
  });
}
