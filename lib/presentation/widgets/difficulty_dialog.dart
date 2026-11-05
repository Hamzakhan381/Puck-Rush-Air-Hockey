import 'package:flutter/material.dart';
import '../../core/state/game_app_state.dart';
import '../../core/theme/neon_colors.dart';
import '../../domain/models/difficulty.dart';
import '../../domain/models/game_mode.dart';
import '../pages/live_match_screen.dart';

class DifficultySelectionDialog extends StatefulWidget {
  const DifficultySelectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => const DifficultySelectionDialog(),
    );
  }

  @override
  State<DifficultySelectionDialog> createState() => _DifficultySelectionDialogState();
}

class _DifficultySelectionDialogState extends State<DifficultySelectionDialog> {
  Difficulty _selectedDifficulty = GameAppState.instance.defaultDifficulty;
  int _targetScore = GameAppState.instance.targetScore;

  void _startMatch() {
    GameAppState.instance.setDifficulty(_selectedDifficulty);
    GameAppState.instance.setTargetScore(_targetScore);
    Navigator.pop(context); // Close dialog

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LiveMatchScreen(
          mode: GameMode.quickPlay,
          difficulty: _selectedDifficulty,
          maxScore: _targetScore,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _selectedDifficulty.color;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1826),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: activeColor.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.psychology, color: activeColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI DIFFICULTY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: NeonColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your AI opponent skill tier',
                style: TextStyle(
                  color: NeonColors.muted,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),

              // Difficulty Cards
              ...Difficulty.values.map((diff) {
                final isSelected = _selectedDifficulty == diff;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedDifficulty = diff),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? diff.color.withValues(alpha: 0.15)
                            : NeonColors.surfaceHigh.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? diff.color : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: diff.color.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? diff.color.withValues(alpha: 0.25)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              diff.icon,
                              color: isSelected ? diff.color : Colors.white70,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      diff.label,
                                      style: TextStyle(
                                        color: isSelected ? diff.color : Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    if (diff == Difficulty.easy) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: NeonColors.green.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: NeonColors.green.withValues(alpha: 0.6)),
                                        ),
                                        child: const Text(
                                          '★ BEGINNER',
                                          style: TextStyle(
                                            color: NeonColors.green,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: diff.color,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'ACTIVE',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  diff.description,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white70
                                        : NeonColors.muted.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? diff.color : Colors.white24,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Match Target Goals
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NeonColors.surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_score, color: NeonColors.muted, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'GOALS TO WIN:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    ...[5, 7, 10].map((score) {
                      final isPicked = _targetScore == score;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _targetScore = score),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isPicked ? activeColor : Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$score',
                              style: TextStyle(
                                color: isPicked ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Launch Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _startMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    foregroundColor: const Color(0xFF04060A),
                    elevation: 10,
                    shadowColor: activeColor.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'START ${_selectedDifficulty.label} MATCH',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
