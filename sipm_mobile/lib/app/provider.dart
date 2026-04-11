import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/app/services/secure_storage_service.dart';
import 'package:sipm_mobile/app/services/signalr_service.dart';
import 'package:sipm_mobile/domain/entities/auth_token.dart';
import 'package:sipm_mobile/domain/entities/employee.dart';
import 'package:sipm_mobile/domain/usecases/auth/logout_usecase.dart';
import 'package:sipm_mobile/domain/usecases/profile/change_profile_usecase.dart';
import 'package:sipm_mobile/domain/usecases/auth/biometric_usecase.dart';
import 'package:sipm_mobile/app/services/biometric_service.dart';
import 'package:sipm_mobile/domain/usecases/notification/get_initial_notification_message_usecase.dart';
import '../data/datasource/remote/abstract/auth_2fa_remote_datasource.dart';
import '../data/datasource/remote/abstract/auth_remote_datasource.dart';
import '../data/datasource/remote/abstract/chat_message_remote_datasource.dart';
import '../data/datasource/remote/abstract/chat_remote_datasource.dart';
import '../data/datasource/remote/abstract/notification_remote_datasource.dart';
import '../data/datasource/remote/abstract/profile_remote_datasource.dart';
import '../data/datasource/remote/abstract/session_remote_datasource.dart';
import '../data/datasource/remote/implement/auth_2fa_remote_datasource_impl.dart';
import '../data/datasource/remote/implement/auth_remote_datasource_impl.dart';
import '../data/datasource/remote/implement/chat_message_remote_datasource_impl.dart';
import '../data/datasource/remote/implement/chat_remote_datasource_impl.dart';
import '../data/datasource/remote/implement/notification_remote_datasource_impl.dart';
import '../data/datasource/remote/implement/profile_remote_datasource_impl.dart';
import '../data/datasource/remote/implement/session_remote_datasource_impl.dart';
import '../data/mapper/notification_mapper.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/chat_message_remote_datasource_impl.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../data/repositories/token_storage_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/chat_message_repository.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/repositories/token_storage_repository.dart';

import '../domain/usecases/auth/change_password_usecase.dart';
import '../domain/usecases/auth/delete_device_token_usecase.dart';
import '../domain/usecases/auth/login_with_otp_usecase.dart';
// Attendance imports
import '../domain/usecases/chat/get_chat_messages_usecase.dart';
import '../domain/usecases/chat/mark_all_unread_messages_as_read_usecase.dart';
import '../domain/usecases/chat/send_message_usecase.dart';
import '../domain/usecases/chat/upload_file_usecase.dart';
import '../domain/usecases/friend/block_user_usecase.dart';
import '../domain/usecases/friend/create_friendship_request_usecase.dart';
import '../domain/usecases/friend/find_users_usecase.dart';
import '../domain/usecases/friend/get_chat_friends_usecase.dart';
import '../domain/usecases/friend/unblock_user_usecase.dart';
import '../domain/usecases/notification/get_notification_message_stream_usecase.dart';
import '../domain/usecases/auth/get_session_info_usecase.dart';
import '../domain/usecases/notification/get_notification_opened_stream_usecase.dart';
import '../domain/usecases/notification/initialize_notification_usecase.dart';
import '../domain/usecases/auth/save_tenant_id_usecase.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/profile/get_profile_usecase.dart';
import '../domain/usecases/auth/refresh_token_usecase.dart';
import '../domain/usecases/auth/register_device_token_usecase.dart';
import '../domain/usecases/auth/save_employee_id_usecase.dart';
import '../domain/usecases/auth/get_employee_id_usecase.dart';
import 'consts/app_config.dart';
import 'services/app_auth_interceptor.dart';

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Global auth token provider
final authTokenProvider = StateProvider<AuthToken?>((ref) => null);

/// Global employee provider - lÆ°u thÃ´ng tin nhÃ¢n viÃªn hiá»‡n táº¡i
final currentEmployeeProvider = StateProvider<Employee?>((ref) => null);

