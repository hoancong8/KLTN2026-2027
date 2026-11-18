import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/payment/payment_usecases.dart';
import 'my_fees_state.dart';

final myFeesViewModelProvider =
    StateNotifierProvider.autoDispose<MyFeesViewModel, MyFeesState>((ref) {
      return MyFeesViewModel(ref.watch(getMyFeesUseCaseProvider));
    });

class MyFeesViewModel extends StateNotifier<MyFeesState> {
  final GetMyFeesUseCase _getMyFees;

  MyFeesViewModel(this._getMyFees) : super(const MyFeesState()) {
    load();
  }

  Future<void> load({String? filter, bool refresh = false}) async {
    final selectedFilter = filter ?? state.statusFilter;
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      statusFilter: selectedFilter,
      page: 1,
      fees: refresh || filter != null ? const [] : state.fees,
      clearError: true,
    );
    try {
      final result = await _getMyFees.execute(
        page: 1,
        pageSize: state.pageSize,
        paymentStatus: selectedFilter,
      );
      state = state.copyWith(
        fees: result.items,
        total: result.total,
        page: result.page,
        pageSize: result.pageSize,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: e.toString()),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final nextPage = state.page + 1;
      final result = await _getMyFees.execute(
        page: nextPage,
        pageSize: state.pageSize,
        paymentStatus: state.statusFilter,
      );
      state = state.copyWith(
        fees: [...state.fees, ...result.items],
        total: result.total,
        page: result.page,
        pageSize: result.pageSize,
        isLoadingMore: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: AppException(message: e.toString()),
      );
    }
  }
}
