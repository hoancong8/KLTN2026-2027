import 'package:equatable/equatable.dart';
import '../../../../domain/entities/reconciliation/reconciliation_transaction.dart';

class ReconciliationListState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final String? selectedStatus; // 'MANUAL_CHECK' | 'MATCHED' | null
  final List<ReconciliationTransaction> transactions;
  final int total;
  final int page;
  final int pageSize;
  final String? errorMessage;
  final String? errorMessageKey;

  const ReconciliationListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.selectedStatus = 'MANUAL_CHECK',
    this.transactions = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.errorMessage,
    this.errorMessageKey,
  });

  bool get hasMore => page * pageSize < total;

  ReconciliationListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? selectedStatus,
    bool clearStatus = false,
    List<ReconciliationTransaction>? transactions,
    int? total,
    int? page,
    int? pageSize,
    String? errorMessage,
    String? errorMessageKey,
    bool clearError = false,
  }) {
    return ReconciliationListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedStatus: clearStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      transactions: transactions ?? this.transactions,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorMessageKey: clearError
          ? null
          : (errorMessageKey ?? this.errorMessageKey),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    selectedStatus,
    transactions,
    total,
    page,
    pageSize,
    errorMessage,
    errorMessageKey,
  ];
}
