// test/session_detail_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/domain/entities/session/session.dart';
import 'package:kltn2026_2027/domain/entities/session/session_booking.dart';
import 'package:kltn2026_2027/domain/entities/session/session_detail.dart';
import 'package:kltn2026_2027/domain/enums/session_enums.dart';
import 'package:kltn2026_2027/ui/screen/club/session_detail_screen.dart';
import 'package:kltn2026_2027/ui/screen/club/session_vm/session_detail_state.dart';
import 'package:kltn2026_2027/ui/screen/club/session_vm/session_detail_vm.dart';

class FakeSessionDetailNotifier extends StateNotifier<SessionDetailState> implements SessionDetailViewModel {
  @override
  final String sessionId;

  FakeSessionDetailNotifier(this.sessionId, SessionDetail initialDetail)
      : super(SessionDetailState(isLoading: false, detail: initialDetail));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> loadDetail() async {}
}

void main() {
  testWidgets('Renders SessionDetailScreen without errors on desktop and mobile', (tester) async {
    tester.view.physicalSize = const Size(1024, 496);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final session = Session(
      id: 'session-1',
      groupId: 'club-1',
      clubName: 'CLB Cầu Lông Chiến Binh Quận 10',
      title: 'Buổi sinh hoạt Thứ 2 (19:00 - 22:00)',
      startTime: DateTime(2026, 10, 29, 19, 0),
      endTime: DateTime(2026, 10, 29, 22, 0),
      courtLocation: 'Sân Cầu Lông Kỳ Hòa, 238 Đường 3/2, Phường 12, Quận 10, TP.HCM',
      courtCount: 2,
      targetPlayerPerCourt: 6,
      maxPlayers: 12,
      deadlineBooking: DateTime(2026, 10, 29, 17, 0),
      courtRentalCost: 300000,
      status: SessionStatus.open,
      confirmedCount: 1,
      waitingCount: 0,
      isBookedByCurrentUser: false,
      currentUserBookingStatus: null,
      currentUserQueueOrder: 0,
    );

    final detail = SessionDetail(
      session: session,
      confirmedPlayers: [
        SessionBooking(
          bookingId: 'b-1',
          sessionId: 'session-1',
          userId: 'user-me',
          fullName: 'Nguyễn Văn A',
          skillLevel: 'TB',
          status: BookingStatus.confirmed,
          queueOrder: 0,
          bookedAt: DateTime(2026, 10, 25, 10, 0),
        ),
      ],
      waitingQueue: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionDetailViewModelProvider('session-1').overrideWith(
            (ref) => FakeSessionDetailNotifier('session-1', detail),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('vi'),
          home: SessionDetailScreen(sessionId: 'session-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Buổi sinh hoạt Thứ 2 (19:00 - 22:00)'), findsWidgets);
    expect(find.text('Đăng Ký Tham Gia'), findsOneWidget);
    expect(tester.getRect(find.byType(AppBar)).bottom, 56.0);
    expect(tester.getRect(find.byType(NestedScrollView)).height, greaterThan(200.0));
    expect(tester.getRect(find.text('Đăng Ký Tham Gia')).top, greaterThan(400.0));
  });

  testWidgets('Renders SessionDetailScreen with cancel confirmation button when booked', (tester) async {
    tester.view.physicalSize = const Size(1024, 496);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final session = Session(
      id: 'session-2',
      groupId: 'club-1',
      clubName: 'CLB Cầu Lông Chiến Binh Quận 10',
      title: 'Buổi sinh hoạt Thứ 4 (19:00 - 22:00)',
      startTime: DateTime(2026, 10, 28, 19, 0),
      endTime: DateTime(2026, 10, 28, 22, 0),
      courtLocation: 'Sân Cầu Lông Kỳ Hòa, 238 Đường 3/2, Phường 12, Quận 10, TP.HCM',
      courtCount: 2,
      targetPlayerPerCourt: 6,
      maxPlayers: 12,
      deadlineBooking: DateTime(2026, 10, 28, 17, 0),
      courtRentalCost: 300000,
      status: SessionStatus.open,
      confirmedCount: 1,
      waitingCount: 0,
      isBookedByCurrentUser: true,
      currentUserBookingStatus: BookingStatus.confirmed,
      currentUserQueueOrder: 0,
    );

    final detail = SessionDetail(
      session: session,
      confirmedPlayers: [
        SessionBooking(
          bookingId: 'b-2',
          sessionId: 'session-2',
          userId: 'user-me',
          fullName: 'Nguyễn Văn A',
          skillLevel: 'TB',
          status: BookingStatus.confirmed,
          queueOrder: 0,
          bookedAt: DateTime(2026, 10, 25, 10, 0),
        ),
      ],
      waitingQueue: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionDetailViewModelProvider('session-2').overrideWith(
            (ref) => FakeSessionDetailNotifier('session-2', detail),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('vi'),
          home: SessionDetailScreen(sessionId: 'session-2'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hủy Giữ Chỗ'), findsOneWidget);
  });

  testWidgets('Disables cancel action and shows ongoing banner when session is currently playing', (tester) async {
    tester.view.physicalSize = const Size(1024, 496);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now();
    final session = Session(
      id: 'session-playing',
      groupId: 'club-1',
      clubName: 'CLB Cầu Lông Chiến Binh Quận 10',
      title: 'Buổi sinh hoạt đang diễn ra',
      startTime: now.subtract(const Duration(minutes: 30)),
      endTime: now.add(const Duration(hours: 2)),
      courtLocation: 'Sân Cầu Lông Kỳ Hòa',
      courtCount: 2,
      targetPlayerPerCourt: 6,
      maxPlayers: 12,
      deadlineBooking: now.subtract(const Duration(hours: 1)),
      courtRentalCost: 300000,
      status: SessionStatus.playing,
      confirmedCount: 1,
      waitingCount: 0,
      isBookedByCurrentUser: true,
      currentUserBookingStatus: BookingStatus.confirmed,
      currentUserQueueOrder: 0,
    );

    final detail = SessionDetail(
      session: session,
      confirmedPlayers: [
        SessionBooking(
          bookingId: 'b-playing',
          sessionId: 'session-playing',
          userId: 'user-me',
          fullName: 'Nguyễn Văn A',
          skillLevel: 'TB',
          status: BookingStatus.confirmed,
          queueOrder: 0,
          bookedAt: now.subtract(const Duration(days: 1)),
        ),
      ],
      waitingQueue: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionDetailViewModelProvider('session-playing').overrideWith(
            (ref) => FakeSessionDetailNotifier('session-playing', detail),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('vi'),
          home: SessionDetailScreen(sessionId: 'session-playing'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Buổi chơi đang diễn ra • Không thể hủy slot'), findsOneWidget);
    expect(find.text('Báo Vắng'), findsNothing);
    expect(find.text('Hủy Giữ Chỗ'), findsNothing);
  });

  testWidgets('Disables cancel action and shows deadline passed banner when session registration is expired', (tester) async {
    tester.view.physicalSize = const Size(1024, 496);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now();
    final session = Session(
      id: 'session-expired',
      groupId: 'club-1',
      clubName: 'CLB Cầu Lông Chiến Binh Quận 10',
      title: 'Buổi sinh hoạt đã khóa sổ',
      startTime: now.add(const Duration(minutes: 30)),
      endTime: now.add(const Duration(hours: 3)),
      courtLocation: 'Sân Cầu Lông Kỳ Hòa',
      courtCount: 2,
      targetPlayerPerCourt: 6,
      maxPlayers: 12,
      deadlineBooking: now.subtract(const Duration(minutes: 10)),
      courtRentalCost: 300000,
      status: SessionStatus.locked,
      confirmedCount: 1,
      waitingCount: 0,
      isBookedByCurrentUser: true,
      currentUserBookingStatus: BookingStatus.confirmed,
      currentUserQueueOrder: 0,
    );

    final detail = SessionDetail(
      session: session,
      confirmedPlayers: [
        SessionBooking(
          bookingId: 'b-expired',
          sessionId: 'session-expired',
          userId: 'user-me',
          fullName: 'Nguyễn Văn A',
          skillLevel: 'TB',
          status: BookingStatus.confirmed,
          queueOrder: 0,
          bookedAt: now.subtract(const Duration(days: 1)),
        ),
      ],
      waitingQueue: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionDetailViewModelProvider('session-expired').overrideWith(
            (ref) => FakeSessionDetailNotifier('session-expired', detail),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('vi'),
          home: SessionDetailScreen(sessionId: 'session-expired'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Đã hết hạn đổi vé • Vui lòng liên hệ Host'), findsOneWidget);
    expect(find.text('Báo Vắng'), findsNothing);
    expect(find.text('Hủy Giữ Chỗ'), findsNothing);
  });
}
