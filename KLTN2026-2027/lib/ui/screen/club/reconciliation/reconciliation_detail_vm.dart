import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/exceptions/app_exception.dart';
import 'reconciliation_detail_state.dart';

class ReconciliationDetailParams extends Equatable {
  final String clubId;
  final String transactionId;

  const ReconciliationDetailParams({
    required this.clubId,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [clubId, transactionId];
}

final reconciliationDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<
      ReconciliationDetailViewModel,
      ReconciliationDetailState,
      ReconciliationDetailParams
    >((ref, params) {
      return ReconciliationDetailViewModel(ref, params);
    });

class ReconciliationDetailViewModel
    extends StateNotifier<ReconciliationDetailState> {
  final Ref ref;
  final ReconciliationDetailParams params;

  ReconciliationDetailViewModel(this.ref, this.params)
    : super(const ReconciliationDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final tx = await ref
          .read(getReconciliationDetailUseCaseProvider)
          .execute(params.clubId, params.transactionId);

      state = state.copyWith(isLoading: false, transaction: tx);

      // If MANUAL_CHECK, auto load sessions to prepare candidate fee options
      if (tx.isManualCheck) {
        loadClubSessions();
      }
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null
            ? 'reconciliation_load_detail_failed'
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessageKey: 'error_system_retry',
      );
    }
  }

  Future<void> loadClubSessions() async {
    state = state.copyWith(isLoadingSessions: true);
    try {
      final sessions = await ref
          .read(getClubSessionsUseCaseProvider)
          .execute(params.clubId);

      // Sort by start time descending (most recent first)
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

      state = state.copyWith(isLoadingSessions: false, clubSessions: sessions);

      // If sessions available and none selected yet, pick first session
      if (sessions.isNotEmpty && state.selectedSessionId == null) {
        selectSession(sessions.first.id);
      }
    } catch (_) {
      state = state.copyWith(isLoadingSessions: false);
    }
  }

  Future<void> selectSession(String sessionId) async {
    state = state.copyWith(
      selectedSessionId: sessionId,
      isLoadingCandidates: true,
      clearSelectedFee: true,
      candidateFees: [],
    );

    try {
      final settlement = await ref
          .read(sessionOperationsRepositoryProvider)
          .getSettlement(sessionId);

      final txAmount = state.transaction?.amountReceived ?? 0;

      // Filter candidates:
      // 1. Not paid and not exempt
      // 2. Exact amount matches amountReceived
      // 3. Payment method is not CASH
      final candidates = settlement.memberFees.where((fee) {
        final unpaid = !fee.isPaid && !fee.isExempt;
        final amountMatch = fee.finalFee == txAmount;
        final notCash = fee.paymentMethod != 'CASH';
        return unpaid && amountMatch && notCash;
      }).toList();

      state = state.copyWith(
        isLoadingCandidates: false,
        candidateFees: candidates,
        selectedFeeId: candidates.isNotEmpty ? candidates.first.feeId : null,
      );
    } catch (_) {
      state = state.copyWith(isLoadingCandidates: false, candidateFees: []);
    }
  }

  void selectCandidateFee(String feeId) {
    state = state.copyWith(selectedFeeId: feeId);
  }

  Future<bool> confirmManual({required String reason}) async {
    final feeId = state.selectedFeeId;
    if (feeId == null || feeId.isEmpty) {
      state = state.copyWith(errorMessageKey: 'reconciliation_fee_required');
      return false;
    }

    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      state = state.copyWith(
        errorMessageKey: 'reconciliation_manual_reason_required',
      );
      return false;
    }

    if (trimmedReason.length > 2000) {
      state = state.copyWith(
        errorMessageKey: 'reconciliation_manual_reason_too_long',
      );
      return false;
    }

    state = state.copyWith(isConfirming: true, clearMessages: true);

    try {
      final updatedTx = await ref
          .read(confirmManualReconciliationUseCaseProvider)
          .execute(
            params.clubId,
            params.transactionId,
            feeId: feeId,
            reason: trimmedReason,
          );

      state = state.copyWith(
        isConfirming: false,
        transaction: updatedTx,
        successMessageKey: 'reconciliation_manual_confirm_succeeded',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isConfirming: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null
            ? 'reconciliation_manual_confirm_failed'
            : null,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isConfirming: false,
        errorMessageKey: 'error_system_retry',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}
