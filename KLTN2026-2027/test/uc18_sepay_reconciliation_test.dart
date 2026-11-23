import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/data/dto/reconciliation/reconciliation_dto.dart';
import 'package:kltn2026_2027/data/dto/sepay/sepay_dto.dart';
import 'package:kltn2026_2027/data/mapper/reconciliation_mapper.dart';
import 'package:kltn2026_2027/data/mapper/sepay_mapper.dart';
import 'package:kltn2026_2027/domain/entities/reconciliation/reconciliation_transaction.dart';
import 'package:kltn2026_2027/domain/entities/sepay/sepay_connection.dart';
import 'package:kltn2026_2027/domain/entities/sepay/sepay_provider_account.dart';
import 'package:kltn2026_2027/domain/entities/session/session_settlement.dart';
import 'package:kltn2026_2027/domain/repositories/sepay_repository.dart';
import 'package:kltn2026_2027/ui/screen/club/sepay_connection/club_sepay_state.dart';
import 'package:kltn2026_2027/ui/screen/club/sepay_connection/club_sepay_vm.dart';

class _SepayConnectionRepository implements SepayRepository {
  _SepayConnectionRepository({this.failActivationOnce = false});

  final bool failActivationOnce;
  final calls = <String>[];
  SepayConnection _connection = current;

  static const current = SepayConnection(
    connectionId: 'current',
    status: 'AUTHORIZED',
    applicationReady: true,
    webhookEnabled: true,
  );
  static const previous = SepayConnection(
    connectionId: 'previous',
    status: 'CONNECTED',
    applicationReady: true,
    webhookEnabled: true,
  );

  @override
  Future<SepayConnection> getClubSepayConnection(String clubId) async =>
      _connection;

  @override
  Future<List<SepayProviderAccount>> getClubSepayBankAccounts(
    String clubId,
  ) async => const [
    SepayProviderAccount(
      id: 101,
      accountNumber: '00123',
      accountHolder: 'CLB',
      bankBin: '970422',
      gateway: 'MB',
      active: true,
      matchesClubBank: true,
    ),
  ];

  @override
  Future<List<SepayConnection>> listClubSepayConnections(String clubId) async =>
      [_connection, previous];

  @override
  Future<SepayConnection> selectClubSepayBankAccount(
    String clubId,
    int providerBankId,
  ) async {
    calls.add('select:$providerBankId');
    return _connection = _connection.copyWith(status: 'PROVISIONING');
  }

