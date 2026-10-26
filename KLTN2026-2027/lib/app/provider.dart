import '../domain/repositories/session_operations_repository.dart';
import '../data/repositories/session_operations_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/consts/app_validator.dart';
import 'package:kltn2026_2027/app/services/secure_storage_service.dart';
import 'package:kltn2026_2027/domain/entities/auth_token.dart';
import '../domain/entities/club/active_club_context.dart';
import '../domain/entities/user_profile.dart';
import 'package:kltn2026_2027/domain/usecases/auth/logout_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/auth/biometric_usecase.dart';
import 'package:kltn2026_2027/app/services/biometric_service.dart';
import '../data/datasource/remote/abstract/auth_remote_datasource.dart';
import '../data/datasource/remote/implement/auth_remote_datasource_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/token_storage_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/token_storage_repository.dart';
import '../domain/services/i_biometric_service.dart';
import '../domain/services/i_location_service.dart';
import '../data/services/location_service_impl.dart';
import '../domain/usecases/auth/change_password_usecase.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/refresh_token_usecase.dart';
import 'consts/app_config.dart';
import 'services/app_auth_interceptor.dart';

// User & Role imports
import '../data/datasource/remote/abstract/role_remote_datasource.dart';
import '../data/datasource/remote/implement/role_remote_datasource_impl.dart';
import '../domain/repositories/role_repository.dart';
import '../data/repositories/role_repository_impl.dart';
import '../domain/usecases/role/get_roles_usecase.dart';
import '../domain/usecases/role/manage_role_usecase.dart';
import '../domain/usecases/user/get_user_permissions_usecase.dart';
import '../domain/usecases/user/get_all_permissions_usecase.dart';
import '../domain/usecases/user/manage_user_usecase.dart';
import '../domain/usecases/user/get_user_me_usecase.dart';
import '../domain/usecases/user/get_users_usecase.dart';
import '../domain/usecases/user/lock_user_usecase.dart';
import '../domain/usecases/user/update_user_roles_usecase.dart';
import '../domain/usecases/user/get_player_profile_usecase.dart';
import '../domain/usecases/user/update_player_profile_usecase.dart';
import '../data/datasource/remote/abstract/user_remote_datasource.dart';
import '../data/datasource/remote/implement/user_remote_datasource_impl.dart';
import '../domain/repositories/user_repository.dart';
import '../data/repositories/user_repository_impl.dart';

// Venue, Schedule, Court, Pricing imports
import '../data/datasource/remote/abstract/venue_remote_datasource.dart';
import '../data/datasource/remote/implement/venue_remote_datasource_impl.dart';
import '../data/datasource/remote/abstract/venue_schedule_remote_datasource.dart';
import '../data/datasource/remote/implement/venue_schedule_remote_datasource_impl.dart';
import '../data/datasource/remote/abstract/court_remote_datasource.dart';
import '../data/datasource/remote/implement/court_remote_datasource_impl.dart';
import '../data/datasource/remote/abstract/court_pricing_remote_datasource.dart';
import '../data/datasource/remote/implement/court_pricing_remote_datasource_impl.dart';
import '../domain/repositories/venue_repository.dart';
import '../data/repositories/venue_repository_impl.dart';
import '../domain/repositories/venue_schedule_repository.dart';
import '../data/repositories/venue_schedule_repository_impl.dart';
import '../domain/repositories/court_repository.dart';
import '../data/repositories/court_repository_impl.dart';
import '../domain/repositories/court_pricing_repository.dart';
import '../data/repositories/court_pricing_repository_impl.dart';
import '../domain/usecases/venue/get_venues_usecase.dart';
import '../domain/usecases/venue/get_venue_recommendations_usecase.dart';
import '../domain/usecases/venue/manage_venue_usecase.dart';
import '../domain/usecases/venue_schedule/get_venue_schedules_usecase.dart';
import '../domain/usecases/venue_schedule/manage_venue_schedule_usecase.dart';
import '../domain/usecases/court/get_courts_usecase.dart';
import '../domain/usecases/court/manage_court_usecase.dart';
import '../domain/usecases/court_pricing/get_court_pricings_usecase.dart';
import '../domain/usecases/court_pricing/manage_court_pricing_usecase.dart';

