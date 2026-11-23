import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/consts/permissions.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/ledger_provider.dart';
import '../../../../domain/entities/ledger/ledger.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/exceptions/ledger_exception.dart';

typedef LedgerContext = ({String clubId, String userId});

final clubLedgerViewModelProvider = StateNotifierProvider.autoDispose
    .family<ClubLedgerViewModel, ClubLedgerState, LedgerContext>((ref, scope) {
      final vm = ClubLedgerViewModel(ref, scope);
      ref.listen(ledgerUpdateProvider, (_, update) {
        final event = update.value;
        if (event != null && event.clubId == scope.clubId) {
          vm.onUpdated(event.eventId);
        }
      });
      ref.listen(activeClubContextProvider, (_, _) => vm.checkContext());
      ref.listen(authTokenProvider, (_, _) => vm.checkContext());
      return vm;
    });

@immutable
class LedgerListState<T> {
  final List<T> items;
  final int page;
  final int total;
  final bool loading;
  final AppException? error;

  const LedgerListState({
    this.items = const [],
    this.page = 0,
    this.total = 0,
    this.loading = false,
    this.error,
  });

  bool get hasMore => items.length < total;
}

@immutable
class ClubLedgerState {
  final LedgerOverview? overview;
  final AppException? error;
  final bool loading;
  final LedgerFilter filter;
  final LedgerListState<LedgerTransaction> transactions;
  final LedgerListState<LedgerDebt> debts;
  final LedgerListState<LedgerCandidate> candidates;
  final bool writing;
  final bool canRetryWrite;
  final bool accessRevoked;

  const ClubLedgerState({
    this.overview,
    this.error,
    this.loading = false,
    this.filter = const LedgerFilter(),
    this.transactions = const LedgerListState(),
    this.debts = const LedgerListState(),
    this.candidates = const LedgerListState(),
    this.writing = false,
    this.canRetryWrite = false,
    this.accessRevoked = false,
  });

  ClubLedgerState copyWith({
    LedgerOverview? overview,
    AppException? error,
    bool clearError = false,
    bool? loading,
    LedgerFilter? filter,
    LedgerListState<LedgerTransaction>? transactions,
    LedgerListState<LedgerDebt>? debts,
    LedgerListState<LedgerCandidate>? candidates,
    bool? writing,
    bool? canRetryWrite,
  }) => ClubLedgerState(
    overview: overview ?? this.overview,
    error: clearError ? null : error ?? this.error,
    loading: loading ?? this.loading,
    filter: filter ?? this.filter,
    transactions: transactions ?? this.transactions,
    debts: debts ?? this.debts,
    candidates: candidates ?? this.candidates,
    writing: writing ?? this.writing,
    canRetryWrite: canRetryWrite ?? this.canRetryWrite,
    accessRevoked: accessRevoked,
  );
}

class ClubLedgerViewModel extends StateNotifier<ClubLedgerState> {
  final Ref _ref;
  final LedgerContext _scope;
  final _requests = <String, Object>{};
  final _recentEvents = <String>{};
  String? _candidateMonth;
  String _search = '';
  Future<void> Function()? _pendingWrite;
  void Function()? _releaseWriteLifetime;
  bool _contextSuspended = false;

  ClubLedgerViewModel(this._ref, this._scope) : super(const ClubLedgerState()) {
    unawaited(refresh());
  }

  bool _hasContextPermission(String permission) {
    if (!mounted) return false;
    final context = _ref.read(activeClubContextProvider);
    final token = _ref.read(authTokenProvider);
    final actor = token?.userId ?? _ref.read(currentUserProfileProvider)?.id;
    return token != null &&
        actor == _scope.userId &&
        context?.clubId == _scope.clubId &&
        context!.hasPermission(permission);
  }

  bool _allowed(String permission) =>
      !state.accessRevoked && _hasContextPermission(permission);

  bool get _canRead => _allowed(ClubPermissions.ledgerView);
  bool get _canManage =>
      _canRead &&
      _allowed(ClubPermissions.ledgerManage) &&
      state.overview?.canManage == true;

