import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/neon_colors.dart';
import 'home_arena_hub.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _puckController;
  late Animation<double> _glowAnimation;
  late Animation<double> _puckRotation;

  double _loadingProgress = 0.0;
  String _statusText = 'CHARGING AIR BLOWERS...';
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _puckController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _puckRotation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(_puckController);

    _startLoadingSequence();
  }

  void _startLoadingSequence() {
    const steps = [
      (0.25, 'INITIALIZING PUCK ARENA...'),
      (0.55, 'CALIBRATING AIR CUSHIONS...'),
      (0.85, 'SYNCHRONIZING OPPONENTS...'),
      (1.0, 'SYSTEM READY!'),
    ];

    int stepIndex = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 320), (timer) {
      if (stepIndex < steps.length) {
        setState(() {
          _loadingProgress = steps[stepIndex].$1;
          _statusText = steps[stepIndex].$2;
        });
        stepIndex++;
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomeArenaHub(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _glowController.dispose();
    _puckController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.surface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF132242),
              Color(0xFF090E1A),
              Color(0xFF04060C),
            ],
            center: Alignment.center,
            radius: 1.3,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Pulsing glowing hockey crest
                AnimatedBuilder(
                  animation: Listenable.merge([_glowAnimation, _puckRotation]),
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _glowAnimation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer neon shockwave ring
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: NeonColors.cyan.withValues(alpha: 0.35),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: NeonColors.cyan.withValues(alpha: 0.3),
                                  blurRadius: 35,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          // Middle coral ring
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: NeonColors.coral.withValues(alpha: 0.6),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: NeonColors.coral.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // Center glowing hockey icon
                          Transform.rotate(
                            angle: _puckRotation.value,
                            child: const Icon(
                              Icons.sports_hockey,
                              size: 72,
                              color: NeonColors.cyan,
                              shadows: [
                                Shadow(color: NeonColors.cyan, blurRadius: 25),
                                Shadow(color: Colors.white, blurRadius: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 36),

                // App Title with Cyber Glow
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
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: NeonColors.cyan, blurRadius: 28),
                        Shadow(color: NeonColors.coral, blurRadius: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'FAST NEON AIR HOCKEY ARCADE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.5,
                    color: NeonColors.muted,
                  ),
                ),

                const Spacer(flex: 3),

                // Progress Indicator
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _statusText,
                          style: const TextStyle(
                            color: NeonColors.cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '${(_loadingProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: NeonColors.coral,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            color: NeonColors.surfaceHigh,
                          ),
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 350),
                            widthFactor: _loadingProgress,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    NeonColors.cyan,
                                    NeonColors.green,
                                    NeonColors.coral,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: NeonColors.cyan.withValues(alpha: 0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2,
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

                const SizedBox(height: 24),

                const Text(
                  'v2.0 • HIGH PERFORMANCE EDITION',
                  style: TextStyle(
                    color: Color(0xFF6B7F93),
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
