import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/my_app.dart';

void main() {
  testWidgets('MyApp mounts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyApp(initialRoute: '/login')),
    );
    expect(find.byType(MyApp), findsOneWidget);
  });
}
