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
  double velocityX;
  bool isMerging;

  Ball({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.colorIndex,
    required this.velocityY,
    this.velocityX = 0,
    this.isMerging = false,
  });

  Rect get rect => Rect.fromCircle(center: Offset(x, y), radius: radius);

  bool collidesWith(Ball other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy) < (radius + other.radius);
  }

  double distanceTo(Ball other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }
}

class GameLogic {
  static const double gravity  = 600.0;
  static const double bounce   = 0.15;   // low → balls settle quickly
  static const double friction = 0.80;
  static const double minBallRadius = 20.0;
  static const double maxBallRadius = 30.0;

  final Random _random = Random();

  List<Ball> balls = [];
  int    score             = 0;
  int    highScore         = 0;
  int    comboCount        = 0;
  int    comboMultiplier   = 1;
  double spawnInterval     = 2.0;
  double timeSinceLastSpawn  = 0;
  double timeSinceLastCombo  = 0;
  double difficultyTimer     = 0;
  bool   isGameOver          = false;
  String? draggedBallId;

  final double gameWidth;
  final double gameHeight;

  /// Visible floor — balls rest here.
  double get floorY => gameHeight - 60.0;

  /// Danger line just below the HUD — game over when a *settled* ball reaches it.
  double get dangerLineY => 180.0;

  GameLogic({required this.gameWidth, required this.gameHeight}) {
    timeSinceLastSpawn = spawnInterval - 0.5;
  }

  // ── Spawn ─────────────────────────────────────────────────────────────────

  void spawnBall() {
    final colorIndex = _random.nextInt(AppColors.ballColors.length);
    final radius     = minBallRadius +
        _random.nextDouble() * (maxBallRadius - minBallRadius);
    final x = radius + _random.nextDouble() * (gameWidth - radius * 2);

    balls.add(Ball(
      id: '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(9999)}',
      x: x,
      y: -radius,          // just above screen top
      radius: radius,
      color: AppColors.ballColors[colorIndex],
      colorIndex: colorIndex,
      velocityY: 0,
    ));
  }

  // ── Main update loop ──────────────────────────────────────────────────────