  void _revoke() {
    _requests.clear();
    _pendingWrite = null;
    _releaseWriteLifetime?.call();
    _releaseWriteLifetime = null;
    state = const ClubLedgerState(accessRevoked: true);
  }

  void checkContext() {
    if (!mounted) return;
    if (state.accessRevoked) {
      if (_contextSuspended &&
          _hasContextPermission(ClubPermissions.ledgerView)) {
        _contextSuspended = false;
        state = const ClubLedgerState();
        unawaited(refresh());
      }
      return;
    }
    if (!_canRead) {
      final context = _ref.read(activeClubContextProvider);
      final token = _ref.read(authTokenProvider);
      final actor = token?.userId ?? _ref.read(currentUserProfileProvider)?.id;
      _contextSuspended =
          token != null && actor == _scope.userId && context?.clubId != _scope.clubId;
      _revoke();
    } else if (!_allowed(ClubPermissions.ledgerManage)) {
      _pendingWrite = null;
      _releaseWriteLifetime?.call();
      _releaseWriteLifetime = null;
      _requests.remove('candidates');
      state = state.copyWith(
        candidates: const LedgerListState(),
        canRetryWrite: false,
      );
    }
  }

  void onUpdated(String eventId) {
    if (!_recentEvents.add(eventId)) return;
    if (_recentEvents.length > 64) _recentEvents.remove(_recentEvents.first);
    unawaited(refresh());
  }

  Future<void> refresh() async {
    if (!_canRead) return;
    final request = _requests['overview'] = Object();
    state = state.copyWith(loading: true, clearError: true);
    try {
      final overview = await _ref
          .read(getLedgerOverviewUseCaseProvider)
          .execute(_scope.clubId, state.filter.dates);
      if (!_canRead || _requests['overview'] != request) return;
      if (!overview.canView) {
        _revoke();
        return;
      }
      state = state.copyWith(overview: overview, loading: false);
      if (_candidateMonth != null) {
        _candidateMonth = ledgerVietnameseMonth(DateTime.now());
      }
      await Future.wait([
        loadTransactions(),
        loadDebts(),
        if (_candidateMonth != null && _canManage) _loadCandidates(),
      ]);
    } on AppException catch (error) {
      if (!_canRead || _requests['overview'] != request) return;
      if (error is LedgerException && error.status == 403) {
        _revoke();
      } else if (error is LedgerException && error.code == 'Ledger.Disabled') {
        _requests.clear();
        state = ClubLedgerState(
          error: error,
          filter: state.filter,
          writing: state.writing,
          canRetryWrite: _pendingWrite != null,
        );
      } else {
        state = state.copyWith(loading: false, error: error);
      }
    }
  }

  Future<void> setFilter(LedgerFilter filter) {
    _requests.remove('transactions');
    _requests.remove('debts');
    state = state.copyWith(
      filter: filter,
      transactions: const LedgerListState(),
      debts: const LedgerListState(),
    );
    return refresh();
  }

  Future<void> _loadPage<T>({
    required String key,
    required bool append,
    required LedgerListState<T> current,
    required bool Function() allowed,
    required void Function(LedgerListState<T>) update,
    required Future<LedgerPage<T>> Function(int) fetch,
  }) async {
    if (!allowed() || append && (current.loading || !current.hasMore)) return;
    final request = _requests[key] = Object();
    final page = append ? current.page + 1 : 1;
    update(
      LedgerListState(
        items: current.items,
        page: current.page,
        total: current.total,
        loading: true,
      ),
    );
    try {
      final result = await fetch(page);
      if (!allowed() || _requests[key] != request) return;
      final items = <T>[if (append) ...current.items, ...result.items];
      update(
        LedgerListState(
          items: List.unmodifiable(items),
          total: result.items.isEmpty ? items.length : result.total,
          page: result.page,
        ),
      );
    } on AppException catch (error) {
      if (!allowed() || _requests[key] != request) return;
      if (error is LedgerException && error.status == 403) {
        if (key == 'candidates') {
          update(LedgerListState(error: error));
        } else {
          _revoke();
        }
        return;
      }
      update(
        LedgerListState(
          items: current.items,
          total: current.total,
          page: current.page,
          error: error,
        ),
      );
    }
  }