/// Helper provider Ä‘á»ƒ check role admin
final isAdminProvider = Provider<bool>((ref) {
  final employee = ref.watch(currentEmployeeProvider);
  if (employee == null) return false;

  final roleId = employee.roleId;
  final roleName = employee.roleName?.toLowerCase() ?? '';

  return roleName.contains('admin') || roleId == 1;
});

/// Provider for current tab index in Home Screen
final homeTabProvider = StateProvider<int>((ref) => 0);

// ============================================================================
// PRIVATE HELPERS - Token Refresh & Session Management (MOVED TO AppAuthInterceptor)
// ============================================================================

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// BiometricService provider
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

// ============================================================================
// INFRASTRUCTURE PROVIDERS
// ============================================================================

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.httpClientAdapter = AppAuthInterceptor.buildAdapter();

  dio.interceptors.add(AppAuthInterceptor(ref, dio));

  return dio;
});

final tokenStorageProvider = Provider<TokenStorageRepository>((ref) {
  return TokenStorageRepositoryImpl(SecureStorageService.instance);
});

final signalRServiceProvider = Provider<SignalRService>((ref) {
  return SignalRService();
});

// ============================================================================
// DATA SOURCE PROVIDERS
// ============================================================================

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(ref.watch(dioProvider));
});

final auth2faRemoteDatasourceProvider = Provider<Auth2FARemoteDatasource>((
  ref,
) {
  return Auth2faRemoteDatasourceImpl(ref.watch(dioProvider));
});

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((
  ref,
) {
  return ProfileRemoteDatasourceImpl(ref.watch(dioProvider));
});

final sessionRemoteDatasourceProvider = Provider<SessionRemoteDatasource>((
  ref,
) {
  return SessionRemoteDatasourceImpl(ref.watch(dioProvider));
});

final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
      return NotificationRemoteDatasourceImpl(
        dio: ref.watch(dioProvider),
        messaging: FirebaseMessaging.instance,
        localNotifications: FlutterLocalNotificationsPlugin(),
        userIdProvider: () {
          final employee = ref.read(currentEmployeeProvider);
          return employee?.userId ?? employee?.id;
        },
      );
    });

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  return ChatRemoteDatasourceImpl(ref.watch(dioProvider));
});
final chatMessageRemoteDatasourceProvider =
    Provider<ChatMessageRemoteDatasource>((ref) {
      return ChatMessageRemoteDatasourceImpl(ref.watch(dioProvider));
    });
// ============================================================================
// MAPPER PROVIDERS
// ============================================================================

final notificationMapperProvider = Provider<NotificationMapper>((ref) {
  return NotificationMapper();
});

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
    ref.watch(auth2faRemoteDatasourceProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDatasourceProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDatasourceProvider),
    ref.watch(notificationMapperProvider),
  );
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(ref.watch(sessionRemoteDatasourceProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    ref.watch(chatRemoteDatasourceProvider),
    ref.watch(tokenStorageProvider),
  );
});

final chatMessageRepositoryProvider = Provider<ChatMessageRepository>((ref) {
  return ChatMessageRepositoryImpl(
    ref.watch(chatMessageRemoteDatasourceProvider),
  );
});
// ============================================================================
// USE CASE PROVIDERS - Authentication
// ============================================================================

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final loginWithOtpUseCaseProvider = Provider<LoginWithOtpUseCase>((ref) {
  return LoginWithOtpUseCase(ref.watch(authRepositoryProvider));
});

final logOutUseCase = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStorageProvider),
    ref.watch(deleteDeviceTokenUseCaseProvider),
  );
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(authRepositoryProvider));
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.watch(authRepositoryProvider));
});

final biometricUseCaseProvider = Provider<BiometricUseCase>((ref) {
  return BiometricUseCase(ref.watch(biometricServiceProvider));
});

