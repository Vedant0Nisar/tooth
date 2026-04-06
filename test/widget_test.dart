import 'package:flutter_test/flutter_test.dart';
import 'package:tooth/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ToothApp());

    // Verify it loads ModelViewer etc. Just checking if no exceptions happen.
    expect(find.byType(ToothApp), findsOneWidget);
  });
}
