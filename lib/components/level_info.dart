import 'dart:ui';
import 'package:color_mixer/screens/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelInfo extends PositionComponent with HasGameRef<GameManager>{

  @override
  Future<void> onLoad() {
    size = Vector2(gameRef.screenSize.width, 24);
    x = gameRef.halfWidth - 40;
    y = gameRef.halfHeight + 20;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    textPainter(Color(0xffffe082)).paint(canvas, Offset(x + 5, y + 1));

    super.render(canvas);
  }

  TextPainter textPainter(Color textColor) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Level ${gameRef.level}',
        style: TextStyle(
          color: textColor,
          fontSize: 24,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: width,
    );
    return textPainter;
  }
}