import 'dart:math';
import 'dart:ui';
import '../models/difficulty.dart';

class GameEngine {
  static const double rail = 18;
  static const double puckR = 14;
  static const double malletR = 28;

  Size table = Size.zero;
  Offset puck = Offset.zero;
  Offset puckVel = Offset.zero;
  Offset player = Offset.zero;
  Offset ai = Offset.zero;

  int playerScore = 0;
  int aiScore = 0;
  bool scoring = false;

  Difficulty difficulty = Difficulty.medium;

  final Random _rng = Random();

  void Function(Offset pos, bool isMalletHit, bool isBoosted)? onHit;
  void Function(bool playerScored)? onGoalScored;

  static const double shieldTotalDuration = 5.0;
  static const double shieldTotalCooldown = 12.0;
  static const double boostTotalDuration = 4.0;
  static const double boostTotalCooldown = 10.0;

  // P1 Power-ups
  bool shieldActive = false;
  double shieldRemaining = 0.0;
  double shieldCooldown = 0.0;
  double shieldHitFlash = 0.0;

  bool boostActive = false;
  double boostRemaining = 0.0;
  double boostCooldown = 0.0;
  double puckBoostTimer = 0.0;

  // P2 Power-ups (for local 2P mode)
  bool p2ShieldActive = false;
  double p2ShieldRemaining = 0.0;
  double p2ShieldCooldown = 0.0;
  double p2ShieldHitFlash = 0.0;

  bool p2BoostActive = false;
  double p2BoostRemaining = 0.0;
  double p2BoostCooldown = 0.0;

  bool activateShield({bool forP2 = false}) {
    if (forP2) {
      if (p2ShieldCooldown <= 0 && !p2ShieldActive) {
        p2ShieldActive = true;
        p2ShieldRemaining = shieldTotalDuration;
        return true;
      }
      return false;
    }
    if (shieldCooldown <= 0 && !shieldActive) {
      shieldActive = true;
      shieldRemaining = shieldTotalDuration;
      return true;
    }
    return false;
  }

  bool activateBoost({bool forP2 = false}) {
    if (forP2) {
      if (p2BoostCooldown <= 0 && !p2BoostActive) {
        p2BoostActive = true;
        p2BoostRemaining = boostTotalDuration;
        return true;
      }
      return false;
    }
    if (boostCooldown <= 0 && !boostActive) {
      boostActive = true;
      boostRemaining = boostTotalDuration;
      return true;
    }
    return false;
  }

  // Accumulated time for AI animation, avoids DateTime.now() in hot loop
  double _aiTime = 0.0;
  double _stuckTimer = 0.0;

  void layoutTable(Size size) {
    if (size == table || size.width <= 0 || size.height <= 0) return;
    table = size;
    player = Offset(size.width / 2, size.height * 0.78);
    ai = Offset(size.width / 2, size.height * 0.22);
  }

  void serve({required bool towardAi}) {
    puck = Offset(table.width / 2, table.height / 2);
    puckBoostTimer = 0.0;
    _stuckTimer = 0.0;
    final speedMultiplier = difficulty == Difficulty.insane ? 1.25 : (difficulty == Difficulty.easy ? 0.85 : 1.0);
    puckVel = Offset(
      (_rng.nextDouble() - 0.5) * 180 * speedMultiplier,
      (towardAi ? -1 : 1) * (240 + _rng.nextDouble() * 80) * speedMultiplier,
    );
    scoring = false;
  }

