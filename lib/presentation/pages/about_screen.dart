import 'package:flutter/material.dart';
import '../../core/theme/neon_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.surface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF131D2E),
              Color(0xFF090E17),
              Color(0xFF04060A),
            ],
            center: Alignment.topCenter,
            radius: 1.4,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ABOUT & RULES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(color: NeonColors.cyan, blurRadius: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Banner Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            NeonColors.cyan.withValues(alpha: 0.15),
                            NeonColors.coral.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: NeonColors.cyan.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NeonColors.cyan.withValues(alpha: 0.2),
                              border: Border.all(color: NeonColors.cyan, width: 2),
                            ),
                            child: const Icon(
                              Icons.sports_hockey,
                              color: NeonColors.cyan,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'PUCK RUSH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Version 2.0 • Fast Air Hockey Arcade',
                            style: TextStyle(
                              color: NeonColors.muted,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // How to Play Card
                    _InfoCard(
                      icon: Icons.touch_app_outlined,
                      title: 'HOW TO PLAY',
                      color: NeonColors.cyan,
                      children: const [
                        _BulletPoint(
                          title: 'Drag Your Mallet',
                          desc: 'Touch and slide anywhere in your half of the arena to steer your neon striker.',
                        ),
                        _BulletPoint(
                          title: 'Strike with Momentum',
                          desc: 'Hit the puck forcefully forward to accelerate it past your rival into their goal.',
                        ),
                        _BulletPoint(
                          title: 'Rebound Off Rails',
                          desc: 'Use wall angles to curve shots and confuse opponents.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Game Modes Card
                    _InfoCard(
                      icon: Icons.sports_esports_outlined,
                      title: 'GAME MODES',
                      color: NeonColors.coral,
                      children: const [
                        _BulletPoint(
                          title: '1 Player (Vs AI)',
                          desc: 'Challenge dynamic AI across 4 difficulty tiers: Easy, Medium, Hard, and Insane.',
                        ),
                        _BulletPoint(
                          title: '2 Players (Local)',
                          desc: 'Play head-to-head on the same phone or tablet! Player 1 defends bottom, Player 2 commands top.',
                        ),
                        _BulletPoint(
                          title: 'First to 7 Goals',
                          desc: 'Standard matches run until one competitor reaches 7 goals (customizable in Settings).',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Difficulty Breakdown
                    _InfoCard(
                      icon: Icons.psychology_outlined,
                      title: 'AI DIFFICULTY TIERS',
                      color: NeonColors.green,
                      children: const [
                        _BulletPoint(
                          title: 'EASY',
                          desc: 'Relaxed tempo, generous reaction time, slight target wobble.',
                        ),
                        _BulletPoint(
                          title: 'MEDIUM',
                          desc: 'Balanced defense and steady returns. Standard competition.',
                        ),
                        _BulletPoint(
                          title: 'HARD',
                          desc: 'Fast tracking, aggressive counter-smashes, high-speed returns.',
                        ),
                        _BulletPoint(
                          title: 'INSANE',
                          desc: 'Predictive bank calculations, maximum impulse velocity, ruthless attack.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Credits Footer
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Built with Flutter 3 & High-Performance Skia Engine',
                            style: TextStyle(
                              color: Color(0xFF6B7F93),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '© ${DateTime.now().year} Puck Rush Arcade',
                            style: const TextStyle(
                              color: Color(0xFF4B5E70),
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeonColors.surfaceHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.title, required this.desc});
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: NeonColors.cyan,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, height: 1.4),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: desc,
                    style: const TextStyle(
                      color: NeonColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
