// Widget test untuk CareHub App
import 'package:flutter_test/flutter_test.dart';
import 'package:carehub/main.dart';

void main() {
  testWidgets('CareHub app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CareHubApp());
    await tester.pump();

    // Verify app starts without crashing
    expect(find.byType(CareHubApp), findsOneWidget);
  });
}
