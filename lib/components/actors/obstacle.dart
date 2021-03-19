import 'dart:math';
import 'dart:ui';

import 'package:color_mixer/screens/game.dart';
import 'package:color_mixer/utils/sound_helper.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class Obstacles extends PositionComponent with HasGameRef<GameManager> {
  double currentY = 0;
  double count = 4;
  double speed = 50;
  double maxSpeed = 250;
  List<Obstacle> items = [];
  int hitIndex = -1; //the obstacle that hits player

  Obstacles() {
    //debugMode = true;
    //debugColor = Colors.red;
  }

  @override
  Future<void> onLoad() {
    for (var i = 0; i < count; i++) {
      var isEnemy = i % 2 == 0 ? true : false;
      var posX = i > 0 ? items[i - 1].x + items[i - 1].width : 0.0;
      var pos = Vector2(posX, -50);
      var oWidth = isEnemy
          ? gameRef.screenSize.width / count * 1.5
          : gameRef.screenSize.width / count * 0.5;
      var s = Vector2(oWidth, 20);
      Obstacle o = Obstacle(
          pos, s, gameRef.objectives[i], speed, isEnemy, gameRef.halfHeight);
      items.add(o);
      addChild(o);
    }

    return super.onLoad();
  }



  void stop(bool stop) {
    items.forEach((element) {
      element.stop = stop;
    });
  }

  bool isHitPlayer() {
    for (var item in items) {
      if (item.y >= gameRef.player.y - gameRef.playerSize) {
        return true;
      }
    }
    return false;
  }

  void detectHit() {
    if (isHitPlayer()) {
      //stop obstacles when hit player (1/2 player)
      stop(true);

      //find the obstacle that hit player
      for (var i = 0; i < items.length; i++) {
        if (items[i].x <= gameRef.player.x &&
            gameRef.player.x <= items[i].x + items[i].width) {
          hitIndex = i;
          items[i].hitPlayer = true;
        }
      }
    }
  }

  @override
  void update(double dt) {
    detectHit();

    //stop if there is a hit
    if (hitIndex >= 0 && items[hitIndex].hitPlayer) {

      //kill or pass
      if(!gameRef.player.isDead){
        if (gameRef.player.color != items[hitIndex].color ||
            items[hitIndex].isEnemy) {
          //check y condition to make sure player die once
          SoundHelper.bgmStop();
          if(items[0].y.floorToDouble() >= gameRef.player.y - gameRef.player.height){
            gameRef.player.y += 1; //just to make sure player's y is always bigger than obstacles
            gameRef.killPlayer();
          }
        } else {
          //continue pass player through the same color obstacle
          gameRef.passPlayer();
          _resetForNextLevel();
        }
      }
    }

    super.update(dt);
  }

  void _resetForNextLevel() {
    hitIndex = -1; //reset hit index
    gameRef.resetCardColors();//get card objectives
    gameRef.calculateObjectives(); //get new objectives
    //increase level and speed based on level
    gameRef.level += 1;
    if (speed < maxSpeed){
      speed += gameRef.level * 2;
      for(var o in items){
        o.speed = speed;
      }
    }
    //reset obstacles position
    updateObstacles();
  }

  void updateObstacles() {
    for (var i = 0; i < items.length; i++) {
      var isEnemy = !items[i].isEnemy;
      var posX = i > 0 ? items[i - 1].x + items[i - 1].width + 1 : 0.0;
      var pos = Vector2(posX, -50);
      var oWidth = isEnemy
          ? gameRef.screenSize.width / count * 1.5
          : gameRef.screenSize.width / count * 0.5;
      items[i]
        ..color = gameRef.objectives[i]
        ..position = pos
        ..isEnemy = isEnemy
        ..width = oWidth
        ..hitPlayer = false
        ..stop = false;
    }
  }
}

class Obstacle extends PositionComponent {
  Color color;
  double speed;
  bool isEnemy = false;
  bool hitPlayer = false;
  bool stop = false;
  double deadPoint = 0;

  Obstacle(Vector2 position, Vector2 size, Color color, double speed,
      bool isEnemy, double deadPoint) {
    this.position = position;
    this.color = color;
    this.speed = speed;
    this.isEnemy = isEnemy;
    this.size = size;
    this.deadPoint = deadPoint;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint());

    //shadows
    canvas.drawRect(Rect.fromLTWH(x, y - 2, width, 2),
        Paint()..color = color.brighten(0.5));
    canvas.drawRect(Rect.fromLTWH(x, y + height, width, 2),
        Paint()..color = color.brighten(0.5));

    //text for enemy
    if (isEnemy) {
      textPainter(Color(0xffffe082)).paint(canvas, Offset(x + 5, y + 1));
    }

    super.render(canvas);
  }

  Paint paint() {
    return Paint()..color = this.color;
  }

  TextPainter textPainter(Color textColor) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'DANGER',
        style: TextStyle(
          color: textColor,
          fontSize: 16,
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

  @override
  void update(double dt) {
    //move down obstacle
    if (!stop && y <= deadPoint - height) {
      y += speed * dt;
    }

    super.update(dt);
  }
}
