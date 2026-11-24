import 'package:equatable/equatable.dart';
import '../../../../domain/entities/sepay/sepay_connection.dart';
import '../../../../domain/entities/sepay/sepay_provider_account.dart';

class ClubSepayState extends Equatable {
  final bool isLoading;
  final bool isActionInProgress;
  final String?
  actionType; // 'authorize' | 'complete' | 'connect' | 'disconnect'
  final SepayConnection? connection;
  final List<SepayProviderAccount> accounts;
  final List<SepayConnection> oldConnections;
  final String? errorMessage;
  final String? errorMessageKey;
  final String? successMessageKey;
  final int? selectedProviderBankId;
  final bool accountsLoadFailed;
  final bool connectionsLoadFailed;

  const ClubSepayState({
    this.isLoading = false,
    this.isActionInProgress = false,
    this.actionType,
    this.connection,
    this.accounts = const [],
    this.oldConnections = const [],
    this.errorMessage,
    this.errorMessageKey,
    this.successMessageKey,
    this.selectedProviderBankId,
    this.accountsLoadFailed = false,
    this.connectionsLoadFailed = false,
  });

  ClubSepayState copyWith({
    bool? isLoading,
    bool? isActionInProgress,
    String? actionType,
    SepayConnection? connection,
    List<SepayProviderAccount>? accounts,
    List<SepayConnection>? oldConnections,
    String? errorMessage,
    String? errorMessageKey,
    String? successMessageKey,
    int? selectedProviderBankId,
    bool clearSelectedProviderBankId = false,
    bool? accountsLoadFailed,
    bool? connectionsLoadFailed,
    bool clearMessages = false,
  }) {
    return ClubSepayState(
      isLoading: isLoading ?? this.isLoading,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      actionType: actionType ?? this.actionType,
      connection: connection ?? this.connection,
      accounts: accounts ?? this.accounts,
      oldConnections: oldConnections ?? this.oldConnections,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      errorMessageKey: clearMessages
          ? null
          : (errorMessageKey ?? this.errorMessageKey),
      successMessageKey: clearMessages
          ? null
          : (successMessageKey ?? this.successMessageKey),
      selectedProviderBankId: clearSelectedProviderBankId
          ? null
          : (selectedProviderBankId ?? this.selectedProviderBankId),
      accountsLoadFailed: accountsLoadFailed ?? this.accountsLoadFailed,
      connectionsLoadFailed:
          connectionsLoadFailed ?? this.connectionsLoadFailed,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isActionInProgress,
    actionType,
    connection,
    accounts,
    oldConnections,
    errorMessage,
    errorMessageKey,
    successMessageKey,
    selectedProviderBankId,
    accountsLoadFailed,
    connectionsLoadFailed,
  ];
}
