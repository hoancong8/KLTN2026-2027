import '../../entities/sepay/sepay_application.dart';
import '../../entities/sepay/sepay_connection.dart';
import '../../entities/sepay/sepay_provider_account.dart';
import '../../repositories/sepay_repository.dart';

class GetSepayApplicationUseCase {
  final SepayRepository repository;
  const GetSepayApplicationUseCase(this.repository);

  Future<SepayApplication> execute() => repository.getSepayApplication();
}

class ConfigureSepayApplicationUseCase {
  final SepayRepository repository;
  const ConfigureSepayApplicationUseCase(this.repository);

  Future<SepayApplication> execute({
    required String clientId,
    String? clientSecret,
    required String publicApiBaseUrl,
    required String frontendBaseUrl,
    required bool enabled,
    String? revision,
  }) =>
      repository.configureSepayApplication(
        clientId: clientId,
        clientSecret: clientSecret,
        publicApiBaseUrl: publicApiBaseUrl,
        frontendBaseUrl: frontendBaseUrl,
        enabled: enabled,
        revision: revision,
      );
}

class GetClubSepayConnectionUseCase {
  final SepayRepository repository;
  const GetClubSepayConnectionUseCase(this.repository);

  Future<SepayConnection> execute(String clubId) =>
      repository.getClubSepayConnection(clubId);
}

class StartClubSepayConnectionUseCase {
  final SepayRepository repository;
  const StartClubSepayConnectionUseCase(this.repository);

  Future<String> execute(String clubId) =>
      repository.startClubSepayConnection(clubId);
}

class CompleteClubSepayConnectionUseCase {
  final SepayRepository repository;
  const CompleteClubSepayConnectionUseCase(this.repository);

  Future<SepayConnection> execute(String clubId, String ticket) =>
      repository.completeClubSepayConnection(clubId, ticket);
}

class GetClubSepayBankAccountsUseCase {
  final SepayRepository repository;
  const GetClubSepayBankAccountsUseCase(this.repository);

  Future<List<SepayProviderAccount>> execute(String clubId) =>
      repository.getClubSepayBankAccounts(clubId);
}

class SelectClubSepayBankAccountUseCase {
  final SepayRepository repository;
  const SelectClubSepayBankAccountUseCase(this.repository);

  Future<SepayConnection> execute(String clubId, int providerBankId) =>
      repository.selectClubSepayBankAccount(clubId, providerBankId);
}

class ActivateClubSepayConnectionUseCase {
  final SepayRepository repository;
  const ActivateClubSepayConnectionUseCase(this.repository);

  Future<SepayConnection> execute(String clubId) =>
      repository.activateClubSepayConnection(clubId);
}

class ListClubSepayConnectionsUseCase {
  final SepayRepository repository;
  const ListClubSepayConnectionsUseCase(this.repository);

  Future<List<SepayConnection>> execute(String clubId) =>
      repository.listClubSepayConnections(clubId);
}

class DisconnectClubSepayConnectionUseCase {
  final SepayRepository repository;
  const DisconnectClubSepayConnectionUseCase(this.repository);

  Future<SepayConnection> execute(String clubId, {String? connectionId}) =>
      repository.disconnectClubSepayConnection(clubId,
          connectionId: connectionId);
}
