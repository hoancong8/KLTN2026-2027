// test/explore_recruitments_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/data/dto/session/guest_recruitment_dto.dart';
import 'package:kltn2026_2027/data/mapper/session_mapper.dart';
import 'package:kltn2026_2027/domain/entities/session/guest_recruitment.dart';
import 'package:kltn2026_2027/ui/screen/club/session_vm/explore_recruitments_state.dart';
import 'package:kltn2026_2027/ui/screen/club/session_vm/explore_recruitments_vm.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/explore/explore_recruitments_page.dart';

class FakeExploreRecruitmentsNotifier extends StateNotifier<ExploreRecruitmentsState>
    implements ExploreRecruitmentsViewModel {
  FakeExploreRecruitmentsNotifier(
    List<GuestRecruitment> items, {
    Set<String> joinedSessionIds = const {},
    Set<String> myClubNames = const {},
  }) : super(ExploreRecruitmentsState(
          isLoading: false,
          recruitments: items,
          radiusKm: 10.0,
          joinedSessionIds: joinedSessionIds,
          myClubNames: myClubNames,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> explore() async {}
}

void main() {
  testWidgets('ExploreRecruitmentsPage on exact emulator specs (1280x2856 @ 3.0 = 426.7x952)', (tester) async {
    tester.view.physicalSize = const Size(1280, 2856);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rawJson1 = {
      "id": "1bff2e72-5a67-4a87-a5ca-a4e815034de4",
      "sessionId": "6cd685b3-a2b2-4ebd-aade-7c2fd56f986a",
      "clubName": "CLB Cau Long Tia Chop",
      "courtLocation": "Sân Cầu Lông Kỳ Hòa, Quận 10",
      "startTime": "2026-10-27T08:00:00.780372Z",
      "endTime": "2026-10-27T10:00:00.78085Z",
      "slotsNeeded": 12,
      "slotsRemaining": 12,
      "minSkillLevel": "TB",
      "sharedCost": 25000.00,
      "scanRadiusKm": 5.00,
      "status": "ACTIVE",
      "broadcastAt": "2026-10-26T07:02:57.824564Z",
      "distanceKm": 3
    };

    final rawJson2 = {
      "id": "c6ead7b8-021a-4ab5-9301-c0b86b951fb5",
      "sessionId": "93a2d494-0d31-4ea3-81f4-46dd7bf16afc",
      "clubName": "CLB Cầu Lông Legends Quận 7",
      "courtLocation": "San Ky Hoa Q10",
      "startTime": "2026-10-28T14:00:00Z",
      "endTime": "2026-10-28T17:00:00Z",
      "slotsNeeded": 2,
      "slotsRemaining": 1,
      "minSkillLevel": "TB",
      "sharedCost": 50000.00,
      "scanRadiusKm": 10.00,
      "status": "ACTIVE",
      "broadcastAt": "2026-10-26T06:43:56.969142Z",
      "distanceKm": 5
    };

    final item1 = SessionMapper.toRecruitmentEntity(GuestRecruitmentDto.fromJson(rawJson1));
    final item2 = SessionMapper.toRecruitmentEntity(GuestRecruitmentDto.fromJson(rawJson2));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exploreRecruitmentsViewModelProvider.overrideWith(
            (ref) => FakeExploreRecruitmentsNotifier([item1, item2]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('vi')],
          home: const Scaffold(
            body: ExploreRecruitmentsPage(isEmbedded: true),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('2 kèo khả dụng'), findsOneWidget);
    expect(find.text('CLB Cau Long Tia Chop'), findsOneWidget);
    expect(find.text('CLB Cầu Lông Legends Quận 7'), findsOneWidget);
  });


  testWidgets('Renders Da tham gia and CLB cua ban when joined or belonging to user club', (tester) async {
    tester.view.physicalSize = const Size(1280, 2856);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final rawJson1 = {
      'id': '1bff2e72-5a67-4a87-a5ca-a4e815034de4',
      'sessionId': '6cd685b3-a2b2-4ebd-aade-7c2fd56f986a',
      'clubName': 'CLB Cau Long Tia Chop',
      'courtLocation': 'Sân Cầu Lông Kỳ Hòa, Quận 10',
      'startTime': '2026-10-27T08:00:00.780372Z',
      'endTime': '2026-10-27T10:00:00.78085Z',
      'slotsNeeded': 12,
      'slotsRemaining': 12,
      'minSkillLevel': 'TB',
      'sharedCost': 25000.00,
      'scanRadiusKm': 5.00,
      'status': 'ACTIVE',
      'broadcastAt': '2026-10-26T07:02:57.824564Z',
      'distanceKm': 3
    };

    final rawJson2 = {
      'id': 'c6ead7b8-021a-4ab5-9301-c0b86b951fb5',
      'sessionId': '93a2d494-0d31-4ea3-81f4-46dd7bf16afc',
      'clubName': 'CLB Cầu Lông Legends Quận 7',
      'courtLocation': 'San Ky Hoa Q10',
      'startTime': '2026-10-28T14:00:00Z',
      'endTime': '2026-10-28T17:00:00Z',
      'slotsNeeded': 2,
      'slotsRemaining': 1,
      'minSkillLevel': 'TB',
      'sharedCost': 50000.00,
      'scanRadiusKm': 10.00,
      'status': 'ACTIVE',
      'broadcastAt': '2026-10-26T06:43:56.969142Z',
      'distanceKm': 5
    };

    final item1 = SessionMapper.toRecruitmentEntity(GuestRecruitmentDto.fromJson(rawJson1));
    final item2 = SessionMapper.toRecruitmentEntity(GuestRecruitmentDto.fromJson(rawJson2));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exploreRecruitmentsViewModelProvider.overrideWith(
            (ref) => FakeExploreRecruitmentsNotifier(
              [item1, item2],
              joinedSessionIds: {'6cd685b3-a2b2-4ebd-aade-7c2fd56f986a'},
              myClubNames: {'clb cầu lông legends quận 7'},
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('vi')],
          home: const Scaffold(
            body: ExploreRecruitmentsPage(isEmbedded: true),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Đã tham gia'), findsOneWidget);
    expect(find.text('CLB của bạn'), findsOneWidget);
    expect(find.text('Tham gia ngay'), findsNothing);
  });
}
