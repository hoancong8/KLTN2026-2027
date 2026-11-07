import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/club/widgets/club_qr_dialog.dart';

void main() {
  testWidgets('renders ClubQrDialog without layout assertion errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ClubQrDialog.show(
                context: context,
                clubName: 'HOAN TET',
                clubCode: 'CLB-1E415A',
              ),
              child: const Text('Show QR'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show QR'));
    await tester.pumpAndSettle();

    expect(find.text('Mã Tham Gia Nhóm'), findsOneWidget);
    expect(find.text('HOAN TET'), findsOneWidget);
    expect(find.text('CLB-1E415A'), findsOneWidget);
    expect(find.text('Sao chép mã (CLB-1E415A)'), findsOneWidget);
  });
}

