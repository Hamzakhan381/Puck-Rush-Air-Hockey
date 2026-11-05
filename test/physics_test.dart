import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Table Boundary & Collision Tests', () {
    const double arenaWidth = 360.0;
    const double arenaHeight = 640.0;
    const double railThickness = 16.0;
    const double cornerCut = 40.0;
    const double playerRadius = 26.0;
    const double aiRadius = 24.0;

    Offset clampMallet(Offset pos, double radius, bool isTopHalf) {
      final double minX = railThickness + radius;
      final double maxX = arenaWidth - railThickness - radius;
      final double minY = isTopHalf
          ? (railThickness + radius)
          : (arenaHeight * 0.5 + 8.0 + radius);
      final double maxY = isTopHalf
          ? (arenaHeight * 0.5 - 8.0 - radius)
          : (arenaHeight - railThickness - radius);

      double cx = pos.dx.clamp(minX, maxX);
      double cy = pos.dy.clamp(minY, maxY);

      final double cornerReq = cornerCut + radius * 1.4142;

      if (isTopHalf) {
        final double dTL = (cx - railThickness) + (cy - railThickness);
        if (dTL < cornerReq) {
          final double diff = (cornerReq - dTL) * 0.5;
          cx += diff;
          cy += diff;
        }
        final double dTR = (arenaWidth - railThickness - cx) + (cy - railThickness);
        if (dTR < cornerReq) {
          final double diff = (cornerReq - dTR) * 0.5;
          cx -= diff;
          cy += diff;
        }
      } else {
        final double dBL = (cx - railThickness) + (arenaHeight - railThickness - cy);
        if (dBL < cornerReq) {
          final double diff = (cornerReq - dBL) * 0.5;
          cx += diff;
          cy -= diff;
        }
        final double dBR = (arenaWidth - railThickness - cx) + (arenaHeight - railThickness - cy);
        if (dBR < cornerReq) {
          final double diff = (cornerReq - dBR) * 0.5;
          cx -= diff;
          cy -= diff;
        }
      }

      return Offset(cx.clamp(minX, maxX), cy.clamp(minY, maxY));
    }

    test('AI mallet cannot go outside table in top-right corner', () {
      final extremePos = const Offset(999.0, -999.0);
      final clamped = clampMallet(extremePos, aiRadius, true);

      expect(clamped.dx - aiRadius >= railThickness, isTrue);
      expect(clamped.dx + aiRadius <= arenaWidth - railThickness, isTrue);
      expect(clamped.dy - aiRadius >= railThickness, isTrue);
      expect(clamped.dy + aiRadius <= arenaHeight * 0.5 - 8.0, isTrue);

      final cornerDist = (arenaWidth - railThickness - clamped.dx) + (clamped.dy - railThickness);
      expect(cornerDist >= cornerCut + aiRadius * 1.4142 - 0.001, isTrue);
    });

    test('Player mallet cannot go outside table in bottom-left corner', () {
      final extremePos = const Offset(-999.0, 999.0);
      final clamped = clampMallet(extremePos, playerRadius, false);

      expect(clamped.dx - playerRadius >= railThickness, isTrue);
      expect(clamped.dx + playerRadius <= arenaWidth - railThickness, isTrue);
      expect(clamped.dy - playerRadius >= arenaHeight * 0.5 + 8.0, isTrue);
      expect(clamped.dy + playerRadius <= arenaHeight - railThickness, isTrue);

      final cornerDist = (clamped.dx - railThickness) + (arenaHeight - railThickness - clamped.dy);
      expect(cornerDist >= cornerCut + playerRadius * 1.4142 - 0.001, isTrue);
    });

    test('Player mallet cannot cross the midline', () {
      final tryCrossPos = const Offset(180.0, 50.0);
      final clamped = clampMallet(tryCrossPos, playerRadius, false);

      expect(clamped.dy >= arenaHeight * 0.5 + 8.0 + playerRadius, isTrue);
    });

    test('AI mallet cannot cross the midline', () {
      final tryCrossPos = const Offset(180.0, 500.0);
      final clamped = clampMallet(tryCrossPos, aiRadius, true);

      expect(clamped.dy <= arenaHeight * 0.5 - 8.0 - aiRadius, isTrue);
    });

    test('Puck corner cushion enforcement prevents puck escaping through corners', () {
      const double puckRadius = 15.0;
      final double cornerReq = cornerCut + puckRadius * 1.4142;

      // Simulate puck pushed into top-left corner
      Offset puckPos = const Offset(railThickness + 2.0, railThickness + 2.0);
      final double dTL = (puckPos.dx - railThickness) + (puckPos.dy - railThickness);
      if (dTL < cornerReq) {
        final double pen = (cornerReq - dTL) * 0.5;
        puckPos += Offset(pen, pen);
      }

      final double finalDTL = (puckPos.dx - railThickness) + (puckPos.dy - railThickness);
      expect(finalDTL >= cornerReq - 0.001, isTrue);
      expect(puckPos.dx - puckRadius >= railThickness, isTrue);
      expect(puckPos.dy - puckRadius >= railThickness, isTrue);
    });

    test('Goal state transition flag prevents duplicate scoring', () {
      int score = 0;
      bool isGoalTransition = false;

      void onGoalScored() {
        if (isGoalTransition) return;
        isGoalTransition = true;
        score++;
      }

      // First trigger on entering goal mouth
      onGoalScored();
      expect(score, 1);
      expect(isGoalTransition, isTrue);

      // Subsequent 60 frames while puck sits in goal net before 900ms reset
      for (int i = 0; i < 60; i++) {
        onGoalScored();
      }
      expect(score, 1, reason: 'Score must not inflate during goal fanfare');

      // Reset puck for next round
      isGoalTransition = false;
      expect(isGoalTransition, isFalse);
    });
  });
}