// Club imports
import '../data/datasource/remote/abstract/club_remote_datasource.dart';
import '../data/datasource/remote/implement/club_remote_datasource_impl.dart';
import '../domain/repositories/club_repository.dart';
import '../data/repositories/club_repository_impl.dart';
import '../domain/usecases/club/get_my_clubs_usecase.dart';
import '../domain/usecases/club/get_club_by_id_usecase.dart';
import '../domain/usecases/club/create_club_usecase.dart';
import '../domain/usecases/club/join_club_usecase.dart';
import '../domain/usecases/club/get_club_members_usecase.dart';
import '../domain/usecases/club/update_member_role_usecase.dart';
import '../domain/usecases/club/remove_club_member_usecase.dart';
import '../domain/usecases/club/switch_club_context_usecase.dart';
import '../domain/usecases/club/club_role_usecases.dart';
import '../domain/usecases/club/join_request_usecases.dart';
import '../domain/usecases/club/explore_clubs_usecase.dart';
import '../domain/usecases/club/get_club_detail_usecase.dart';
import '../domain/usecases/club/update_club_info_usecase.dart';
import '../domain/usecases/club/update_club_schedules_usecase.dart';
import '../domain/usecases/club/club_fee_rule_usecases.dart';
import '../domain/usecases/auth/register_usecase.dart';

// Session imports
import '../data/datasource/remote/abstract/session_remote_datasource.dart';
import '../data/datasource/remote/implement/session_remote_datasource_impl.dart';
import '../domain/repositories/session_repository.dart';
import '../data/repositories/session_repository_impl.dart';
import '../domain/usecases/session/get_my_bookings_usecase.dart';
import '../domain/usecases/session/session_usecases.dart';

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Global auth token provider
final authTokenProvider = StateProvider<AuthToken?>((ref) => null);

/// Ngữ cảnh Câu lạc bộ đang hoạt động (Contextual Multi-Club RBAC)
final activeClubContextProvider =
    StateProvider<ActiveClubContext?>((ref) => null);

/// Active Club ID hiện tại (dùng cho Dio Interceptor và API query)
final activeClubIdProvider = Provider<String?>((ref) {
  return ref.watch(activeClubContextProvider)?.clubId;
});

