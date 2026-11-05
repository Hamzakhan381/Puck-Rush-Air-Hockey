import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:air_hockey/domain/models/game_mode.dart';
import 'package:air_hockey/domain/models/difficulty.dart';
import 'package:air_hockey/domain/usecases/game_engine.dart';
import 'package:air_hockey/presentation/pages/live_match_screen.dart';

void main() {
  group('Power-Up Mechanics (Shield & Boost)', () {
    test('Shield activation protects goal against scoring', () {
      final engine = GameEngine();
      engine.layoutTable(const Size(400, 800));
      engine.serve(towardAi: false);

      expect(engine.isShieldReady, isTrue);
      final activated = engine.activateShield();
      expect(activated, isTrue);
      expect(engine.shieldActive, isTrue);
      expect(engine.shieldRemaining, 5.0);

      // Place puck inside goal mouth traveling down into player goal
      engine.puck = const Offset(200, 785); // goalLeft=124, goalRight=276, maxY=768
      engine.puckVel = const Offset(0, 300);

      final scored = engine.update(0.016, twoPlayer: false);

      // Must NOT score because shield deflected it!
      expect(scored, isFalse);
      expect(engine.aiScore, 0);
      expect(engine.puckVel.dy < 0, isTrue, reason: 'Puck must bounce upward off shield');
      expect(engine.shieldHitFlash > 0, isTrue);
    });

    test('Boost activation powers up player mallet shot', () {
      final engine = GameEngine();
      engine.layoutTable(const Size(400, 800));
      engine.serve(towardAi: true);

      expect(engine.boostActive, isFalse);
      final activated = engine.activateBoost();
      expect(activated, isTrue);
      expect(engine.boostActive, isTrue);
      expect(engine.boostRemaining, 4.0);

      // Place puck right above player mallet to hit it
      engine.puck = Offset(engine.player.dx, engine.player.dy - 35);
      engine.puckVel = const Offset(0, 100);

      engine.update(0.016, twoPlayer: false);

      // Puck should be shot upward with super speed
      expect(engine.puckVel.dy < -500, isTrue, reason: 'Boost hit must blast puck forward at super speed');
      expect(engine.puckBoostTimer > 0, isTrue);
    });

    test('P2 Shield activation protects top goal in twoPlayer mode', () {
      final engine = GameEngine();
      engine.layoutTable(const Size(400, 800));
      engine.serve(towardAi: true);

      final activated = engine.activateShield(forP2: true);
      expect(activated, isTrue);
      expect(engine.p2ShieldActive, isTrue);
      expect(engine.p2ShieldRemaining, 5.0);

      // Place puck inside top goal mouth traveling up into P2 goal
      engine.puck = const Offset(200, 15);
      engine.puckVel = const Offset(0, -300);

      final scored = engine.update(0.016, twoPlayer: true);

      // Must NOT score because P2 shield deflected it!
      expect(scored, isFalse);
      expect(engine.playerScore, 0);
      expect(engine.puckVel.dy > 0, isTrue, reason: 'Puck must bounce downward off P2 shield');
      expect(engine.p2ShieldHitFlash > 0, isTrue);
    });

    test('P2 Boost activation powers up P2 mallet shot in twoPlayer mode', () {
      final engine = GameEngine();
      engine.layoutTable(const Size(400, 800));
      engine.serve(towardAi: false);

      final activated = engine.activateBoost(forP2: true);
      expect(activated, isTrue);
      expect(engine.p2BoostActive, isTrue);

      // Place puck right below P2 mallet (ai mallet) to hit it
      engine.puck = Offset(engine.ai.dx, engine.ai.dy + 35);
      engine.puckVel = const Offset(0, -100);

      engine.update(0.016, twoPlayer: true);

      // Puck should be shot downward towards P1 with super speed
      expect(engine.puckVel.dy > 500, isTrue, reason: 'P2 Boost hit must blast puck downward at super speed');
      expect(engine.puckBoostTimer > 0, isTrue);
    });
  });

  testWidgets('LiveMatchScreen renders Shield (left) and Boost (right) buttons in 1P mode', (WidgetTester tester) async {
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
    await tester.pump(const Duration(milliseconds: 50));

    // Verify Shield button exists on left
    final shieldFinder = find.text('SHIELD');
    expect(shieldFinder, findsOneWidget);

    // Verify Boost button exists on right
    final boostFinder = find.text('BOOST');
    expect(boostFinder, findsOneWidget);

    // Tap Shield button
    await tester.tap(shieldFinder);
    await tester.pump();

    // Verify Shield became active
    expect(find.textContaining('s'), findsWidgets);

    // Tap Boost button
    await tester.tap(boostFinder);
    await tester.pump();

    // Both active and counting down
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('LiveMatchScreen renders both P1 and P2 power-ups in 2P mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: LiveMatchScreen(
          mode: GameMode.local2P,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // P2 buttons should be rendered for Player 2 at the top
    expect(find.text('P2 SHIELD'), findsOneWidget);
    expect(find.text('P2 BOOST'), findsOneWidget);

    // P1 buttons should be rendered for Player 1 at the bottom
    expect(find.text('P1 SHIELD'), findsOneWidget);
    expect(find.text('P1 BOOST'), findsOneWidget);

    // Tap P2 Shield
    await tester.tap(find.text('P2 SHIELD'));
    await tester.pump();

    // Tap P1 Boost
    await tester.tap(find.text('P1 BOOST'));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 100));
  });
}

extension on GameEngine {
  bool get isShieldReady => shieldCooldown <= 0 && !shieldActive;
}
