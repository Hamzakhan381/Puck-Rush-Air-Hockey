import 'package:flutter/material.dart';
import '../../core/theme/neon_colors.dart';
import '../controllers/game_controller.dart';

class TablePainter extends CustomPainter {
  TablePainter(this.controller) : super(repaint: controller);

  final GameController controller;

  // ── Cached static paints (created once, zero per-frame allocations) ────────

  static final Paint _railGlowPaint = Paint()
    ..color = NeonColors.cyan.withValues(alpha: 0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

  static final Paint _railPaint = Paint()
    ..color = NeonColors.cyan
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  static final Paint _midLinePaint = Paint()
    ..color = NeonColors.cyan.withValues(alpha: 0.20)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  static final Paint _centerCirclePaint = Paint()
    ..color = NeonColors.cyan.withValues(alpha: 0.18)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  static final Paint _centerDotPaint = Paint()
    ..color = NeonColors.cyan.withValues(alpha: 0.28);

  // Goal paints
  static final Paint _topGoalGlowPaint = Paint()
    ..color = NeonColors.coral.withValues(alpha: 0.7)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  static final Paint _topGoalPaint = Paint()..color = NeonColors.coral;

  static final Paint _bottomGoalGlowPaint = Paint()
    ..color = NeonColors.green.withValues(alpha: 0.7)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  static final Paint _bottomGoalPaint = Paint()..color = NeonColors.green;

  // Puck paints
  static final Paint _puckAmbientPaint = Paint()
    ..color = NeonColors.cyan.withValues(alpha: 0.12)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

  static final Paint _puckHaloPaint = Paint()
    ..color = NeonColors.cyan.withValues(alpha: 0.28)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  static final Paint _puckBodyPaint = Paint()..color = const Color(0xFFD8F9FF);

  static final Paint _puckRimPaint = Paint()
    ..color = NeonColors.cyan
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  static final Paint _puckCoreGlowPaint = Paint()
    ..color = NeonColors.cyan
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  static final Paint _puckCorePaint = Paint()..color = Colors.white;

  // Overlay
  static final Paint _pauseOverlayPaint = Paint()
    ..color = const Color(0xD9050C13);

  // Mallet base
  static final Paint _malletBasePaint = Paint()..color = const Color(0xFF0F1D28);

  // Pause TextPainter — cached after first layout
  static TextPainter? _pauseTP;


  // Mallet highlight
  static final Paint _malletHighlightPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.28);

  // Ice surface gradient paint (shader set per-frame, paint reused)
  static final Paint _icePaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const radius = Radius.circular(20);
    final rink = RRect.fromRectAndRadius(rect, radius);

    // ── Ice surface ──────────────────────────────────────────────────────────
    _icePaint.shader = RadialGradient(
      center: Alignment.center,
      radius: 1.15,
      colors: const [Color(0xFF0C172E), Color(0xFF050914)],
    ).createShader(rect);
    canvas.drawRRect(rink, _icePaint);

    // Clip to rink
    canvas.save();
    canvas.clipRRect(rink);