/// Danh sách permissions của CLB đang hoạt động
final activeClubPermissionsProvider = Provider<List<String>>((ref) {
  return ref.watch(activeClubContextProvider)?.permissions ?? const [];
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

/// Global provider danh sách permissions của user hiện tại (gộp cả System permissions và Active Club permissions)
final userPermissionsProvider = Provider<List<String>>((ref) {
  final userProfile = ref.watch(currentUserProfileProvider);
  final activeContext = ref.watch(activeClubContextProvider);
  final result = <String>{};
  if (userProfile != null) {
    result.addAll(userProfile.permissions);
  }
  if (activeContext != null) {
    result.addAll(activeContext.permissions);
  }
  return result.toList();
});

/// Helper check role Admin từ user profile
final isAdminUserProvider = Provider<bool>((ref) {
  final userProfile = ref.watch(currentUserProfileProvider);
  if (userProfile == null) return false;
  return userProfile.roles.any((r) => r.trim().toLowerCase() == 'admin') ||
      userProfile.permissions.contains('System.Administrator');
});

/// Helper check permission trong CLB đang hoạt động (Contextual Multi-Club Dynamic RBAC)
final hasClubPermissionProvider =
    Provider.family<bool, String>((ref, permissionCode) {
  if (permissionCode.isEmpty) return true;

  final activeContext = ref.watch(activeClubContextProvider);
  if (activeContext == null) return false;
  return activeContext.permissions.contains(permissionCode);
});

/// Helper check permission của user hiện tại (hỗ trợ Admin bypass, Contextual Club & System Permissions)
final hasPermissionProvider =
    Provider.family<bool, String>((ref, permissionName) {
  if (permissionName.isEmpty) return true;
  final isAdmin = ref.watch(isAdminUserProvider);
  if (isAdmin) return true; // Admin có toàn quyền

  // 1. Kiểm tra quyền trong ngữ cảnh CLB đang chọn (Contextual RBAC - X-Group-Id)
  final activeContext = ref.watch(activeClubContextProvider);
  if (activeContext != null &&
      activeContext.permissions.contains(permissionName)) {
    return true;
  }

  // 2. Kiểm tra quyền hệ thống từ UserProfile
  final userProfile = ref.watch(currentUserProfileProvider);
  if (userProfile != null &&
      userProfile.permissions.contains(permissionName)) {
    return true;
  }

  return false;
});

/// Extension hỗ trợ kiểm tra quyền dùng chung qua Ref
extension PermissionRefX on Ref {
  bool hasPermission(String permission) =>
      watch(hasPermissionProvider(permission));
  bool hasClubPermission(String permission) =>
      watch(hasClubPermissionProvider(permission));
  bool hasAnyPermission(Iterable<String> permissions) =>
      permissions.any((p) => watch(hasPermissionProvider(p)));
  bool hasAllPermissions(Iterable<String> permissions) =>
      permissions.every((p) => watch(hasPermissionProvider(p)));
  bool get isAdmin => watch(isAdminUserProvider);
  ActiveClubContext? get activeClubContext => watch(activeClubContextProvider);
  String? get activeClubId => watch(activeClubIdProvider);
}

/// Extension hỗ trợ kiểm tra quyền dùng chung qua WidgetRef
extension PermissionWidgetRefX on WidgetRef {
  bool hasPermission(String permission) =>
      watch(hasPermissionProvider(permission));
  bool hasClubPermission(String permission) =>
      watch(hasClubPermissionProvider(permission));
  bool hasAnyPermission(Iterable<String> permissions) =>
      permissions.any((p) => watch(hasPermissionProvider(p)));
  bool hasAllPermissions(Iterable<String> permissions) =>
      permissions.every((p) => watch(hasPermissionProvider(p)));
  bool get isAdmin => watch(isAdminUserProvider);
  ActiveClubContext? get activeClubContext => watch(activeClubContextProvider);
  String? get activeClubId => watch(activeClubIdProvider);
}

/// Provider for current tab index in Home Screen
final homeTabProvider = StateProvider<int>((ref) => 0);

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// BiometricService provider
final biometricServiceProvider = Provider<IBiometricService>((ref) {
  return BiometricService();
});

/// LocationService provider
final locationServiceProvider = Provider<ILocationService>((ref) {
  return LocationServiceImpl();
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

// ============================================================================
// DATA SOURCE PROVIDERS - Auth
// ============================================================================

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(ref.watch(dioProvider));
});

// ============================================================================
// REPOSITORY PROVIDERS - Auth
// ============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
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

final logOutUseCase = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStorageProvider),
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

final getPlayerProfileUseCaseProvider = Provider<GetPlayerProfileUseCase>((ref) {
  return GetPlayerProfileUseCase(ref.watch(userRepositoryProvider));
});

final updatePlayerProfileUseCaseProvider = Provider<UpdatePlayerProfileUseCase>((ref) {
  return UpdatePlayerProfileUseCase(ref.watch(userRepositoryProvider));
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

// ============================================================================
// CLUB PROVIDERS
// ============================================================================
final clubRemoteDatasourceProvider = Provider<ClubRemoteDatasource>((ref) {
  return ClubRemoteDatasourceImpl(ref.watch(dioProvider));
});

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepositoryImpl(ref.watch(clubRemoteDatasourceProvider));
});

final getMyClubsUseCaseProvider = Provider<GetMyClubsUseCase>((ref) {
  return GetMyClubsUseCase(ref.watch(clubRepositoryProvider));
});

final getClubByIdUseCaseProvider = Provider<GetClubByIdUseCase>((ref) {
  return GetClubByIdUseCase(ref.watch(clubRepositoryProvider));
});

final createClubUseCaseProvider = Provider<CreateClubUseCase>((ref) {
  return CreateClubUseCase(ref.watch(clubRepositoryProvider));
});

final joinClubUseCaseProvider = Provider<JoinClubUseCase>((ref) {
  return JoinClubUseCase(ref.watch(clubRepositoryProvider));
});

final getClubMembersUseCaseProvider = Provider<GetClubMembersUseCase>((ref) {
  return GetClubMembersUseCase(ref.watch(clubRepositoryProvider));
});

final updateMemberRoleUseCaseProvider = Provider<UpdateMemberRoleUseCase>((ref) {
  return UpdateMemberRoleUseCase(ref.watch(clubRepositoryProvider));
});

final removeClubMemberUseCaseProvider = Provider<RemoveClubMemberUseCase>((ref) {
  return RemoveClubMemberUseCase(ref.watch(clubRepositoryProvider));
});

final switchClubContextUseCaseProvider = Provider<SwitchClubContextUseCase>((ref) {
  return SwitchClubContextUseCase(ref.watch(clubRepositoryProvider));
});

// Club Roles UseCases
final getClubPermissionsUseCaseProvider = Provider<GetClubPermissionsUseCase>((ref) {
  return GetClubPermissionsUseCase(ref.watch(clubRepositoryProvider));
});

final getClubRolesUseCaseProvider = Provider<GetClubRolesUseCase>((ref) {
  return GetClubRolesUseCase(ref.watch(clubRepositoryProvider));
});

final createClubRoleUseCaseProvider = Provider<CreateClubRoleUseCase>((ref) {
  return CreateClubRoleUseCase(ref.watch(clubRepositoryProvider));
});

final updateClubRolePermissionsUseCaseProvider = Provider<UpdateClubRolePermissionsUseCase>((ref) {
  return UpdateClubRolePermissionsUseCase(ref.watch(clubRepositoryProvider));
});

final deleteClubRoleUseCaseProvider = Provider<DeleteClubRoleUseCase>((ref) {
  return DeleteClubRoleUseCase(ref.watch(clubRepositoryProvider));
});

// Join Request UseCases
final createJoinRequestUseCaseProvider = Provider<CreateJoinRequestUseCase>((ref) {
  return CreateJoinRequestUseCase(ref.watch(clubRepositoryProvider));
});

final getJoinRequestsUseCaseProvider = Provider<GetJoinRequestsUseCase>((ref) {
  return GetJoinRequestsUseCase(ref.watch(clubRepositoryProvider));
});

final approveJoinRequestUseCaseProvider = Provider<ApproveJoinRequestUseCase>((ref) {
  return ApproveJoinRequestUseCase(ref.watch(clubRepositoryProvider));
});

final rejectJoinRequestUseCaseProvider = Provider<RejectJoinRequestUseCase>((ref) {
  return RejectJoinRequestUseCase(ref.watch(clubRepositoryProvider));
});

// --- FR06: Khám phá CLB theo GPS & Bán kính ---
final exploreClubsUseCaseProvider = Provider<ExploreClubsUseCase>((ref) {
  return ExploreClubsUseCase(ref.watch(clubRepositoryProvider));
});

// --- FR07: Thông tin chi tiết & Lịch sinh hoạt nhóm ---
final getClubDetailUseCaseProvider = Provider<GetClubDetailUseCase>((ref) {
  return GetClubDetailUseCase(ref.watch(clubRepositoryProvider));
});

final updateClubInfoUseCaseProvider = Provider<UpdateClubInfoUseCase>((ref) {
  return UpdateClubInfoUseCase(ref.watch(clubRepositoryProvider));
});

final updateClubSchedulesUseCaseProvider = Provider<UpdateClubSchedulesUseCase>((ref) {
  return UpdateClubSchedulesUseCase(ref.watch(clubRepositoryProvider));
});

// --- FR19: Hạch toán biểu phí và Quỹ nhóm ---
final getClubFeeRuleUseCaseProvider = Provider<GetClubFeeRuleUseCase>((ref) {
  return GetClubFeeRuleUseCase(ref.watch(clubRepositoryProvider));
});

final updateClubFeeRuleUseCaseProvider = Provider<UpdateClubFeeRuleUseCase>((ref) {
  return UpdateClubFeeRuleUseCase(ref.watch(clubRepositoryProvider));
});

// Registration
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStorageProvider),
  );
});

