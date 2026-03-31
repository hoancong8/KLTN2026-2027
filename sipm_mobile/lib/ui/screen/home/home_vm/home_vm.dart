import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/app/consts/app_router.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/app/services/signalr_service.dart';
import 'package:sipm_mobile/domain/entities/employee.dart';
import 'package:sipm_mobile/domain/exceptions/auth_exceptions.dart';
import 'package:sipm_mobile/domain/usecases/notification/get_initial_notification_message_usecase.dart';
import 'package:sipm_mobile/domain/usecases/notification/get_notification_message_stream_usecase.dart';
import 'package:sipm_mobile/domain/usecases/profile/get_profile_usecase.dart';
import 'package:sipm_mobile/domain/usecases/auth/get_session_info_usecase.dart';
import 'package:sipm_mobile/domain/usecases/auth/logout_usecase.dart';
import 'package:sipm_mobile/domain/usecases/auth/register_device_token_usecase.dart';
import 'package:sipm_mobile/domain/usecases/auth/save_employee_id_usecase.dart';
import 'package:sipm_mobile/domain/usecases/auth/save_tenant_id_usecase.dart';
import 'package:sipm_mobile/ui/screen/home/home_screen.dart';
import '../../../../domain/usecases/notification/get_notification_opened_stream_usecase.dart';
import '../../chat_detail/chat_detail_screen.dart';
import 'home_state.dart';

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  final viewModel = HomeViewModel(
    logoutUseCase: ref.watch(logOutUseCase),
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    getSessionInfoUseCase: ref.watch(getSessionInfoUseCaseProvider),
    saveTenantIdUseCase: ref.watch(saveTenantIdUseCaseProvider), // NEW
    saveEmployeeIdUseCase: ref.watch(saveEmployeeIdUseCaseProvider),
    signalRService: ref.watch(signalRServiceProvider),
    registerDeviceTokenUseCase: ref.watch(registerDeviceTokenUseCaseProvider),
    getNotificationMessageStreamUseCase: ref.watch(
      getNotificationMessageStreamUseCaseProvider,
    ),
    getNotificationOpenedStreamUseCase: ref.watch(
      getNotificationOpenedStreamUseCaseProvider,
    ),
    getInitialNotificationMessageUseCase: ref.watch(
      getInitialNotificationMessageUseCaseProvider,
    ),
    ref: ref,
  );

  // Manual cleanup khi provider bị dispose
  ref.onDispose(() {
    print('[HomeVM] Provider disposing - cleaning up');
    viewModel.cleanup();
  });

  return viewModel;
});

class HomeViewModel extends StateNotifier<HomeState> {
  final LogoutUseCase logoutUseCase;
  final GetProfileUseCase getProfileUseCase;
  final GetSessionInfoUseCase getSessionInfoUseCase;
  final SaveTenantIdUseCase saveTenantIdUseCase;
  final SaveEmployeeIdUseCase saveEmployeeIdUseCase;
  final SignalRService signalRService;
  final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  final GetNotificationMessageStreamUseCase getNotificationMessageStreamUseCase;
  final GetNotificationOpenedStreamUseCase getNotificationOpenedStreamUseCase;
  final GetInitialNotificationMessageUseCase
  getInitialNotificationMessageUseCase;
  final Ref ref;

  HomeViewModel({
    required this.logoutUseCase,
    required this.getProfileUseCase,
    required this.getSessionInfoUseCase,
    required this.saveTenantIdUseCase,
    required this.saveEmployeeIdUseCase,
    required this.signalRService,
    required this.registerDeviceTokenUseCase,
    required this.getNotificationMessageStreamUseCase,
    required this.getNotificationOpenedStreamUseCase,
    required this.getInitialNotificationMessageUseCase,
    required this.ref,
  }) : super(const HomeState());

  Future<void> initialize(String accessToken, int? userId) async {
    if (!mounted || state.isInitialized) return;

    try {
      await Future.wait([
        _loadUserDataDirectly(userId),
        _connectSignalR(accessToken),
        _listenToNotifications(),
      ]);

      if (!mounted) return;

      // Handle any notification that woke up the app
      final initialMessage = getInitialNotificationMessageUseCase.execute();
      if (initialMessage != null) {
        print('[HomeVM] Processing initial notification on startup');
        _handleNotificationClick(initialMessage);
        getInitialNotificationMessageUseCase.clear();
      }

      state = state.copyWith(isInitialized: true);
    } on SessionExpiredException {
      // Session expired - để interceptor xử lý dialog
      print('[HomeVM] Initialize failed: Session expired');
    } catch (e) {
      print('[HomeVM] Initialize failed: $e');
      if (mounted) {
        state = state.copyWith(isInitialized: true);
      }
    }
  }

