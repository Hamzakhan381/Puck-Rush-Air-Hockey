import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'air_hockey_neon_arena.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const AirHockeyNeonArena());
}
