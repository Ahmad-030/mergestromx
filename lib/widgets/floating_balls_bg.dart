import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class FloatingBallsBackground extends StatefulWidget {
  final Widget child;
  const FloatingBallsBackground({super.key, required this.child});

  @override
  State<FloatingBallsBackground> createState() => _FloatingBallsBackgroundState();
}

class _FloatingBallsBackgroundState extends State<FloatingBallsBackground>
    with TickerProviderStateMixin {
  final Random _random = Random();
  late List<_BallData> _balls;

  @override
  void initState() {
    super.initState();
    _balls = List.generate(10, (i) => _BallData(
      color: AppColors.ballColors[i % AppColors.ballColors.length],
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 40 + _random.nextDouble() * 50,
      duration: 3000 + _random.nextInt(3000),
      delay: _random.nextInt(2000),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F4FD), Color(0xFFF3E5F5), Color(0xFFE0F7FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Floating balls
        ..._balls.map((ball) => Positioned(
          left: MediaQuery.of(context).size.width * ball.x - ball.size / 2,
          top: MediaQuery.of(context).size.height * ball.y - ball.size / 2,
          child: _FloatingBall(ball: ball),
        )),
        // Content
        widget.child,
      ],
    );
  }
}

class _FloatingBall extends StatelessWidget {
  final _BallData ball;
  const _FloatingBall({required this.ball});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ball.size,
      height: ball.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.6),
            ball.color.withOpacity(0.7),
          ],
          center: const Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: ball.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(2, 4),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -20,
          duration: Duration(milliseconds: ball.duration),
          delay: Duration(milliseconds: ball.delay),
          curve: Curves.easeInOut,
        )
        .fadeIn(duration: 800.ms);
  }
}

class _BallData {
  final Color color;
  final double x;
  final double y;
  final double size;
  final int duration;
  final int delay;

  _BallData({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.duration,
    required this.delay,
  });
}