  bool update(double dt, {required bool twoPlayer}) {
    if (scoring || table == Size.zero) return false;

    _aiTime += dt;
    if (!twoPlayer) _updateAi(dt);

    // Power-up timers
    if (shieldActive) {
      shieldRemaining -= dt;
      if (shieldRemaining <= 0) {
        shieldRemaining = 0;
        shieldActive = false;
        shieldCooldown = shieldTotalCooldown;
      }
    } else if (shieldCooldown > 0) {
      shieldCooldown = max(0.0, shieldCooldown - dt);
    }

    if (shieldHitFlash > 0) {
      shieldHitFlash = max(0.0, shieldHitFlash - dt * 3.0);
    }

    if (boostActive) {
      boostRemaining -= dt;
      if (boostRemaining <= 0) {
        boostRemaining = 0;
        boostActive = false;
        boostCooldown = boostTotalCooldown;
      }
    } else if (boostCooldown > 0) {
      boostCooldown = max(0.0, boostCooldown - dt);
    }

    if (puckBoostTimer > 0) {
      puckBoostTimer = max(0.0, puckBoostTimer - dt);
    }

    // P2 Power-up timers
    if (twoPlayer) {
      if (p2ShieldActive) {
        p2ShieldRemaining -= dt;
        if (p2ShieldRemaining <= 0) {
          p2ShieldRemaining = 0;
          p2ShieldActive = false;
          p2ShieldCooldown = shieldTotalCooldown;
        }
      } else if (p2ShieldCooldown > 0) {
        p2ShieldCooldown = max(0.0, p2ShieldCooldown - dt);
      }

      if (p2ShieldHitFlash > 0) {
        p2ShieldHitFlash = max(0.0, p2ShieldHitFlash - dt * 3.0);
      }

      if (p2BoostActive) {
        p2BoostRemaining -= dt;
        if (p2BoostRemaining <= 0) {
          p2BoostRemaining = 0;
          p2BoostActive = false;
          p2BoostCooldown = boostTotalCooldown;
        }
      } else if (p2BoostCooldown > 0) {
        p2BoostCooldown = max(0.0, p2BoostCooldown - dt);
      }
    }

    var pos = puck + puckVel * dt;
    var vel = puckVel * pow(0.995, dt * 60).toDouble();

    // Prevent puck from permanently stalling anywhere on table (e.g. 0 speed dead-puck)
    if (vel.distance < 20.0) {
      _stuckTimer += dt;
      if (_stuckTimer > 2.5) {
        // Table air-blower pulse to keep puck in dynamic play
        final nudgeY = pos.dy < table.height * 0.5 ? 160.0 : -160.0;
        final dirX = (table.width / 2 - pos.dx).sign;
        final nudgeX = (dirX == 0 ? 1.0 : dirX) * 90.0;
        vel = Offset(nudgeX, nudgeY);
        _stuckTimer = 0.0;
      }
    } else {
      _stuckTimer = 0.0;
    }

    final minX = rail + puckR;
    final maxX = table.width - rail - puckR;
    final minY = rail + puckR;
    final maxY = table.height - rail - puckR;
    final goalW = table.width * 0.38;
    final goalLeft = (table.width - goalW) / 2;
    final goalRight = goalLeft + goalW;
    final inGoalX = pos.dx > goalLeft + puckR && pos.dx < goalRight - puckR;

    bool scored = false;

    if (pos.dx < minX) {
      pos = Offset(minX, pos.dy);
      vel = Offset(max(vel.dx.abs(), 100.0), vel.dy);
      onHit?.call(pos, false, false);
    } else if (pos.dx > maxX) {
      pos = Offset(maxX, pos.dy);
      vel = Offset(min(-vel.dx.abs(), -100.0), vel.dy);
      onHit?.call(pos, false, false);
    }

    if (pos.dy < minY) {
      if (inGoalX) {
        if (twoPlayer && p2ShieldActive) {
          // P2 Shield protects top goal! Deflect puck downward
          pos = Offset(pos.dx, minY);
          final bounceSpeed = max(vel.dy.abs() * 1.3, 440.0);
          vel = Offset(vel.dx, bounceSpeed);
          p2ShieldHitFlash = 1.0;
          onHit?.call(pos, false, true);
        } else {
          playerScore++;
          scored = true;
          onGoalScored?.call(true);
        }
      } else {
        pos = Offset(pos.dx, minY);
        vel = Offset(vel.dx, max(vel.dy.abs(), 100.0));
        onHit?.call(pos, false, false);
      }
    } else if (pos.dy > maxY) {
      if (inGoalX) {
        if (shieldActive) {
          // Shield protects the player's goal! Deflect puck upward
          pos = Offset(pos.dx, maxY);
          final bounceSpeed = max(vel.dy.abs() * 1.3, 440.0);
          vel = Offset(vel.dx, -bounceSpeed);
          shieldHitFlash = 1.0;
          onHit?.call(pos, false, true);
        } else {
          aiScore++;
          scored = true;
          onGoalScored?.call(false);
        }
      } else {
        pos = Offset(pos.dx, maxY);
        vel = Offset(vel.dx, min(-vel.dy.abs(), -100.0));
        onHit?.call(pos, false, false);
      }
    }

    if (!scored) {
      final playerHit = _hit(pos, vel, player, malletR, isAi: false, twoPlayer: twoPlayer);
      pos = playerHit.$1;
      vel = playerHit.$2;
      final aiHit = _hit(pos, vel, ai, malletR, isAi: true, twoPlayer: twoPlayer);
      pos = aiHit.$1;
      vel = aiHit.$2;
    }

    puck = pos;
    puckVel = vel;
    
    if (scored) scoring = true;
    return scored;
  }

