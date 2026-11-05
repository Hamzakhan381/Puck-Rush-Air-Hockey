import 'package:flutter/material.dart';
import '../../core/state/game_app_state.dart';
import '../../core/theme/neon_colors.dart';

class PlayerProfileModal extends StatefulWidget {
  const PlayerProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const PlayerProfileModal(),
    );
  }

  @override
  State<PlayerProfileModal> createState() => _PlayerProfileModalState();
}

class _PlayerProfileModalState extends State<PlayerProfileModal> {
  late final TextEditingController _nameController;
  late int _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final user = GameAppState.instance.currentUser;
    _nameController = TextEditingController(text: user?.username ?? 'PUCK_STRIKER');
    _selectedAvatar = user?.avatarIndex ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final appState = GameAppState.instance;
    final user = appState.currentUser;
    if (user != null) {
      user.username = name;
      user.avatarIndex = _selectedAvatar;
      // Trigger update
      appState.quickGuestPlay(name);
      user.username = name;
      user.avatarIndex = _selectedAvatar;
    } else {
      appState.quickGuestPlay(name);
      if (appState.currentUser != null) {
        appState.currentUser!.avatarIndex = _selectedAvatar;
      }
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NeonColors.surfaceHigh,
        content: Text(
          'Profile updated to $name!',
          style: const TextStyle(color: NeonColors.cyan, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final user = GameAppState.instance.currentUser;

    return Container(
      padding: EdgeInsets.fromLTRB(22, 16, 22, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF0E1526),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: NeonColors.cyan, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x6600E5FF),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PLAYER PROFILE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              if (user != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeonColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeonColors.green.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '${user.wins}W - ${user.losses}L',
                    style: const TextStyle(
                      color: NeonColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Nickname Input
          const Text(
            'PLAYER NAME',
            style: TextStyle(
              color: NeonColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            maxLength: 16,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: NeonColors.surfaceHigh.withValues(alpha: 0.6),
              counterText: '',
              prefixIcon: const Icon(Icons.person_rounded, color: NeonColors.cyan, size: 20),
              hintText: 'Enter your nickname...',
              hintStyle: const TextStyle(color: Colors.white24),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: NeonColors.cyan, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Avatar Picker
          const Text(
            'CHOOSE AVATAR',
            style: TextStyle(
              color: NeonColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: GameAppState.availableAvatars.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = _selectedAvatar == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? NeonColors.cyan.withValues(alpha: 0.25)
                          : NeonColors.surfaceHigh.withValues(alpha: 0.4),
                      border: Border.all(
                        color: isSelected ? NeonColors.cyan : Colors.white12,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: NeonColors.cyan.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      GameAppState.availableAvatars[index],
                      color: isSelected ? NeonColors.cyan : Colors.white54,
                      size: 26,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 22),

          // Save Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeonColors.cyan,
                foregroundColor: const Color(0xFF050B15),
                elevation: 4,
                shadowColor: NeonColors.cyan.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _saveProfile,
              child: const Text(
                'SAVE CHANGES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
