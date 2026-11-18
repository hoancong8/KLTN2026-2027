import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/payment/personal_fee.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/payment/payment_usecases.dart';
import 'fee_detail_state.dart';

final feeDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<FeeDetailViewModel, FeeDetailState, String>((ref, feeId) {
      return FeeDetailViewModel(
        feeId: feeId,
        getFee: ref.watch(getMyFeeUseCaseProvider),
        prepareTransfer: ref.watch(prepareBankTransferUseCaseProvider),
        getQr: ref.watch(getFeeQrImageUseCaseProvider),
        reportTransfer: ref.watch(reportFeeTransferUseCaseProvider),
        requestCash: ref.watch(requestCashPaymentUseCaseProvider),
      );
    });

class FeeDetailViewModel extends StateNotifier<FeeDetailState> {
  final String feeId;
  final GetMyFeeUseCase _getFee;
  final PrepareBankTransferUseCase _prepareTransfer;
  final GetFeeQrImageUseCase _getQr;
  final ReportFeeTransferUseCase _reportTransfer;
  final RequestCashPaymentUseCase _requestCash;

  FeeDetailViewModel({
    required this.feeId,
    required GetMyFeeUseCase getFee,
    required PrepareBankTransferUseCase prepareTransfer,
    required GetFeeQrImageUseCase getQr,
    required ReportFeeTransferUseCase reportTransfer,
    required RequestCashPaymentUseCase requestCash,
  }) : _getFee = getFee,
       _prepareTransfer = prepareTransfer,
       _getQr = getQr,
       _reportTransfer = reportTransfer,
       _requestCash = requestCash,
       super(const FeeDetailState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final fee = await _getFee.execute(feeId);
      if (!mounted) return;
      _adoptFee(fee);
      state = state.copyWith(isLoading: false);
      if (fee.paymentInstructions != null &&
          !fee.isPaid &&
          !fee.isExempt &&
          state.qrBytes == null) {
        await loadQr();
      }
    } on AppException catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: AppException(message: e.toString()),
        );
      }
    }
  }

  Future<void> prepareBankTransfer() => _runOperation(
    action: () => _prepareTransfer.execute(feeId),
    reloadAfterWriteError: (fee) => fee.paymentInstructions != null,
  );

  Future<void> requestCash() => _runOperation(
    action: () => _requestCash.execute(feeId),
    reloadAfterWriteError: (fee) =>
        fee.paymentProgress?.toUpperCase() == 'CASH_CONFIRMATION_REQUESTED',
  );

  Future<void> reportTransfer() => _runOperation(
    action: () => _reportTransfer.execute(feeId),
    reloadAfterWriteError: (fee) =>
        fee.paymentProgress?.toUpperCase() == 'AWAITING_RECONCILIATION',
  );

  Future<void> _runOperation({
    required Future<PersonalFee> Function() action,
    bool Function(PersonalFee fee)? reloadAfterWriteError,
  }) async {
    if (state.isOperating) return;
    state = state.copyWith(
      isOperating: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final fee = await action();
      if (!mounted) return;
      _adoptFee(fee);
      state = state.copyWith(isOperating: false);
      if (fee.paymentInstructions != null &&
          !fee.isPaid &&
          !fee.isExempt &&
          state.qrBytes == null) {
        await loadQr();
      }
    } on AppException catch (e) {
      if (!mounted) return;
      state = state.copyWith(isOperating: false, error: e);
      if (reloadAfterWriteError != null) {
        await _reloadAfterUncertainWrite(e, reloadAfterWriteError);
      }
    } catch (e) {
      if (!mounted) return;
      final error = AppException(message: e.toString());
      state = state.copyWith(isOperating: false, error: error);
      if (reloadAfterWriteError != null) {
        await _reloadAfterUncertainWrite(error, reloadAfterWriteError);
      }
    }
  }

  Future<void> _reloadAfterUncertainWrite(
    AppException actionError,
    bool Function(PersonalFee fee) wasCommitted,
  ) async {
    try {
      final latest = await _getFee.execute(feeId);
      if (!mounted) return;
      _adoptFee(latest);
      state = state.copyWith(
        isOperating: false,
        error: actionError,
        clearError: wasCommitted(latest) || latest.isPaid || latest.isExempt,
      );
      if (latest.paymentInstructions != null &&
          !latest.isPaid &&
          !latest.isExempt &&
          state.qrBytes == null) {
        await loadQr();
      }
    } catch (_) {
      // Keep the action error visible; the user can explicitly reload the detail.
    }
  }

  void _adoptFee(PersonalFee fee) {
    final terminal = fee.isPaid || fee.isExempt;
    if (terminal) _evictQr();
    state = state.copyWith(
      fee: fee,
      clearQr: terminal || fee.paymentInstructions == null,
      clearQrError: true,
    );
  }

  void _evictQr() {
    final bytes = state.qrBytes;
    if (bytes != null && bytes.isNotEmpty) {
      unawaited(MemoryImage(bytes).evict());
    }
  }

  Future<void> loadQr() async {
    final path = state.fee?.paymentInstructions?.imagePath;
    if (path == null || path.isEmpty) {
      state = state.copyWith(
        clearQr: true,
        qrError: const InvalidResponseException(
          originalError: 'Missing QR path',
        ),
      );
      return;
    }
    if (state.fee?.isPaid == true || state.fee?.isExempt == true) {
      state = state.copyWith(clearQr: true);
      return;
    }
    if (state.isQrLoading) return;
    state = state.copyWith(isQrLoading: true, clearQrError: true);
    try {
      final bytes = await _getQr.execute(path);
      if (mounted) {
        state = state.copyWith(
          isQrLoading: false,
          qrBytes: Uint8List.fromList(bytes),
        );
      }
    } on AppException catch (e) {
      if (mounted) state = state.copyWith(isQrLoading: false, qrError: e);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isQrLoading: false,
          qrError: AppException(message: e.toString()),
        );
      }
    }
  }

  @override
  void dispose() {
    _evictQr();
    super.dispose();
  }
}
