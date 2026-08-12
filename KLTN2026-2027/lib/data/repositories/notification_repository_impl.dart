import '../../domain/entities/notification_message.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasource/remote/abstract/notification_remote_datasource.dart';
import '../dto/notification/register_device_token_request_dto.dart';
import '../mapper/notification_mapper.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remote;
  final NotificationMapper mapper;

  NotificationRepositoryImpl(this.remote, this.mapper);

  @override
  Future<void> initialize() async {
    await remote.initialize();
  }

  @override
  Future<String?> getDeviceToken() async {
    return await remote.getToken();
  }

  @override
  Future<void> registerDeviceToken(String deviceToken) async {
    final request = RegisterDeviceTokenRequestDto(deviceToken: deviceToken);
    await remote.registerDeviceToken(request);
  }

  @override
  Future<void> deleteDeviceToken() async {
    await remote.deleteDeviceToken();
  }

  @override
  Stream<NotificationMessage> get onMessageReceived {
    return remote.onMessageReceived.map((dto) => mapper.map(dto));
  }

  @override
  Stream<NotificationMessage> get onMessageOpened {
    return remote.onMessageOpened.map((dto) => mapper.map(dto));
  }

  @override
  NotificationMessage? getInitialMessage() {
    final dto = remote.getInitialMessage();
    if (dto == null) return null;
    return mapper.map(dto);
  }

  @override
  void clearInitialMessage() {
    remote.clearInitialMessage();
  }
}
