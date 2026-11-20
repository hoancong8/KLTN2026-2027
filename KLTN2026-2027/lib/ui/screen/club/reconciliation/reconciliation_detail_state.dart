import 'package:equatable/equatable.dart';
import '../../../../domain/entities/reconciliation/reconciliation_transaction.dart';
import '../../../../domain/entities/session/session.dart';
import '../../../../domain/entities/session/session_settlement.dart';

class ReconciliationDetailState extends Equatable {
  final bool isLoading;
  final bool isConfirming;
  final ReconciliationTransaction? transaction;
  final List<Session> clubSessions;
  final bool isLoadingSessions;
  final String? selectedSessionId;
  final List<MemberSettlementFee> candidateFees;
  final bool isLoadingCandidates;
  final String? selectedFeeId;
  final String? errorMessage;
  final String? errorMessageKey;
  final String? successMessageKey;

  const ReconciliationDetailState({
    this.isLoading = false,
    this.isConfirming = false,
    this.transaction,
    this.clubSessions = const [],
    this.isLoadingSessions = false,
    this.selectedSessionId,
    this.candidateFees = const [],
    this.isLoadingCandidates = false,
    this.selectedFeeId,
    this.errorMessage,
    this.errorMessageKey,
    this.successMessageKey,
  });

  ReconciliationDetailState copyWith({
    bool? isLoading,
    bool? isConfirming,
    ReconciliationTransaction? transaction,
    List<Session>? clubSessions,
    bool? isLoadingSessions,
    String? selectedSessionId,
    bool clearSelectedSession = false,
    List<MemberSettlementFee>? candidateFees,
    bool? isLoadingCandidates,
    String? selectedFeeId,
    bool clearSelectedFee = false,
    String? errorMessage,
    String? errorMessageKey,
    String? successMessageKey,
    bool clearMessages = false,
  }) {
    return ReconciliationDetailState(
      isLoading: isLoading ?? this.isLoading,
      isConfirming: isConfirming ?? this.isConfirming,
      transaction: transaction ?? this.transaction,
      clubSessions: clubSessions ?? this.clubSessions,
      isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
      selectedSessionId: clearSelectedSession
          ? null
          : (selectedSessionId ?? this.selectedSessionId),
      candidateFees: candidateFees ?? this.candidateFees,
      isLoadingCandidates: isLoadingCandidates ?? this.isLoadingCandidates,
      selectedFeeId: clearSelectedFee
          ? null
          : (selectedFeeId ?? this.selectedFeeId),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      errorMessageKey: clearMessages
          ? null
          : (errorMessageKey ?? this.errorMessageKey),
      successMessageKey: clearMessages
          ? null
          : (successMessageKey ?? this.successMessageKey),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isConfirming,
    transaction,
    clubSessions,
    isLoadingSessions,
    selectedSessionId,
    candidateFees,
    isLoadingCandidates,
    selectedFeeId,
    errorMessage,
    errorMessageKey,
    successMessageKey,
  ];
}