final saveTenantIdUseCaseProvider = Provider<SaveTenantIdUseCase>((ref) {
  return SaveTenantIdUseCase(ref.watch(tokenStorageProvider));
});

final saveEmployeeIdUseCaseProvider = Provider<SaveEmployeeIdUseCase>((ref) {
  return SaveEmployeeIdUseCase(ref.watch(tokenStorageProvider));
});

final getEmployeeIdUseCaseProvider = Provider<GetEmployeeIdUseCase>((ref) {
  return GetEmployeeIdUseCase(ref.watch(tokenStorageProvider));
});

// ============================================================================
// USE CASE PROVIDERS - Profile
// ============================================================================

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final changeProfileUseCaseProvider = Provider<ChangeProfileUseCase>((ref) {
  return ChangeProfileUseCase(ref.watch(profileRepositoryProvider));
});

// ============================================================================
// USE CASE PROVIDERS - Notification (FCM)
// ============================================================================

final initializeNotificationUseCaseProvider =
    Provider<InitializeNotificationUseCase>((ref) {
      return InitializeNotificationUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final registerDeviceTokenUseCaseProvider = Provider<RegisterDeviceTokenUseCase>(
  (ref) {
    return RegisterDeviceTokenUseCase(
      ref.watch(notificationRepositoryProvider),
    );
  },
);

final deleteDeviceTokenUseCaseProvider = Provider<DeleteDeviceTokenUseCase>((
  ref,
) {
  return DeleteDeviceTokenUseCase(ref.watch(notificationRepositoryProvider));
});

final getNotificationMessageStreamUseCaseProvider =
    Provider<GetNotificationMessageStreamUseCase>((ref) {
      return GetNotificationMessageStreamUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final getNotificationOpenedStreamUseCaseProvider =
    Provider<GetNotificationOpenedStreamUseCase>((ref) {
      return GetNotificationOpenedStreamUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final getInitialNotificationMessageUseCaseProvider =
    Provider<GetInitialNotificationMessageUseCase>((ref) {
      return GetInitialNotificationMessageUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

// ============================================================================
// USE CASE PROVIDERS - Session
// ============================================================================

final getSessionInfoUseCaseProvider = Provider<GetSessionInfoUseCase>((ref) {
  return GetSessionInfoUseCase(ref.watch(sessionRepositoryProvider));
});

// ============================================================================
// USE CASE PROVIDERS - chat
// ============================================================================
final getChatFriendsUseCaseProvider = Provider<GetChatFriendsUseCase>((ref) {
  return GetChatFriendsUseCase(ref.watch(chatRepositoryProvider));
});

final getChatMessagesUseCaseProvider = Provider<GetChatMessagesUseCase>((ref) {
  return GetChatMessagesUseCase(ref.watch(chatMessageRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(signalRServiceProvider));
});

final markAllUnreadMessagesAsReadUseCaseProvider =
    Provider<MarkAllUnreadMessagesAsReadUseCase>((ref) {
      return MarkAllUnreadMessagesAsReadUseCase(
        ref.watch(chatMessageRepositoryProvider),
      );
    });

final blockUserUseCaseProvider = Provider<BlockUserUseCase>((ref) {
  return BlockUserUseCase(ref.watch(chatRepositoryProvider));
});

final unblockUserUseCaseProvider = Provider<UnblockUserUseCase>((ref) {
  return UnblockUserUseCase(ref.watch(chatRepositoryProvider));
});

final uploadFileUseCaseProvider = Provider<UploadFileUseCase>((ref) {
  return UploadFileUseCase(ref.watch(chatRepositoryProvider));
});

final findUsersUseCaseProvider = Provider<FindUsersUseCase>((ref) {
  return FindUsersUseCase(ref.watch(chatRepositoryProvider));
});

final createFriendshipRequestUseCaseProvider =
    Provider<CreateFriendshipRequestUseCase>((ref) {
      return CreateFriendshipRequestUseCase(ref.watch(chatRepositoryProvider));
    });
