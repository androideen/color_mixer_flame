import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart' show Colors;

class ColorGenerator {
  static Color backgroundColor = Color(0xff212121);

  static List<Color> allowColors = [
    Colors.blue,
    Colors.amber,
    Colors.green,
    Colors.red,
    Colors.teal,
    Colors.purple,
    Colors.brown,
    Colors.orange,
    Colors.lime
  ];

  static List<Color> generate(int count) {
    List<Color> colors = [];
    for (var i = 0; i < count; i++) {
      colors.add(allowColors[i]);
    }
    return colors;
  }

  static Color randomColor() {
    return allowColors[Random().nextInt(allowColors.length)];
  }

  static Color mix(Color source, Color destination) {
    var r = (source.red + destination.red) / 2;
    var g = (source.green + destination.green) / 2;
    var b = (source.blue + destination.blue) / 2;
    return Color.fromRGBO(r.toInt(), g.toInt(), b.toInt(), 1);
  }
}
