import 'package:flutter/material.dart';
import '../../core/state/game_app_state.dart';
import '../../core/theme/neon_colors.dart';
import '../../domain/models/game_mode.dart';
import '../widgets/difficulty_dialog.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/player_profile_modal.dart';
import 'about_screen.dart';
import 'live_match_screen.dart';
import 'settings_screen.dart';
import '../widgets/arcade_duel_background.dart';

class HomeArenaHub extends StatefulWidget {
  const HomeArenaHub({super.key});

  @override
  State<HomeArenaHub> createState() => _HomeArenaHubState();
}

class _HomeArenaHubState extends State<HomeArenaHub> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.75).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // If no user exists, initialize smoothly with friendly default name
    if (GameAppState.instance.currentUser == null) {
      GameAppState.instance.quickGuestPlay('PUCK_MASTER');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onQuickPlayTapped() {
    final targetScore = GameAppState.instance.targetScore;
    final diff = GameAppState.instance.defaultDifficulty;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LiveMatchScreen(
          mode: GameMode.quickPlay,
          difficulty: diff,
          maxScore: targetScore,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  void _on1PlayerTapped() {
    DifficultySelectionDialog.show(context);
  }

  void _on2PlayerTapped() {
    final targetScore = GameAppState.instance.targetScore;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LiveMatchScreen(
          mode: GameMode.local2P,
          maxScore: targetScore,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  void _onSettingsTapped() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  void _onAboutTapped() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AboutScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  void _openProfile() {
    PlayerProfileModal.show(context);
  }

  void _openHowToPlay() {
    HowToPlayDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.surface,
      body: Stack(
        children: [
          // ── Background: Animated Striker Clash & Cyber Puck Duel ──
          const Positioned.fill(
            child: IgnorePointer(
              child: ArcadeDuelBackground(),
            ),
          ),

          // ── Foreground Arcade Menu UI ──
          SafeArea(
            child: Column(
            children: [
              // ── Top User Profile Header ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                child: ListenableBuilder(
                  listenable: GameAppState.instance,
                  builder: (context, _) {
                    final user = GameAppState.instance.currentUser;
                    return Row(
                      children: [
                        // Profile chip (Tap to customize!)
                        Expanded(
                          child: InkWell(
                            onTap: _openProfile,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: NeonColors.surfaceHigh.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: NeonColors.cyan.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: NeonColors.cyan.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: NeonColors.cyan.withValues(alpha: 0.2),
                                      border: Border.all(color: NeonColors.cyan, width: 2),
                                    ),
                                    child: Icon(
                                      user != null
                                          ? GameAppState.availableAvatars[user.avatarIndex]
                                          : Icons.sports_hockey,
                                      color: NeonColors.cyan,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                user?.username ?? 'PLAYER',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Icon(
                                              Icons.edit_rounded,
                                              size: 13,
                                              color: NeonColors.cyan,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          user != null
                                              ? '${user.wins}W - ${user.losses}L'
                                              : 'ONLINE',
                                          style: const TextStyle(
                                            color: NeonColors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Quick "How to Play" tutorial button
                        InkWell(
                          onTap: _openHowToPlay,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: NeonColors.surfaceHigh.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: NeonColors.gold.withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.help_outline_rounded,
                              color: NeonColors.gold,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ── Main Scrolling Content ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Animated Glowing Emblem
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: NeonColors.cyan, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: NeonColors.cyan.withValues(alpha: _glowAnimation.value),
                                    blurRadius: 36,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: NeonColors.coral.withValues(alpha: 0.25),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: NeonColors.cyan.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.sports_hockey,
                                    size: 56,
                                    color: NeonColors.cyan,
                                    shadows: [
                                      Shadow(color: NeonColors.cyan, blurRadius: 20),
                                      Shadow(color: Colors.white, blurRadius: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // App Title with Cyber Glow: PUCK RUSH
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF00E5FF),
                            Color(0xFFFFFFFF),
                            Color(0xFFFF2A6D),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'PUCK RUSH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 6,
                            shadows: [
                              Shadow(color: NeonColors.cyan, blurRadius: 25),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'AIR HOCKEY ARCADE',
                        style: TextStyle(
                          color: NeonColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3.5,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Beginner friendly guide banner
                      InkWell(
                        onTap: _openHowToPlay,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                NeonColors.gold.withValues(alpha: 0.15),
                                NeonColors.cyan.withValues(alpha: 0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: NeonColors.gold.withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lightbulb_rounded, color: NeonColors.gold, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'New to Puck Rush? Tap for 30s tutorial!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: NeonColors.gold,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // HERO ACTION BUTTON: ⚡ QUICK PLAY
                      GestureDetector(
                        onTap: _onQuickPlayTapped,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 70),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00E5FF),
                                Color(0xFF0091FF),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: NeonColors.cyan.withValues(alpha: 0.45),
                                blurRadius: 22,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'QUICK PLAY',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFF040A14),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Instant Match • 1 Tap to Play',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFF082240),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF040A14),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Option 1: 1 PLAYER VS AI
                      _NeonMenuButton(
                        label: '1 PLAYER',
                        subtitle: 'Vs Smart AI • Choose Difficulty',
                        color: NeonColors.cyan,
                        icon: Icons.smart_toy_rounded,
                        onTap: _on1PlayerTapped,
                      ),

                      const SizedBox(height: 12),

                      // Option 2: 2 PLAYERS LOCAL
                      _NeonMenuButton(
                        label: '2 PLAYERS',
                        subtitle: 'Local 2P • Head-to-Head On 1 Device',
                        color: NeonColors.coral,
                        icon: Icons.people_alt_rounded,
                        onTap: _on2PlayerTapped,
                      ),

                      const SizedBox(height: 12),

                      // Secondary Row: Settings & About
                      Row(
                        children: [
                          Expanded(
                            child: _SmallMenuTile(
                              icon: Icons.settings_rounded,
                              label: 'SETTINGS',
                              color: NeonColors.amber,
                              onTap: _onSettingsTapped,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SmallMenuTile(
                              icon: Icons.info_outline_rounded,
                              label: 'ABOUT',
                              color: NeonColors.green,
                              onTap: _onAboutTapped,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

class _SmallMenuTile extends StatelessWidget {
  const _SmallMenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: NeonColors.surfaceHigh.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonMenuButton extends StatefulWidget {
  const _NeonMenuButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_NeonMenuButton> createState() => _NeonMenuButtonState();
}

class _NeonMenuButtonState extends State<_NeonMenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.color.withValues(alpha: 0.22)
              : NeonColors.surfaceHigh.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isPressed ? widget.color : widget.color.withValues(alpha: 0.65),
            width: _isPressed ? 2.2 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _isPressed ? 0.35 : 0.12),
              blurRadius: _isPressed ? 18 : 8,
              spreadRadius: _isPressed ? 1 : 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 22,
                shadows: [
                  Shadow(color: widget.color, blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 16,
                      shadows: [
                        Shadow(color: widget.color, blurRadius: 12),
                      ],
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: NeonColors.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: widget.color.withValues(alpha: 0.75),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
