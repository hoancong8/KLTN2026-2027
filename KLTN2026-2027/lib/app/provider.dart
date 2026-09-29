import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/consts/app_validator.dart';
import 'package:kltn2026_2027/app/services/secure_storage_service.dart';
import 'package:kltn2026_2027/app/services/signalr_service.dart';
import 'package:kltn2026_2027/domain/entities/auth_token.dart';
import 'package:kltn2026_2027/domain/entities/employee.dart';
import '../domain/entities/user_profile.dart';
import 'package:kltn2026_2027/domain/usecases/auth/logout_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/profile/change_profile_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/auth/biometric_usecase.dart';
import 'package:kltn2026_2027/app/services/biometric_service.dart';
import 'package:kltn2026_2027/domain/usecases/notification/get_initial_notification_message_usecase.dart';
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

import '../domain/services/i_biometric_service.dart';
import '../domain/services/i_signalr_service.dart';
import '../domain/usecases/auth/change_password_usecase.dart';
import '../domain/usecases/auth/delete_device_token_usecase.dart';
import '../domain/usecases/auth/login_with_otp_usecase.dart';
// Attendance imports
import '../domain/usecases/user/get_user_permissions_usecase.dart';
import '../domain/usecases/user/get_all_permissions_usecase.dart';
import '../domain/usecases/user/manage_user_usecase.dart';
import '../domain/usecases/role/get_roles_usecase.dart';
import '../domain/usecases/role/manage_role_usecase.dart';
import '../data/datasource/remote/abstract/role_remote_datasource.dart';
import '../data/datasource/remote/implement/role_remote_datasource_impl.dart';
import '../domain/repositories/role_repository.dart';
import '../data/repositories/role_repository_impl.dart';
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

// Admin imports - Remote DataSources
import '../data/datasource/remote/abstract/user_remote_datasource.dart';
import '../data/datasource/remote/implement/user_remote_datasource_impl.dart';
import '../data/datasource/remote/abstract/venue_remote_datasource.dart';
import '../data/datasource/remote/implement/venue_remote_datasource_impl.dart';
import '../data/datasource/remote/abstract/venue_schedule_remote_datasource.dart';
import '../data/datasource/remote/implement/venue_schedule_remote_datasource_impl.dart';
import '../data/datasource/remote/abstract/court_remote_datasource.dart';
import '../data/datasource/remote/implement/court_remote_datasource_impl.dart';
import '../data/datasource/remote/abstract/court_pricing_remote_datasource.dart';
import '../data/datasource/remote/implement/court_pricing_remote_datasource_impl.dart';

// Admin imports - Repositories
import '../domain/repositories/user_repository.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/venue_repository.dart';
import '../data/repositories/venue_repository_impl.dart';
import '../domain/repositories/venue_schedule_repository.dart';
import '../data/repositories/venue_schedule_repository_impl.dart';
import '../domain/repositories/court_repository.dart';
import '../data/repositories/court_repository_impl.dart';
import '../domain/repositories/court_pricing_repository.dart';
import '../data/repositories/court_pricing_repository_impl.dart';

// Admin imports - UseCases
import '../domain/usecases/user/get_user_me_usecase.dart';
import '../domain/usecases/user/get_users_usecase.dart';
import '../domain/usecases/user/lock_user_usecase.dart';
import '../domain/usecases/user/update_user_roles_usecase.dart';
import '../domain/usecases/venue/get_venues_usecase.dart';
import '../domain/usecases/venue/get_venue_recommendations_usecase.dart';
import '../domain/usecases/venue/manage_venue_usecase.dart';
import '../domain/usecases/venue_schedule/get_venue_schedules_usecase.dart';
import '../domain/usecases/venue_schedule/manage_venue_schedule_usecase.dart';
import '../domain/usecases/court/get_courts_usecase.dart';
import '../domain/usecases/court/manage_court_usecase.dart';
import '../domain/usecases/court_pricing/get_court_pricings_usecase.dart';
import '../domain/usecases/court_pricing/manage_court_pricing_usecase.dart';

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

