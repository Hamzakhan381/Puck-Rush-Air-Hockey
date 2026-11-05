import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/neon_colors.dart';
import '../../domain/models/difficulty.dart';
import '../../domain/models/game_mode.dart';
import '../../domain/usecases/game_engine.dart';

class ShockwaveRipple {
  ShockwaveRipple({
    required this.center,
    required this.color,
    required this.maxRadius,
    this.progress = 0.0,
  });
  final Offset center;
  final Color color;
  final double maxRadius;
  double progress; // 0.0 -> 1.0
}

class SparkParticle {
  SparkParticle({
    required this.pos,
    required this.vel,
    required this.color,
    this.life = 1.0,
  });
  Offset pos;
  Offset vel;
  final Color color;
  double life; // 1.0 -> 0.0
}

class GameController extends ChangeNotifier {
  GameController({
    required this.mode,
    required this.maxScore,
    this.difficulty = Difficulty.medium,
    required TickerProvider vsync,
  }) {
    _engine = GameEngine()..difficulty = difficulty;
    _engine.onHit = (pos, isMalletHit, isBoosted) {
      _spawnCollisionEffects(pos, isMalletHit: isMalletHit, isBoosted: isBoosted);
    };
    _engine.onGoalScored = (playerScored) {
      _spawnGoalEffects(playerScored);
    };

    _ticker = vsync.createTicker(_onTick)..start();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!paused) {
        elapsed++;
      }
    });
  }

  final GameMode mode;
  final int maxScore;
  final Difficulty difficulty;
  
  late final GameEngine _engine;
  late final Ticker _ticker;
  Timer? _clock;

  Duration _lastTick = Duration.zero;
  int elapsed = 0;
  bool paused = false;
  bool _disposed = false;
  final Random _rng = Random();

  // Dynamic visual effects
  final List<Offset> puckTrail = [];
  final List<ShockwaveRipple> ripples = [];
  final List<SparkParticle> sparks = [];
  double goalFlashAlpha = 0.0;
  Color goalFlashColor = Colors.transparent;
  double arenaTime = 0.0;

  // Expose state
  Offset get puck => _engine.puck;
  Offset get player => _engine.player;
  Offset get ai => _engine.ai;
  int get playerScore => _engine.playerScore;
  int get aiScore => _engine.aiScore;
  bool get twoPlayer => mode == GameMode.local2P;

  // Power-up state
  bool get shieldActive => _engine.shieldActive;
  double get shieldRemaining => _engine.shieldRemaining;
  double get shieldCooldown => _engine.shieldCooldown;
  double get shieldHitFlash => _engine.shieldHitFlash;
  bool get isShieldReady => _engine.shieldCooldown <= 0 && !_engine.shieldActive;
  double get shieldProgress {
    if (_engine.shieldActive) {
      return (_engine.shieldRemaining / GameEngine.shieldTotalDuration).clamp(0.0, 1.0);
    }
    if (_engine.shieldCooldown > 0) {
      return (1.0 - _engine.shieldCooldown / GameEngine.shieldTotalCooldown).clamp(0.0, 1.0);
    }
    return 1.0;
  }

  bool get boostActive => _engine.boostActive;
  double get boostRemaining => _engine.boostRemaining;
  double get boostCooldown => _engine.boostCooldown;
  bool get isPuckBoosted => _engine.puckBoostTimer > 0;
  bool get isBoostReady => _engine.boostCooldown <= 0 && !_engine.boostActive;
  double get boostProgress {
    if (_engine.boostActive) {
      return (_engine.boostRemaining / GameEngine.boostTotalDuration).clamp(0.0, 1.0);
    }
    if (_engine.boostCooldown > 0) {
      return (1.0 - _engine.boostCooldown / GameEngine.boostTotalCooldown).clamp(0.0, 1.0);
    }
    return 1.0;
  }

  // P2 Power-up state
  bool get p2ShieldActive => _engine.p2ShieldActive;
  double get p2ShieldRemaining => _engine.p2ShieldRemaining;
  double get p2ShieldCooldown => _engine.p2ShieldCooldown;
  double get p2ShieldHitFlash => _engine.p2ShieldHitFlash;
  bool get isP2ShieldReady => _engine.p2ShieldCooldown <= 0 && !_engine.p2ShieldActive;
  double get p2ShieldProgress {
    if (_engine.p2ShieldActive) {
      return (_engine.p2ShieldRemaining / GameEngine.shieldTotalDuration).clamp(0.0, 1.0);
    }
    if (_engine.p2ShieldCooldown > 0) {
      return (1.0 - _engine.p2ShieldCooldown / GameEngine.shieldTotalCooldown).clamp(0.0, 1.0);
    }
    return 1.0;
  }

  bool get p2BoostActive => _engine.p2BoostActive;
  double get p2BoostRemaining => _engine.p2BoostRemaining;
  double get p2BoostCooldown => _engine.p2BoostCooldown;
  bool get isP2BoostReady => _engine.p2BoostCooldown <= 0 && !_engine.p2BoostActive;
  double get p2BoostProgress {
    if (_engine.p2BoostActive) {
      return (_engine.p2BoostRemaining / GameEngine.boostTotalDuration).clamp(0.0, 1.0);
    }
    if (_engine.p2BoostCooldown > 0) {
      return (1.0 - _engine.p2BoostCooldown / GameEngine.boostTotalCooldown).clamp(0.0, 1.0);
    }
    return 1.0;
  }

  void activateShield({bool forP2 = false}) {
    if (paused) return;
    if (_engine.activateShield(forP2: forP2)) {
      notifyListeners();
    }
  }

  void activateBoost({bool forP2 = false}) {
    if (paused) return;
    if (_engine.activateBoost(forP2: forP2)) {
      notifyListeners();
    }
  }
  
  // Callback for when the game ends
  void Function(bool playerWon)? onGameOver;
  
  void layoutTable(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (size != _engine.table) {
      _engine.layoutTable(size);
      _engine.serve(towardAi: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) {
          notifyListeners();
        }
      });
    }
  }

  void _spawnCollisionEffects(Offset pos, {required bool isMalletHit, required bool isBoosted}) {
    if (ripples.length > 8) ripples.removeAt(0);
    final color = isBoosted
        ? const Color(0xFFFFB703)
        : (isMalletHit ? NeonColors.cyan : const Color(0xFF64D2FF));

    ripples.add(
      ShockwaveRipple(
        center: pos,
        color: color,
        maxRadius: isBoosted ? 52.0 : (isMalletHit ? 36.0 : 22.0),
      ),
    );

    // Spawn vibrant flying sparks
    final count = isBoosted ? 12 : (isMalletHit ? 7 : 4);
    for (int i = 0; i < count; i++) {
      if (sparks.length > 36) sparks.removeAt(0);
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = (isBoosted ? 260.0 : 160.0) + _rng.nextDouble() * 120.0;
      sparks.add(
        SparkParticle(
          pos: pos,
          vel: Offset(cos(angle) * speed, sin(angle) * speed),
          color: isBoosted
              ? (_rng.nextBool() ? const Color(0xFFFF9E00) : const Color(0xFFFFD60A))
              : (_rng.nextBool() ? NeonColors.cyan : Colors.white),
        ),
      );
    }
  }

  void _spawnGoalEffects(bool playerScored) {
    goalFlashAlpha = 1.0;
    goalFlashColor = playerScored ? NeonColors.green : NeonColors.coral;

    final goalCenter = playerScored
        ? Offset(_engine.table.width / 2, 16)
        : Offset(_engine.table.width / 2, _engine.table.height - 16);

    // Expanding celebration ripples
    for (int r = 0; r < 3; r++) {
      ripples.add(
        ShockwaveRipple(
          center: goalCenter,
          color: goalFlashColor,
          maxRadius: 80.0 + r * 30.0,
          progress: -r * 0.15,
        ),
      );
    }

    // Celebratory spark shower
    for (int i = 0; i < 20; i++) {
      if (sparks.length > 50) sparks.removeAt(0);
      final angle = playerScored
          ? (pi * 0.15 + _rng.nextDouble() * pi * 0.7)
          : (-pi * 0.85 + _rng.nextDouble() * pi * 0.7);
      final speed = 180.0 + _rng.nextDouble() * 260.0;
      sparks.add(
        SparkParticle(
          pos: goalCenter,
          vel: Offset(cos(angle) * speed, sin(angle) * speed),
          color: _rng.nextBool() ? goalFlashColor : Colors.white,
          life: 1.2,
        ),
      );
    }
  }

  void _onTick(Duration currentElapsed) {
    if (paused || _engine.table == Size.zero) {
      _lastTick = currentElapsed;
      return;
    }

    double dt = (currentElapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = currentElapsed;
    if (dt <= 0) return;
    if (dt > 0.05) dt = 0.05;

    arenaTime += dt;

    // Update puck comet trail
    if (!_engine.scoring) {
      final puckSpeedSq = _engine.puckVel.distanceSquared;
      if (puckSpeedSq > 900) {
        puckTrail.add(_engine.puck);
        if (puckTrail.length > 10) {
          puckTrail.removeAt(0);
        }
      } else if (puckTrail.isNotEmpty) {
        puckTrail.removeAt(0);
      }
    } else if (puckTrail.isNotEmpty) {
      puckTrail.removeAt(0);
    }

    // Update shockwave ripples
    for (int i = ripples.length - 1; i >= 0; i--) {
      ripples[i].progress += dt * 3.2;
      if (ripples[i].progress >= 1.0) {
        ripples.removeAt(i);
      }
    }

    // Update flying sparks
    for (int i = sparks.length - 1; i >= 0; i--) {
      final s = sparks[i];
      s.pos += s.vel * dt;
      s.vel *= 0.93;
      s.life -= dt * 2.5;
      if (s.life <= 0) {
        sparks.removeAt(i);
      }
    }

    // Fade goal flash
    if (goalFlashAlpha > 0) {
      goalFlashAlpha = (goalFlashAlpha - dt * 2.2).clamp(0.0, 1.0);
    }

    if (!_engine.scoring) {
      final scored = _engine.update(dt, twoPlayer: twoPlayer);
      if (scored) {
        _handleScore();
      }
    }

    notifyListeners();
  }
  
  void _handleScore() {
    if (_engine.playerScore >= maxScore || _engine.aiScore >= maxScore) {
      _ticker.stop();
      onGameOver?.call(_engine.playerScore > _engine.aiScore);
      return;
    }

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (_disposed) return;
      bool playerScored = _engine.puck.dy < _engine.table.height / 2;
      _engine.serve(towardAi: playerScored);
      notifyListeners();
    });
  }
  
  void togglePause() {
    paused = !paused;
    notifyListeners();
  }
  
  void updatePlayerMallet(Offset pos, {required bool topHalf}) {
    if (paused) return;
    final clamped = _engine.clampMallet(pos, topHalf: topHalf);
    if (topHalf) {
      // Only notify if mallet actually moved (avoids jitter repaints)
      if ((_engine.ai - clamped).distanceSquared < 0.25) return;
      _engine.ai = clamped;
    } else {
      if ((_engine.player - clamped).distanceSquared < 0.25) return;
      _engine.player = clamped;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.dispose();
    _clock?.cancel();
    super.dispose();
  }
}
