import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/entities/sepay/sepay_connection.dart';
import '../../../../domain/entities/sepay/sepay_provider_account.dart';
import 'club_sepay_state.dart';

final clubSepayViewModelProvider = StateNotifierProvider.autoDispose
    .family<ClubSepayViewModel, ClubSepayState, String>((ref, clubId) {
      return ClubSepayViewModel(ref, clubId);
    });

class ClubSepayViewModel extends StateNotifier<ClubSepayState> {
  final Ref ref;
  final String clubId;

  ClubSepayViewModel(this.ref, this.clubId) : super(const ClubSepayState()) {
    loadStatus();
  }

  Future<void> loadStatus() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final conn = await ref
          .read(getClubSepayConnectionUseCaseProvider)
          .execute(clubId);

      var accounts = const <SepayProviderAccount>[];
      var accountsLoadFailed = false;
      if (conn.isAuthorized) {
        try {
          accounts = await ref
              .read(getClubSepayBankAccountsUseCaseProvider)
              .execute(clubId);
        } catch (_) {
          accountsLoadFailed = true;
        }
      }

      var oldConnections = const <SepayConnection>[];
      var connectionsLoadFailed = false;
      try {
        oldConnections = await ref
            .read(listClubSepayConnectionsUseCaseProvider)
            .execute(clubId);
      } catch (_) {
        connectionsLoadFailed = true;
      }

      int? selectedId = state.selectedProviderBankId;
      final eligible = accounts.where((a) => a.isEligibleToSelect).toList();
      if (!eligible.any((account) => account.id == selectedId)) {
        selectedId = eligible.isEmpty ? null : eligible.first.id;
      }

      state = state.copyWith(
        isLoading: false,
        connection: conn,
        accounts: accounts,
        oldConnections: oldConnections,
        selectedProviderBankId: selectedId,
        clearSelectedProviderBankId: selectedId == null,
        accountsLoadFailed: accountsLoadFailed,
        connectionsLoadFailed: connectionsLoadFailed,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null ? 'sepay_load_status_failed' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessageKey: 'error_system_retry',
      );
    }
  }

  Future<String?> startOAuth() async {
    state = state.copyWith(
      isActionInProgress: true,
      actionType: 'authorize',
      clearMessages: true,
    );
    try {
      final authUrl = await ref
          .read(startClubSepayConnectionUseCaseProvider)
          .execute(clubId);
      state = state.copyWith(isActionInProgress: false);
      return authUrl;
    } on AppException catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null
            ? 'sepay_start_authorization_failed'
            : null,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessageKey: 'error_system_retry',
      );
      return null;
    }
  }

  Future<bool> completeOAuth(String ticket) async {
    state = state.copyWith(
      isActionInProgress: true,
      actionType: 'complete',
      clearMessages: true,
    );
    try {
      final conn = await ref
          .read(completeClubSepayConnectionUseCaseProvider)
          .execute(clubId, ticket);

      state = state.copyWith(
        isActionInProgress: false,
        connection: conn,
        successMessageKey: 'sepay_authorization_succeeded_choose_bank',
      );
      await loadStatus();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null
            ? 'sepay_complete_authorization_failed'
            : null,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessageKey: 'error_system_retry',
      );
      return false;
    }
  }

  void setSelectedProviderBank(int providerBankId) {
    state = state.copyWith(selectedProviderBankId: providerBankId);
  }

  Future<bool> selectAccount([int? providerBankId]) async {
    final targetId = providerBankId ?? state.selectedProviderBankId;
    if (targetId == null) {
      state = state.copyWith(
        errorMessageKey: 'sepay_select_matching_bank_required',
      );
      return false;
    }

    state = state.copyWith(
      isActionInProgress: true,
      actionType: 'select',
      clearMessages: true,
    );
    try {
      final conn = await ref
          .read(selectClubSepayBankAccountUseCaseProvider)
          .execute(clubId, targetId);

      state = state.copyWith(
        isActionInProgress: false,
        connection: conn,
        successMessageKey: 'sepay_bank_linked_activate_next',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null ? 'sepay_select_bank_failed' : null,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessageKey: 'error_system_retry',
      );
      return false;
    }
  }

  Future<bool> activateConnection() async {
    state = state.copyWith(
      isActionInProgress: true,
      actionType: 'activate',
      clearMessages: true,
    );
    try {
      final conn = await ref
          .read(activateClubSepayConnectionUseCaseProvider)
          .execute(clubId);

      state = state.copyWith(
        isActionInProgress: false,
        connection: conn,
        successMessageKey: 'sepay_activate_connection_succeeded',
      );
      await loadStatus();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null
            ? 'sepay_activate_connection_failed'
            : null,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessageKey: 'error_system_retry',
      );
      return false;
    }
  }

  Future<bool> disconnectConnection({String? connectionId}) async {
    state = state.copyWith(
      isActionInProgress: true,
      actionType: 'disconnect',
      clearMessages: true,
    );
    try {
      final conn = await ref
          .read(disconnectClubSepayConnectionUseCaseProvider)
          .execute(clubId, connectionId: connectionId);

      state = state.copyWith(
        isActionInProgress: false,
        connection: conn,
        successMessageKey: 'sepay_disconnect_requested',
      );
      await loadStatus();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null ? 'sepay_disconnect_failed' : null,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessageKey: 'error_system_retry',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}
