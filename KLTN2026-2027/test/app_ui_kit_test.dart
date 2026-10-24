// test/app_ui_kit_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/widget/app_confirm_dialog.dart';
import 'package:kltn2026_2027/widget/app_shimmer.dart';
import 'package:kltn2026_2027/widget/app_status_badge.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      home: Scaffold(body: child),
    );
  }

  testWidgets('AppStatusBadge renders all semantic variants', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const Column(
          children: [
            AppStatusBadge.success(label: 'ĐÃ THANH TOÁN'),
            AppStatusBadge.warning(label: 'CHỜ DUYỆT'),
            AppStatusBadge.error(label: 'BÁO VẮNG'),
            AppStatusBadge.info(label: 'ĐANG TUYỂN'),
            AppStatusBadge.primary(label: 'ĐANG THI ĐẤU'),
          ],
        ),
      ),
    );

    expect(find.text('ĐÃ THANH TOÁN'), findsOneWidget);
    expect(find.text('CHỜ DUYỆT'), findsOneWidget);
    expect(find.text('BÁO VẮNG'), findsOneWidget);
    expect(find.text('ĐANG TUYỂN'), findsOneWidget);
    expect(find.text('ĐANG THI ĐẤU'), findsOneWidget);
  });

  testWidgets('AppShimmer renders line, circle and card variants', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        Column(
          children: [
            AppShimmer.line(width: 100, height: 16),
            AppShimmer.circle(radius: 20),
            AppShimmer.card(width: 200, height: 80),
          ],
        ),
      ),
    );

    expect(find.byType(AppShimmer), findsNWidgets(3));
  });

  testWidgets('AppConfirmDialog triggers onConfirm callback', (tester) async {
    var confirmed = false;

    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AppConfirmDialog.show(
                context,
                title: 'Xác nhận xóa',
                message: 'Bạn có chắc chắn?',
                isDestructive: true,
                onConfirm: () => confirmed = true,
              );
            },
            child: const Text('Mở Modal'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mở Modal'));
    await tester.pumpAndSettle();

    expect(find.text('Xác nhận xóa'), findsOneWidget);
    expect(find.text('Bạn có chắc chắn?'), findsOneWidget);

    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });
}