  (Offset, Offset) _hit(Offset puck, Offset vel, Offset mallet, double malletR, {required bool isAi, bool twoPlayer = false}) {
    final delta = puck - mallet;
    final dist = delta.distance;
    final minDist = puckR + malletR;
    if (dist <= 0 || dist >= minDist) return (puck, vel);

    final isBoostedHit = isAi ? (twoPlayer && p2BoostActive) : boostActive;
    onHit?.call((puck + mallet) / 2, true, isBoostedHit);

    final n = delta / dist;
    var out = vel;
    if (out.dx * n.dx + out.dy * n.dy < 0) {
      out = out - n * 2 * (out.dx * n.dx + out.dy * n.dy);
    }

    // AI / Player power tuning
    double bonusImpulse = 280;
    double maxSpeed = 980;
    if (isAi) {
      if (twoPlayer && p2BoostActive) {
        // P2 Super Boost shot!
        bonusImpulse = 680;
        maxSpeed = 1650;
        puckBoostTimer = 1.6;
      } else {
        switch (difficulty) {
          case Difficulty.easy:
            bonusImpulse = 180;
            maxSpeed = 650;
            break;
          case Difficulty.medium:
            bonusImpulse = 280;
            maxSpeed = 950;
            break;
          case Difficulty.hard:
            bonusImpulse = 360;
            maxSpeed = 1150;
            break;
          case Difficulty.insane:
            bonusImpulse = 460;
            maxSpeed = 1400;
            break;
        }
      }
    } else if (boostActive) {
      // P1 Super Boost shot!
      bonusImpulse = 680;
      maxSpeed = 1650;
      puckBoostTimer = 1.6;
    }

    out += n * bonusImpulse;
    final speed = out.distance.clamp(0.0, maxSpeed);
    final bounced = out == Offset.zero ? n * bonusImpulse : (out / out.distance) * speed;
    return (mallet + n * minDist, bounced);
  }

