import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/provider/ledger_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/data/datasource/remote/implement/ledger_remote_datasource_impl.dart';
import 'package:kltn2026_2027/data/repositories/ledger_repository_impl.dart';
import 'package:kltn2026_2027/domain/entities/ledger/ledger.dart';
import 'package:kltn2026_2027/domain/entities/auth_token.dart';
import 'package:kltn2026_2027/domain/entities/club/active_club_context.dart';
import 'package:kltn2026_2027/domain/enums/club_role.dart';
import 'package:kltn2026_2027/domain/exceptions/ledger_exception.dart';
import 'package:kltn2026_2027/ui/screen/club/ledger/club_ledger_screen.dart';
import 'package:kltn2026_2027/ui/screen/club/ledger/club_ledger_vm.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/club/widgets/club_ledger_tab.dart';

void main() {
  late Dio dio;
  late LedgerRepositoryImpl repository;

  setUp(() {
    dio = Dio();
    repository = LedgerRepositoryImpl(LedgerRemoteDatasourceImpl(dio));
  });
  tearDown(() => dio.close());

  testWidgets('ledger reloads when the user returns to the previous club', (tester) async {
    var overviewCalls = 0;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final overview = options.path.endsWith('/ledger');
      if (overview) overviewCalls++;
      handler.resolve(Response<String>(
        requestOptions: options,
        statusCode: 200,
        data: overview
            ? '{"availableBalance":100,"totalInflow":100,"totalOutflow":0,"sessionDebtTotal":0,"monthlyDebtTotal":0,"debtTotal":0,"asOfUtc":"2026-11-23T00:00:00Z","capabilities":{"canView":true,"canManage":false,"canWrite":false}}'
            : '{"items":[],"total":0,"page":1,"pageSize":20}',
      ));
    }));
    const clubA = ActiveClubContext(
      clubId: 'club-a', clubName: 'A', role: ClubRole.host,
      permissions: [ClubPermissions.ledgerView],
    );
    const clubB = ActiveClubContext(
      clubId: 'club-b', clubName: 'B', role: ClubRole.member,
      permissions: [],
    );
    final container = ProviderContainer(overrides: [
      ledgerRepositoryProvider.overrideWithValue(repository),
      ledgerUpdateProvider.overrideWith((ref) => const Stream.empty()),
      authTokenProvider.overrideWith((ref) => AuthToken(
        accessToken: 'token', refreshToken: 'refresh', userId: 'member-a',
      )),
      activeClubContextProvider.overrideWith((ref) => clubA),
    ]);
    addTearDown(container.dispose);
    const scope = (clubId: 'club-a', userId: 'member-a');
    final provider = clubLedgerViewModelProvider(scope);
    final subscription = container.listen(provider, (_, _) {}, fireImmediately: true);
    addTearDown(subscription.close);
    await tester.pumpAndSettle();
    expect(container.read(provider).overview, isNotNull);
    expect(overviewCalls, 1);

    container.read(activeClubContextProvider.notifier).state = clubB;
    await tester.pump();
    expect(container.read(provider).accessRevoked, isTrue);
    expect(container.read(provider).overview, isNull);

    container.read(activeClubContextProvider.notifier).state = clubA;
    await tester.pumpAndSettle();
    expect(container.read(provider).accessRevoked, isFalse);
    expect(container.read(provider).overview, isNotNull);
    expect(overviewCalls, 2);
  });

  for (final tablet in [false, true]) {
    testWidgets(
      'renders the read-only ledger on ${tablet ? 'tablet' : 'phone'}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(tablet ? 1100 : 390, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final isOverview = options.path.endsWith('/ledger');
              handler.resolve(
                Response<String>(
                  requestOptions: options,
                  statusCode: 200,
                  data: isOverview
                      ? '''{
            "availableBalance": 1020.25,
            "totalInflow": 1020.25,
            "totalOutflow": 0, "sessionDebtTotal": 0, "monthlyDebtTotal": 0, "debtTotal": 0,
            "asOfUtc": "2026-11-22T03:00:00Z",
            "capabilities": {"canView": true, "canManage": false, "canWrite": false}
          }'''
                      : '{"items":[],"total":0,"page":1,"pageSize":20}',
                ),
              );
            },
          ),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ledgerRepositoryProvider.overrideWithValue(repository),
              ledgerUpdateProvider.overrideWith((ref) => const Stream.empty()),
              authTokenProvider.overrideWith(
                (ref) => AuthToken(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  userId: 'member-a',
                ),
              ),
              activeClubContextProvider.overrideWith(
                (ref) => const ActiveClubContext(
                  clubId: 'club-a',
                  clubName: 'Club',
                  role: ClubRole.member,
                  permissions: [ClubPermissions.ledgerView],
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: tablet
                  ? const Scaffold(body: ClubLedgerTab(clubId: 'club-a'))
                  : const ClubLedgerScreen(clubId: 'club-a'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('1,020.25 ₫'), findsWidgets);
        expect(find.byTooltip('My contributions'), findsOneWidget);
        expect(find.text('Record expense'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  void jsonReply(String body) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<String>(
            requestOptions: options,
            data: body,
            statusCode: 200,
          ),
        ),
      ),
    );
  }

  test(
    'preserves exact cent values in ledger reads and collection requests',
    () async {
      RequestOptions? request;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            request = options;
            handler.next(options);
          },
        ),
      );
      jsonReply('''{
      "availableBalance": 9999999999999999.99,
      "totalInflow": 9999999999999999.99,
      "totalOutflow": 0, "sessionDebtTotal": 0, "monthlyDebtTotal": 0, "debtTotal": 0,
      "asOfUtc": "2026-11-22T03:00:00Z",
      "capabilities": {"canView": true, "canManage": true, "canWrite": true},
      "status": "PAID"
    }''');
      final overview = await repository.overview('club-a', (
        from: null,
        to: null,
      ));
      expect(overview.balance.decimal, '9999999999999999.99');
      await repository.collect(
        'club-a',
        'contribution-a',
        'request-a',
        overview.balance,
      );
      expect(
        request?.path,
        endsWith('/monthly-contributions/contribution-a/collect'),
      );
      expect(
        request?.data,
        '{"requestId":"request-a","expectedAmount":9999999999999999.99}',
      );
    },
  );

  test(
    'filters session debt without sending a monthly contribution period',
    () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.queryParameters, {
              'page': 2,
              'onlyMine': true,
              'debtType': 'SESSION_FEE',
            });
            expect(options.path, '/api/v1/clubs/club-a/ledger/debts');
            handler.next(options);
          },
        ),
      );
      jsonReply('{"items":[],"total":20,"page":2,"pageSize":20}');
      final page = await repository.debts(
        'club-a',
        const LedgerFilter(
          onlyMine: true,
          debtType: LedgerDebtType.sessionFee,
          month: '2026-11-01',
        ),
        2,
      );
      expect(page.page, 2);
      expect(page.total, 20);
    },
  );

  test(
    'same expense retry rebuilds the invoice body with the original key',
    () async {
      final forms = <FormData>[];
      final payloads = <String>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final form = options.data as FormData;
            forms.add(form);
            payloads.add(latin1.decode(await form.readAsBytes()));
            if (forms.length == 1) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.receiveTimeout,
                ),
              );
            } else {
              handler.resolve(
                Response<String>(
                  requestOptions: options,
                  data: '{"status":"RECORDED"}',
                  statusCode: 200,
                ),
              );
            }
          },
        ),
      );
      final expense = (
        requestId: 'same-key',
        amount: LedgerMoney.tryParse('15000.25')!,
        category: LedgerCategory.courtRent,
        description: 'Court',
        sessionId: 'session-a',
        invoice: (
          name: 'invoice.pdf',
          mimeType: 'application/pdf',
          bytes: Uint8List.fromList(ascii.encode('%PDF-1.4')),
        ),
      );
      await expectLater(
        repository.expense('club-a', expense),
        throwsA(
          isA<LedgerException>().having(
            (error) => error.isUncertain,
            'isUncertain',
            true,
          ),
        ),
      );
      await repository.expense('club-a', expense);
      expect(forms[0], isNot(same(forms[1])));
      for (final body in payloads) {
        expect(body, contains('same-key'));
        expect(body, contains('15000.25'));
        expect(body, contains('invoice.pdf'));
        expect(body, contains('%PDF-1.4'));
      }
    },
  );

  test('Vietnamese contribution month rolls over before UTC month', () {
    expect(ledgerVietnameseMonth(DateTime.utc(2026, 11, 30, 17)), '2026-12-01');
  });
}
