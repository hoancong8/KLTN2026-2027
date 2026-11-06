import '../tab/dashboard/dashboard_vm/dashboard_vm.dart';
import '../tab/report/report_vm/report_vm.dart';
import '../../explore_clubs/explore_clubs_vm/explore_clubs_vm.dart';
import '../../club/session_vm/explore_recruitments_vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/services/app_auth_interceptor.dart';
import 'package:kltn2026_2027/domain/exceptions/auth_exceptions.dart';
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

    try {
      await logoutUseCase.execute();

      ref.read(authTokenProvider.notifier).state = null;
      ref.read(activeClubContextProvider.notifier).state = null;
      ref.read(currentUserProfileProvider.notifier).clear();
      ref.read(homeTabProvider.notifier).state = 0;
      ref.invalidate(dashboardViewModelProvider);
      ref.invalidate(reportViewModelProvider);
      ref.invalidate(exploreClubsViewModelProvider);
      ref.invalidate(exploreRecruitmentsViewModelProvider);
      AppAuthInterceptor.resetStaticState();

      if (!mounted) return false;

      state = state.copyWith(isLoading: false, didLogout: true);
      return true;
    } on SessionExpiredException {
      if (!mounted) return true;
      ref.read(authTokenProvider.notifier).state = null;
      ref.read(activeClubContextProvider.notifier).state = null;
      ref.read(currentUserProfileProvider.notifier).clear();
      ref.read(homeTabProvider.notifier).state = 0;
      ref.invalidate(dashboardViewModelProvider);
      ref.invalidate(reportViewModelProvider);
      ref.invalidate(exploreClubsViewModelProvider);
      ref.invalidate(exploreRecruitmentsViewModelProvider);
      AppAuthInterceptor.resetStaticState();
      state = state.copyWith(isLoading: false, didLogout: true);
      return true;
    } catch (e) {
      ref.read(authTokenProvider.notifier).state = null;
      ref.read(activeClubContextProvider.notifier).state = null;
      ref.read(currentUserProfileProvider.notifier).clear();
      ref.read(homeTabProvider.notifier).state = 0;
      ref.invalidate(dashboardViewModelProvider);
      ref.invalidate(reportViewModelProvider);
      ref.invalidate(exploreClubsViewModelProvider);
      ref.invalidate(exploreRecruitmentsViewModelProvider);
      AppAuthInterceptor.resetStaticState();
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        didLogout: true,
      );
      return false;
    }
  }
}
