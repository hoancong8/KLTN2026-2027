import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/notification/notification_dto.dart';
import '../abstract/notification_remote_datasource.dart';
import '../base_remote_datasource.dart';

class NotificationRemoteDatasourceImpl extends BaseRemoteDatasource
    implements NotificationRemoteDatasource {
  final Dio dio;

  NotificationRemoteDatasourceImpl(this.dio);

  @override
  Future<List<NotificationDto>> getMyNotifications() async {
    try {
      final response = await dio.get(AppConfig.myNotificationsEndpoint);
      return handleListResponse(
        response,
        (json) => NotificationDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await dio.put(AppConfig.markNotificationReadEndpoint(id));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await dio.put(AppConfig.markAllNotificationsReadEndpoint);
    } catch (e) {
      throw handleError(e);
    }
  }
}

