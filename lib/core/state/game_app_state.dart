import 'package:flutter/material.dart';
import '../../domain/models/difficulty.dart';
import '../theme/neon_colors.dart';

class UserProfile {
  UserProfile({
    required this.username,
    required this.email,
    required this.avatarIndex,
    this.wins = 0,
    this.losses = 0,
    this.isGuest = false,
  });

  String username;
  String email;
  int avatarIndex;
  int wins;
  int losses;
  bool isGuest;

  int get totalMatches => wins + losses;
  double get winRate => totalMatches == 0 ? 0.0 : (wins / totalMatches) * 100;
}

class GameAppState extends ChangeNotifier {
  GameAppState._internal();
  static final GameAppState instance = GameAppState._internal();

  UserProfile? _currentUser;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  int _targetScore = 7;
  Difficulty _defaultDifficulty = Difficulty.medium;
  Color _themeAccent = NeonColors.cyan;

  // Predefined avatar icons
  static const List<IconData> availableAvatars = [
    Icons.sports_hockey,
    Icons.bolt,
    Icons.shield_outlined,
    Icons.rocket_launch,
    Icons.smart_toy,
    Icons.whatshot,
  ];

  static const List<String> avatarTitles = [
    'CYBER STRIKER',
    'LIGHTNING MALLET',
    'NEON GUARDIAN',
    'ROCKET PUCK',
    'AI DOMINATOR',
    'FIRE BLADE',
  ];

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  int get targetScore => _targetScore;
  Difficulty get defaultDifficulty => _defaultDifficulty;
  Color get themeAccent => _themeAccent;

  void quickGuestPlay([String name = 'NEON_PLAYER']) {
    _currentUser = UserProfile(
      username: name.isEmpty ? 'GUEST_${DateTime.now().millisecond % 1000}' : name,
      email: 'guest@neonarena.gg',
      avatarIndex: 0,
      isGuest: true,
      wins: 3,
      losses: 1,
    );
    notifyListeners();
  }

  bool login({required String username, required String password}) {
    if (username.trim().isEmpty || password.isEmpty) return false;
    _currentUser = UserProfile(
      username: username.trim(),
      email: '${username.trim().toLowerCase()}@arena.net',
      avatarIndex: 1,
      isGuest: false,
      wins: 5,
      losses: 2,
    );
    notifyListeners();
    return true;
  }

  bool signUp({
    required String username,
    required String email,
    required String password,
    required int avatarIndex,
  }) {
    if (username.trim().isEmpty || password.isEmpty) return false;
    _currentUser = UserProfile(
      username: username.trim(),
      email: email.trim(),
      avatarIndex: avatarIndex.clamp(0, availableAvatars.length - 1),
      isGuest: false,
      wins: 0,
      losses: 0,
    );
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void recordMatchResult({required bool won}) {
    if (_currentUser != null) {
      if (won) {
        _currentUser!.wins++;
      } else {
        _currentUser!.losses++;
      }
      notifyListeners();
    }
  }

  void setSound(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  void setHaptics(bool enabled) {
    _hapticsEnabled = enabled;
    notifyListeners();
  }

  void setTargetScore(int score) {
    _targetScore = score;
    notifyListeners();
  }

  void setDifficulty(Difficulty diff) {
    _defaultDifficulty = diff;
    notifyListeners();
  }

  void setThemeAccent(Color color) {
    _themeAccent = color;
    notifyListeners();
  }

  void resetStats() {
    if (_currentUser != null) {
      _currentUser!.wins = 0;
      _currentUser!.losses = 0;
      notifyListeners();
    }
  }
}
