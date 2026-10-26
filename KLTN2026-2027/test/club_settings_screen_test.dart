// test/club_settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/entities/club/active_club_context.dart';
import 'package:kltn2026_2027/domain/entities/club/club_detail.dart';
import 'package:kltn2026_2027/domain/entities/user_profile.dart';
import 'package:kltn2026_2027/domain/enums/club_role.dart';
import 'package:kltn2026_2027/domain/enums/session_enums.dart';
import 'package:kltn2026_2027/ui/screen/club/settings/club_settings_screen.dart';
import 'package:kltn2026_2027/ui/screen/club_detail/club_detail_vm/club_detail_state.dart';
import 'package:kltn2026_2027/ui/screen/club_detail/club_detail_vm/club_detail_vm.dart';

class FakeClubDetailNotifier extends StateNotifier<ClubDetailState> implements ClubDetailViewModel {
  FakeClubDetailNotifier(ClubDetail club)
      : super(ClubDetailState(isLoading: false, club: club));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Renders ClubSettingsScreen without errors on mobile and tablet', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const club = ClubDetail(
      id: 'club-1',
      groupName: 'CLB Cầu Lông Chiến Binh',
      code: 'CLB-LEGENDS7',
      description: 'Mô tả CLB',
      avatarUrl: 'https://example.com/avatar.png',
      fixedVenueName: 'Sân Kỳ Hòa',
      fixedAddress: '238 Đường 3/2, Q10',
      lat: 10.77,
      lng: 106.66,
      minSkillLevel: SkillLevel.nb,
      maxSkillLevel: SkillLevel.k,
      qualityScore: 5.0,
      isRecruiting: true,
      memberCount: 20,
      host: ClubHostEntity(
        userId: 'user-host',
        fullName: 'Nguyễn Văn Host',
      ),
      schedules: [
        ClubScheduleEntity(
          id: 'sched-1',
          dayOfWeek: 2,
          dayName: 'Thứ 2',
          startTime: '18:00',
          endTime: '20:00',
          isActive: true,
        ),
      ],
      currentUserStatus: ClubUserStatusEntity(
        isMember: true,
        roleName: 'Host',
        hasPendingJoinRequest: false,
      ),
    );

    const profile = UserProfile(
      id: 'user-host',
      email: 'host@test.com',
      userName: 'nguyenhost',
      isLocked: false,
      roles: ['Admin'],
      permissions: [],
    );

    const context = ActiveClubContext(
      clubId: 'club-1',
      clubName: 'CLB Cầu Lông Chiến Binh',
      role: ClubRole.host,
      roleName: 'Host',
      permissions: ['MEMBER.INFO.UPDATE', 'OPERATIONS.SCHEDULE.MANAGE'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProfileProvider.overrideWith(() => CurrentUserProfileNotifier(profile)),
          activeClubContextProvider.overrideWith((ref) => context),
          clubDetailViewModelProvider('club-1').overrideWith(
            (ref) => FakeClubDetailNotifier(club),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('vi')],
          home: ClubSettingsScreen(clubId: 'club-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Cài Đặt Câu Lạc Bộ'), findsOneWidget);
    // Tap Tab Biểu Phí & Ngân Hàng to view fees
    await tester.tap(find.text('Biểu Phí & Ngân Hàng'));
    await tester.pumpAndSettle();
    expect(find.text('500.000'), findsOneWidget);
    final btn = tester.getRect(find.text('Lưu Thay Đổi Cài Đặt'));
    final form = tester.getRect(find.byType(Form));
    expect(form.height, greaterThan(400));
    expect(btn.bottom, greaterThan(700));
  });

  test('CurrencyThousandsFormatter formats numbers with thousands dot', () {
    const formatter = CurrencyThousandsFormatter();

    final result1 = formatter.formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '10000', selection: TextSelection.collapsed(offset: 5)),
    );
    expect(result1.text, '10.000');
    expect(result1.selection.baseOffset, 6);

    final result2 = formatter.formatEditUpdate(
      const TextEditingValue(text: '10.000'),
      const TextEditingValue(text: '500000', selection: TextSelection.collapsed(offset: 6)),
    );
    expect(result2.text, '500.000');

    final result3 = formatter.formatEditUpdate(
      const TextEditingValue(text: '50.000'),
      const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0)),
    );
    expect(result3.text, '');
  });
}
