// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
// ← point at your package name; if your pubspec defines `name: hali`:
import 'package:hali/main.dart';

void main() {
  testWidgets('HaliApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HaliApp());

    // Verify that by default it shows your LoginScreen (or whatever the first route is).
    expect(find.text('Login'), findsOneWidget);
  });
}
