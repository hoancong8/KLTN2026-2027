import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/usecases/session/get_my_bookings_usecase.dart';
import 'report_state.dart';

final reportViewModelProvider =
    StateNotifierProvider.autoDispose<ReportViewModel, ReportState>((ref) {
  final getMyBookingsUseCase = ref.watch(getMyBookingsUseCaseProvider);
  return ReportViewModel(getMyBookingsUseCase);
});

class ReportViewModel extends StateNotifier<ReportState> {
  final GetMyBookingsUseCase _getMyBookingsUseCase;

  ReportViewModel(this._getMyBookingsUseCase)
      : super(ReportState(
          focusedMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
          selectedDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        ));

  Future<void> loadData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookings = await _getMyBookingsUseCase.execute();
      bookings.sort((a, b) => a.startTime.compareTo(b.startTime));
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        myBookings: bookings,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void changeMonth(int monthOffset) {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + monthOffset,
      1,
    );
    state = state.copyWith(
      focusedMonth: newMonth,
      clearSelectedDate: true,
    );
  }

  void selectDate(DateTime date) {
    if (state.selectedDate != null &&
        state.selectedDate!.year == date.year &&
        state.selectedDate!.month == date.month &&
        state.selectedDate!.day == date.day) {
      state = state.copyWith(clearSelectedDate: true);
    } else {
      state = state.copyWith(selectedDate: date);
    }
  }

  void setFilter(ReportFilter filter) {
    state = state.copyWith(filter: filter);
  }
}
