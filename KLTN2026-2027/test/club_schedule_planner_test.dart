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
      expect(find.text('2 - 4 - 6'), findsOneWidget);
      expect(find.text('3 - 5 - 7'), findsOneWidget);
      expect(find.text('Cuối tuần'), findsOneWidget);

      // Check time modes
      expect(find.text('Giờ cố định chung'), findsOneWidget);
      expect(find.text('Giờ tùy chỉnh theo ngày'), findsOneWidget);

      // Test preset 2 - 4 - 6 tap
      await tester.tap(find.text('2 - 4 - 6'));
      await tester.pumpAndSettle();

      expect(changedSchedules.length, 3);
      final days = changedSchedules.map((e) => e.dayOfWeek).toList();
      expect(days, containsAll([1, 3, 5]));
    });

    testWidgets('Toggles dayOfWeek on and off via weekday chips', (tester) async {
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

      // Tap 'Thứ 4'
      await tester.tap(find.text('Thứ 4'));
      await tester.pumpAndSettle();

      expect(changedSchedules.length, 1);
      expect(changedSchedules.first.dayOfWeek, 3);

      // Tap 'Thứ 4' again to unselect
      await tester.tap(find.text('Thứ 4'));
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ClubSchedulePlanner(
                initialSchedules: [
                  ClubScheduleEntry(
                    dayOfWeek: 1, // Thu 2
                    startTime: const TimeOfDay(hour: 17, minute: 30),
                    endTime: const TimeOfDay(hour: 19, minute: 30),
                  ),
                  ClubScheduleEntry(
                    dayOfWeek: 5, // Thu 6
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
      await tester.tap(find.text('Giờ tùy chỉnh theo ngày'));
      await tester.pumpAndSettle();

      // Verify custom day cards exist
      expect(find.text('Thứ Hai'), findsOneWidget);
      expect(find.text('Thứ Sáu'), findsOneWidget);
      expect(find.text('Áp dụng khung giờ này cho các ngày còn lại'), findsWidgets);
    });
  });
}
