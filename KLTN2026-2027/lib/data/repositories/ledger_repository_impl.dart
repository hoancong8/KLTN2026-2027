import 'dart:convert';

import '../../domain/entities/ledger/ledger.dart';
import '../../domain/exceptions/app_exception.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasource/remote/abstract/ledger_remote_datasource.dart';
import '../mapper/ledger_mapper.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  final LedgerRemoteDatasource _remote;
  LedgerRepositoryImpl(this._remote);

  Map<String, Object?> _dates(LedgerDates dates) => {
    if (dates.from case final from?) 'fromUtc': from.toUtc().toIso8601String(),
    if (dates.to case final to?) 'toUtc': to.toUtc().toIso8601String(),
  };

  Future<T> _map<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FormatException {
      throw const InvalidResponseException();
    }
  }

  @override
  Future<LedgerOverview> overview(String clubId, LedgerDates dates) => _map(
    () async => (await _remote.get(clubId, query: _dates(dates))).toOverview(),
  );

  @override
  Future<LedgerPage<LedgerTransaction>> transactions(
    String clubId,
    LedgerFilter filter,
    int page,
  ) => _map(() async {
    final dto = await _remote.get(
      clubId,
      suffix: '/transactions',
      query: {
        ..._dates(filter.dates),
        'page': page,
        if (filter.onlyMine) 'onlyMine': true,
        if (filter.direction case final direction?)
          'type': ledgerDirection(direction),
        if (filter.category case final category?)
          'category': ledgerCategories[category],
        'contributionMonth': ?filter.month,
      },
    );
    return dto.toPage((item) => item.toTransaction());
  });

  @override
  Future<LedgerPage<LedgerDebt>> debts(
    String clubId,
    LedgerFilter filter,
    int page,
  ) => _map(() async {
    final dto = await _remote.get(
      clubId,
      suffix: '/debts',
      query: {
        ..._dates(filter.dates),
        'page': page,
        if (filter.onlyMine) 'onlyMine': true,
        if (filter.debtType case final type?) 'debtType': ledgerDebtType(type),
        if (filter.month != null &&
            filter.debtType != LedgerDebtType.sessionFee)
          'contributionMonth': filter.month,
      },
    );
    return dto.toPage((item) => item.toDebt());
  });

  @override
  Future<LedgerPage<LedgerCandidate>> candidates(
    String clubId,
    String month,
    String search,
    int page,
  ) => _map(() async {
    final dto = await _remote.get(
      clubId,
      suffix: '/monthly-contributions/candidates',
      query: {
        'contributionMonth': month,
        'page': page,
        if (search.isNotEmpty) 'search': search,
      },
    );
    return dto.toPage((item) => item.toCandidate());
  });

  @override
  Future<LedgerInvoice> invoice(String clubId, String ledgerId) =>
      _remote.invoice(clubId, ledgerId);

  @override
  Future<void> issue(String clubId, String userId, String month) =>
      _remote.post(clubId, '/monthly-contributions', {
        'userId': userId,
        'contributionMonth': month,
      });

  @override
  Future<void> collect(
    String clubId,
    String contributionId,
    String requestId,
    LedgerMoney amount,
  ) => _remote.post(
    clubId,
    '/monthly-contributions/$contributionId/collect',
    '{"requestId":${jsonEncode(requestId)},"expectedAmount":${amount.decimal}}',
  );

  @override
  Future<void> expense(String clubId, LedgerExpense expense) =>
      _remote.expense(clubId, expense);
}
