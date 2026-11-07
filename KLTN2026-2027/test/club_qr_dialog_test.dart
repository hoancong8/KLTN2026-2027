import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/club/widgets/club_qr_dialog.dart';

void main() {
  testWidgets('renders ClubQrDialog with web link and club code actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ClubQrDialog.show(
                context: context,
                clubId: '01932f41-abcd-ef01-2345-6789abcdef01',
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
    expect(find.text('Sao chép liên kết web'), findsOneWidget);
    expect(find.text('Sao chép mã (CLB-1E415A)'), findsOneWidget);
  });
}
