
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_theme.dart';
import '../services/audio_service.dart';
import '../widgets/floating_balls_bg.dart';
import '../widgets/glass_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final AudioService _audio = AudioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingBallsBackground(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.5),
                      const Color(0xFFE8F4FD).withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Music toggle top right
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _MusicToggle(),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

// WITH THIS:
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Lottie.asset(
                      'assets/Bubbles.json',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF4DD0E1)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bubble_chart, size: 48, color: Colors.white),
                      ),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 8),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4DD0E1)],
                    ).createShader(bounds),
                    child: const Text(
                      'MergeStormX',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  Text(
                    'Merge. Survive. Conquer.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMid,
                      letterSpacing: 1.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 28),

                  // High score card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFFFB300), size: 26),
                          const SizedBox(width: 10),
                          Text(
                            'Best Score: ',
                            style: TextStyle(
                              color: AppColors.textMid,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '0',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 32),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        GlassButton(
                          label: 'Play Now',
                          icon: Icons.play_arrow_rounded,
                          width: double.infinity,
                          height: 60,
                          fontSize: 19,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.game),
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: GlassButton(
                                label: 'About',
                                icon: Icons.info_outline,
                                color: AppColors.secondary,
                                onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                              ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3, end: 0),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GlassButton(
                                label: 'Privacy',
                                icon: Icons.privacy_tip_outlined,
                                color: const Color(0xFFAB47BC),
                                onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
                              ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.3, end: 0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicToggle extends StatefulWidget {
  @override
  State<_MusicToggle> createState() => _MusicToggleState();
}

class _MusicToggleState extends State<_MusicToggle> {
  final _audio = AudioService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _audio.toggleMusic();
        setState(() {});
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          _audio.isMusicOn ? Icons.music_note : Icons.music_off,
          color: _audio.isMusicOn ? AppColors.primary : AppColors.textLight,
          size: 24,
        ),
      ),
    );
  }
}
