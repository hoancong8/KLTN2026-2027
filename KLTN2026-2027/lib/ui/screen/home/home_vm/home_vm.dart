import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/consts/app_log.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/services/app_auth_interceptor.dart';
import 'package:kltn2026_2027/domain/usecases/auth/logout_usecase.dart';
import 'home_state.dart';

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    logoutUseCase: ref.watch(logOutUseCase),
    ref: ref,
  );
});

class HomeViewModel extends StateNotifier<HomeState> {
  final LogoutUseCase logoutUseCase;
  final Ref ref;

  HomeViewModel({
    required this.logoutUseCase,
    required this.ref,
  }) : super(const HomeState());

  Future<bool> logout() async {
    if (!mounted) return false;

    state = state.copyWith(isLoading: true, error: null, didLogout: false);
    AppAuthInterceptor.isLoggingOut = true;

    try {
      await logoutUseCase.execute();
    } catch (e) {
      AppLog.info('[HomeViewModel] Logout remote error: $e');
    } finally {
      ref.read(authTokenProvider.notifier).state = null;
      ref.read(activeClubContextProvider.notifier).state = null;
      ref.read(currentUserProfileProvider.notifier).clear();
      ref.read(homeTabProvider.notifier).state = 0;
      AppAuthInterceptor.resetStaticState();

      if (mounted) {
        state = state.copyWith(isLoading: false, didLogout: true);
      }
    }
    return true;
  }
}
