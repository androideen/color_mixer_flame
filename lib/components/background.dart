import 'dart:math';
import 'dart:ui';

import 'package:color_mixer/screens/game.dart';
import 'package:color_mixer/utils/color_helper.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

class Background extends PositionComponent {
  final Color color = ColorGenerator.backgroundColor;

  @override
  void render(Canvas canvas) {
    Rect bgRect = Rect.largest;
    Paint bgPaint = Paint();
    bgPaint.color = color;
    canvas.drawRect(bgRect, bgPaint);
    super.render(canvas);
  }
}

class PlayerBackground extends PositionComponent with HasGameRef<GameManager> {
  final Color color = ColorGenerator.backgroundColor;

  @override
  Future<void> onLoad() {

    var deadPoint = gameRef.halfHeight - 30;
    for(var i = 0; i < 10; i ++){
      var posX = Random().nextDouble() * gameRef.screenSize.width;
      var posY = Random().nextDouble() * (gameRef.halfHeight - 60);
      var circle = CircleBackground(Vector2(posX, posY), deadPoint);
      addChild(circle);
    }

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    //background
    Rect bgRect = Rect.fromLTWH(0, 0, gameRef.screenSize.width,
        (gameRef.screenSize.height / 2).floorToDouble());
    canvas.drawRect(bgRect, Paint()..color = color);

    //ground
    Rect ground = Rect.fromLTWH(
        0,
        (gameRef.screenSize.height / 2).floorToDouble(),
        gameRef.screenSize.width,
        1);
    canvas.drawRect(ground, Paint()..color = Colors.white.withOpacity(0.15));

    super.render(canvas);
  }
}

class CircleBackground extends PositionComponent {
  final Color color = Colors.white;
  double deadPoint = 0;
  List<double> sizeList = [20, 25, 30, 35, 40];

  CircleBackground(Vector2 position, double deadPoint) {
    this.size =
        Vector2(sizeList[Random().nextInt(4)], sizeList[Random().nextInt(4)]);
    this.deadPoint = deadPoint;
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
        position.toOffset(), 12, Paint()..color = color.withOpacity(0.15));
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (y < deadPoint) {
      //create random size after reaching dead point
      size =
          Vector2(sizeList[Random().nextInt(4)], sizeList[Random().nextInt(4)]);
      y += 10 * dt;
    } else {
      y = -50;
    }
    super.update(dt);
  }
}
