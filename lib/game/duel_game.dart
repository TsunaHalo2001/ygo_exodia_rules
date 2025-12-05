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
  late YGOCard selectedCard;

  late GameField field;

  late SpriteComponent background;

  late int currentBgm;
  late int currentTurn;

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
    currentTurn = 1;

    field = GameField();
    world.add(field);

    _startRandomBgm();
  }

  void setupPlayers() {
    if (gameMode == GameMode.testing) {
      player1 = PlayerData(playerType: PlayerType.human);
      player1.genDeck(normalMonsters);
      player1.genHand();
      player2 = PlayerData(playerType: PlayerType.human);
      player2.genDeck(normalMonsters);
      player2.genHand();
    }
    else {
      player1 = PlayerData(playerType: PlayerType.human);
      player1.genDeck(normalMonsters);
      player1.genHand();
      player2 = PlayerData(playerType: PlayerType.ai);
      player2.genDeck(normalMonsters);
      player2.genHand();
    }
  }

  void _startRandomBgm() {
    FlameAudio.bgm.stop();

    currentBgm = Random().nextInt(16) + 1;
    String bgmPadded = currentBgm.toString().padLeft(2, '0');

    FlameAudio.bgm.play('BGM_DUEL_NORMAL_$bgmPadded.ogg', volume: 0.5);
  }

  void showDeckMenu(bool isPlayer1) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPlayer1) {
        overlays.add('DeckMenu1');
      }
      else {
        overlays.add('DeckMenu2');
      }
    });
  }

  void showExtraDeckMenu(bool isPlayer1) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPlayer1) {
        overlays.add('ExtraDeckMenu1');
      }
      else {
        overlays.add('ExtraDeckMenu2');
      }
    });
  }

  void hideDeckMenu(bool isPlayer1) {
    if (isPlayer1) {
      overlays.remove('DeckMenu1');
    }
    else {
      overlays.remove('DeckMenu2');
    }
  }

  void hideExtraDeckMenu() {
    overlays.remove('ExtraDeckMenu1');
    overlays.remove('ExtraDeckMenu2');
  }

  void showDeck(bool isPlayer1) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPlayer1) {
        overlays.add('Deck1');
      }
      else {
        overlays.add('Deck2');
      }
    });
  }

  void showExtraDeck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlays.add('ExtraDeck');
    });
  }

  void hideDeck(bool isPlayer1) {
    if (isPlayer1) {
      overlays.remove('Deck1');
    }
    else {
      overlays.remove('Deck2');
    }
  }

  void hideExtraDeck() {
    overlays.remove('ExtraDeck');
  }

  void showCardInfo(YGOCard card) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedCard = card;
      overlays.add('CardInfo');
    });
  }

  void hideCardInfo() {
    overlays.remove('CardInfo');
  }

  void drawCard(bool isPlayer1){
    if (isPlayer1) {
      player1.drawCard();
    }
    else {
      player2.drawCard();
    }
  }

  void passPhase(){}
  void selectCard(){}
}