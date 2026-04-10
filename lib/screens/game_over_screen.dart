import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_button.dart';
import '../widgets/floating_balls_bg.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onRestart;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.highScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isNewRecord = score >= highScore;

    return Scaffold(
      body: FloatingBallsBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie confetti / game over animation
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Lottie.asset(
                    'assets/confetti.json',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      isNewRecord ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                      size: 80,
                      color: isNewRecord ? AppColors.gold : AppColors.textMid,
                    ),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),

                Text(
                  isNewRecord ? '🎉 New Record!' : 'Game Over',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isNewRecord ? AppColors.gold : AppColors.textDark,
                    letterSpacing: 1.0,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 28),

                // Score card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ScoreRow(
                        label: 'Your Score',
                        value: score.toString(),
                        icon: Icons.stars_rounded,
                        color: AppColors.primary,
                        large: true,
                      ),
                      const SizedBox(height: 8),
                      Divider(color: AppColors.textLight.withOpacity(0.3)),
                      const SizedBox(height: 8),
                      _ScoreRow(
                        label: 'Best Score',
                        value: highScore.toString(),
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // Buttons
                GlassButton(
                  label: 'Play Again',
                  icon: Icons.replay_rounded,
                  width: double.infinity,
                  height: 58,
                  fontSize: 18,
                  onTap: onRestart,
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 14),

                GlassButton(
                  label: 'Back to Menu',
                  icon: Icons.home_rounded,
                  width: double.infinity,
                  color: AppColors.secondary,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.menu, (_) => false),
                ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool large;

  const _ScoreRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: large ? 26 : 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: large ? 16 : 14,
                color: AppColors.textMid,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 32 : 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}