import 'package:color_mixer/screens/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  runApp(MaterialApp(home: App()));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  GameManager _gameManager;


  Widget resetMenuBuilder(BuildContext buildContext, GameManager game) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        child: Icon(Icons.refresh, color: Colors.white),
        onPressed: () {
          setState(() {
            _gameManager = GameManager();
          });
        },
      ),
    );
  }

  Widget _buildGame(BuildContext context) {
    if (_gameManager != null) {
      return GameWidget(
        game: _gameManager,
        overlayBuilderMap: {
          "ResetMenu": resetMenuBuilder,
        },
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Color Mixer', style: TextStyle(color: Colors.white, fontSize: 48)),
              ElevatedButton(
                child: Icon(Icons.play_arrow, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _gameManager = GameManager();
                    _gameManager.screenSize = MediaQuery.of(context).size;
                  });
                },
              ),
              ElevatedButton(
                child: Icon(Icons.help_outline, color: Colors.white),
                onPressed: () {
                  _showHelp(context);
                },
              ),
              ElevatedButton(
                child: Icon(Icons.code, color: Colors.white),
                onPressed: () {
                  _launchURL('https://tltemplates.com/color-mixer-game/');
                },
              )
            ]),
      );
    }
  }

  _showHelp(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: Text("How to play"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("Mix 2 color cards to create new color for Player. "
                    "\n\nIf the player's color is the same as the bar, it passes. "
                    "If the player hit the DANGER bar, it dies despite color.\n\n"),
                Image.network('https://tltemplates.com/wp-content/uploads/2021/03/help.png')
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ));
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Flame.device.setPortrait();
    return Scaffold(
      backgroundColor: Color(0xff212121),
        body: Stack(children: [_buildGame(context)]));
  }
}
