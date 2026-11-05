import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:air_hockey/domain/models/game_mode.dart';
import 'package:air_hockey/domain/models/difficulty.dart';
import 'package:air_hockey/presentation/pages/live_match_screen.dart';
import 'package:air_hockey/presentation/widgets/table_painter.dart';

void main() {
  testWidgets('LiveMatchScreen runs game loop and responds to touches', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: LiveMatchScreen(
          mode: GameMode.quickPlay,
          difficulty: Difficulty.medium,
        ),
      ),
    );

    await tester.pump();

    final customPaintFinder = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is TablePainter,
    );
    expect(customPaintFinder, findsOneWidget);

    final customPaint = tester.widget<CustomPaint>(customPaintFinder);
    final painter = customPaint.painter as TablePainter;

    final initialPlayer = painter.controller.player;
    final initialPuck = painter.controller.puck;

    // Pump frames to let the game engine tick
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    // Verify puck has moved
    expect(painter.controller.puck, isNot(equals(initialPuck)));

    // Drag the player mallet
    final center = tester.getCenter(customPaintFinder);
    final tableBottomHalf = Offset(center.dx, center.dy + 120);

    final gesture = await tester.startGesture(tableBottomHalf);
    await tester.pump();
    await gesture.moveBy(const Offset(40, -20));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    // Verify player mallet moved
    expect(painter.controller.player, isNot(equals(initialPlayer)));

    // Verify pause toggle
    final pauseButtonFinder = find.byIcon(Icons.pause_rounded);
    expect(pauseButtonFinder, findsOneWidget);
    await tester.tap(pauseButtonFinder);
    await tester.pump();

    expect(painter.controller.paused, isTrue);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // Unpause
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(painter.controller.paused, isFalse);
  });
}
