import 'package:flutter/material.dart';
import '../../core/state/game_app_state.dart';
import '../../core/theme/neon_colors.dart';
import '../../domain/models/difficulty.dart';
import '../../domain/models/game_mode.dart';
import '../widgets/difficulty_dialog.dart';
import 'live_match_screen.dart';

class VictoryScreen extends StatefulWidget {
  const VictoryScreen({
    super.key,
    required this.playerScore,
    required this.opponentScore,
    required this.playerWon,
    required this.elapsedSeconds,
    required this.mode,
    this.difficulty = Difficulty.medium,
    this.maxScore = 7,
    this.maxSpeedKmh,
    this.longestRally,
    this.savesMade,
  });

  final int playerScore;
  final int opponentScore;
  final bool playerWon;
  final int elapsedSeconds;
  final GameMode mode;
  final Difficulty difficulty;
  final int maxScore;
  final int? maxSpeedKmh;
  final int? longestRally;
  final int? savesMade;

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack);
    _entryController.forward();
    GameAppState.instance.recordMatchResult(won: widget.playerWon);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _rematch(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LiveMatchScreen(
          mode: widget.mode,
          difficulty: widget.difficulty,
          maxScore: widget.maxScore,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _changeDifficulty(BuildContext context) {
    DifficultySelectionDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (widget.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (widget.elapsedSeconds % 60).toString().padLeft(2, '0');
    final won = widget.playerWon;
    final titleColor = won ? NeonColors.green : NeonColors.coral;
    final titleText = won ? 'VICTORY!' : 'DEFEAT';
    final subtitleText = won ? 'CHAMPION OF THE ARENA' : 'GREAT EFFORT! TRY AGAIN';
    final bgAccent = won ? const Color(0xFF0D2818) : const Color(0xFF280B18);

    return Scaffold(
      backgroundColor: const Color(0xFF040810),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              bgAccent,
              const Color(0xFF081020),
              const Color(0xFF03050C),
            ],
            center: const Alignment(0, -0.4),
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: ScaleTransition(
            scale: _entryAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // Animated Trophy / Puck Emblem
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseController, _ringController]),
                    builder: (context, _) {
                      final pulse = 0.94 + _pulseController.value * 0.08;
                      final ring = _ringController.value;
                      return Transform.scale(
                        scale: pulse,
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: ring * 6.28,
                                child: CustomPaint(
                                  size: const Size(150, 150),
                                  painter: _RingArcPainter(won ? NeonColors.gold : titleColor),
                                ),
                              ),
                              Container(
                                width: 116,
                                height: 116,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (won ? NeonColors.gold : titleColor).withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (won ? NeonColors.gold : titleColor).withValues(alpha: 0.35),
                                      blurRadius: 32,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (won ? NeonColors.gold : titleColor).withValues(alpha: 0.15),
                                ),
                                child: Icon(
                                  won ? Icons.emoji_events_rounded : Icons.sports_hockey,
                                  size: 52,
                                  color: won ? NeonColors.gold : titleColor,
                                  shadows: [
                                    Shadow(color: won ? NeonColors.gold : titleColor, blurRadius: 20),
                                    const Shadow(color: Colors.white, blurRadius: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Title with Cyber Glow
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: won
                          ? [const Color(0xFFFFBE0B), const Color(0xFF00FF88), Colors.white]
                          : [const Color(0xFFFF2A6D), const Color(0xFFFF758F), Colors.white],
                    ).createShader(bounds),
                    child: Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                        height: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitleText,
                    style: TextStyle(
                      color: won ? NeonColors.green : NeonColors.muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (widget.mode != GameMode.local2P)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.difficulty.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.difficulty.color.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        '${widget.difficulty.label.toUpperCase()} AI MODE',
                        style: TextStyle(
                          color: widget.difficulty.color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Scoreboard Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1728),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: titleColor.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: titleColor.withValues(alpha: 0.15),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.mode == GameMode.local2P ? 'PLAYER 1' : 'YOU',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: NeonColors.green,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              widget.mode == GameMode.local2P ? 'PLAYER 2' : 'AI OPPONENT',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: NeonColors.coral,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${widget.playerScore}',
                              style: const TextStyle(
                                fontSize: 62,
                                fontWeight: FontWeight.w900,
                                color: NeonColors.green,
                                height: 1,
                                shadows: [
                                  Shadow(color: NeonColors.green, blurRadius: 18),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            Text(
                              '${widget.opponentScore}',
                              style: const TextStyle(
                                fontSize: 62,
                                fontWeight: FontWeight.w900,
                                color: NeonColors.coral,
                                height: 1,
                                shadows: [
                                  Shadow(color: NeonColors.coral, blurRadius: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatChip(icon: Icons.timer_outlined, label: '$minutes:$seconds'),
                            const SizedBox(width: 12),
                            _StatChip(
                              icon: Icons.sports_score_rounded,
                              label: 'TO ${widget.maxScore} GOALS',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // PRIMARY ACTION: REMATCH (Tests check for exact 'REMATCH')
                  _NeonActionButton(
                    label: 'REMATCH',
                    color: NeonColors.cyan,
                    icon: Icons.refresh_rounded,
                    onTap: () => _rematch(context),
                  ),

                  const SizedBox(height: 12),

                  // Option to change difficulty (if in 1P mode)
                  if (widget.mode != GameMode.local2P)
                    _NeonActionButton(
                      label: 'CHANGE DIFFICULTY',
                      color: NeonColors.amber,
                      icon: Icons.psychology_rounded,
                      onTap: () => _changeDifficulty(context),
                      outlined: true,
                    ),

                  if (widget.mode != GameMode.local2P) const SizedBox(height: 12),

                  // MAIN MENU
                  _NeonActionButton(
                    label: 'MAIN MENU',
                    color: NeonColors.muted,
                    icon: Icons.home_rounded,
                    onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    outlined: true,
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingArcPainter extends CustomPainter {
  _RingArcPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      paint.color = color.withValues(alpha: 0.4 + i * 0.15);
      canvas.drawArc(Rect.fromCircle(center: center, radius: r), i * 1.57, 0.9, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingArcPainter old) => old.color != color;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: NeonColors.muted, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: NeonColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonActionButton extends StatefulWidget {
  const _NeonActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  State<_NeonActionButton> createState() => _NeonActionButtonState();
}

class _NeonActionButtonState extends State<_NeonActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSolid = !widget.outlined;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSolid
              ? (_pressed
                  ? widget.color.withValues(alpha: 0.45)
                  : widget.color.withValues(alpha: 0.22))
              : (_pressed ? widget.color.withValues(alpha: 0.15) : Colors.transparent),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _pressed ? widget.color : widget.color.withValues(alpha: 0.75),
            width: _pressed ? 2.2 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _pressed ? 0.45 : 0.15),
              blurRadius: _pressed ? 22 : 8,
              spreadRadius: _pressed ? 1 : 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: _pressed ? Colors.white : widget.color,
              size: 20,
              shadows: _pressed ? [Shadow(color: widget.color, blurRadius: 10)] : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                color: _pressed ? Colors.white : widget.color,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 14,
                shadows: _pressed ? [Shadow(color: widget.color, blurRadius: 10)] : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
