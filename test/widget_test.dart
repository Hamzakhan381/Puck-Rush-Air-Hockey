import 'package:flutter_test/flutter_test.dart';
import 'package:air_hockey/air_hockey_neon_arena.dart';

void main() {
  testWidgets('Puck Rush smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AirHockeyNeonArena());

    // Verify that AirHockeyNeonArena builds and displays PUCK RUSH header.
    expect(find.text('PUCK RUSH'), findsWidgets);
  });
}
