import 'package:flutter/material.dart';
import '../../core/state/game_app_state.dart';
import '../../core/theme/neon_colors.dart';
import 'home_arena_hub.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  int _selectedAvatar = 0;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _errorMessage = null);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      setState(() => _errorMessage = 'Please enter a player handle / username');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    if (_isLogin) {
      GameAppState.instance.login(username: username, password: password);
      _goToHome();
    } else {
      final email = _emailController.text.trim();
      final confirm = _confirmPasswordController.text;

      if (email.isEmpty || !email.contains('@')) {
        setState(() => _errorMessage = 'Please enter a valid email address');
        return;
      }
      if (password.length < 4) {
        setState(() => _errorMessage = 'Password must be at least 4 characters');
        return;
      }
      if (password != confirm) {
        setState(() => _errorMessage = 'Passwords do not match');
        return;
      }

      GameAppState.instance.signUp(
        username: username,
        email: email,
        password: password,
        avatarIndex: _selectedAvatar,
      );
      _goToHome();
    }
  }

  void _quickGuestPlay() {
    GameAppState.instance.quickGuestPlay('CYBER_GUEST');
    _goToHome();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeArenaHub(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: NeonColors.cyan, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: NeonColors.cyan.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_hockey,
                      color: NeonColors.cyan,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PLAYER ACCESS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: NeonColors.cyan, blurRadius: 15),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sync your player stats & leaderboard',
                    style: TextStyle(
                      fontSize: 13,
                      color: NeonColors.muted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab switcher (LOGIN / SIGN UP)
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: NeonColors.surfaceHigh.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isLogin = true;
                              _errorMessage = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: _isLogin ? NeonColors.cyan : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: _isLogin
                                    ? [
                                        BoxShadow(
                                          color: NeonColors.cyan.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                  color: _isLogin ? const Color(0xFF04060A) : NeonColors.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isLogin = false;
                              _errorMessage = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: !_isLogin ? NeonColors.coral : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: !_isLogin
                                    ? [
                                        BoxShadow(
                                          color: NeonColors.coral.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                  color: !_isLogin ? Colors.white : NeonColors.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Avatar Picker when Signing up
                  if (!_isLogin) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'SELECT AVATAR ICON:',
                        style: TextStyle(
                          color: NeonColors.muted.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: GameAppState.availableAvatars.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final isSelected = _selectedAvatar == idx;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedAvatar = idx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? NeonColors.coral.withValues(alpha: 0.25)
                                    : NeonColors.surfaceHigh,
                                border: Border.all(
                                  color: isSelected ? NeonColors.coral : Colors.white24,
                                  width: isSelected ? 2.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: NeonColors.coral.withValues(alpha: 0.5),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                GameAppState.availableAvatars[idx],
                                color: isSelected ? NeonColors.coral : Colors.white70,
                                size: 26,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Form Fields Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: NeonColors.surfaceHigh.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (_isLogin ? NeonColors.cyan : NeonColors.coral).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Player Handle / Username
                        _CyberTextField(
                          controller: _usernameController,
                          hintText: 'PLAYER HANDLE / USERNAME',
                          icon: Icons.person_outline,
                          accentColor: _isLogin ? NeonColors.cyan : NeonColors.coral,
                        ),
                        const SizedBox(height: 16),

                        // Email (only for sign up)
                        if (!_isLogin) ...[
                          _CyberTextField(
                            controller: _emailController,
                            hintText: 'EMAIL ADDRESS',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            accentColor: NeonColors.coral,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Password
                        _CyberTextField(
                          controller: _passwordController,
                          hintText: 'PASSWORD',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          accentColor: _isLogin ? NeonColors.cyan : NeonColors.coral,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: NeonColors.muted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),

                        // Confirm Password (only for sign up)
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          _CyberTextField(
                            controller: _confirmPasswordController,
                            hintText: 'CONFIRM PASSWORD',
                            icon: Icons.lock_reset,
                            obscureText: _obscurePassword,
                            accentColor: NeonColors.coral,
                          ),
                        ],

                        // Error message banner
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Button (LOGIN / SIGN UP)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLogin ? NeonColors.cyan : NeonColors.coral,
                        foregroundColor: _isLogin ? const Color(0xFF04060A) : Colors.white,
                        elevation: 8,
                        shadowColor: (_isLogin ? NeonColors.cyan : NeonColors.coral).withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isLogin ? Icons.login : Icons.how_to_reg,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isLogin ? 'ENTER ARENA' : 'CREATE ACCOUNT',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Guest Play
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _quickGuestPlay,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NeonColors.green,
                        side: BorderSide(
                          color: NeonColors.green.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flash_on, size: 18, color: NeonColors.green),
                          SizedBox(width: 8),
                          Text(
                            'QUICK GUEST PLAY',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberTextField extends StatelessWidget {
  const _CyberTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.accentColor,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final Color accentColor;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      cursorColor: accentColor,
      decoration: InputDecoration(
        filled: true,
        fillColor: NeonColors.surfaceLow.withValues(alpha: 0.8),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF6B7F93),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        prefixIcon: Icon(icon, color: accentColor, size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
    );
  }
}