    // Subtle laser grid lines across table surface
    final gridPaint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    final laneStep = size.width / 6;
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(laneStep * i, 0),
        Offset(laneStep * i, size.height),
        gridPaint,
      );
    }
    final horizStep = size.height / 8;
    for (int j = 1; j < 8; j++) {
      canvas.drawLine(
        Offset(0, horizStep * j),
        Offset(size.width, horizStep * j),
        gridPaint,
      );
    }

    // Top half (Opponent) subtle crimson neon wash
    final topHalfPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          NeonColors.coral.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height / 2));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), topHalfPaint);

    // Bottom half (Player) subtle cyan/green neon wash
    final bottomHalfPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.center,
        colors: [
          NeonColors.green.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2));
    canvas.drawRect(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2), bottomHalfPaint);

    // Corner decorative laser arcs
    final cornerArcPaint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, 48, cornerArcPaint);
    canvas.drawCircle(Offset(size.width, 0), 48, cornerArcPaint);
    canvas.drawCircle(Offset(0, size.height), 48, cornerArcPaint);
    canvas.drawCircle(Offset(size.width, size.height), 48, cornerArcPaint);

    // Center dividing zone
    // Glowing beam
    final midGlowPaint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(
      Offset(14, size.height / 2),
      Offset(size.width - 14, size.height / 2),
      midGlowPaint,
    );
    canvas.drawLine(
      Offset(14, size.height / 2),
      Offset(size.width - 14, size.height / 2),
      _midLinePaint,
    );

    // Center circle with double neon rings and glowing core
    final centerOuterGlow = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 48, centerOuterGlow);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 48, _centerCirclePaint);

    final centerInnerRing = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 22, centerInnerRing);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 7, _centerDotPaint);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    // Goals
    final goalW = size.width * 0.38;
    final goalLeft = (size.width - goalW) / 2;
    _drawGoal(canvas, goalLeft, 0, goalW, 16, isTop: true);
    _drawGoal(canvas, goalLeft, size.height - 16, goalW, 16, isTop: false);

    // Shield forcefield barrier over player goal (bottom goal)
    if (controller.shieldActive) {
      _drawShieldBarrier(canvas, goalLeft, size.height - 24, goalW, 16, isTop: false);
    }

    // Shield forcefield barrier over P2 goal (top goal)
    if (controller.twoPlayer && controller.p2ShieldActive) {
      _drawShieldBarrier(canvas, goalLeft, 8, goalW, 16, isTop: true);
    }

    // Mallets
    _mallet(
      canvas,
      controller.ai,
      controller.twoPlayer ? NeonColors.green : NeonColors.coral,
      isBoosted: controller.twoPlayer && controller.p2BoostActive,
    );
    _mallet(
      canvas,
      controller.player,
      NeonColors.green,
      isBoosted: controller.boostActive,
    );

    // Puck
    _drawPuck(canvas, controller.puck, isBoosted: controller.isPuckBoosted);

    canvas.restore();

    // Rail glow + border (outside clip so glow bleeds onto edge)
    final outerRailGlow = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(rink.deflate(2), outerRailGlow);
    canvas.drawRRect(rink.deflate(2), _railGlowPaint);
    canvas.drawRRect(rink.deflate(2), _railPaint);

    // Pause overlay
    if (controller.paused) _drawPauseOverlay(canvas, size);
  }

  void _drawShieldBarrier(Canvas canvas, double left, double top, double w, double h, {bool isTop = false}) {
    final r = Rect.fromLTWH(left, top, w, h);
    final rrect = RRect.fromRectAndRadius(r, const Radius.circular(8));

    final remaining = isTop ? controller.p2ShieldRemaining : controller.shieldRemaining;
    final hitFlash = isTop ? controller.p2ShieldHitFlash : controller.shieldHitFlash;

    // Outer cyan glow
    final glowAlpha = (0.55 + 0.15 * (remaining % 1.0)).clamp(0.2, 0.85);
    canvas.drawRRect(
      rrect.inflate(6),
      Paint()
        ..color = NeonColors.cyan.withValues(alpha: glowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Barrier energy fill
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x6600E5FF)
        ..style = PaintingStyle.fill,
    );

    // Forcefield border beam
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFB3F5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Core laser line
    canvas.drawLine(
      Offset(left + 6, top + h / 2),
      Offset(left + w - 6, top + h / 2),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0,
    );

    // Energy diagonal hash lines across barrier
    final hashPaint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    for (double x = left + 10; x < left + w - 10; x += 16) {
      canvas.drawLine(Offset(x, top + 2), Offset(x + 8, top + h - 2), hashPaint);
    }

    // Shield impact flash when hit
    if (hitFlash > 0) {
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: hitFlash.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(Offset(left + w / 2, top + h / 2), 36, flashPaint);
    }
  }

  void _drawGoal(Canvas canvas, double left, double top, double w, double h,
      {required bool isTop}) {
    final r = Rect.fromLTWH(left, top, w, h);
    canvas.drawRect(r.inflate(3), isTop ? _topGoalGlowPaint : _bottomGoalGlowPaint);
    canvas.drawRect(r, isTop ? _topGoalPaint : _bottomGoalPaint);
    // Inner highlight strip
    canvas.drawRect(
      Rect.fromLTWH(left + 5, top + (isTop ? 3 : 0), w - 10, 3),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  void _drawPuck(Canvas canvas, Offset c, {bool isBoosted = false}) {
    if (isBoosted) {
      // Blazing super-shot aura
      canvas.drawCircle(
        c,
        36,
        Paint()
          ..color = const Color(0xFFFF9E00).withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawCircle(
        c,
        22,
        Paint()
          ..color = const Color(0xFFFFD60A).withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawCircle(c, 28, _puckAmbientPaint);
    canvas.drawCircle(c, 18, isBoosted ? (Paint()..color = const Color(0xFFFFB703)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)) : _puckHaloPaint);
    canvas.drawCircle(c, 13, isBoosted ? (Paint()..color = const Color(0xFFFFF7D6)) : _puckBodyPaint);
    canvas.drawCircle(c, 13, isBoosted ? (Paint()..color = const Color(0xFFFF9E00)..style = PaintingStyle.stroke..strokeWidth = 2.5) : _puckRimPaint);
    canvas.drawCircle(c, 5, isBoosted ? (Paint()..color = const Color(0xFFFFD60A)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)) : _puckCoreGlowPaint);
    canvas.drawCircle(c, 4, _puckCorePaint);
    // Specular highlight
    canvas.drawCircle(
      Offset(c.dx - 3.5, c.dy - 3.5),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  void _mallet(Canvas canvas, Offset c, Color color, {bool isBoosted = false}) {
    if (isBoosted) {
      // Supercharge flame aura
      canvas.drawCircle(
        c,
        50,
        Paint()
          ..color = const Color(0xFFFF9E00).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
      canvas.drawCircle(
        c,
        34,
        Paint()
          ..color = const Color(0xFFFF3D00).withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    // Ambient glow
    canvas.drawCircle(
      c,
      42,
      Paint()
        ..color = (isBoosted ? const Color(0xFFFF9E00) : color).withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    // Drop shadow
    canvas.drawCircle(
      Offset(c.dx + 2, c.dy + 4),
      28,
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );
    // Base disc
    canvas.drawCircle(c, 28, _malletBasePaint);
    // Gradient tint
    canvas.drawCircle(
      c,
      28,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.9,
          colors: [color.withValues(alpha: 0.32), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: 28)),
    );
    // Rim glow
    canvas.drawCircle(
      c,
      28,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // Rim hard edge
    canvas.drawCircle(
      c,
      28,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Inner nub
    canvas.drawCircle(c, 10, Paint()..color = color);
    canvas.drawCircle(c, 10, _malletHighlightPaint);
    // Nub specular
    canvas.drawCircle(
      Offset(c.dx - 2.5, c.dy - 2.5),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _drawPauseOverlay(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _pauseOverlayPaint);

    _pauseTP ??= TextPainter(
      text: const TextSpan(
        text: 'PAUSED',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 5,
          shadows: [
            Shadow(color: NeonColors.cyan, blurRadius: 18),
            Shadow(color: NeonColors.cyan, blurRadius: 36),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _pauseTP!.paint(
      canvas,
      Offset(
        (size.width - _pauseTP!.width) / 2,
        (size.height - _pauseTP!.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant TablePainter old) => old.controller != controller;

  @override
  bool? hitTest(Offset position) => true;
}