// ============================================================================
// SESSION PROVIDERS (FR13, FR08-FR10, FR11, FR12)
// ============================================================================
final sessionRemoteDataSourceProvider = Provider<SessionRemoteDataSource>((ref) {
  return SessionRemoteDataSourceImpl(ref.watch(dioProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(ref.watch(sessionRemoteDataSourceProvider));
});

final createSessionUseCaseProvider = Provider<CreateSessionUseCase>((ref) {
  return CreateSessionUseCase(ref.watch(sessionRepositoryProvider));
});

final getClubSessionsUseCaseProvider = Provider<GetClubSessionsUseCase>((ref) {
  return GetClubSessionsUseCase(ref.watch(sessionRepositoryProvider));
});

final getSessionDetailUseCaseProvider = Provider<GetSessionDetailUseCase>((ref) {
  return GetSessionDetailUseCase(ref.watch(sessionRepositoryProvider));
});

final updateSessionUseCaseProvider = Provider<UpdateSessionUseCase>((ref) {
  return UpdateSessionUseCase(ref.watch(sessionRepositoryProvider));
});

final updateSessionStatusUseCaseProvider = Provider<UpdateSessionStatusUseCase>((ref) {
  return UpdateSessionStatusUseCase(ref.watch(sessionRepositoryProvider));
});

final deleteSessionUseCaseProvider = Provider<DeleteSessionUseCase>((ref) {
  return DeleteSessionUseCase(ref.watch(sessionRepositoryProvider));
});

final voteBookingUseCaseProvider = Provider<VoteBookingUseCase>((ref) {
  return VoteBookingUseCase(ref.watch(sessionRepositoryProvider));
});

final cancelBookingUseCaseProvider = Provider<CancelBookingUseCase>((ref) {
  return CancelBookingUseCase(ref.watch(sessionRepositoryProvider));
});

final getSessionBookingsUseCaseProvider = Provider<GetSessionBookingsUseCase>((ref) {
  return GetSessionBookingsUseCase(ref.watch(sessionRepositoryProvider));
});

final getMyBookingUseCaseProvider = Provider<GetMyBookingUseCase>((ref) {
  return GetMyBookingUseCase(ref.watch(sessionRepositoryProvider));
});

final getMyBookingsUseCaseProvider = Provider<GetMyBookingsUseCase>((ref) {
  return GetMyBookingsUseCase(ref.watch(sessionRepositoryProvider));
});

final createRecruitmentUseCaseProvider = Provider<CreateRecruitmentUseCase>((ref) {
  return CreateRecruitmentUseCase(ref.watch(sessionRepositoryProvider));
});

final getSessionRecruitmentUseCaseProvider = Provider<GetSessionRecruitmentUseCase>((ref) {
  return GetSessionRecruitmentUseCase(ref.watch(sessionRepositoryProvider));
});

final deleteRecruitmentUseCaseProvider = Provider<DeleteRecruitmentUseCase>((ref) {
  return DeleteRecruitmentUseCase(ref.watch(sessionRepositoryProvider));
});

final exploreRecruitmentsUseCaseProvider = Provider<ExploreRecruitmentsUseCase>((ref) {
  return ExploreRecruitmentsUseCase(ref.watch(sessionRepositoryProvider));
});

final joinRecruitmentUseCaseProvider = Provider<JoinRecruitmentUseCase>((ref) {
  return JoinRecruitmentUseCase(ref.watch(sessionRepositoryProvider));
});

final cancelRecruitmentBookingUseCaseProvider = Provider<CancelRecruitmentBookingUseCase>((ref) {
  return CancelRecruitmentBookingUseCase(ref.watch(sessionRepositoryProvider));
});

// ============================================================================
// FR14 - FR23: SESSION ON-COURT OPERATIONS & SETTLEMENT PROVIDERS
// ============================================================================

final sessionOperationsRepositoryProvider = Provider<SessionOperationsRepository>((ref) {
  return SessionOperationsRepositoryImpl(dio: ref.watch(dioProvider));
});
