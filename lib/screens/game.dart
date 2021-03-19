import 'dart:ui';

import 'package:color_mixer/components/actors/card.dart';
import 'package:color_mixer/components/actors/obstacle.dart';
import 'package:color_mixer/components/actors/player.dart';
import 'package:color_mixer/components/background.dart';
import 'package:color_mixer/components/level_info.dart';
import 'package:color_mixer/utils/color_helper.dart';
import 'package:color_mixer/utils/sound_helper.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;

class GameManager extends BaseGame with HasTapableComponents {
  Size screenSize;
  double halfWidth;
  double halfHeight;

  List<ColorCard> cards = [];
  double cardSize = 60;
  int cardPerRow = 2;
  double spacer = 20.0;
  double marginX = 50.0; //left and right margin

  double playerSize = 20;
  double playerSpeed = 24;

  List<Color> objectives = [];

  //game logic variables: color card index in card list
  int level = 1;
  List<int> selectedIndexes = [];


  //Player & enemies
  Player player;
  Obstacles obstacles;
  bool gameOver = false;

  @override
  Future<void> onLoad() {
    print('Game Start');
    _calculateScreenSize();
    SoundHelper.bgmStop();
    SoundHelper.bgm();

    //game background
    add(Background());
    add(PlayerBackground());

    //add card list to a grid
    _addColorCards();
    calculateObjectives();

    //player
    var pX = (screenSize.width / 2 - playerSize).floorToDouble();
    var pY = (screenSize.height / 2 - playerSize).floorToDouble() + 50;
    player = Player(Vector2(pX, pY), Vector2.all(playerSize), Colors.blue[400]);
    add(player);

    player.addEffect(MoveEffect(
        path: [
          Vector2(player.x, player.y - 100),
        ],
        speed: playerSpeed * 10,
        onComplete: () {
        }));

    //enemies & helpers
    obstacles = Obstacles();
    add(obstacles);

    //add level info
    add(LevelInfo());

    return super.onLoad();
  }

  void _calculateScreenSize() {
    screenSize = Size(canvasSize.toOffset().dx, canvasSize.toOffset().dy);
    halfWidth = (screenSize.width / 2).floorToDouble();
    halfHeight = (screenSize.height / 2).floorToDouble();
  }

  @override
  void onResize(Vector2 canvasSize) {
    super.onResize(canvasSize);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (gameOver) {
      overlays.add("ResetMenu");
    }

    super.update(dt);
  }

  void _addColorCards() {
    double gridStartX = (screenSize.width -
            (cardSize * cardPerRow + spacer * (cardPerRow - 1))) /
        2;
    double gridStartY = screenSize.height / 2;
    Vector2 gridPosition = Vector2(gridStartX, gridStartY);

    //generate colors first
    List<Color> colors = ColorGenerator.generate(cardPerRow * cardPerRow);

    for (var i = 0; i < cardPerRow * cardPerRow; i++) {
      //increase position.y every cardPerRow rows
      if (i % cardPerRow == 0) {
        gridPosition = Vector2(gridStartX, gridPosition.y + spacer + cardSize);
      }

      //add color card to game
      ColorCard card = ColorCard(i, colors[i], cardSize.floorToDouble());
      card.position = gridPosition;
      cards.add(card);
      add(card);

      //move position.x of grid placeholder for next card
      gridPosition += Vector2(card.width + spacer, 0);
    }
  }

  void selectColor(int index, bool toggle) {
    if (toggle) {
      selectedIndexes.add(index);
    } else {
      selectedIndexes.remove(index); //remove where index = value
    }

    //mix colors if there are 2 selected cards
    if (selectedIndexes.length >= 2) {
      //mix color
      var newColorSource = ColorGenerator.randomColor();
      var mixedColor = ColorGenerator.mix(
          cards[selectedIndexes[0]].color, cards[selectedIndexes[1]].color);
      cards[selectedIndexes[0]].updateColor(newColorSource, true);
      cards[selectedIndexes[1]].updateColor(mixedColor, false);

      //update color to player
      player.updatePlayerColor(mixedColor);

      var newPost = _posOfObstacleWithSameColor();
      if (newPost != Vector2(0, 0)) {
        player.moveTo(newPost);
      }
    }
  }



  void resetSelectedColors() {
    //reset selected indexes after mixing
    if (selectedIndexes.length >= 2) {
      selectedIndexes = [];
    }
  }

  void resetCardColors(){
    //change card color positions
    List<Color> colors = ColorGenerator.generate(cardPerRow * cardPerRow);
    colors.shuffle();
    for(var i = 0; i < cards.length; i++){
      cards[i].color = colors[i];
    }

  }

  Vector2 _posOfObstacleWithSameColor() {
    for (var o in obstacles.items) {
      if (player.color == o.color) {
        return Vector2((o.x + o.width / 2) - playerSize / 2, player.y);
      }
    }
    return Vector2(0, 0);
  }

  void calculateObjectives() {
    objectives = [];
    //get all available colors
    List<Color> availableColors = [];
    for (var c in cards) {
      availableColors.add(c.color);
    }
    //calculate random mix
    availableColors.shuffle();
    for (var i = 0; i < availableColors.length; i++) {
      for (var j = 0; j < availableColors.length; j++) {
        var mix = ColorGenerator.mix(availableColors[i], availableColors[j]);
        if (!objectives.contains(mix)) {
          objectives.add(mix);
        }
      }
    }
  }

  void killPlayer() {
    gameOver = true;
    player.isDead = true;
    player.deadAnimation();

    //disable card on die
    for(var card in cards){
      card.color = card.color.withOpacity(0.5);
      card.selectable = false;
    }
  }

  void passPlayer() {
    obstacles.stop(true);
    player.passAnimation();
  }
}
