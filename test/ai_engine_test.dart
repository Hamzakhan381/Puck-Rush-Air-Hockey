import 'package:flutter_test/flutter_test.dart';
import 'package:air_hockey/domain/models/difficulty.dart';
import 'package:air_hockey/domain/usecases/game_engine.dart';
import 'dart:ui';
import 'dart:math';

void main() {
  group('AI Takeover and Stuck Puck Tests', () {
    const tableSize = Size(400, 800);

    test('Insane AI comes forward to take over stationary puck in its half', () {
      final engine = GameEngine();
      engine.difficulty = Difficulty.insane;
      engine.layoutTable(tableSize);

      // Place puck at 0.45 height (in bot's half, near center line, exactly as in screenshot)
      engine.puck = const Offset(260, 360); // 360 is 0.45 * 800
      engine.puckVel = Offset.zero; // completely stationary

      final initialAiY = engine.ai.dy;
      expect(initialAiY, lessThan(200.0)); // around defendY (0.18-0.22)

      double maxAiY = initialAiY;
      bool struckForward = false;

      // Run engine updates for up to 1 second
      for (int i = 0; i < 60; i++) {
        engine.update(1 / 60, twoPlayer: false);
        maxAiY = max(maxAiY, engine.ai.dy);
        if (engine.puckVel.dy > 100) {
          struckForward = true;
          break;
        }
      }

      // AI should have charged forward and struck the stationary puck
      expect(maxAiY, greaterThan(initialAiY + 50.0),
          reason: 'Bot must come in front to take over the stationary puck');
      expect(struckForward, isTrue,
          reason: 'Bot must smash the stationary puck towards the opponent');
    });

    test('Insane AI hits stationary puck near center line and drives it towards player', () {
      final engine = GameEngine();
      engine.difficulty = Difficulty.insane;
      engine.layoutTable(tableSize);

      // Puck placed at table.height * 0.46
      engine.puck = const Offset(200, 368);
      engine.puckVel = Offset.zero;

      bool struck = false;
      for (int i = 0; i < 90; i++) {
        engine.update(1 / 60, twoPlayer: false);
        if (engine.puckVel.dy > 100) {
          struck = true;
          break;
        }
      }

      expect(struck, isTrue,
          reason: 'Bot should smash the loose puck towards player side');
    });

    test('Hard and Medium AI also take over stationary puck in their half', () {
      for (final diff in [Difficulty.medium, Difficulty.hard]) {
        final engine = GameEngine();
        engine.difficulty = diff;
        engine.layoutTable(tableSize);

        engine.puck = const Offset(200, 350);
        engine.puckVel = Offset.zero;

        final initialY = engine.ai.dy;
        double maxY = initialY;
        bool struck = false;

        for (int i = 0; i < 60; i++) {
          engine.update(1 / 60, twoPlayer: false);
          maxY = max(maxY, engine.ai.dy);
          if (engine.puckVel.dy > 100) {
            struck = true;
            break;
          }
        }

        expect(maxY, greaterThan(initialY + 50.0),
            reason: '$diff AI should advance to take over stationary puck');
        expect(struck, isTrue,
            reason: '$diff AI must strike the stationary puck');
      }
    });

    test('Table blower watchdog nudges stationary puck if motionless for 2.6 seconds', () {
      final engine = GameEngine();
      engine.difficulty = Difficulty.insane;
      engine.layoutTable(tableSize);

      // Deep in player half so AI cannot hit it, player is idle
      engine.puck = const Offset(200, 600);
      engine.puckVel = Offset.zero;

      // Update for 2.6 seconds (approx 156 frames at 60fps)
      for (int i = 0; i < 160; i++) {
        engine.update(1 / 60, twoPlayer: true); // twoPlayer = true so AI doesn't interfere
      }

      // Watchdog should have activated and given puck velocity
      expect(engine.puckVel.distance, greaterThan(50.0),
          reason: 'Blower pulse must give puck velocity after becoming motionless');
    });
  });
}
