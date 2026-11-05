import 'package:flutter/material.dart';

import 'core/theme/neon_colors.dart';
import 'presentation/pages/splash_screen.dart';

class AirHockeyNeonArena extends StatelessWidget {
  const AirHockeyNeonArena({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puck Rush - Air Hockey Arcade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: NeonColors.surface,
        colorScheme: const ColorScheme.dark(
          surface: NeonColors.surface,
          primary: NeonColors.cyan,
          secondary: NeonColors.coral,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
