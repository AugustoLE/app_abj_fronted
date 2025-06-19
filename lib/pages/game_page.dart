import 'package:flutter/material.dart';
import '../models/game_model.dart';

class GamePage extends StatelessWidget {
  final GameModel game;
  const GamePage({required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.title)),
      body: Center(
        child: Text('Pantalla vacía para ${game.title}', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}