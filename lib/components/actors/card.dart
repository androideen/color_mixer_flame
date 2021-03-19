import 'dart:ui';

import 'package:color_mixer/screens/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ColorCard extends PositionComponent
    with Tapable, HasGameRef<GameManager> {
  int index;
  Color color;
  Color newColor;
  double cardSize;
  bool toggle = false;
  bool selectable = true;

  bool isSource = true;
  double textSize = 9;
  double speed = 30;
  double limitRange = 16;
  bool mixed = false;

  ColorCard(int index, Color color, double cardSize) {
    this
      ..index = index
      ..color = color
      ..newColor = color
      ..cardSize = cardSize;
    size = Vector2.all(cardSize);
  }

  void updateColor(Color newColor, bool isSource) {
    this.toggle = false;
    this.isSource = isSource;

    if (!isSource) {
      addEffect(MoveEffect(
        path: [
          Vector2(x, y + limitRange),
          Vector2(x, y),
        ],
        speed: speed * 10,
        curve: Curves.ease,
        isRelative: false,
        isInfinite: false,
        isAlternating: true,
        onComplete: _mixDone,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    var shadowColor = Colors.white;
    var thickness = 3.0;

    if(cardSize > 0){
      if (toggle) {
        canvas.drawRect(
            Rect.fromLTWH(x - thickness, y - thickness, width + thickness * 2,
                height + thickness * 2),
            Paint()..color = shadowColor);
      } else {
        canvas.drawRect(Rect.fromLTWH(x + width, y, thickness, height),
            Paint()..color = shadowColor);
        canvas.drawRect(
            Rect.fromLTWH(x, y + height, width + thickness, thickness),
            Paint()..color = shadowColor);
      }
    }


    //color rectangle
    canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint());

    super.render(canvas);
  }

  Paint paint() {
    return Paint()..color = this.color;
  }

  @override
  bool onTapDown(TapDownDetails details) {
    //only allow selection if there is place for choices
    if(selectable){
      if (gameRef.selectedIndexes.length < 2 || gameRef.selectedIndexes.isEmpty) {
        toggle = !toggle;
        gameRef.selectColor(this.index, toggle);
      }
    }


    return true;
  }

  void _mixDone() {
    //reset colors
    gameRef.resetSelectedColors();
  }

  @override
  bool onTapUp(TapUpDetails details) {
    return super.onTapUp(details);
  }
}
