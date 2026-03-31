import 'package:dio/dio.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/data/datasource/remote/abstract/profile_remote_datasource.dart';
import 'package:sipm_mobile/data/dto/profile/change_profile_request_dto.dart';
import 'package:sipm_mobile/data/dto/profile/change_profile_response_dto.dart';

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final Dio dio;

  ProfileRemoteDatasourceImpl(this.dio);


  @override
  Future<ChangeProfileResponseDto> getProfile(int employeeId) async {
    final response = await dio.get(
      AppConfig.getProfilePath,
      queryParameters: {'Id': employeeId},
    );
    return ChangeProfileResponseDto.fromJson(response.data);
  }

  @override
  Future<void> changeProfile(ChangeProfileRequestDto request) async {
    final response = await dio.post(
      AppConfig.changeProfilePath,
      data: request.toJson(),
      options: Options(
        contentType: 'application/json-patch+json',
      ),
    );
    // Check if success
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['error']?['message'] ?? 'Update failed');
    }
  }
}
