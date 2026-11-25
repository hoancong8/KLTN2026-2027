import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/remote/abstract/ledger_remote_datasource.dart';
import '../../data/datasource/remote/implement/ledger_remote_datasource_impl.dart';
import '../../data/repositories/ledger_repository_impl.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../../domain/usecases/ledger/ledger_usecases.dart';
import '../services/realtime_hub_service.dart';
import '../provider.dart';

final _ledgerRemoteProvider = Provider<LedgerRemoteDatasource>(
  (ref) => LedgerRemoteDatasourceImpl(ref.watch(dioProvider)),
);

final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => LedgerRepositoryImpl(ref.watch(_ledgerRemoteProvider)),
);

final getLedgerOverviewUseCaseProvider = Provider(
  (ref) => GetLedgerOverviewUseCase(ref.watch(ledgerRepositoryProvider)),
);

final listLedgerTransactionsUseCaseProvider = Provider(
  (ref) => ListLedgerTransactionsUseCase(ref.watch(ledgerRepositoryProvider)),
);

final listLedgerDebtsUseCaseProvider = Provider(
  (ref) => ListLedgerDebtsUseCase(ref.watch(ledgerRepositoryProvider)),
);

final listLedgerCandidatesUseCaseProvider = Provider(
  (ref) => ListLedgerCandidatesUseCase(ref.watch(ledgerRepositoryProvider)),
);

final downloadLedgerInvoiceUseCaseProvider = Provider(
  (ref) => DownloadLedgerInvoiceUseCase(ref.watch(ledgerRepositoryProvider)),
);

final issueLedgerContributionUseCaseProvider = Provider(
  (ref) => IssueLedgerContributionUseCase(ref.watch(ledgerRepositoryProvider)),
);

final collectLedgerContributionUseCaseProvider = Provider(
  (ref) =>
      CollectLedgerContributionUseCase(ref.watch(ledgerRepositoryProvider)),
);

final createLedgerExpenseUseCaseProvider = Provider(
  (ref) => CreateLedgerExpenseUseCase(ref.watch(ledgerRepositoryProvider)),
);

final ledgerUpdateProvider =
    StreamProvider.autoDispose<({String clubId, String eventId})>(
      (ref) {
        final controller = StreamController<({String clubId, String eventId})>();

        final fcmSub = FirebaseMessaging.onMessage
            .map((message) => message.data)
            .where(
              (data) =>
                  data['groupId'] is String &&
                  data['eventId'] is String &&
                  data['ledgerId'] is String,
            )
            .listen((data) {
              controller.add((
                clubId: data['groupId'] as String,
                eventId: data['eventId'] as String,
              ));
            });

        final hub = RealtimeHubService.instance;
        hub.start();
        final hubSub = hub.onLedgerUpdated.listen((data) {
          final groupId = (data['groupId'] ?? data['GroupId'])?.toString();
          final eventId = (data['eventId'] ?? data['EventId'])?.toString();
          if (groupId != null && eventId != null) {
            controller.add((clubId: groupId, eventId: eventId));
          }
        });

        ref.onDispose(() {
          fcmSub.cancel();
          hubSub.cancel();
          controller.close();
        });

        return controller.stream;
      },
    );
