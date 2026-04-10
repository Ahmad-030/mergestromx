
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_theme.dart';
import '../widgets/floating_balls_bg.dart';
import '../widgets/glass_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingBallsBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.12),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      // Game logo
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Lottie.asset(
                          'assets/bubble.json',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF4DD0E1)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.bubble_chart,
                                size: 52, color: Colors.white),
                          ),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 10),

                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4DD0E1)],
                        ).createShader(bounds),
                        child: const Text(
                          'MergeStormX',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 28),

                      // Game Description Card
                      _InfoCard(
                        icon: Icons.gamepad_rounded,
                        iconColor: AppColors.primary,
                        title: 'About the Game',
                        content:
                            'MergeStormX is a fast-paced color merge survival puzzle game. '
                            'Catch falling colored balls, drag and position matching colors to merge them, '
                            'create combo streaks, and survive as long as possible while '
                            'difficulty ramps up!',
                        delay: 400,
                      ),

                      const SizedBox(height: 14),

                      // Features Card
                      _InfoCard(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.gold,
                        title: 'Features',
                        content: '🎯  Drag & drop merge mechanics\n'
                            '🔥  Combo multiplier system (x1 → x4)\n'
                            '⬆️  Increasing difficulty over time\n'
                            '🎵  Background music with toggle\n'
                            '📊  High score tracking\n'
                            '🌈  8 vibrant ball colors',
                        delay: 500,
                      ),

                      const SizedBox(height: 14),

                      // Developer Card
                      _InfoCard(
                        icon: Icons.business_rounded,
                        iconColor: const Color(0xFFAB47BC),
                        title: 'Developer',
                        delay: 600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DevRow(
                              icon: Icons.apartment,
                              label: 'Studio',
                              value: 'BLIND LLC',
                              bold: true,
                            ),
                            const SizedBox(height: 10),
                            _DevRow(
                              icon: Icons.tag,
                              label: 'ID',
                              value: 'R45',
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(const ClipboardData(
                                    text: 'educationlimited4@gmail.com'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Email copied to clipboard!'),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              child: _DevRow(
                                icon: Icons.email_rounded,
                                label: 'Email',
                                value: 'educationlimited4@gmail.com',
                                tappable: true,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Back button
                      GlassButton(
                        label: 'Back to Menu',
                        icon: Icons.home_rounded,
                        width: double.infinity,
                        color: AppColors.secondary,
                        onTap: () => Navigator.pop(context),
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 24),

                      Text(
                        '© 2025 BLIND LLC · All rights reserved',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ).animate().fadeIn(delay: 800.ms),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? content;
  final Widget? child;
  final int delay;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.content,
    this.child,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 12),
            Text(
              content!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMid,
                height: 1.65,
              ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 14),
            child!,
          ],
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2, end: 0);
  }
}

class _DevRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool bold;
  final bool tappable;

  const _DevRow({
    required this.icon,
    required this.label,
    required this.value,
    this.bold = false,
    this.tappable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.7)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMid,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: tappable ? AppColors.primary : AppColors.textDark,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              decoration: tappable ? TextDecoration.underline : null,
            ),
          ),
        ),
        if (tappable)
          const Icon(Icons.copy, size: 14, color: AppColors.primary),
      ],
    );
  }
}
