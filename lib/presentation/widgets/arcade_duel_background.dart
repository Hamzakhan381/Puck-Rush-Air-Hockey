import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/neon_colors.dart';

/// Ultra-smooth, high-performance animated arcade background featuring two
/// neon strikers dueling and clashing into each other with electric shockwaves,
/// sparks, and light trails.
///
/// Designed to be 100% non-blocking (`IgnorePointer`), zero-rebuild (uses
/// `Listenable` repaint so only the CustomPainter repaints), and GPU-optimized
/// (no heavy per-frame offscreen blur filters).
class ArcadeDuelBackground extends StatefulWidget {
  const ArcadeDuelBackground({
    super.key,
    this.showPuck = true,
    this.opacity = 1.0,
  });

  /// Whether the neon puck is also volleyed between the strikers.
  final bool showPuck;

  /// Overall opacity multiplier (0.0 to 1.0).
  final double opacity;

  @override
  State<ArcadeDuelBackground> createState() => _ArcadeDuelBackgroundState();
}

class _ArcadeDuelBackgroundState extends State<ArcadeDuelBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final _DuelSimulation _simulation;
  DateTime _lastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _simulation = _DuelSimulation(showPuck: widget.showPuck);
    _lastTime = DateTime.now();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick)..repeat();
  }

  void _onTick() {
    final now = DateTime.now();
    final double dt = (now.difference(_lastTime).inMicroseconds / 1000000.0)
        .clamp(0.008, 0.033);
    _lastTime = now;

    _simulation.step(dt);
  }

  @override
  void didUpdateWidget(covariant ArcadeDuelBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showPuck != widget.showPuck) {
      _simulation.showPuck = widget.showPuck;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _simulation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Opacity(
        opacity: widget.opacity.clamp(0.0, 1.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(
              constraints.maxWidth > 0 ? constraints.maxWidth : 400,
              constraints.maxHeight > 0 ? constraints.maxHeight : 800,
            );
            _simulation.updateArenaSize(size);

            return CustomPaint(
              painter: _DuelPainter(
                simulation: _simulation,
                repaint: _simulation,
              ),
              size: size,
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DUEL SIMULATION CONTROLLER (Runs independent of widget build passes)
// ─────────────────────────────────────────────────────────────────────────────

class _DuelSimulation extends ChangeNotifier {
  _DuelSimulation({this.showPuck = true}) {
    _initStrikers();
  }

  bool showPuck;
  Size arenaSize = const Size(400, 800);
  bool _initialized = false;

  // Entities
  late _StrikerEntity cyanStriker;
  late _StrikerEntity coralStriker;
  late _PuckEntity puck;

  // Effects pools
  final List<_ShockwaveEntity> shockwaves = [];
  final List<_SparkEntity> sparks = [];
  final List<_FlashEntity> flashes = [];
  final List<_StarEntity> stars = [];

  // Choreography
  double elapsedTime = 0.0;
  int phase = 0; // 0: Rally Puck, 1: Head-on Clash Charge, 2: Recoil/Orbit Weave
  double phaseTimer = 0.0;
  final math.Random rng = math.Random();

  void _initStrikers() {
    cyanStriker = _StrikerEntity(
      color: NeonColors.cyan,
      accentColor: const Color(0xFFD4FAFF),
      radius: 25.0,
      pos: const Offset(140, 560),
      vel: const Offset(60, -140),
    );

    coralStriker = _StrikerEntity(
      color: NeonColors.coral,
      accentColor: const Color(0xFFFFD4E2),
      radius: 25.0,
      pos: const Offset(260, 220),
      vel: const Offset(-60, 140),
    );

    puck = _PuckEntity(
      radius: 11.0,
      pos: const Offset(200, 390),
      vel: const Offset(110, 160),
    );

    // Seed stars
    stars.clear();
    for (int i = 0; i < 20; i++) {
      stars.add(_StarEntity(
        xRatio: rng.nextDouble(),
        yRatio: rng.nextDouble(),
        size: 1.2 + rng.nextDouble() * 2.0,
        speed: 0.15 + rng.nextDouble() * 0.35,
        alphaBase: 0.12 + rng.nextDouble() * 0.28,
        color: rng.nextBool() ? NeonColors.cyan : NeonColors.purple,
      ));
    }
  }

  void updateArenaSize(Size size) {
    if (size.width <= 10 || size.height <= 10) return;
    if (arenaSize == size && _initialized) return;

    final bool first = !_initialized;
    arenaSize = size;
    _initialized = true;

    if (first) {
      cyanStriker.pos = Offset(size.width * 0.35, size.height * 0.68);
      coralStriker.pos = Offset(size.width * 0.65, size.height * 0.28);
      puck.pos = Offset(size.width * 0.50, size.height * 0.48);
    }
  }

  void step(double dt) {
    if (!_initialized || arenaSize.width < 50 || arenaSize.height < 50) {
      return;
    }

    elapsedTime += dt;
    phaseTimer += dt;

    final w = arenaSize.width;
    final h = arenaSize.height;
    const margin = 26.0;

    // Choreography switcher:
    // Every 3.4s rally puck -> 2.4s charge straight at each other -> 1.6s recoil & weave
    if (phase == 0 && phaseTimer > 3.4) {
      phase = 1; // CHARGE straight at each other!
      phaseTimer = 0.0;
    } else if (phase == 1 && phaseTimer > 2.4) {
      phase = 2; // Recoil & Weave
      phaseTimer = 0.0;
    } else if (phase == 2 && phaseTimer > 1.6) {
      phase = 0; // Back to puck rally
      phaseTimer = 0.0;
    }

    // AI steering based on active phase
    if (phase == 1) {
      // ── PHASE 1: DIRECT HEAD-ON STRIKER CLASH CHARGE ──────────────────
      final toCoral = coralStriker.pos - cyanStriker.pos;
      final dist = toCoral.distance;
      if (dist > 1.0) {
        final dir = toCoral / dist;
        cyanStriker.vel += dir * (750.0 * dt);
        coralStriker.vel -= dir * (750.0 * dt);
      }
    } else if (phase == 0 && showPuck) {
      // ── PHASE 0: PUCK BATTLE ──────────────────────────────────────────
      final toPuck1 = puck.pos - cyanStriker.pos;
      if (toPuck1.distance > 1.0) {
        final dir1 = toPuck1 / toPuck1.distance;
        cyanStriker.vel += dir1 * (520.0 * dt);
      }

      final toPuck2 = puck.pos - coralStriker.pos;
      if (toPuck2.distance > 1.0) {
        final dir2 = toPuck2 / toPuck2.distance;
        coralStriker.vel += dir2 * (520.0 * dt);
      }
    } else {
      // ── PHASE 2: RECOIL & SINUSOIDAL ARC WEAVING ──────────────────────
      final center = Offset(w * 0.5, h * 0.5);
      final angle = elapsedTime * 2.4;
      final target1 = center +
          Offset(math.cos(angle) * w * 0.28,
              math.sin(angle) * h * 0.20 + h * 0.16);
      final target2 = center +
          Offset(math.cos(angle + math.pi) * w * 0.28,
              math.sin(angle + math.pi) * h * 0.20 - h * 0.16);

      final dir1 = target1 - cyanStriker.pos;
      if (dir1.distance > 1.0) {
        cyanStriker.vel += (dir1 / dir1.distance) * (460.0 * dt);
      }

      final dir2 = target2 - coralStriker.pos;
      if (dir2.distance > 1.0) {
        coralStriker.vel += (dir2 / dir2.distance) * (460.0 * dt);
      }
    }

    // Velocity limits & friction
    cyanStriker.update(dt, maxSpeed: 520.0, friction: 0.985);
    coralStriker.update(dt, maxSpeed: 520.0, friction: 0.985);
    if (showPuck) {
      puck.update(dt, maxSpeed: 680.0, friction: 0.992);
    }

    // ── STRIKER VS STRIKER COLLISION (The Main Clash!) ──────────────────
    final strikersDelta = coralStriker.pos - cyanStriker.pos;
    final strikersDist = strikersDelta.distance;
    final minDistance = cyanStriker.radius + coralStriker.radius;

    if (strikersDist < minDistance && strikersDist > 0.001) {
      final normal = strikersDelta / strikersDist;

      // Position correction to avoid sticky overlap
      final overlap = minDistance - strikersDist;
      cyanStriker.pos -= normal * (overlap * 0.52);
      coralStriker.pos += normal * (overlap * 0.52);

      // Elastic bounce with arcade impulse
      final double relVel = (coralStriker.vel - cyanStriker.vel).dx * normal.dx +
          (coralStriker.vel - cyanStriker.vel).dy * normal.dy;

      final double impulse = (-relVel * 1.35 + 260.0).clamp(220.0, 780.0);
      cyanStriker.vel -= normal * impulse;
      coralStriker.vel += normal * impulse;

      // Spawn Epic Clash Effects!
      final clashPoint = (cyanStriker.pos + coralStriker.pos) * 0.5;
      _triggerClashEffects(
        point: clashPoint,
        isStrikerClash: true,
        primaryColor: NeonColors.cyan,
        secondaryColor: NeonColors.coral,
      );

      // If in charge phase, transition immediately to recoil phase
      if (phase == 1) {
        phase = 2;
        phaseTimer = 0.0;
      }
    }

    // ── STRIKER VS PUCK COLLISIONS ──────────────────────────────────────
    if (showPuck) {
      _checkStrikerPuck(cyanStriker, isCyan: true);
      _checkStrikerPuck(coralStriker, isCyan: false);
    }

    // ── BOUNDARY BOUNCES ────────────────────────────────────────────────
    _bounceStriker(cyanStriker, margin, w, h);
    _bounceStriker(coralStriker, margin, w, h);

    if (showPuck) {
      if (puck.pos.dx - puck.radius < margin) {
        puck.pos = Offset(margin + puck.radius, puck.pos.dy);
        puck.vel = Offset(-puck.vel.dx * 0.95, puck.vel.dy);
        _triggerWallSparks(puck.pos, NeonColors.cyan);
      } else if (puck.pos.dx + puck.radius > w - margin) {
        puck.pos = Offset(w - margin - puck.radius, puck.pos.dy);
        puck.vel = Offset(-puck.vel.dx * 0.95, puck.vel.dy);
        _triggerWallSparks(puck.pos, NeonColors.cyan);
      }

      if (puck.pos.dy - puck.radius < margin) {
        puck.pos = Offset(puck.pos.dx, margin + puck.radius);
        puck.vel = Offset(puck.vel.dx, -puck.vel.dy * 0.95);
        _triggerWallSparks(puck.pos, NeonColors.coral);
      } else if (puck.pos.dy + puck.radius > h - margin) {
        puck.pos = Offset(puck.pos.dx, h - margin - puck.radius);
        puck.vel = Offset(puck.vel.dx, -puck.vel.dy * 0.95);
        _triggerWallSparks(puck.pos, NeonColors.green);
      }
    }

    // ── UPDATE EFFECTS ──────────────────────────────────────────────────
    for (int i = shockwaves.length - 1; i >= 0; i--) {
      shockwaves[i].progress += dt * 3.0;
      if (shockwaves[i].progress >= 1.0) {
        shockwaves.removeAt(i);
      }
    }

    for (int i = sparks.length - 1; i >= 0; i--) {
      sparks[i].life -= dt * sparks[i].decay;
      sparks[i].pos += sparks[i].vel * dt;
      sparks[i].vel *= (1.0 - 2.8 * dt);
      if (sparks[i].life <= 0.0) {
        sparks.removeAt(i);
      }
    }

    for (int i = flashes.length - 1; i >= 0; i--) {
      flashes[i].life -= dt * 7.0;
      if (flashes[i].life <= 0.0) {
        flashes.removeAt(i);
      }
    }

    // Notify CustomPainter to repaint (zero widget rebuild overhead!)
    notifyListeners();
  }

  void _checkStrikerPuck(_StrikerEntity striker, {required bool isCyan}) {
    final delta = puck.pos - striker.pos;
    final dist = delta.distance;
    final minDist = striker.radius + puck.radius;

    if (dist < minDist && dist > 0.001) {
      final normal = delta / dist;
      puck.pos = striker.pos + normal * (minDist + 1.0);

      final double currentSpeed = math.max(puck.vel.distance, 440.0);
      final double launchSpeed = (currentSpeed * 1.18).clamp(420.0, 750.0);

      puck.vel = normal * launchSpeed + striker.vel * 0.35;
      striker.vel -= normal * 85.0;

      _triggerClashEffects(
        point: puck.pos,
        isStrikerClash: false,
        primaryColor: isCyan ? NeonColors.cyan : NeonColors.coral,
        secondaryColor: Colors.white,
      );
    }
  }

  void _bounceStriker(_StrikerEntity striker, double margin, double w, double h) {
    if (striker.pos.dx - striker.radius < margin) {
      striker.pos = Offset(margin + striker.radius, striker.pos.dy);
      striker.vel = Offset(-striker.vel.dx * 0.88, striker.vel.dy);
    } else if (striker.pos.dx + striker.radius > w - margin) {
      striker.pos = Offset(w - margin - striker.radius, striker.pos.dy);
      striker.vel = Offset(-striker.vel.dx * 0.88, striker.vel.dy);
    }

    if (striker.pos.dy - striker.radius < margin) {
      striker.pos = Offset(striker.pos.dx, margin + striker.radius);
      striker.vel = Offset(striker.vel.dx, -striker.vel.dy * 0.88);
    } else if (striker.pos.dy + striker.radius > h - margin) {
      striker.pos = Offset(striker.pos.dx, h - margin - striker.radius);
      striker.vel = Offset(striker.vel.dx, -striker.vel.dy * 0.88);
    }
  }

  void _triggerClashEffects({
    required Offset point,
    required bool isStrikerClash,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    // 1. Dual Shockwaves
    shockwaves.add(_ShockwaveEntity(
      center: point,
      color: primaryColor,
      maxRadius: isStrikerClash ? 135.0 : 70.0,
      strokeWidth: isStrikerClash ? 3.5 : 2.2,
    ));

    if (isStrikerClash) {
      shockwaves.add(_ShockwaveEntity(
        center: point,
        color: secondaryColor,
        maxRadius: 95.0,
        strokeWidth: 2.2,
      ));
    }

    // 2. High-speed Sparks
    final count = isStrikerClash ? 20 : 10;
    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final speed = (isStrikerClash ? 150.0 : 100.0) + rng.nextDouble() * 300.0;
      final pick = rng.nextInt(4);
      final Color sparkColor = pick == 0
          ? Colors.white
          : pick == 1
              ? NeonColors.cyan
              : pick == 2
                  ? NeonColors.coral
                  : NeonColors.gold;

      sparks.add(_SparkEntity(
        pos: point,
        vel: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: sparkColor,
        size: 2.2 + rng.nextDouble() * 2.4,
        decay: 1.5 + rng.nextDouble() * 1.2,
      ));
    }

    if (sparks.length > 60) {
      sparks.removeRange(0, sparks.length - 60);
    }

    // 3. Collision Flash
    flashes.add(_FlashEntity(
      center: point,
      color: isStrikerClash ? Colors.white : primaryColor,
      maxRadius: isStrikerClash ? 50.0 : 32.0,
    ));
  }

  void _triggerWallSparks(Offset point, Color color) {
    for (int i = 0; i < 3; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final speed = 70.0 + rng.nextDouble() * 130.0;
      sparks.add(_SparkEntity(
        pos: point,
        vel: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: color,
        size: 1.8,
        decay: 2.5,
      ));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class _StrikerEntity {
  _StrikerEntity({
    required this.color,
    required this.accentColor,
    required this.radius,
    required this.pos,
    required this.vel,
  });

  final Color color;
  final Color accentColor;
  final double radius;
  Offset pos;
  Offset vel;
  final List<Offset> trail = [];

  void update(double dt, {required double maxSpeed, required double friction}) {
    trail.insert(0, pos);
    if (trail.length > 8) trail.removeLast();

    final speed = vel.distance;
    if (speed > maxSpeed) {
      vel = (vel / speed) * maxSpeed;
    }
    vel *= friction;
    pos += vel * dt;
  }
}

class _PuckEntity {
  _PuckEntity({
    required this.radius,
    required this.pos,
    required this.vel,
  });

  final double radius;
  Offset pos;
  Offset vel;
  final List<Offset> trail = [];

  void update(double dt, {required double maxSpeed, required double friction}) {
    trail.insert(0, pos);
    if (trail.length > 6) trail.removeLast();

    final speed = vel.distance;
    if (speed > maxSpeed) {
      vel = (vel / speed) * maxSpeed;
    }
    vel *= friction;
    pos += vel * dt;
  }
}

class _ShockwaveEntity {
  _ShockwaveEntity({
    required this.center,
    required this.color,
    required this.maxRadius,
    required this.strokeWidth,
  });

  final Offset center;
  final Color color;
  final double maxRadius;
  final double strokeWidth;
  double progress = 0.0;
}

class _SparkEntity {
  _SparkEntity({
    required this.pos,
    required this.vel,
    required this.color,
    required this.size,
    required this.decay,
  });

  Offset pos;
  Offset vel;
  final Color color;
  final double size;
  final double decay;
  double life = 1.0;
}

class _FlashEntity {
  _FlashEntity({
    required this.center,
    required this.color,
    required this.maxRadius,
  });

  final Offset center;
  final Color color;
  final double maxRadius;
  double life = 1.0;
}

class _StarEntity {
  _StarEntity({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.alphaBase,
    required this.color,
  });

  final double xRatio;
  final double yRatio;
  final double size;
  final double speed;
  final double alphaBase;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER (High Performance - Layered Alpha, Zero Heavy Blur Shaders)
// ─────────────────────────────────────────────────────────────────────────────

class _DuelPainter extends CustomPainter {
  _DuelPainter({
    required this.simulation,
    required super.repaint,
  });

  final _DuelSimulation simulation;

  // Cached paints to completely avoid heap allocations during paint()
  static final Paint _bgPaint = Paint();
  static final Paint _gridPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ── 1. Base Dark Cyber Gradient ─────────────────────────────────────
    _bgPaint.shader = RadialGradient(
      center: const Alignment(0.0, -0.15),
      radius: 1.35,
      colors: const [
        Color(0xFF14244A),
        Color(0xFF091022),
        Color(0xFF040710),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, _bgPaint);

    // ── 2. Subtle Rink Grid Lines ───────────────────────────────────────
    _drawGrid(canvas, size);

    // ── 3. Ambient Dust Stars ───────────────────────────────────────────
    _drawStars(canvas, size);

    // ── 4. Striker Motion Trails ────────────────────────────────────────
    _drawTrail(canvas, simulation.cyanStriker.trail, NeonColors.cyan,
        simulation.cyanStriker.radius);
    _drawTrail(canvas, simulation.coralStriker.trail, NeonColors.coral,
        simulation.coralStriker.radius);
    if (simulation.showPuck) {
      _drawTrail(canvas, simulation.puck.trail, NeonColors.cyan,
          simulation.puck.radius);
    }

    // ── 5. Expanding Collision Shockwave Rings ──────────────────────────
    for (final sw in simulation.shockwaves) {
      final currentRadius = sw.maxRadius * sw.progress;
      final alpha = (1.0 - sw.progress).clamp(0.0, 1.0);

      // Outer soft ring
      _strokePaint
        ..color = sw.color.withValues(alpha: alpha * 0.35)
        ..strokeWidth = sw.strokeWidth * 2.2;
      canvas.drawCircle(sw.center, currentRadius, _strokePaint);

      // Inner sharp ring
      _strokePaint
        ..color = (sw.progress < 0.25 ? Colors.white : sw.color)
            .withValues(alpha: alpha * 0.85)
        ..strokeWidth = sw.strokeWidth;
      canvas.drawCircle(sw.center, currentRadius, _strokePaint);
    }

    // ── 6. Radiant Sparks ───────────────────────────────────────────────
    for (final sp in simulation.sparks) {
      final alpha = sp.life.clamp(0.0, 1.0);
      // Soft spark glow halo
      _fillPaint.color = sp.color.withValues(alpha: alpha * 0.45);
      canvas.drawCircle(sp.pos, sp.size * 1.6, _fillPaint);

      // Bright spark core
      _fillPaint.color = Colors.white.withValues(alpha: alpha * 0.9);
      canvas.drawCircle(sp.pos, sp.size * 0.55, _fillPaint);
    }

    // ── 7. Flash Flares ─────────────────────────────────────────────────
    for (final fl in simulation.flashes) {
      final radius = fl.maxRadius * (1.1 - 0.1 * fl.life);
      final alpha = (fl.life * 0.6).clamp(0.0, 1.0);

      // Outer flare
      _fillPaint.color = fl.color.withValues(alpha: alpha * 0.35);
      canvas.drawCircle(fl.center, radius, _fillPaint);

      // Core flare
      _fillPaint.color = Colors.white.withValues(alpha: alpha * 0.75);
      canvas.drawCircle(fl.center, radius * 0.45, _fillPaint);
    }

    // ── 8. Draw Puck ────────────────────────────────────────────────────
    if (simulation.showPuck) {
      _drawPuck(canvas, simulation.puck.pos, simulation.puck.radius);
    }

    // ── 9. Draw Neon Strikers ───────────────────────────────────────────
    _drawStriker(canvas, simulation.cyanStriker);
    _drawStriker(canvas, simulation.coralStriker);

    // ── 10. Vignette Shade (Ensures UI Cards and Text Pop) ──────────────
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.15,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.22),
          Colors.black.withValues(alpha: 0.52),
        ],
        stops: const [0.55, 0.85, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final double pulse = 0.035 + 0.015 * math.sin(simulation.elapsedTime * 1.6);
    _gridPaint
      ..color = NeonColors.cyan.withValues(alpha: pulse)
      ..strokeWidth = 1.0;

    // Vertical lane lines
    final double colStep = size.width / 6;
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(colStep * i, 0),
        Offset(colStep * i, size.height),
        _gridPaint,
      );
    }

    // Horizontal lane lines
    final double rowStep = size.height / 10;
    for (int j = 1; j < 10; j++) {
      canvas.drawLine(
        Offset(0, rowStep * j),
        Offset(size.width, rowStep * j),
        _gridPaint,
      );
    }

    // Center dividing line & circle
    final midY = size.height * 0.5;
    _gridPaint
      ..color = NeonColors.cyan.withValues(alpha: 0.07)
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(20, midY), Offset(size.width - 20, midY), _gridPaint);
    canvas.drawCircle(Offset(size.width * 0.5, midY), 52, _gridPaint);
  }

  void _drawStars(Canvas canvas, Size size) {
    for (final star in simulation.stars) {
      final yOffset =
          (star.yRatio * size.height + simulation.elapsedTime * star.speed * 18) %
              size.height;
      final xPos = star.xRatio * size.width;
      final breathe =
          star.alphaBase + 0.08 * math.sin(simulation.elapsedTime * 2.0 + star.xRatio * 8);

      _fillPaint.color = star.color.withValues(alpha: breathe.clamp(0.04, 0.5));
      canvas.drawCircle(Offset(xPos, yOffset), star.size, _fillPaint);
    }
  }

  void _drawTrail(
      Canvas canvas, List<Offset> trail, Color color, double baseRadius) {
    if (trail.length < 2) return;
    for (int i = 0; i < trail.length; i++) {
      final double ratio = 1.0 - (i / trail.length);
      final double r = baseRadius * (0.25 + 0.55 * ratio);
      final double alpha = (0.24 * ratio * ratio).clamp(0.0, 1.0);

      _fillPaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(trail[i], r, _fillPaint);
    }
  }

  void _drawStriker(Canvas canvas, _StrikerEntity striker) {
    final c = striker.pos;
    final r = striker.radius;
    final color = striker.color;

    // 1. Soft layered ambient halo (layered alpha: 120 FPS on all GPUs)
    _fillPaint.color = color.withValues(alpha: 0.12);
    canvas.drawCircle(c, r * 1.6, _fillPaint);
    _fillPaint.color = color.withValues(alpha: 0.22);
    canvas.drawCircle(c, r * 1.25, _fillPaint);

    // 2. Drop shadow
    _fillPaint.color = Colors.black.withValues(alpha: 0.45);
    canvas.drawCircle(Offset(c.dx + 2, c.dy + 3), r, _fillPaint);

    // 3. Metallic base disc
    _fillPaint.color = const Color(0xFF0F1D28);
    canvas.drawCircle(c, r, _fillPaint);

    // 4. Gradient radial tint
    _fillPaint.shader = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.85,
      colors: [color.withValues(alpha: 0.45), Colors.transparent],
    ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, _fillPaint);
    _fillPaint.shader = null;

    // 5. Outer glowing rim ring
    _strokePaint
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 5.0;
    canvas.drawCircle(c, r, _strokePaint);

    // 6. Crisp neon rim edge
    _strokePaint
      ..color = color
      ..strokeWidth = 2.2;
    canvas.drawCircle(c, r, _strokePaint);

    // 7. Center grip knob
    final knobR = r * 0.35;
    _fillPaint.color = color;
    canvas.drawCircle(c, knobR, _fillPaint);
    _fillPaint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(c, knobR, _fillPaint);

    // 8. Specular highlight
    _fillPaint.color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(c.dx - knobR * 0.35, c.dy - knobR * 0.35),
      knobR * 0.3,
      _fillPaint,
    );
  }

  void _drawPuck(Canvas canvas, Offset c, double r) {
    // 1. Soft halo
    _fillPaint.color = NeonColors.cyan.withValues(alpha: 0.18);
    canvas.drawCircle(c, r * 2.0, _fillPaint);
    _fillPaint.color = NeonColors.cyan.withValues(alpha: 0.35);
    canvas.drawCircle(c, r * 1.3, _fillPaint);

    // 2. Bright body core
    _fillPaint.color = const Color(0xFFD8F9FF);
    canvas.drawCircle(c, r, _fillPaint);

    // 3. Crisp neon rim
    _strokePaint
      ..color = NeonColors.cyan
      ..strokeWidth = 2.0;
    canvas.drawCircle(c, r, _strokePaint);

    // 4. Core laser
    _fillPaint.color = Colors.white;
    canvas.drawCircle(c, r * 0.35, _fillPaint);

    // 5. Specular highlight
    _fillPaint.color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(
      Offset(c.dx - r * 0.3, c.dy - r * 0.3),
      r * 0.22,
      _fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DuelPainter oldDelegate) => false;
}
