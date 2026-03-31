import 'package:flutter_riverpod/legacy.dart';
import 'dashboard_state.dart';

final dashboardViewModelProvider =
    StateNotifierProvider.autoDispose<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel();
});

class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel() : super(const DashboardState());

  Future<void> loadData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement load dashboard data
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
