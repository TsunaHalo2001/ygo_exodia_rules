part of '../main.dart';

enum GameMode {
  testing,
  vsAI,
}

enum TurnPhases {
  drawPhase,
  standbyPhase,
  mainPhase1,
  battlePhase,
  mainPhase2,
  endPhase,
}

enum CombatSteps {
  startStep,
  battleStep,
  damageStep,
  endStep,
}

class DuelGame extends FlameGame {
  final GameMode gameMode;
  final Map<int, YGOCard> normalMonsters;

  late final PlayerData player1;
  late final PlayerData player2;

  late PlayerData currentPlayer;
  late TurnPhases currentTurnPhase;

  late GameField field;

  late SpriteComponent background;

  DuelGame({
    required this.gameMode,
    required this.normalMonsters,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final backgroundSprite = await loadSprite('duel_background.png');
    final bgSize = Vector2(size.x, size.x * 0.717225161669606);

    background = SpriteComponent(
      sprite: backgroundSprite,
      size: bgSize,
      anchor: Anchor.center,
      position: Vector2.zero()
    );

    world.add(
      background,
    );

    setupPlayers();

    currentPlayer = player1;
    currentTurnPhase = TurnPhases.drawPhase;

    field = GameField();
    world.add(field);
  }

  void setupPlayers() {
    if (gameMode == GameMode.testing) {
      player1 = PlayerData(playerType: PlayerType.human);
      player1.genDeck(normalMonsters);
      player2 = PlayerData(playerType: PlayerType.human);
      player2.genDeck(normalMonsters);
    }
    else {
      player1 = PlayerData(playerType: PlayerType.human);
      player1.genDeck(normalMonsters);
      player2 = PlayerData(playerType: PlayerType.ai);
      player2.genDeck(normalMonsters);
    }
  }
  void drawCard(){}
  void passPhase(){}
  void selectCard(){}

}