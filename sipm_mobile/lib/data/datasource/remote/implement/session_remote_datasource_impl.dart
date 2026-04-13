import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/session/session_info_dto.dart';
import '../abstract/session_remote_datasource.dart';
import '../base_remote_datasource.dart';

class SessionRemoteDatasourceImpl extends BaseRemoteDatasource
    implements SessionRemoteDatasource {
  final Dio dio;

  SessionRemoteDatasourceImpl(this.dio);

  @override
  Future<SessionInfoDto> getCurrentLoginInfo() async {
    try {
      final res = await dio.get(AppConfig.sessionInfoPath);
      return handleResponse(
        res,
            (e) => SessionInfoDto.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      throw handleError(e);
    }
  }
}