import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class Ball {
  final String id;
  double x;
  double y;
  double radius;
  Color color;
  int colorIndex;
  double velocityY;
  bool isMerging;

  Ball({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.colorIndex,
    required this.velocityY,
    this.isMerging = false,
  });

  Rect get rect => Rect.fromCircle(center: Offset(x, y), radius: radius);

  bool collidesWith(Ball other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final distance = sqrt(dx * dx + dy * dy);
    return distance < (radius + other.radius) * 0.9;
  }
}

class GameLogic {
  static const double dangerLineY = 80.0;
  static const double minBallRadius = 22.0;
  static const double maxBallRadius = 32.0;

  final Random _random = Random();
  List<Ball> balls = [];
  int score = 0;
  int highScore = 0;
  int comboCount = 0;
  int comboMultiplier = 1;
  double spawnInterval = 2.0;
  double ballSpeed = 60.0;
  double timeSinceLastSpawn = 0;
  double timeSinceLastCombo = 0;
  double difficultyTimer = 0;
  bool isGameOver = false;
  Ball? draggedBall;
  String? draggedBallId;

  final double gameWidth;
  final double gameHeight;

  GameLogic({required this.gameWidth, required this.gameHeight});

  void spawnBall() {
    final colorIndex = _random.nextInt(AppColors.ballColors.length);
    final radius = minBallRadius + _random.nextDouble() * (maxBallRadius - minBallRadius);
    final x = radius + _random.nextDouble() * (gameWidth - radius * 2);

    balls.add(Ball(
      id: DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(9999).toString(),
      x: x,
      y: -radius,
      radius: radius,
      color: AppColors.ballColors[colorIndex],
      colorIndex: colorIndex,
      velocityY: ballSpeed,
    ));
  }

  List<String> update(double dt) {
    if (isGameOver) return [];

    timeSinceLastSpawn += dt;
    timeSinceLastCombo += dt;
    difficultyTimer += dt;

    // Combo decay
    if (timeSinceLastCombo > 2.0) {
      comboCount = 0;
      comboMultiplier = 1;
    }

    // Difficulty scaling every 30 seconds
    if (difficultyTimer >= 30.0) {
      difficultyTimer = 0;
      ballSpeed = min(ballSpeed + 15.0, 200.0);
      spawnInterval = max(spawnInterval - 0.2, 0.6);
    }

    // Spawn new balls
    if (timeSinceLastSpawn >= spawnInterval) {
      timeSinceLastSpawn = 0;
      spawnBall();
    }

    // Move balls
    for (var ball in balls) {
      if (ball.id != draggedBallId) {
        ball.y += ball.velocityY * dt;
        // Clamp x
        ball.x = ball.x.clamp(ball.radius, gameWidth - ball.radius);
      }
    }

    // Check merges
    List<String> mergedIds = [];
    List<Ball> toRemove = [];

    for (int i = 0; i < balls.length; i++) {
      for (int j = i + 1; j < balls.length; j++) {
        final a = balls[i];
        final b = balls[j];
        if (toRemove.contains(a) || toRemove.contains(b)) continue;
        if (a.colorIndex == b.colorIndex && a.collidesWith(b)) {
          // Merge!
          toRemove.add(a);
          toRemove.add(b);
          mergedIds.add(a.id);
          mergedIds.add(b.id);

          comboCount++;
          timeSinceLastCombo = 0;
          comboMultiplier = min(comboCount, 4);
          score += 10 * comboMultiplier;
          if (score > highScore) highScore = score;
        }
      }
    }

    balls.removeWhere((b) => toRemove.contains(b));

    // Check game over - ball reaches danger line
    for (var ball in balls) {
      if (ball.y - ball.radius <= dangerLineY) {
        isGameOver = true;
        break;
      }
    }

    // Remove balls that go below screen
    balls.removeWhere((b) => b.y - b.radius > gameHeight + 50);

    return mergedIds;
  }

  void startDrag(String ballId) {
    draggedBallId = ballId;
    draggedBall = balls.firstWhere((b) => b.id == ballId, orElse: () => balls.first);
  }

  void updateDrag(double x, double y) {
    if (draggedBall != null) {
      draggedBall!.x = x.clamp(draggedBall!.radius, gameWidth - draggedBall!.radius);
      draggedBall!.y = y;
    }
  }

  void endDrag() {
    draggedBallId = null;
    draggedBall = null;
  }

  void reset() {
    balls.clear();
    score = 0;
    comboCount = 0;
    comboMultiplier = 1;
    spawnInterval = 2.0;
    ballSpeed = 60.0;
    timeSinceLastSpawn = 0;
    difficultyTimer = 0;
    isGameOver = false;
    draggedBall = null;
    draggedBallId = null;
  }
}