  Future<void> loadTransactions({bool append = false}) => _loadPage(
    key: 'transactions',
    append: append,
    current: state.transactions,
    allowed: () => _canRead,
    update: (value) => state = state.copyWith(transactions: value),
    fetch: (page) => _ref
        .read(listLedgerTransactionsUseCaseProvider)
        .execute(_scope.clubId, state.filter, page),
  );

  Future<void> loadDebts({bool append = false}) => _loadPage(
    key: 'debts',
    append: append,
    current: state.debts,
    allowed: () => _canRead,
    update: (value) => state = state.copyWith(debts: value),
    fetch: (page) => _ref
        .read(listLedgerDebtsUseCaseProvider)
        .execute(_scope.clubId, state.filter, page),
  );

  Future<void> searchCandidates(String search) {
    _candidateMonth = ledgerVietnameseMonth(DateTime.now());
    _search = search.trim();
    state = state.copyWith(candidates: const LedgerListState());
    return _loadCandidates();
  }

  Future<void> loadMoreCandidates() => _loadCandidates(append: true);

  Future<void> _loadCandidates({bool append = false}) => _loadPage(
    key: 'candidates',
    append: append,
    current: state.candidates,
    allowed: () => _canManage,
    update: (value) => state = state.copyWith(candidates: value),
    fetch: (page) => _ref
        .read(listLedgerCandidatesUseCaseProvider)
        .execute(_scope.clubId, _candidateMonth!, _search, page),
  );

  Future<LedgerInvoice?> invoice(String id) async {
    if (!_canRead) return null;
    try {
      final result = await _ref
          .read(downloadLedgerInvoiceUseCaseProvider)
          .execute(_scope.clubId, id);
      return _canRead ? result : null;
    } on LedgerException catch (error) {
      if (_canRead && error.status == 403) _revoke();
      rethrow;
    }
  }

  Future<AppException?> issue(LedgerCandidate candidate) => _write(
    () => _ref
        .read(issueLedgerContributionUseCaseProvider)
        .execute(_scope.clubId, candidate.userId, candidate.month),
  );

  Future<AppException?> collect(LedgerCandidate candidate) {
    final id = candidate.contributionId;
    final amount = candidate.amount;
    if (id == null || amount == null) {
      return Future.value(const InvalidResponseException());
    }
    final requestId = const Uuid().v4();
    return _write(
      () => _ref
          .read(collectLedgerContributionUseCaseProvider)
          .execute(_scope.clubId, id, requestId, amount),
    );
  }

  Future<AppException?> expense({
    required LedgerMoney amount,
    required LedgerCategory category,
    required String description,
    LedgerInvoice? invoice,
    String? sessionId,
  }) {
    final expense = (
      requestId: const Uuid().v4(),
      amount: amount,
      category: category,
      description: description,
      invoice: invoice,
      sessionId: sessionId,
    );
    return _write(
      () => _ref
          .read(createLedgerExpenseUseCaseProvider)
          .execute(_scope.clubId, expense),
    );
  }

  Future<AppException?> retryWrite() => _write();

  Future<AppException?> _write([Future<void> Function()? newAction]) async {
    if (!_canManage ||
        state.overview?.canWrite != true ||
        state.writing ||
        (newAction != null && _pendingWrite != null)) {
      return const LedgerException(code: 'Ledger.WritesDisabled');
    }
    final action = newAction ?? _pendingWrite;
    if (action == null) return const InvalidResponseException();
    _pendingWrite = action;
    _releaseWriteLifetime ??= _ref.keepAlive().close;
    state = state.copyWith(writing: true);
    AppException? failure;
    try {
      await action();
      _pendingWrite = null;
    } on AppException catch (error) {
      failure = error;
      if (error is! LedgerException || !error.isUncertain) _pendingWrite = null;
    }
    if (!_canRead) return failure;
    await refresh();
    if (_canRead) {
      state = state.copyWith(
        writing: false,
        canRetryWrite: _pendingWrite != null,
      );
    }
    if (_pendingWrite == null) {
      _releaseWriteLifetime?.call();
      _releaseWriteLifetime = null;
    }
    return failure;
  }
}
