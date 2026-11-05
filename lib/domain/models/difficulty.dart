import 'package:flutter/material.dart';

enum Difficulty {
  easy,
  medium,
  hard,
  insane;

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'EASY';
      case Difficulty.medium:
        return 'MEDIUM';
      case Difficulty.hard:
        return 'HARD';
      case Difficulty.insane:
        return 'INSANE';
    }
  }

  String get subtitle {
    switch (this) {
      case Difficulty.easy:
        return 'Novice / Gentle AI';
      case Difficulty.medium:
        return 'Pro / Balanced Speed';
      case Difficulty.hard:
        return 'Elite / Fast Counter-Attacks';
      case Difficulty.insane:
        return 'Cyber God / Predictive Smashes';
    }
  }

  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'Slower AI reflexes and wider error margin. Great for warm-up.';
      case Difficulty.medium:
        return 'Balanced tracking and counter-shots. Competitive standard.';
      case Difficulty.hard:
        return 'Aggressive forward dashes, quick wall rebounds, intense rally.';
      case Difficulty.insane:
        return 'Unstoppable predictive angles, maximum velocity, relentless pressure!';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF5DE06F); // Lime Green
      case Difficulty.medium:
        return const Color(0xFF39E7FF); // Cyan
      case Difficulty.hard:
        return const Color(0xFFFF9E00); // Amber Orange
      case Difficulty.insane:
        return const Color(0xFFFF1361); // Hot Magenta
    }
  }

  IconData get icon {
    switch (this) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_alt;
      case Difficulty.medium:
        return Icons.bolt;
      case Difficulty.hard:
        return Icons.local_fire_department;
      case Difficulty.insane:
        return Icons.electric_bolt;
    }
  }

  /// AI speed lerp factor per second
  double get aiLerpSpeed {
    switch (this) {
      case Difficulty.easy:
        return 1.9;
      case Difficulty.medium:
        return 3.5;
      case Difficulty.hard:
        return 5.2;
      case Difficulty.insane:
        return 8.2;
    }
  }

  /// Forward smash aggressiveness threshold
  double get smashThreshold {
    switch (this) {
      case Difficulty.easy:
        return 0.15;
      case Difficulty.medium:
        return 0.28;
      case Difficulty.hard:
        return 0.42;
      case Difficulty.insane:
        return 0.50;
    }
  }
}
