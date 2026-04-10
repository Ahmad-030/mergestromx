import 'package:flutter/material.dart';
import 'dart:async';
import '../services/game_logic.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_button.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  GameLogic? _logic;
  Timer? _timer;
  bool _isPaused = false;
  bool _gameOverShown = false;
  Set<String> _mergingBalls = {};
  final AudioService _audio = AudioService();
  late AnimationController _comboController;

  @override
  void initState() {
    super.initState();
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      setState(() {
        _logic = GameLogic(
          gameWidth: size.width,
          gameHeight: size.height,
        );
      });
      _timer = Timer.periodic(const Duration(milliseconds: 16), _tick);
    });
  }

  void _tick(Timer t) {
    if (_logic == null || _isPaused || _gameOverShown) return;

    final merged = _logic!.update(0.016);

    if (merged.isNotEmpty) {
      setState(() => _mergingBalls.addAll(merged));
      _comboController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _mergingBalls.clear());
      });
    }

    if (_logic!.isGameOver) {
      _gameOverShown = true;
      _timer?.cancel();
      _timer = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showGameOver());
      return;
    }

    if (mounted) setState(() {});
  }

  void _showGameOver() {
    if (!mounted) return;
    final score     = _logic!.score;
    final highScore = _logic!.highScore;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameOverScreen(
          score: score,
          highScore: highScore,
          onRestart: () {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, AppRoutes.game);
          },
        ),
      ),
    );
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _audio.pauseMusic();
    } else {
      _audio.resumeMusic();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _comboController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_logic == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F4FD),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F4FD), Color(0xFFF3E5F5), Color(0xFFE0F7FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Ball canvas
          GestureDetector(
            onPanStart: (details) {
              if (_isPaused) return;
              final pos = details.localPosition;
              for (final ball in _logic!.balls.reversed) {
                final dx = ball.x - pos.dx;
                final dy = ball.y - pos.dy;
                if ((dx * dx + dy * dy) < ball.radius * ball.radius * 2.0) {
                  _logic!.startDrag(ball.id);
                  break;
                }
              }
            },
            onPanUpdate: (details) {
              _logic?.updateDrag(
                details.localPosition.dx,
                details.localPosition.dy,
              );
            },
            onPanEnd: (_) => _logic?.endDrag(),
            child: CustomPaint(
              painter: _BallPainter(
                balls: _logic!.balls,
                mergingIds: _mergingBalls,
                floorY: _logic!.floorY,
                dangerLineY: _logic!.dangerLineY,
              ),
              size: Size.infinite,
            ),
          ),

          // HUD
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HudCard(
                        icon: Icons.stars_rounded,
                        label: 'Score',
                        value: _logic!.score.toString(),
                        color: AppColors.primary,
                      ),
                      GestureDetector(
                        onTap: _togglePause,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.15),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                      ),
                      _HudCard(
                        icon: Icons.emoji_events_rounded,
                        label: 'Best',
                        value: _logic!.highScore.toString(),
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ),

                if (_logic!.comboMultiplier > 1)
                  AnimatedBuilder(
                    animation: _comboController,
                    builder: (_, __) => Transform.scale(
                      scale: 1.0 + 0.2 * (1 - _comboController.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B9D), Color(0xFF6C63FF)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          'x${_logic!.comboMultiplier} COMBO! 🔥',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Pause overlay
          if (_isPaused)
            _PauseOverlay(
              onResume: _togglePause,
              onRestart: () {
                _timer?.cancel();
                Navigator.pushReplacementNamed(context, AppRoutes.game);
              },
              onMenu: () {
                _timer?.cancel();
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.menu, (_) => false);
              },
            ),
        ],
      ),
    );
  }
}

// ── HUD Card ──────────────────────────────────────────────────────────────────

class _HudCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _HudCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600)),
                Text(value,
                    style: TextStyle(
                        fontSize: 18,
                        color: color,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ball Painter ──────────────────────────────────────────────────────────────

class _BallPainter extends CustomPainter {
  final List<Ball> balls;
  final Set<String> mergingIds;
  final double floorY;
  final double dangerLineY;

  _BallPainter({
    required this.balls,
    required this.mergingIds,
    required this.floorY,
    required this.dangerLineY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw danger line (top — game over threshold)
    final dangerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.red.withOpacity(0),
          Colors.red.withOpacity(0.7),
          Colors.red.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, dangerLineY, size.width, 2));
    canvas.drawRect(
        Rect.fromLTWH(0, dangerLineY, size.width, 2), dangerPaint);

    // Draw floor line (bottom)
    final floorPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blueGrey.withOpacity(0),
          Colors.blueGrey.withOpacity(0.4),
          Colors.blueGrey.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, floorY, size.width, 3));
    canvas.drawRect(Rect.fromLTWH(0, floorY, size.width, 3), floorPaint);

    // Draw balls
    for (final ball in balls) {
      final isMerging = mergingIds.contains(ball.id);
      final radius    = isMerging ? ball.radius * 1.15 : ball.radius;

      // Shadow
      canvas.drawCircle(
        Offset(ball.x, ball.y + 4),
        radius * 0.9,
        Paint()
          ..color      = ball.color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      // Main ball
      canvas.drawCircle(
        Offset(ball.x, ball.y),
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color.lerp(Colors.white, ball.color, 0.3)!,
              ball.color,
              Color.lerp(ball.color, Colors.black, 0.15)!,
            ],
            stops: const [0.0, 0.6, 1.0],
            center: const Alignment(-0.35, -0.35),
          ).createShader(
              Rect.fromCircle(center: Offset(ball.x, ball.y), radius: radius)),
      );

      // Shine
      canvas.drawCircle(
        Offset(ball.x - radius * 0.32, ball.y - radius * 0.32),
        radius * 0.28,
        Paint()
          ..color      = Colors.white.withOpacity(0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Merge ring
      if (isMerging) {
        canvas.drawCircle(
          Offset(ball.x, ball.y),
          radius + 6,
          Paint()
            ..color       = ball.color.withOpacity(0.5)
            ..style       = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BallPainter old) => true;
}

// ── Pause Overlay ─────────────────────────────────────────────────────────────

class _PauseOverlay extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const _PauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  State<_PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<_PauseOverlay> {
  final _audio = AudioService();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          margin:  const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color:        Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            border:       Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color:      AppColors.primary.withOpacity(0.15),
                blurRadius: 30,
                offset:     const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ).createShader(b),
                child: const Text(
                  '⏸ Paused',
                  style: TextStyle(
                    fontSize:   28,
                    fontWeight: FontWeight.w900,
                    color:      Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  await _audio.toggleMusic();
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _audio.isMusicOn
                                ? Icons.music_note
                                : Icons.music_off,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          const Text('Background Music',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                        ],
                      ),
                      Switch(
                        value:    _audio.isMusicOn,
                        onChanged: (_) async {
                          await _audio.toggleMusic();
                          setState(() {});
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GlassButton(
                label: 'Resume',
                icon:  Icons.play_arrow_rounded,
                width: double.infinity,
                onTap: widget.onResume,
              ),
              const SizedBox(height: 10),
              GlassButton(
                label: 'Restart',
                icon:  Icons.replay_rounded,
                width: double.infinity,
                color: AppColors.secondary,
                onTap: widget.onRestart,
              ),
              const SizedBox(height: 10),
              GlassButton(
                label: 'Main Menu',
                icon:  Icons.home_rounded,
                width: double.infinity,
                color: AppColors.danger,
                onTap: widget.onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}