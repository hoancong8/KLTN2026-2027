import 'package:dio/dio.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/app/consts/app_log.dart';
import 'package:sipm_mobile/data/datasource/remote/abstract/session_remote_datasource.dart';
import 'package:sipm_mobile/data/dto/session/session_info_dto.dart';

class SessionRemoteDatasourceImpl implements SessionRemoteDatasource {
  final Dio dio;

  SessionRemoteDatasourceImpl(this.dio);

  @override
  Future<SessionInfoDto> getCurrentLoginInfo() async {
    final response = await dio.get(AppConfig.sessionInfoPath);
    AppLog.info('[Session] Raw response: ${response.data}');
    return SessionInfoDto.fromJson(response.data);
  }
}
