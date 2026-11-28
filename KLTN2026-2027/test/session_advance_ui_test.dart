import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/app/provider/session_advance_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/domain/entities/payment/session_advance.dart';
import 'package:kltn2026_2027/ui/screen/payment/advance/session_advance_ui.dart';

void main() {
  for (final width in [360.0, 1100.0]) {
    testWidgets('optional advance action fits width $width', (tester) async {
      tester.view.physicalSize = Size(width, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionAdvanceQuoteProvider('session').overrideWith(
              (ref) => const SessionAdvance(
                id: null,
                sessionId: 'session',
                title: 'Buổi thử',
                status: 'AVAILABLE',
                amount: 50000,
                received: 0,
                applied: 0,
                refundDue: 0,
                canPrepare: true,
                canHandle: false,
                refundClaimed: false,
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SessionAdvanceCard(sessionId: 'session'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Đóng trước ·'), findsOneWidget);
      expect(find.text('Đóng sau'), findsNothing);
      await tester.tap(find.textContaining('Đóng trước ·'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