/// Notifier quản lý thông tin profile & permissions người dùng đang đăng nhập
class CurrentUserProfileNotifier extends Notifier<UserProfile?> {
  final UserProfile? initialValue;

  CurrentUserProfileNotifier([this.initialValue]);

  @override
  UserProfile? build() => initialValue;

  void setProfile(UserProfile? profile) {
    state = profile;
  }

  Future<UserProfile?> fetchProfile() async {
    try {
      final profile = await ref.read(getUserMeUseCaseProvider).execute();
      state = profile;
      return profile;
    } catch (e) {
      return null;
    }
  }

  void clear() {
    state = null;
  }
}

/// Global user profile provider (Riverpod NotifierProvider)
final currentUserProfileProvider =
    NotifierProvider<CurrentUserProfileNotifier, UserProfile?>(
  CurrentUserProfileNotifier.new,
);

/// Global provider danh sách permissions của user hiện tại
final userPermissionsProvider = Provider<List<String>>((ref) {
  final userProfile = ref.watch(currentUserProfileProvider);
  return userProfile?.permissions ?? [];
});

/// Helper check permission của user hiện tại
final hasPermissionProvider = Provider.family<bool, String>((ref, permissionName) {
  final userProfile = ref.watch(currentUserProfileProvider);
  if (userProfile == null) return false;
  if (userProfile.roles.contains('Admin') ||
      userProfile.permissions.contains('System.Administrator')) {
    return true; // Admin có toàn quyền
  }
  return userProfile.permissions.contains(permissionName);
});

/// Helper check role Admin từ user profile
final isAdminUserProvider = Provider<bool>((ref) {
  final userProfile = ref.watch(currentUserProfileProvider);
  if (userProfile == null) return false;
  return userProfile.roles.contains('Admin') ||
      userProfile.permissions.contains('System.Administrator');
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
final biometricServiceProvider = Provider<IBiometricService>((ref) {
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
  if (!kIsWeb) {
    final adapter = AppAuthInterceptor.buildAdapter();
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
    }
  }

  dio.interceptors.add(AppAuthInterceptor(ref, dio));

  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  return dio;
});

final tokenStorageProvider = Provider<TokenStorageRepository>((ref) {
  return TokenStorageRepositoryImpl(SecureStorageService.instance);
});

final signalRServiceProvider = Provider<ISignalRService>((ref) {
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
  return LoginUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStorageProvider),
  );
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

final appValidatorProvider = Provider<AppValidator>((ref) {
  return AppValidator();
});

// ============================================================================
// ADMIN REMOTE DATASOURCES
// ============================================================================
final roleRemoteDatasourceProvider = Provider<RoleRemoteDatasource>((ref) {
  return RoleRemoteDatasourceImpl(ref.watch(dioProvider));
});

final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasourceImpl(ref.watch(dioProvider));
});

final venueRemoteDatasourceProvider = Provider<VenueRemoteDatasource>((ref) {
  return VenueRemoteDatasourceImpl(ref.watch(dioProvider));
});

final venueScheduleRemoteDatasourceProvider = Provider<VenueScheduleRemoteDatasource>((ref) {
  return VenueScheduleRemoteDatasourceImpl(ref.watch(dioProvider));
});

final courtRemoteDatasourceProvider = Provider<CourtRemoteDatasource>((ref) {
  return CourtRemoteDatasourceImpl(ref.watch(dioProvider));
});

final courtPricingRemoteDatasourceProvider = Provider<CourtPricingRemoteDatasource>((ref) {
  return CourtPricingRemoteDatasourceImpl(ref.watch(dioProvider));
});

// ============================================================================
// ADMIN REPOSITORIES
// ============================================================================
final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepositoryImpl(ref.watch(roleRemoteDatasourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDatasourceProvider));
});

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  return VenueRepositoryImpl(ref.watch(venueRemoteDatasourceProvider));
});

