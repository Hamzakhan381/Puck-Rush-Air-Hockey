import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/state/game_app_state.dart';
import '../../core/theme/neon_colors.dart';
import '../../domain/models/difficulty.dart';
import '../../domain/models/game_mode.dart';
import '../controllers/game_controller.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/table_painter.dart';
import 'victory_screen.dart';

class LiveMatchScreen extends StatefulWidget {
  const LiveMatchScreen({
    super.key,
    required this.mode,
    this.difficulty = Difficulty.medium,
    this.maxScore = 7,
  });

  final GameMode mode;
  final Difficulty difficulty;
  final int maxScore;

  @override
  State<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends State<LiveMatchScreen>
    with SingleTickerProviderStateMixin {
  late final GameController _controller;
  int? _p1Pointer;
  int? _p2Pointer;

  bool _hasTouchedTable = false;
  int _lastPlayerScore = 0;
  int _lastAiScore = 0;


  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller = GameController(
      mode: widget.mode,
      difficulty: widget.difficulty,
      maxScore: widget.maxScore,
      vsync: this,
    );
    _controller.onGameOver = _handleGameOver;
    _controller.addListener(_checkScoreChange);
  }

  void _checkScoreChange() {
    if (_controller.playerScore > _lastPlayerScore) {
      _lastPlayerScore = _controller.playerScore;
      if (GameAppState.instance.hapticsEnabled) {
        HapticFeedback.heavyImpact();
      }
    } else if (_controller.aiScore > _lastAiScore) {
      _lastAiScore = _controller.aiScore;
      if (GameAppState.instance.hapticsEnabled) {
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _handleGameOver(bool playerWon) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VictoryScreen(
          playerScore: _controller.playerScore,
          opponentScore: _controller.aiScore,
          playerWon: playerWon,
          elapsedSeconds: _controller.elapsed,
          mode: widget.mode,
          difficulty: widget.difficulty,
          maxScore: widget.maxScore,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_checkScoreChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = widget.difficulty.color;

    return Scaffold(
      backgroundColor: const Color(0xFF04080F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050D1A), Color(0xFF030709)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── HUD Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1520).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: NeonColors.cyan.withValues(alpha: 0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: NeonColors.cyan.withValues(alpha: 0.08),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Back button
                      _HudIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),

                      // Score display
                      Expanded(
                        child: ListenableBuilder(
                          listenable: _controller,
                          builder: (context, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _TeamBadge(
                                  label: _controller.twoPlayer ? 'P1' : 'YOU',
                                  score: _controller.playerScore,
                                  color: NeonColors.green,
                                  isLeft: true,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'VS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white24,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'TO ${widget.maxScore}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white24,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _TeamBadge(
                                  label: _controller.twoPlayer ? 'P2' : 'AI',
                                  score: _controller.aiScore,
                                  color: NeonColors.coral,
                                  isLeft: false,
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Pause button
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          return _HudIconButton(
                            icon: _controller.paused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            onTap: _controller.togglePause,
                            color: _controller.paused
                                ? NeonColors.green
                                : NeonColors.onSurface,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Difficulty + Mode badge
              if (!_controller.twoPlayer)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: diffColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: diffColor.withValues(alpha: 0.45), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.difficulty.icon, color: diffColor, size: 11),
                        const SizedBox(width: 5),
                        Text(
                          '${widget.difficulty.label.toUpperCase()} AI',
                          style: TextStyle(
                            color: diffColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 6),

              // ── Player 2 Power-Ups (In 2P Mode) ─────────────────────────
              if (_controller.twoPlayer)
                Transform.rotate(
                  angle: math.pi, // Rotated 180° for Player 2 facing from top!
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return Row(
                          children: [
                            // P2 Shield Button
                            Expanded(
                              child: _PowerUpButton(
                                title: 'P2 SHIELD',
                                subtitle: _controller.p2ShieldActive
                                    ? '${_controller.p2ShieldRemaining.toStringAsFixed(1)}s'
                                    : (_controller.p2ShieldCooldown > 0
                                        ? '${_controller.p2ShieldCooldown.toStringAsFixed(0)}s'
                                        : 'READY'),
                                icon: Icons.shield_rounded,
                                accentColor: NeonColors.cyan,
                                isActive: _controller.p2ShieldActive,
                                isReady: _controller.isP2ShieldReady,
                                progress: _controller.p2ShieldProgress,
                                onTap: () {
                                  if (_controller.isP2ShieldReady) {
                                    HapticFeedback.heavyImpact();
                                    _controller.activateShield(forP2: true);
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            // P2 Boost Button
                            Expanded(
                              child: _PowerUpButton(
                                title: 'P2 BOOST',
                                subtitle: _controller.p2BoostActive
                                    ? '${_controller.p2BoostRemaining.toStringAsFixed(1)}s'
                                    : (_controller.p2BoostCooldown > 0
                                        ? '${_controller.p2BoostCooldown.toStringAsFixed(0)}s'
                                        : 'READY'),
                                icon: Icons.bolt_rounded,
                                accentColor: const Color(0xFFFF9E00),
                                isActive: _controller.p2BoostActive,
                                isReady: _controller.isP2BoostReady,
                                progress: _controller.p2BoostProgress,
                                onTap: () {
                                  if (_controller.isP2BoostReady) {
                                    HapticFeedback.heavyImpact();
                                    _controller.activateBoost(forP2: true);
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

              // ── Game Table ──────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(constraints.maxWidth, constraints.maxHeight);
                      _controller.layoutTable(size);

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Table Gesture listener & CustomPaint
                            Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: (e) {
                                if (!_hasTouchedTable) {
                                  setState(() => _hasTouchedTable = true);
                                }
                                if (_controller.paused) return;
                                final p = e.localPosition;
                                if (_controller.twoPlayer && p.dy < size.height / 2) {
                                  _p2Pointer = e.pointer;
                                  _controller.updatePlayerMallet(p, topHalf: true);
                                } else if (p.dy >= size.height / 2) {
                                  _p1Pointer = e.pointer;
                                  _controller.updatePlayerMallet(p, topHalf: false);
                                }
                              },
                              onPointerMove: (e) {
                                if (_controller.paused) return;
                                if (e.pointer == _p1Pointer) {
                                  _controller.updatePlayerMallet(e.localPosition, topHalf: false);
                                } else if (e.pointer == _p2Pointer) {
                                  _controller.updatePlayerMallet(e.localPosition, topHalf: true);
                                }
                              },
                              onPointerUp: (e) {
                                if (e.pointer == _p1Pointer) _p1Pointer = null;
                                if (e.pointer == _p2Pointer) _p2Pointer = null;
                              },
                              onPointerCancel: (e) {
                                if (e.pointer == _p1Pointer) _p1Pointer = null;
                                if (e.pointer == _p2Pointer) _p2Pointer = null;
                              },
                              child: CustomPaint(
                                size: size,
                                painter: TablePainter(_controller),
                              ),
                            ),

                            // Beginner Onboarding Hint
                            if (!_hasTouchedTable)
                              Positioned(
                                bottom: size.height * 0.16,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: NeonColors.cyan.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: NeonColors.cyan, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: NeonColors.cyan.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.touch_app_rounded, color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'DRAG MALLET TO HIT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),



                            // Interactive Pause Menu Overlay
                            ListenableBuilder(
                              listenable: _controller,
                              builder: (context, _) {
                                if (!_controller.paused) return const SizedBox.shrink();
                                return Container(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Container(
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F1829),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: NeonColors.cyan, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: NeonColors.cyan.withValues(alpha: 0.25),
                                          blurRadius: 28,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'GAME PAUSED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _PauseMenuAction(
                                          label: 'RESUME MATCH',
                                          icon: Icons.play_circle_fill_rounded,
                                          color: NeonColors.green,
                                          onTap: _controller.togglePause,
                                        ),
                                        const SizedBox(height: 10),
                                        _PauseMenuAction(
                                          label: 'HOW TO PLAY',
                                          icon: Icons.help_outline_rounded,
                                          color: NeonColors.gold,
                                          onTap: () => HowToPlayDialog.show(context),
                                        ),
                                        const SizedBox(height: 10),
                                        _PauseMenuAction(
                                          label: 'EXIT TO HUB',
                                          icon: Icons.exit_to_app_rounded,
                                          color: NeonColors.coral,
                                          onTap: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Power-Up Controls (Shield on Left, Boost on Right) ──────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return Row(
                      children: [
                        // Left: Shield Button
                        Expanded(
                          child: _PowerUpButton(
                            title: _controller.twoPlayer ? 'P1 SHIELD' : 'SHIELD',
                            subtitle: _controller.shieldActive
                                ? '${_controller.shieldRemaining.toStringAsFixed(1)}s'
                                : (_controller.shieldCooldown > 0
                                    ? '${_controller.shieldCooldown.toStringAsFixed(0)}s'
                                    : 'READY'),
                            icon: Icons.shield_rounded,
                            accentColor: NeonColors.cyan,
                            isActive: _controller.shieldActive,
                            isReady: _controller.isShieldReady,
                            progress: _controller.shieldProgress,
                            onTap: () {
                              if (_controller.isShieldReady) {
                                HapticFeedback.heavyImpact();
                                _controller.activateShield();
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Right: Boost Button
                        Expanded(
                          child: _PowerUpButton(
                            title: _controller.twoPlayer ? 'P1 BOOST' : 'BOOST',
                            subtitle: _controller.boostActive
                                ? '${_controller.boostRemaining.toStringAsFixed(1)}s'
                                : (_controller.boostCooldown > 0
                                    ? '${_controller.boostCooldown.toStringAsFixed(0)}s'
                                    : 'READY'),
                            icon: Icons.bolt_rounded,
                            accentColor: const Color(0xFFFF9E00),
                            isActive: _controller.boostActive,
                            isReady: _controller.isBoostReady,
                            progress: _controller.boostProgress,
                            onTap: () {
                              if (_controller.isBoostReady) {
                                HapticFeedback.heavyImpact();
                                _controller.activateBoost();
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _HudIconButton extends StatelessWidget {
  const _HudIconButton({
    required this.icon,
    required this.onTap,
    this.color = NeonColors.onSurface,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({
    required this.label,
    required this.score,
    required this.color,
    required this.isLeft,
  });
  final String label;
  final int score;
  final Color color;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final scoreWidget = Text(
      '$score',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: color,
        height: 1,
        shadows: [
          Shadow(color: color, blurRadius: 12),
          Shadow(color: color, blurRadius: 24),
        ],
      ),
    );
    final labelWidget = Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w900,
        color: color.withValues(alpha: 0.8),
        letterSpacing: 1.5,
      ),
    );
    return isLeft
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [labelWidget, scoreWidget],
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [labelWidget, scoreWidget],
              ),
            ],
          );
  }
}

class _PowerUpButton extends StatelessWidget {
  const _PowerUpButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isActive,
    required this.isReady,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isActive;
  final bool isReady;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive
        ? accentColor
        : (isReady ? accentColor.withValues(alpha: 0.8) : accentColor.withValues(alpha: 0.22));

    final bgColor = isActive
        ? accentColor.withValues(alpha: 0.18)
        : (isReady ? accentColor.withValues(alpha: 0.08) : const Color(0xFF070E18));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isActive ? 2 : (isReady ? 1.5 : 1),
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 1,
              )
            else if (isReady)
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon with cooldown circle indicator
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!isReady && !isActive)
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.5,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(accentColor.withValues(alpha: 0.6)),
                    ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: (isActive ? accentColor : Colors.white).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isReady || isActive ? accentColor : Colors.white30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Text info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isReady || isActive ? Colors.white : Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: isActive
                          ? accentColor
                          : (isReady ? NeonColors.green : Colors.white30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseMenuAction extends StatelessWidget {
  const _PauseMenuAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color, width: 1.5),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
