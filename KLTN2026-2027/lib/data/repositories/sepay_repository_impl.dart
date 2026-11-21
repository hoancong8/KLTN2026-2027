import '../../domain/entities/sepay/sepay_application.dart';
import '../../domain/entities/sepay/sepay_connection.dart';
import '../../domain/entities/sepay/sepay_provider_account.dart';
import '../../domain/repositories/sepay_repository.dart';
import '../datasource/remote/abstract/sepay_remote_datasource.dart';
import '../mapper/sepay_mapper.dart';

class SepayRepositoryImpl implements SepayRepository {
  final SepayRemoteDatasource remoteDatasource;

  SepayRepositoryImpl(this.remoteDatasource);

  @override
  Future<SepayApplication> getSepayApplication() async {
    final dto = await remoteDatasource.getSepayApplication();
    return dto.toEntity();
  }

  @override
  Future<SepayApplication> configureSepayApplication({
    required String clientId,
    String? clientSecret,
    required String publicApiBaseUrl,
    required String frontendBaseUrl,
    required bool enabled,
    String? revision,
  }) async {
    final dto = await remoteDatasource.configureSepayApplication(
      clientId: clientId,
      clientSecret: clientSecret,
      publicApiBaseUrl: publicApiBaseUrl,
      frontendBaseUrl: frontendBaseUrl,
      enabled: enabled,
      revision: revision,
    );
    return dto.toEntity();
  }

  @override
  Future<SepayConnection> getClubSepayConnection(String clubId) async {
    final dto = await remoteDatasource.getClubSepayConnection(clubId);
    return dto.toEntity();
  }

  @override
  Future<String> startClubSepayConnection(String clubId) =>
      remoteDatasource.startClubSepayConnection(clubId);

  @override
  Future<SepayConnection> completeClubSepayConnection(
    String clubId,
    String ticket,
  ) async {
    final dto =
        await remoteDatasource.completeClubSepayConnection(clubId, ticket);
    return dto.toEntity();
  }

  @override
  Future<List<SepayProviderAccount>> getClubSepayBankAccounts(
      String clubId) async {
    final list = await remoteDatasource.getClubSepayBankAccounts(clubId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<SepayConnection> selectClubSepayBankAccount(
    String clubId,
    int providerBankId,
  ) async {
    final dto = await remoteDatasource.selectClubSepayBankAccount(
        clubId, providerBankId);
    return dto.toEntity();
  }

  @override
  Future<SepayConnection> activateClubSepayConnection(String clubId) async {
    final dto = await remoteDatasource.activateClubSepayConnection(clubId);
    return dto.toEntity();
  }

  @override
  Future<List<SepayConnection>> listClubSepayConnections(String clubId) async {
    final list = await remoteDatasource.listClubSepayConnections(clubId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<SepayConnection> disconnectClubSepayConnection(
    String clubId, {
    String? connectionId,
  }) async {
    final dto = await remoteDatasource.disconnectClubSepayConnection(
      clubId,
      connectionId: connectionId,
    );
    return dto.toEntity();
  }
}
