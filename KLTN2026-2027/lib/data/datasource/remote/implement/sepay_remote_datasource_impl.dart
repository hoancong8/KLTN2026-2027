import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/sepay/sepay_dto.dart';
import '../abstract/sepay_remote_datasource.dart';
import '../base_remote_datasource.dart';

class SepayRemoteDatasourceImpl extends BaseRemoteDatasource
    implements SepayRemoteDatasource {
  final Dio dio;

  SepayRemoteDatasourceImpl(this.dio);

  @override
  Future<SepayApplicationDto> getSepayApplication() async {
    try {
      final response = await dio.get(AppConfig.sepayApplicationEndpoint);
      return handleResponse(response, SepayApplicationDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SepayApplicationDto> configureSepayApplication({
    required String clientId,
    String? clientSecret,
    required String publicApiBaseUrl,
    required String frontendBaseUrl,
    required bool enabled,
    String? revision,
  }) async {
    try {
      final data = <String, dynamic>{
        'clientId': clientId,
        'clientSecret': clientSecret,
        'publicApiBaseUrl': publicApiBaseUrl,
        'frontendBaseUrl': frontendBaseUrl,
        'enabled': enabled,
        'revision': revision,
      };
      final response = await dio.put(
        AppConfig.sepayApplicationEndpoint,
        data: data,
      );
      return handleResponse(response, SepayApplicationDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SepayConnectionDto> getClubSepayConnection(String clubId) async {
    try {
      final response = await dio.get(AppConfig.clubSepayEndpoint(clubId));
      return handleResponse(response, SepayConnectionDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<String> startClubSepayConnection(String clubId) async {
    try {
      final response =
          await dio.post(
        AppConfig.clubSepayAuthorizeEndpoint(clubId),
        queryParameters: {'returnToMobileApp': !AppConfig.isWeb},
      );
      final authDto =
          handleResponse(response, SepayAuthorizationDto.fromJson);
      return authDto.authorizationUrl;
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SepayConnectionDto> completeClubSepayConnection(
    String clubId,
    String ticket,
  ) async {
    try {
      final response = await dio.post(
        AppConfig.clubSepayCompleteEndpoint(clubId),
        data: {'ticket': ticket},
      );
      return handleResponse(response, SepayConnectionDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<SepayProviderAccountDto>> getClubSepayBankAccounts(
      String clubId) async {
    try {
      final response =
          await dio.get(AppConfig.clubSepayAccountsEndpoint(clubId));
      return handleListResponse(response, SepayProviderAccountDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SepayConnectionDto> selectClubSepayBankAccount(
    String clubId,
    int providerBankId,
  ) async {
    try {
      final response = await dio.post(
        AppConfig.clubSepayAccountEndpoint(clubId),
        data: {'providerBankId': providerBankId},
      );
      return handleResponse(response, SepayConnectionDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SepayConnectionDto> activateClubSepayConnection(String clubId) async {
    try {
      final response =
          await dio.post(AppConfig.clubSepayActivateEndpoint(clubId));
      return handleResponse(response, SepayConnectionDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<SepayConnectionDto>> listClubSepayConnections(
      String clubId) async {
    try {
      final response =
          await dio.get(AppConfig.clubSepayConnectionsEndpoint(clubId));
      return handleListResponse(response, SepayConnectionDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<SepayConnectionDto> disconnectClubSepayConnection(
    String clubId, {
    String? connectionId,
  }) async {
    try {
      final url = connectionId != null && connectionId.isNotEmpty
          ? AppConfig.clubSepayDisconnectConnectionEndpoint(
              clubId, connectionId)
          : AppConfig.clubSepayEndpoint(clubId);
      final response = await dio.delete(url);
      return handleResponse(response, SepayConnectionDto.fromJson);
    } catch (e) {
      throw handleError(e);
    }
  }
}
