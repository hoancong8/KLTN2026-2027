// test/club_schedule_planner_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/club/widgets/club_schedule_planner.dart';

void main() {
  group('ClubSchedulePlanner Component Tests', () {
    testWidgets('Renders month calendar and quick weekday selector correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      List<ClubScheduleEntry> changedSchedules = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ClubSchedulePlanner(
                initialSchedules: [
                  ClubScheduleEntry(
                    dayOfWeek: 1, // Thu 2
                    startTime: const TimeOfDay(hour: 18, minute: 0),
                    endTime: const TimeOfDay(hour: 20, minute: 0),
                  ),
                ],
                onChanged: (schedules) {
                  changedSchedules = schedules;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check month header
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      expect(find.text('T2'), findsWidgets);
      expect(find.text('CN'), findsWidgets);

      // Check quick presets
      expect(find.text('Tất cả 2 - 4 - 6'), findsOneWidget);
      expect(find.text('Tất cả 3 - 5 - 7'), findsOneWidget);
      expect(find.text('Tất cả Cuối tuần'), findsOneWidget);

      // Check time modes
      expect(find.textContaining('Giờ cố định'), findsOneWidget);
      expect(find.text('Giờ tùy chỉnh từng ngày'), findsOneWidget);

      // Test preset 2 - 4 - 6 tap
      await tester.tap(find.text('Tất cả 2 - 4 - 6'));
      await tester.pumpAndSettle();

      expect(changedSchedules.isNotEmpty, isTrue);
      final days = changedSchedules.map((e) => e.dayOfWeek).toSet();
      expect(days, containsAll([1, 3, 5]));
    });

    testWidgets('Toggles specific date on and off when tapping calendar cell', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      List<ClubScheduleEntry> changedSchedules = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ClubSchedulePlanner(
                initialSchedules: const [],
                onChanged: (schedules) {
                  changedSchedules = schedules;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap day 15 on the calendar grid
      final day15Finder = find.text('15');
      expect(day15Finder, findsOneWidget);
      await tester.tap(day15Finder);
      await tester.pumpAndSettle();

      expect(changedSchedules.length, 1);
      expect(changedSchedules.first.date?.day, 15);

      // Tap day 15 again to unselect
      await tester.tap(day15Finder);
      await tester.pumpAndSettle();

      expect(changedSchedules.isEmpty, isTrue);
    });

    testWidgets('Switching to custom time mode displays per-day configuration list', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final now = DateTime.now();
      final sampleDate1 = DateTime(now.year, now.month, 10);
      final sampleDate2 = DateTime(now.year, now.month, 18);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ClubSchedulePlanner(
                initialSchedules: [
                  ClubScheduleEntry(
                    date: sampleDate1,
                    dayOfWeek: sampleDate1.weekday == 7 ? 0 : sampleDate1.weekday,
                    startTime: const TimeOfDay(hour: 17, minute: 30),
                    endTime: const TimeOfDay(hour: 19, minute: 30),
                  ),
                  ClubScheduleEntry(
                    date: sampleDate2,
                    dayOfWeek: sampleDate2.weekday == 7 ? 0 : sampleDate2.weekday,
                    startTime: const TimeOfDay(hour: 19, minute: 0),
                    endTime: const TimeOfDay(hour: 21, minute: 0),
                  ),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to custom time mode
      await tester.tap(find.text('Giờ tùy chỉnh từng ngày'));
      await tester.pumpAndSettle();

      // Verify custom day cards exist with copy action
      expect(find.text('Áp dụng khung giờ này cho các ngày còn lại'), findsWidgets);
    });
  });
}