  @override
  Future<SepayConnection> activateClubSepayConnection(String clubId) async {
    calls.add('activate');
    if (failActivationOnce && calls.length == 2) throw StateError('Unavailable');
    return _connection = _connection.copyWith(status: 'CONNECTED');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('current authorization is excluded from other connections', () async {
    final container = ProviderContainer(
      overrides: [
        sepayRepositoryProvider.overrideWithValue(_SepayConnectionRepository()),
      ],
    );
    addTearDown(container.dispose);
    final loaded = Completer<ClubSepayState>();
    container.listen(clubSepayViewModelProvider('club'), (_, state) {
      if (!state.isLoading && !loaded.isCompleted) loaded.complete(state);
    });

    final state = await loaded.future;
    expect(state.connection, _SepayConnectionRepository.current);
    expect(state.oldConnections, [_SepayConnectionRepository.previous]);
  });

  test('one confirmation selects the bank and activates SePay', () async {
    final repository = _SepayConnectionRepository();
    final container = ProviderContainer(
      overrides: [sepayRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final provider = clubSepayViewModelProvider('club');
    final loaded = Completer<void>();
    container.listen(provider, (_, state) {
      if (!state.isLoading && !loaded.isCompleted) loaded.complete();
    });
    await loaded.future;

    final viewModel = container.read(provider.notifier);
    final connecting = viewModel.connectSelectedAccount();
    expect(await viewModel.connectSelectedAccount(), isFalse);
    expect(await connecting, isTrue);
    expect(repository.calls, ['select:101', 'activate']);
    expect(container.read(provider).connection?.isConnected, isTrue);
  });

  test('an activation retry uses the already selected account', () async {
    final repository = _SepayConnectionRepository(failActivationOnce: true);
    final container = ProviderContainer(
      overrides: [sepayRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final provider = clubSepayViewModelProvider('club');
    final loaded = Completer<void>();
    container.listen(provider, (_, state) {
      if (!state.isLoading && !loaded.isCompleted) loaded.complete();
    });
    await loaded.future;

    final viewModel = container.read(provider.notifier);
    expect(await viewModel.connectSelectedAccount(), isFalse);
    expect(container.read(provider).connection?.isProvisioning, isTrue);
    expect(
      container.read(provider).errorMessageKey,
      'sepay_activate_connection_failed',
    );

    expect(await viewModel.connectSelectedAccount(), isTrue);
    expect(repository.calls, ['select:101', 'activate', 'activate']);
    expect(container.read(provider).connection?.isConnected, isTrue);
  });

  group('UC18 - SePay Application DTO & Entity Mapping', () {
    test('parses SepayApplicationDto and maps to entity correctly', () {
      final json = {
        'clientId': 'test_client_id_123',
        'hasClientSecret': true,
        'callbackUrl': 'https://badminton.local/callback',
        'publicApiBaseUrl': 'https://api.badminton.local',
        'frontendBaseUrl': 'https://badminton.local',
        'enabled': true,
        'revision': 'rev-5',
        'webhookEnabled': true,
      };

      final dto = SepayApplicationDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.clientId, 'test_client_id_123');
      expect(entity.hasClientSecret, true);
      expect(entity.callbackUrl, 'https://badminton.local/callback');
      expect(entity.publicApiBaseUrl, 'https://api.badminton.local');
      expect(entity.frontendBaseUrl, 'https://badminton.local');
      expect(entity.enabled, true);
      expect(entity.revision, 'rev-5');
      expect(entity.webhookEnabled, true);
    });
  });

  group('UC18 - SePay Connection Status Getters', () {
    test('verifies connection status transitions correctly', () {
      const connConnected = SepayConnection(
        connectionId: 'c1',
        status: 'CONNECTED',
        applicationReady: true,
        webhookEnabled: true,
      );
      expect(connConnected.isConnected, true);
      expect(connConnected.isAuthorized, false);
      expect(connConnected.isDisconnected, false);

      const connAuthorized = SepayConnection(
        connectionId: 'c2',
        status: 'AUTHORIZED',
        applicationReady: true,
        webhookEnabled: false,
      );
      expect(connAuthorized.isAuthorized, true);
      expect(connAuthorized.isConnected, false);

      const connBankRequired = SepayConnection(
        connectionId: 'c3',
        status: 'BANK_REQUIRED',
        applicationReady: false,
        webhookEnabled: false,
      );
      expect(connBankRequired.isBankRequired, true);

      const connProvisioning = SepayConnection(
        connectionId: 'c4',
        status: 'PROVISIONING',
        applicationReady: true,
        webhookEnabled: false,
      );
      expect(connProvisioning.isProvisioning, true);

      const connDisconnecting = SepayConnection(
        connectionId: 'c5',
        status: 'DISCONNECTING',
        applicationReady: true,
        webhookEnabled: false,
      );
      expect(connDisconnecting.isDisconnecting, true);
    });
  });

  group('UC18 - SePay Provider Account Eligibility', () {
    test('isEligibleToSelect is true only if active and matches club bank', () {
      const accountEligible = SepayProviderAccount(
        id: 101,
        accountNumber: '0987654321',
        accountHolder: 'NGUYEN VAN HO',
        bankBin: '970422',
        gateway: 'MB',
        active: true,
        matchesClubBank: true,
      );
      expect(accountEligible.isEligibleToSelect, true);

      const accountInactive = SepayProviderAccount(
        id: 102,
        accountNumber: '0987654321',
        accountHolder: 'NGUYEN VAN HO',
        bankBin: '970422',
        gateway: 'MB',
        active: false,
        matchesClubBank: true,
      );
      expect(accountInactive.isEligibleToSelect, false);

      const accountNotMatching = SepayProviderAccount(
        id: 103,
        accountNumber: '1111111111',
        accountHolder: 'NGUYEN VAN HO',
        bankBin: '970407',
        gateway: 'TCB',
        active: true,
        matchesClubBank: false,
      );
      expect(accountNotMatching.isEligibleToSelect, false);
    });
  });

  group('UC18 - Reconciliation Status and Transaction Mapping', () {
    test('parses ReconciliationTransactionDto and maps status correctly', () {
      final json = {
        'transactionId': 'tx-001',
        'amountReceived': 55000,
        'transactionTime': '2026-11-18T10:30:00.000Z',
        'referenceCode': 'SEPAY123456',
        'transferContent': 'CLB AN 55K CHUYEN KHOAN',
        'status': 'MANUAL_CHECK',
        'reasonCode': 'NO_MATCHING_FEE',
        'feeId': null,
        'reconciledBy': null,
        'reconciledAt': null,
      };

      final dto = ReconciliationTransactionDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.transactionId, 'tx-001');
      expect(entity.amountReceived, 55000);
      expect(entity.isManualCheck, true);
      expect(entity.isMatched, false);
      expect(entity.feeId, isNull);
    });

    test('isMatched is true when status is MATCHED', () {
      final tx = ReconciliationTransaction(
        transactionId: 'tx-002',
        amountReceived: 60000,
        transactionTime: DateTime.now(),
        referenceCode: 'SEPAY999',
        transferContent: 'THANH TOAN',
        status: 'MATCHED',
        reasonCode: null,
        feeId: 'fee-123',
        reconciledBy: 'admin-id',
        reconciledAt: null,
      );

      expect(tx.isMatched, true);
      expect(tx.isManualCheck, false);
      expect(tx.feeId, 'fee-123');
    });
  });

  group('UC18 & UC16 - Candidate Fee Filtering and Cash Eligibility', () {
    const fee1 = MemberSettlementFee(
      feeId: 'f1',
      userId: 'u1',
      fullName: 'Nguyễn Văn A',
      roleName: 'Hội viên',
      gender: 'MALE',
      baseFee: 55000,
      discount: 0,
      finalFee: 55000,
      paymentStatus: 'UNPAID',
      paymentMethod: 'BANK_TRANSFER',
      vietQrUrl: 'https://qr.test/1',
      paymentCode: 'CODE1',
    );

    const fee2 = MemberSettlementFee(
      feeId: 'f2',
      userId: 'u2',
      fullName: 'Trần Thị B',
      roleName: 'Vãng lai',
      gender: 'FEMALE',
      baseFee: 70000,
      discount: 0,
      finalFee: 70000,
      paymentStatus: 'UNPAID',
      paymentMethod: 'CASH',
      vietQrUrl: '',
      paymentCode: 'CODE2',
    );

    const fee3Paid = MemberSettlementFee(
      feeId: 'f3',
      userId: 'u3',
      fullName: 'Lê Văn C',
      roleName: 'Hội viên',
      gender: 'MALE',
      baseFee: 55000,
      discount: 0,
      finalFee: 55000,
      paymentStatus: 'PAID',
      paymentMethod: 'BANK_TRANSFER',
      vietQrUrl: 'https://qr.test/3',
      paymentCode: 'CODE3',
    );

    test('isCashEligible is only true for UNPAID with CASH or null method', () {
      expect(fee1.isCashEligible, false);
      expect(fee2.isCashEligible, true);
      expect(fee3Paid.isCashEligible, false);
    });

    test('manual reconciliation candidate filter requires exact amount match, UNPAID, and not CASH', () {
      final allFees = [fee1, fee2, fee3Paid];
      const targetAmount = 55000;

      final candidates = allFees.where((f) {
        final isUnpaid = !f.isPaid && !f.isExempt;
        final amountMatches = f.finalFee == targetAmount;
        final isNotCash = f.paymentMethod != 'CASH';
        return isUnpaid && amountMatches && isNotCash;
      }).toList();

      expect(candidates.length, 1);
      expect(candidates.first.feeId, 'f1');
      expect(candidates.first.fullName, 'Nguyễn Văn A');
    });
  });
}
