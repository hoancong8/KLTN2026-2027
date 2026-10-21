import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/club/widgets/club_create_dialog.dart';

void main() {
  testWidgets('ClubCreateDialog displays confirm button on standard phone', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ClubCreateDialog(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Xác nhận tạo CLB'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
  });

  testWidgets('ClubCreateDialog displays confirm button when keyboard is opened', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetViewInsets();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ClubCreateDialog(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Xác nhận tạo CLB'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
  });

  testWidgets('ClubCreateDialog displays cleanly on compact small phone (320px)', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ClubCreateDialog(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Xác nhận tạo CLB'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
  });

  testWidgets('ClubCreateDialog displays cleanly with large accessibility text scale', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: const Scaffold(
                body: ClubCreateDialog(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Xác nhận tạo CLB'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
  });
}
