import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/game_screen.dart';
import 'screens/about_screen.dart';
import 'screens/privacy_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MergeStormXApp());
}

class MergeStormXApp extends StatelessWidget {
  const MergeStormXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MergeStormX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.menu: (_) => const MenuScreen(),
        AppRoutes.game: (_) => const GameScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.privacy: (_) => const PrivacyScreen(),
      },
    );
  }
}
