import 'package:flutter/material.dart';
import '../../core/theme/neon_colors.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => const HowToPlayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 620),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1424),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: NeonColors.cyan.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: NeonColors.cyan.withValues(alpha: 0.25),
              blurRadius: 32,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 16, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NeonColors.cyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: NeonColors.cyan.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: NeonColors.cyan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HOW TO PLAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          'Quick 30-second beginner guide',
                          style: TextStyle(
                            color: NeonColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Guide content list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  _GuideItem(
                    step: '1',
                    title: 'DRAG TO STRIKE',
                    description:
                        'Touch and slide your finger in your half of the table. Swift swipes hit the puck with explosive power!',
                    icon: Icons.touch_app_rounded,
                    color: NeonColors.cyan,
                  ),
                  SizedBox(height: 14),
                  _GuideItem(
                    step: '2',
                    title: 'SCORE IN THE GOAL',
                    description:
                        'Bank the puck off side cushions into the top goal. First player to reach the match score wins!',
                    icon: Icons.sports_hockey,
                    color: NeonColors.green,
                  ),
                  SizedBox(height: 14),
                  _GuideItem(
                    step: '3',
                    title: 'SHIELD DEFENSE',
                    description:
                        'Tap the SHIELD button when in danger. It deploys a laser forcefield across your goal to block incoming shots.',
                    icon: Icons.shield_rounded,
                    color: NeonColors.cyan,
                  ),
                  SizedBox(height: 14),
                  _GuideItem(
                    step: '4',
                    title: 'SUPER BOOST SHOT',
                    description:
                        'Tap the BOOST button to supercharge your mallet. Your next hit launches a supersonic fiery blast!',
                    icon: Icons.bolt_rounded,
                    color: NeonColors.amber,
                  ),
                  SizedBox(height: 14),
                  _GuideItem(
                    step: '5',
                    title: 'PRO TIPS FOR BEGINNERS',
                    description:
                        'Return to center defense after hitting. Guard your goal line and practice against EASY AI first!',
                    icon: Icons.lightbulb_rounded,
                    color: NeonColors.gold,
                  ),
                ],
              ),
            ),

            // Footer Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeonColors.cyan,
                    foregroundColor: const Color(0xFF040810),
                    elevation: 6,
                    shadowColor: NeonColors.cyan.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_esports_rounded, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'GOT IT, LET\'S PLAY!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String step;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NeonColors.surfaceHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'STEP $step',
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: NeonColors.muted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
