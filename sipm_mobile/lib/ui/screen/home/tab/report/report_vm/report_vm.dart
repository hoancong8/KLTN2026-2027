import 'package:flutter_riverpod/legacy.dart';
import 'report_state.dart';

final reportViewModelProvider =
    StateNotifierProvider.autoDispose<ReportViewModel, ReportState>((ref) {
  return ReportViewModel();
});

class ReportViewModel extends StateNotifier<ReportState> {
  ReportViewModel() : super(const ReportState());

  Future<void> loadData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement load report data
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
