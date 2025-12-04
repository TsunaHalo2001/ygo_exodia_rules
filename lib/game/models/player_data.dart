part of '../../main.dart';

enum PlayerType {
  human,
  ai,
}

class PlayerData {
  int lifePoints;
  PlayerType playerType;

  PlayerData({
    required this.playerType,
    this.lifePoints = 8000
  });
}