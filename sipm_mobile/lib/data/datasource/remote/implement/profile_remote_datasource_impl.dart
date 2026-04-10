import 'package:dio/dio.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/data/datasource/remote/abstract/profile_remote_datasource.dart';
import 'package:sipm_mobile/data/dto/profile/change_profile_request_dto.dart';
import 'package:sipm_mobile/data/dto/profile/change_profile_response_dto.dart';
import '../base_remote_datasource.dart';

class ProfileRemoteDatasourceImpl extends BaseRemoteDatasource implements ProfileRemoteDatasource {
  final Dio dio;

  ProfileRemoteDatasourceImpl(this.dio);

  @override
  Future<ChangeProfileResponseDto> getProfile(int employeeId) async {
    try {
      final response = await dio.get(
        AppConfig.getProfilePath,
        queryParameters: {'Id': employeeId},
      );
      return handleResponse(response, (data) => ChangeProfileResponseDto.fromJson(data));
    }
    catch (e) {
      throw handleError(e);
    }
  }
  @override
  Future<void> changeProfile(ChangeProfileRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.changeProfilePath,
        data: request.toJson(),
      );
      return handleResponse(response, (data) => null);
    } catch (e) {
      throw handleError(e);
    }
  }
}