final venueScheduleRepositoryProvider = Provider<VenueScheduleRepository>((ref) {
  return VenueScheduleRepositoryImpl(ref.watch(venueScheduleRemoteDatasourceProvider));
});

final courtRepositoryProvider = Provider<CourtRepository>((ref) {
  return CourtRepositoryImpl(ref.watch(courtRemoteDatasourceProvider));
});

final courtPricingRepositoryProvider = Provider<CourtPricingRepository>((ref) {
  return CourtPricingRepositoryImpl(ref.watch(courtPricingRemoteDatasourceProvider));
});

// ============================================================================
// ADMIN USECASES
// ============================================================================
final getUserMeUseCaseProvider = Provider<GetUserMeUseCase>((ref) {
  return GetUserMeUseCase(ref.watch(userRepositoryProvider));
});

final getUserPermissionsUseCaseProvider = Provider<GetUserPermissionsUseCase>((ref) {
  return GetUserPermissionsUseCase(ref.watch(userRepositoryProvider));
});

final getAllPermissionsUseCaseProvider = Provider<GetAllPermissionsUseCase>((ref) {
  return GetAllPermissionsUseCase(ref.watch(userRepositoryProvider));
});

final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  return GetUsersUseCase(ref.watch(userRepositoryProvider));
});

final getRolesUseCaseProvider = Provider<GetRolesUseCase>((ref) {
  return GetRolesUseCase(ref.watch(roleRepositoryProvider));
});

final manageRoleUseCaseProvider = Provider<ManageRoleUseCase>((ref) {
  return ManageRoleUseCase(ref.watch(roleRepositoryProvider));
});

final manageUserUseCaseProvider = Provider<ManageUserUseCase>((ref) {
  return ManageUserUseCase(ref.watch(userRepositoryProvider));
});

final lockUserUseCaseProvider = Provider<LockUserUseCase>((ref) {
  return LockUserUseCase(ref.watch(userRepositoryProvider));
});

final updateUserRolesUseCaseProvider = Provider<UpdateUserRolesUseCase>((ref) {
  return UpdateUserRolesUseCase(ref.watch(userRepositoryProvider));
});

final getVenuesUseCaseProvider = Provider<GetVenuesUseCase>((ref) {
  return GetVenuesUseCase(ref.watch(venueRepositoryProvider));
});

final getVenueRecommendationsUseCaseProvider = Provider<GetVenueRecommendationsUseCase>((ref) {
  return GetVenueRecommendationsUseCase(ref.watch(venueRepositoryProvider));
});

final manageVenueUseCaseProvider = Provider<ManageVenueUseCase>((ref) {
  return ManageVenueUseCase(ref.watch(venueRepositoryProvider));
});

final getVenueSchedulesUseCaseProvider = Provider<GetVenueSchedulesUseCase>((ref) {
  return GetVenueSchedulesUseCase(ref.watch(venueScheduleRepositoryProvider));
});

final manageVenueScheduleUseCaseProvider = Provider<ManageVenueScheduleUseCase>((ref) {
  return ManageVenueScheduleUseCase(ref.watch(venueScheduleRepositoryProvider));
});

final getCourtsUseCaseProvider = Provider<GetCourtsUseCase>((ref) {
  return GetCourtsUseCase(ref.watch(courtRepositoryProvider));
});

final manageCourtUseCaseProvider = Provider<ManageCourtUseCase>((ref) {
  return ManageCourtUseCase(ref.watch(courtRepositoryProvider));
});

final getCourtPricingsUseCaseProvider = Provider<GetCourtPricingsUseCase>((ref) {
  return GetCourtPricingsUseCase(ref.watch(courtPricingRepositoryProvider));
});

final manageCourtPricingUseCaseProvider = Provider<ManageCourtPricingUseCase>((ref) {
  return ManageCourtPricingUseCase(ref.watch(courtPricingRepositoryProvider));
});