  void _updateAi(double dt) {
    final mid = table.height / 2;
    final maxAiY = mid - malletR;
    final minAiY = rail + malletR;
    final defendY = table.height * 0.18;
    // The puck can be reached by the AI mallet if its center is within aiReachY
    final aiReachY = mid + puckR;

    double targetX = puck.dx;
    double chaseY = defendY;
    final lerpSpeed = difficulty.aiLerpSpeed;

    // Is the puck in the AI's half or reachable near the centerline?
    final inAiZone = puck.dy <= aiReachY;

    if (inAiZone) {
      if (puck.dy < ai.dy) {
        // Puck slipped behind AI: avoid own-goal by maneuvering laterally and retreating behind puck
        final avoidRight = puck.dx < table.width / 2;
        targetX = avoidRight ? puck.dx + malletR + 30 : puck.dx - malletR - 30;
        chaseY = (puck.dy - malletR - 15).clamp(minAiY, defendY);
      } else {
        // Puck is in front of AI in AI's territory: ATTACK & TAKE OVER!
        switch (difficulty) {
          case Difficulty.easy:
            // Slower reactions, intentional jitter/error
            final wobble = sin(_aiTime * (1000 / 300)) * 35;
            targetX = puck.dx + wobble;
            chaseY = (puck.dy + 15).clamp(minAiY, maxAiY);
            break;

          case Difficulty.medium:
            // Direct offensive charge
            targetX = puck.dx;
            chaseY = (puck.dy + 20).clamp(minAiY, maxAiY);
            break;

          case Difficulty.hard:
            if (puckVel.dy < -50) {
              targetX = puck.dx + (puckVel.dx * 0.15);
            } else {
              // Angled attack on loose/stationary puck
              final angleOffset = puck.dx < table.width / 2 ? 10.0 : -10.0;
              targetX = puck.dx + angleOffset;
            }
            chaseY = (puck.dy + 25).clamp(minAiY, maxAiY);
            break;

          case Difficulty.insane:
            if (puckVel.dy < -50) {
              // Hyper-fast predictive tracking with wall bounce reflection for fast incoming shots
              final timeToReach = ((ai.dy - puck.dy) / (puckVel.dy == 0 ? 1 : puckVel.dy)).abs();
              double predictedX = puck.dx + puckVel.dx * timeToReach;
              final minX = rail + puckR;
              final maxX = table.width - rail - puckR;
              while (predictedX < minX || predictedX > maxX) {
                if (predictedX < minX) {
                  predictedX = minX + (minX - predictedX);
                } else if (predictedX > maxX) {
                  predictedX = maxX - (predictedX - maxX);
                }
              }
              targetX = predictedX;
            } else {
              // Loose / stationary / floating puck takeover:
              // Smash aggressively towards player's undefended goal opening!
              if (player.dx >= table.width / 2) {
                // Player is defending right: aim for open left goal
                targetX = puck.dx + 16.0;
              } else {
                // Player is defending left: aim for open right goal
                targetX = puck.dx - 16.0;
              }
            }
            // Drive forcefully through the puck up to the maximum legal AI baseline
            chaseY = (puck.dy + 30).clamp(minAiY, maxAiY);
            break;
        }
      }
    } else {
      // Puck is on player's half of the table: guard AI goal and anticipate returns
      switch (difficulty) {
        case Difficulty.easy:
          final wobble = sin(_aiTime * (1000 / 300)) * 45;
          targetX = (puck.dx * 0.5 + (table.width / 2) * 0.5) + wobble;
          chaseY = defendY;
          break;

        case Difficulty.medium:
          targetX = puck.dx * 0.7 + (table.width / 2) * 0.3;
          chaseY = defendY;
          break;

        case Difficulty.hard:
          if (puckVel.dy < 0) {
            targetX = puck.dx + (puckVel.dx * 0.12);
            chaseY = defendY + 20;
          } else {
            targetX = puck.dx * 0.75 + (table.width / 2) * 0.25;
            chaseY = defendY;
          }
          break;

        case Difficulty.insane:
          if (puckVel.dy < 0) {
            // Anticipate incoming line early
            final timeToReach = ((defendY - puck.dy) / (puckVel.dy == 0 ? 1 : puckVel.dy)).abs();
            double predictedX = puck.dx + puckVel.dx * timeToReach;
            final minX = rail + puckR;
            final maxX = table.width - rail - puckR;
            while (predictedX < minX || predictedX > maxX) {
              if (predictedX < minX) {
                predictedX = minX + (minX - predictedX);
              } else if (predictedX > maxX) {
                predictedX = maxX - (predictedX - maxX);
              }
            }
            targetX = predictedX;
            chaseY = defendY + 15;
          } else {
            // Optimal defensive angle between puck and goal center
            targetX = puck.dx * 0.65 + (table.width / 2) * 0.35;
            chaseY = defendY;
          }
          break;
      }
    }

    final target = Offset(targetX, chaseY);
    final next = Offset.lerp(ai, target, (lerpSpeed * dt).clamp(0.0, 1.0))!;
    ai = clampMallet(next, topHalf: true);
  }

  Offset clampMallet(Offset pos, {required bool topHalf}) {
    if (table == Size.zero) return pos;
    final r = malletR;
    final minX = rail + r;
    final maxX = table.width - rail - r;
    final mid = table.height / 2;
    final minY = topHalf ? rail + r : mid + r;
    final maxY = topHalf ? mid - r : table.height - rail - r;
    return Offset(pos.dx.clamp(minX, maxX), pos.dy.clamp(minY, maxY));
  }
}
