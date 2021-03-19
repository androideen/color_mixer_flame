import 'dart:math';
import 'dart:ui';

import 'package:color_mixer/screens/game.dart';
import 'package:color_mixer/utils/sound_helper.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent with HasGameRef<GameManager> {
  Color color;
  bool isDead = false;
  List<TrailComponent> trails = [];
  List<double> trailScales = [2/3, 1/2 , 1/3];

  double get widthInScreen => width + x;

  Player(Vector2 position, Vector2 size, Color color) {
    this.position = position;
    this.color = color;
    this.size = size;
    this.isDead = false;
  }

  @override
  Future<void> onLoad() {
    initTrail();
    return super.onLoad();
  }

  void initTrail() {


    var cPosY = height + 2;
    for( var i = 0; i < 3; i++){
      var scale = trailScales[i];
      var c = TrailComponent(Size(width * scale, height * trailScales[i]), color.withOpacity(scale) ,
          (width - width * scale) / 2, cPosY);
      trails.add(c);
      addChild(ParticleComponent(
          particle: ComponentParticle(lifespan: 10000, component: c)));
      cPosY += height * scale + 2;
    }

  }

  @override
  void render(Canvas canvas) {
    var shadow = Rect.fromLTWH(x - 1, y - 1, width + 2, height + 2);
    canvas.drawRect(shadow, Paint()..color = Colors.blue[50]);

    var rect = Rect.fromLTWH(x, y, width, height);
    canvas.drawRect(rect, paint());

    var innerSize = (size.x / 2).floorToDouble();

    var shadow2 = Rect.fromLTWH(x + innerSize / 2 - 1, y + innerSize / 2 - 1,
        innerSize + 2, innerSize + 2);
    canvas.drawRect(shadow2, Paint()..color = Colors.blue[50]);

    var rectInner = Rect.fromLTWH(
        x + innerSize / 2, y + innerSize / 2, innerSize, innerSize);
    canvas.drawRect(rectInner, paint());

    super.render(canvas);
  }

  Paint paint() {
    return Paint()..color = this.color;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void updatePlayerColor(Color mixedColor){
      color = mixedColor;
      for(var i = 0; i < trails.length; i++){
        trails[i].color = mixedColor.withOpacity(trailScales[i]);
      }
  }

  void moveTo(Vector2 newPos) {
    addEffect(MoveEffect(
      path: [
        newPos,
      ],
      speed: gameRef.playerSpeed * 10,
    ));
  }

  void deadAnimation() {
    SoundHelper.dead();
    if(isDead){
      isDead = false;
      hitAnimation();
      addEffect(MoveEffect(
          path: [
            Vector2(x, y + 50),
          ],
          speed: gameRef.playerSpeed * 20,
      ));

    }

  }

  void passAnimation() {
    SoundHelper.shoot();
    addEffect(MoveEffect(
      path: [
        Vector2(x, y - 30),
      ],
      curve: Curves.ease,
      isAlternating: true,
      speed: gameRef.playerSpeed * 20,
    ));
  }

  void hitAnimation() {
    //remove trail
    removeTrail();
    //play hit animation
    Random rnd = Random();
    Function randomOffset = () => Offset(
          rnd.nextDouble() * 300 - 100,
          rnd.nextDouble() * 200 - 100,
        );
    addChild(ParticleComponent(
        particle: Particle.generate(
            count: 10,
            generator: (i) => AcceleratedParticle(
                position: Offset(width / 2, 0),
                acceleration: randomOffset(),
                child: CircleParticle(paint: Paint()..color = color)))));
  }

  void removeTrail(){
    if(trails.isNotEmpty){
      for(var trail in trails){
        trail.size = Size.zero;
      }
    }
  }
}

class TrailComponent extends Component {
  Size size;
  double left;
  double top;
  Color color;

  TrailComponent(Size size, Color color, double left, double top) {
    this.size = size;
    this.left = left;
    this.top = top;
    this.color = color;
  }

  @override
  Future<void> onLoad() {
    return super.onLoad();
  }

  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(left, top, size.width, size.height),
        Paint()..color = color);
  }

  void update(double dt) {

  }
}