  Future<void> _loadUserDataDirectly(int? userId) async {
    try {
      // Dùng Future riêng để handle error mà không ảnh hưởng typing
      // Future<Employee?>
      final profileFuture = (userId != null)
          ? getProfileUseCase
                .execute(userId)
                .then<Employee?>((res) => res)
                .catchError((e) {
                  print('[HomeVM] GetProfile failed: $e');
                  return null;
                })
          : Future<Employee?>.value(null);

      // Future<SessionInfoDto?>
      final sessionFuture = getSessionInfoUseCase
          .execute()
          .then<dynamic>((res) => res)
          .catchError((e) {
            print('[HomeVM] GetSessionInfo failed: $e');
            return null;
          });

      final results = await Future.wait([profileFuture, sessionFuture]);

      if (!mounted) return;

      final employeeResult = results[0] as Employee?;
      final sessionResult = results[1] as dynamic;

      if (employeeResult != null) {
        var employee = employeeResult;

        // Bổ sung TenantId từ Session nếu có
        if (sessionResult != null && sessionResult.tenant != null) {
          employee = employee.copyWith(tenantId: sessionResult.tenant!.id);
        }

        // Lưu TenantId vào Storage nếu có
        if (employee.tenantId != null) {
          try {
            await saveTenantIdUseCase.execute(employee.tenantId!);
            print('[HomeVM] TenantId saved to storage: ${employee.tenantId}');
          } catch (e) {
            print('[HomeVM] Failed to save TenantId: $e');
          }
        }

        // Lưu EmployeeId vào Storage
        try {
          await saveEmployeeIdUseCase.execute(employee.id);
          print('[HomeVM] EmployeeId saved to storage: ${employee.id}');
        } catch (e) {
          print('[HomeVM] Failed to save EmployeeId: $e');
        }

        state = state.copyWith(employee: employee);
        ref.read(currentEmployeeProvider.notifier).state = employee;
        print('[HomeVM] Employee loaded from Profile');
      } else if (sessionResult != null && sessionResult.user != null) {
        final user = sessionResult.user!;
        final isAdminUser =
            user.userName?.toLowerCase() == 'admin' ||
            user.name?.toLowerCase() == 'admin';

        final employee = Employee(
          id: user.id,
          tenantId: sessionResult.tenant?.id,
          fullName: '${user.name ?? ''} ${user.surname ?? ''}'.trim(),
          userName: user.userName,
          roleName: isAdminUser ? 'Admin' : 'User',
        );

        // Cũng lưu TenantId khi dùng fallback
        if (employee.tenantId != null) {
          try {
            await saveTenantIdUseCase.execute(employee.tenantId!);
          } catch (_) {}
        }

        state = state.copyWith(employee: employee);
        ref.read(currentEmployeeProvider.notifier).state = employee;
        print('[HomeVM] Employee loaded from Session API (Fallback)');
      }

      try {
        await registerDeviceTokenUseCase.execute();
      } catch (e) {
        print('[HomeVM] Failed to register device token: $e');
      }
    } catch (e) {
      print('[HomeVM] LoadUserData failed: $e');
    }
  }

  Future<void> _connectSignalR(String accessToken) async {
    try {
      await signalRService.connect(accessToken);
      print('[HomeVM] SignalR connected');
    } catch (e) {
      print('[HomeVM] SignalR connection failed: $e');
    }
  }

  Future<void> _listenToNotifications() async {
    getNotificationMessageStreamUseCase.execute().listen((notification) {
      print('[HomeVM] Notification received: ${notification.title}');
    });

    getNotificationOpenedStreamUseCase.execute().listen((notification) {
      print('[HomeVM] Notification opened: ${notification.title}');
      _handleNotificationClick(notification);
    });
  }

  void _handleNotificationClick(notification) {
    final data = notification.data;
    if (data == null) return;

    final type = data['type'] as String?;
    print('[HomeVM] Notification type: $type');

    // Xử lý theo loại notification
    // Backend cần gửi data với format đúng - xem NOTIFICATION_FORMAT.md
    switch (type) {
      case 'chat':
      case 'message':
        _openChatFromNotification(data);
        break;
      case 'admin_alert':
        // TODO: Xử lý admin alert - hiển thị persistent banner
        print('[HomeVM] Admin alert received');
        break;
      default:
        print('[HomeVM] Unknown notification type: $type');
    }
  }

  void _openChatFromNotification(Map<String, dynamic> data) {
    final userId = data['userId'] ?? data['senderId'];
    final userName = data['userName'] ?? data['senderName'] ?? 'User';

    if (userId == null) {
      print('[HomeVM] Missing userId in notification data');
      return;
    }

    print('[HomeVM] Opening chat with userId: $userId, userName: $userName');

    // Switch sang tab Chat (index 2)
    ref.read(homeTabProvider.notifier).state = 2;

    // Navigate đến ChatDetailScreen
    // Sử dụng rootNavigatorKey để navigate từ bất kỳ đâu
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            userId: int.parse(userId.toString()),
            userName: userName.toString(),
            isOnline:
                false, // Từ notification, mặc định false - sẽ được cập nhật qua SignalR
          ),
        ),
      );
    }
  }

  Future<bool> logout() async {
    if (!mounted) return false;

    state = state.copyWith(isLoading: true, error: null, didLogout: false);

    try {
      // 1) Disconnect SignalR trước
      await signalRService.disconnect(clear: true);
      state = const HomeState();
      // 2) Logout backend / clear session
      await logoutUseCase.execute();

      if (!mounted) return false;

      state = state.copyWith(isLoading: false, didLogout: true);
      return true;
    } on SessionExpiredException {
      if (!mounted) return true;
      await signalRService.disconnect(clear: true);
      state = state.copyWith(isLoading: false, didLogout: true);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void resetLogoutFlag() {
    if (!mounted || !state.didLogout) return;
    state = state.copyWith(didLogout: false);
  }

  void cleanup() {
    print('[HomeVM] Cleaning up resources');
    signalRService.disconnect(clear: false).catchError((e) {
      print('[HomeVM] SignalR disconnect error on cleanup: $e');
    });
  }
}
