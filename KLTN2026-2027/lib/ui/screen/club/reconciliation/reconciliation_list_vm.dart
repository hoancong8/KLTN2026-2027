import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/exceptions/app_exception.dart';
import 'reconciliation_list_state.dart';

final reconciliationListViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReconciliationListViewModel, ReconciliationListState, String>((
      ref,
      clubId,
    ) {
      return ReconciliationListViewModel(ref, clubId);
    });

class ReconciliationListViewModel
    extends StateNotifier<ReconciliationListState> {
  final Ref ref;
  final String clubId;

  ReconciliationListViewModel(this.ref, this.clubId)
    : super(const ReconciliationListState()) {
    loadTransactions();
  }

  Future<void> loadTransactions({String? status, bool resetPage = true}) async {
    final targetStatus = resetPage ? status : state.selectedStatus;
    state = state.copyWith(
      isLoading: true,
      selectedStatus: targetStatus,
      clearStatus: targetStatus == null && resetPage,
      page: resetPage ? 1 : state.page,
      clearError: true,
    );

    try {
      final result = await ref
          .read(getReconciliationsUseCaseProvider)
          .execute(
            clubId,
            status: targetStatus,
            page: 1,
            pageSize: state.pageSize,
          );

      state = state.copyWith(
        isLoading: false,
        transactions: result.items,
        total: result.total,
        page: result.page,
        pageSize: result.pageSize,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null
            ? 'reconciliation_load_list_failed'
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessageKey: 'error_system_retry',
      );
    }
  }

  Future<void> changeFilter(String? status) async {
    if (state.selectedStatus == status) return;
    await loadTransactions(status: status, resetPage: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);
    final nextPage = state.page + 1;

    try {
      final result = await ref
          .read(getReconciliationsUseCaseProvider)
          .execute(
            clubId,
            status: state.selectedStatus,
            page: nextPage,
            pageSize: state.pageSize,
          );

      state = state.copyWith(
        isLoadingMore: false,
        transactions: [...state.transactions, ...result.items],
        total: result.total,
        page: result.page,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null
            ? 'reconciliation_load_more_failed'
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessageKey: 'error_system_retry',
      );
    }
  }

  Future<void> refresh() async {
    await loadTransactions(status: state.selectedStatus, resetPage: true);
  }
}
