import '../../../../domain/entities/payment/personal_fee.dart';
import '../../../../domain/exceptions/app_exception.dart';

class MyFeesState {
  final List<PersonalFee> fees;
  final String? statusFilter;
  final int page;
  final int total;
  final int pageSize;
  final bool isLoading;
  final bool isLoadingMore;
  final AppException? error;

  const MyFeesState({
    this.fees = const [],
    this.statusFilter = 'UNPAID',
    this.page = 1,
    this.total = 0,
    this.pageSize = 20,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  MyFeesState copyWith({
    List<PersonalFee>? fees,
    String? statusFilter,
    int? page,
    int? total,
    int? pageSize,
    bool? isLoading,
    bool? isLoadingMore,
    AppException? error,
    bool clearError = false,
  }) => MyFeesState(
    fees: fees ?? this.fees,
    statusFilter: statusFilter ?? this.statusFilter,
    page: page ?? this.page,
    total: total ?? this.total,
    pageSize: pageSize ?? this.pageSize,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: clearError ? null : error ?? this.error,
  );

  bool get hasMore => fees.length < total;
}
