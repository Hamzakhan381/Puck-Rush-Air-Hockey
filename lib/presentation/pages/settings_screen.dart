import 'package:flutter/material.dart';
import '../../core/state/game_app_state.dart';
import '../../core/theme/neon_colors.dart';
import '../widgets/player_profile_modal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final appState = GameAppState.instance;

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;

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
                      'SETTINGS',
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
                child: ListenableBuilder(
                  listenable: appState,
                  builder: (context, _) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        // Player Card
                        if (user != null) ...[
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: NeonColors.surfaceHigh.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: NeonColors.cyan.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: NeonColors.cyan.withValues(alpha: 0.2),
                                    border: Border.all(color: NeonColors.cyan, width: 2),
                                  ),
                                  child: Icon(
                                    GameAppState.availableAvatars[user.avatarIndex],
                                    color: NeonColors.cyan,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.username,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${user.wins} WINS  •  ${user.losses} LOSSES  (${user.winRate.toStringAsFixed(1)}% WR)',
                                        style: const TextStyle(
                                          color: NeonColors.muted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: NeonColors.cyan, size: 20),
                                  tooltip: 'Edit Profile',
                                  onPressed: () => PlayerProfileModal.show(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Audio & Feedback section
                        _SectionHeader(title: 'AUDIO & HAPTICS'),
                        _SettingSwitchTile(
                          icon: Icons.volume_up_outlined,
                          title: 'SOUND EFFECTS',
                          subtitle: 'Puck strikes, rail impacts, goal horns',
                          value: appState.soundEnabled,
                          onChanged: (val) => appState.setSound(val),
                        ),
                        const SizedBox(height: 10),
                        _SettingSwitchTile(
                          icon: Icons.vibration,
                          title: 'HAPTIC VIBRATION',
                          subtitle: 'Tactile feedback on paddle hits and scores',
                          value: appState.hapticsEnabled,
                          onChanged: (val) => appState.setHaptics(val),
                        ),

                        const SizedBox(height: 24),

                        // Match Rules section
                        _SectionHeader(title: 'DEFAULT MATCH RULES'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: NeonColors.surfaceHigh.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GOALS TO WIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Points required to claim match victory',
                                style: TextStyle(color: NeonColors.muted, fontSize: 11),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [3, 5, 7, 10].map((score) {
                                  final isSelected = appState.targetScore == score;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: InkWell(
                                        onTap: () => appState.setTargetScore(score),
                                        borderRadius: BorderRadius.circular(10),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: isSelected ? NeonColors.cyan : Colors.white10,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: NeonColors.cyan.withValues(alpha: 0.4),
                                                      blurRadius: 10,
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$score',
                                            style: TextStyle(
                                              color: isSelected ? Colors.black : Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Arena Theme section
                        _SectionHeader(title: 'ARENA GLOW ACCENT'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: NeonColors.surfaceHigh.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ColorOption(
                                color: NeonColors.cyan,
                                label: 'CYBER',
                                isSelected: appState.themeAccent == NeonColors.cyan,
                                onTap: () => appState.setThemeAccent(NeonColors.cyan),
                              ),
                              _ColorOption(
                                color: NeonColors.coral,
                                label: 'CORAL',
                                isSelected: appState.themeAccent == NeonColors.coral,
                                onTap: () => appState.setThemeAccent(NeonColors.coral),
                              ),
                              _ColorOption(
                                color: NeonColors.green,
                                label: 'TOXIC',
                                isSelected: appState.themeAccent == NeonColors.green,
                                onTap: () => appState.setThemeAccent(NeonColors.green),
                              ),
                              _ColorOption(
                                color: const Color(0xFFFF9E00),
                                label: 'SOLAR',
                                isSelected: appState.themeAccent == const Color(0xFFFF9E00),
                                onTap: () => appState.setThemeAccent(const Color(0xFFFF9E00)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Reset stats button
                        OutlinedButton(
                          onPressed: () {
                            appState.resetStats();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Player statistics reset successfully!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'RESET MATCH STATS',
                            style: TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: NeonColors.cyan,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: NeonColors.surfaceHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: NeonColors.cyan, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: NeonColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: NeonColors.cyan,
            activeTrackColor: NeonColors.cyan.withValues(alpha: 0.4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.8),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : NeonColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
