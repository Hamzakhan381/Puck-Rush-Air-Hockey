import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:air_hockey/domain/models/game_mode.dart';
import 'package:air_hockey/presentation/pages/live_match_screen.dart';
import 'package:air_hockey/presentation/pages/victory_screen.dart';

void main() {
  testWidgets('Test clicking on REMATCH button on VictoryScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: VictoryScreen(
          playerScore: 0,
          opponentScore: 7,
          playerWon: false,
          elapsedSeconds: 21,
          mode: GameMode.quickPlay,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final rematchFinder = find.text('REMATCH');
    expect(rematchFinder, findsOneWidget);

    await tester.tap(rematchFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(LiveMatchScreen), findsOneWidget);
  });
}
