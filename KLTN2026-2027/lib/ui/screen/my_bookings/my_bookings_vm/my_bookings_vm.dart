// lib/ui/screen/my_bookings/my_bookings_vm/my_bookings_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/session/get_my_bookings_usecase.dart';
import 'my_bookings_state.dart';

final myBookingsViewModelProvider =
    StateNotifierProvider.autoDispose<MyBookingsViewModel, MyBookingsState>((ref) {
  return MyBookingsViewModel(
    getMyBookingsUseCase: ref.watch(getMyBookingsUseCaseProvider),
  );
});

class MyBookingsViewModel extends StateNotifier<MyBookingsState> {
  final GetMyBookingsUseCase getMyBookingsUseCase;

  MyBookingsViewModel({
    required this.getMyBookingsUseCase,
  }) : super(const MyBookingsState()) {
    loadMyBookings();
  }

  Future<void> loadMyBookings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bookings = await getMyBookingsUseCase.execute();
      state = state.copyWith(
        bookings: bookings,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: 'Lỗi tải lịch đã đăng ký: $e'),
      );
    }
  }

  void setFilter(MyBookingsFilter filter) {
    state = state.copyWith(filter: filter);
  }
}