  List<String> update(double dt) {
    if (isGameOver) return [];

    timeSinceLastSpawn += dt;
    timeSinceLastCombo += dt;
    difficultyTimer    += dt;

    // Combo decay
    if (timeSinceLastCombo > 2.0) {
      comboCount     = 0;
      comboMultiplier = 1;
    }

    // Difficulty ramp every 30 s
    if (difficultyTimer >= 30.0) {
      difficultyTimer  = 0;
      spawnInterval    = max(spawnInterval - 0.2, 0.8);
    }

    // Spawn
    if (timeSinceLastSpawn >= spawnInterval) {
      timeSinceLastSpawn = 0;
      spawnBall();
    }

    // ── Physics ──────────────────────────────────────────────────────────
    for (final ball in balls) {
      if (ball.id == draggedBallId) continue;

      ball.velocityY += gravity * dt;
      ball.x += ball.velocityX * dt;
      ball.y += ball.velocityY * dt;

      // Floor
      if (ball.y + ball.radius >= floorY) {
        ball.y          = floorY - ball.radius;
        ball.velocityY  = -ball.velocityY * bounce;
        ball.velocityX *= friction;
        if (ball.velocityY.abs() < 10) ball.velocityY = 0;
        if (ball.velocityX.abs() < 5)  ball.velocityX = 0;
      }

      // Walls
      if (ball.x - ball.radius < 0) {
        ball.x         = ball.radius;
        ball.velocityX = ball.velocityX.abs() * friction;
      }
      if (ball.x + ball.radius > gameWidth) {
        ball.x         = gameWidth - ball.radius;
        ball.velocityX = -ball.velocityX.abs() * friction;
      }
    }

    // ── Ball–ball collisions ─────────────────────────────────────────────
    for (int i = 0; i < balls.length; i++) {
      for (int j = i + 1; j < balls.length; j++) {
        final a    = balls[i];
        final b    = balls[j];
        final dist = a.distanceTo(b);
        final minD = a.radius + b.radius;
        if (dist < minD && dist > 0) {
          final nx      = (b.x - a.x) / dist;
          final ny      = (b.y - a.y) / dist;
          final overlap = (minD - dist) / 2.0;

          if (a.id != draggedBallId) { a.x -= nx * overlap; a.y -= ny * overlap; }
          if (b.id != draggedBallId) { b.x += nx * overlap; b.y += ny * overlap; }

          // Simple velocity exchange
          if (a.id != draggedBallId && b.id != draggedBallId) {
            final relVel = (a.velocityX - b.velocityX) * nx +
                (a.velocityY - b.velocityY) * ny;
            if (relVel > 0) {
              final impulse = relVel * 0.4;
              a.velocityX -= nx * impulse;
              a.velocityY -= ny * impulse;
              b.velocityX += nx * impulse;
              b.velocityY += ny * impulse;
            }
          }
        }
      }
    }

    // ── Merge detection ──────────────────────────────────────────────────
    final List<String> mergedIds = [];
    final List<Ball>   toRemove  = [];

    for (int i = 0; i < balls.length; i++) {
      for (int j = i + 1; j < balls.length; j++) {
        final a = balls[i];
        final b = balls[j];
        if (toRemove.contains(a) || toRemove.contains(b)) continue;
        if (a.colorIndex == b.colorIndex && a.collidesWith(b)) {
          toRemove.add(a);
          toRemove.add(b);
          mergedIds.add(a.id);
          mergedIds.add(b.id);

          comboCount++;
          timeSinceLastCombo = 0;
          comboMultiplier    = min(comboCount, 4);
          score             += 10 * comboMultiplier;
          if (score > highScore) highScore = score;

          // Spawn upgraded merged ball at midpoint
          final nextIndex = min(a.colorIndex + 1, AppColors.ballColors.length - 1);
          final newRadius = min(a.radius * 1.2, maxBallRadius * 1.5);
          balls.add(Ball(
            id: '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(9999)}',
            x: (a.x + b.x) / 2,
            y: (a.y + b.y) / 2,
            radius: newRadius,
            color: AppColors.ballColors[nextIndex],
            colorIndex: nextIndex,
            velocityY: -60,
            velocityX: 0,
          ));
        }
      }
    }
    balls.removeWhere(toRemove.contains);

    // ── Game-over check ──────────────────────────────────────────────────
    // Only fires when a ball is SETTLED (slow-moving) AND its top edge
    // has reached the danger line — meaning the pile stacked to the top.
    for (final ball in balls) {
      final settled = ball.velocityY.abs() < 20 && ball.velocityX.abs() < 20;
      final aboveDangerLine = (ball.y - ball.radius) <= dangerLineY;
      final onScreen = ball.y > 0;
      if (onScreen && settled && aboveDangerLine) {
        isGameOver = true;
        break;
      }
    }

    // Clamp all balls within walls
    for (final ball in balls) {
      ball.x = ball.x.clamp(ball.radius, gameWidth - ball.radius);
    }

    return mergedIds;
  }

  // ── Drag ─────────────────────────────────────────────────────────────────

  void startDrag(String ballId) => draggedBallId = ballId;

  void updateDrag(double x, double y) {
    if (draggedBallId == null) return;
    final ball = _findById(draggedBallId!);
    if (ball == null) return;
    ball.x         = x.clamp(ball.radius, gameWidth - ball.radius);
    ball.y         = y.clamp(ball.radius, floorY - ball.radius);
    ball.velocityX = 0;
    ball.velocityY = 0;
  }

  void endDrag() => draggedBallId = null;

  Ball? _findById(String id) {
    for (final b in balls) {
      if (b.id == id) return b;
    }
    return null;
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() {
    balls.clear();
    score              = 0;
    comboCount         = 0;
    comboMultiplier    = 1;
    spawnInterval      = 2.0;
    timeSinceLastSpawn = spawnInterval - 0.5;
    timeSinceLastCombo = 0;
    difficultyTimer    = 0;
    isGameOver         = false;
    draggedBallId      = null;
  }
}