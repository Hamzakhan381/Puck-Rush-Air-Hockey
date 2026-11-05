import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:air_hockey/presentation/widgets/arcade_duel_background.dart';
import 'package:air_hockey/presentation/pages/home_arena_hub.dart';

void main() {
  testWidgets('ArcadeDuelBackground renders and ticks frames with collision simulation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArcadeDuelBackground(),
        ),
      ),
    );

    expect(find.byType(ArcadeDuelBackground), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    // Pump multiple frames to allow physics simulation, collisions, sparks, and shockwaves to cycle
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(ArcadeDuelBackground), findsOneWidget);
  });

  testWidgets('HomeArenaHub renders with animated ArcadeDuelBackground in the stack', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeArenaHub(),
      ),
    );

    // Verify ArcadeDuelBackground is active behind the menu
    expect(find.byType(ArcadeDuelBackground), findsOneWidget);
    expect(find.text('PUCK RUSH'), findsOneWidget);
    expect(find.text('QUICK PLAY'), findsOneWidget);
    expect(find.text('1 PLAYER'), findsOneWidget);
    expect(find.text('2 PLAYERS'), findsOneWidget);

    // Let it animate smoothly
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
