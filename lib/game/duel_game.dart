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
  final YGOCard exodia;

  late final PlayerData player1;
  late final PlayerData player2;

  late PlayerData currentPlayer;
  late TurnPhases currentTurnPhase;
  late YGOCard selectedCard;

  late GameField field;

  late SpriteComponent background;

  late int currentBgm;
  late int currentTurn;

  late HandComponent player1Hand;
  late HandComponent player2Hand;

  DuelGame({
    required this.gameMode,
    required this.normalMonsters,
    required this.exodia,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final backgroundSprite = await loadSprite('duel_background.png');
    final bgSize = Vector2(size.x, size.x * 0.717225161669606);
    final handSize = Vector2(size.x * 0.73, size.y * 0.3);

    background = SpriteComponent(
      sprite: backgroundSprite,
      size: bgSize,
      anchor: Anchor.center,
      position: Vector2.zero()
    );

    world.add(
      background,
    );

    player1Hand = HandComponent(
      size: handSize,
      position: Vector2(0, size.y * 0.475),
    );

    player2Hand = HandComponent(
      size: handSize,
      position: Vector2(0, -size.y * 0.475),
    );

    setupPlayers(
      player1Hand: player1Hand,
      player2Hand: player2Hand
    );

    world.add(player1Hand);
    world.add(player2Hand);

    currentPlayer = player1;
    currentTurnPhase = TurnPhases.drawPhase;
    currentTurn = 1;

    field = GameField();
    world.add(field);

    _startRandomBgm();
  }

  void setupPlayers({
    required HandComponent player1Hand,
    required HandComponent player2Hand
  }) {
    if (gameMode == GameMode.testing) {
      player1 = PlayerData(playerType: PlayerType.human);
      player2 = PlayerData(playerType: PlayerType.human);
    }
    else {
      player1 = PlayerData(playerType: PlayerType.human);
      player2 = PlayerData(playerType: PlayerType.ai);
    }
    player1.genDeck(normalMonsters);
    player1.genHand();
    player2.genDeck(normalMonsters);
    player2.genHand();

    for (int cardId in player1.hand) {
      final card = cardId == 33396948 ? exodia : normalMonsters[cardId]!;
      final cardComponent = CardComponent(
        card: card,
        isFaceUp: true,
        size: size.y * 0.3,
        position: Vector2(0, size.y * 0.475),
      );
      player1Hand.addCard(cardComponent);
    }

    for (int cardId in player2.hand) {
      final card = cardId == 33396948 ? exodia : normalMonsters[cardId]!;
      final cardComponent = CardComponent(
        card: card,
        isFaceUp: true,
        size: size.y * 0.3,
        position: Vector2(0, -size.y * 0.475),
      );
      player2Hand.addCard(cardComponent);
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

  void passPhase(){
    switch (currentTurnPhase) {
      case TurnPhases.drawPhase:
        currentTurnPhase = TurnPhases.standbyPhase;
        break;
      case TurnPhases.standbyPhase:
        currentTurnPhase = TurnPhases.mainPhase1;
        break;
      case TurnPhases.mainPhase1:
        currentTurnPhase = TurnPhases.battlePhase;
        break;
      case TurnPhases.battlePhase:
        currentTurnPhase = TurnPhases.mainPhase2;
        break;
      case TurnPhases.mainPhase2:
        currentTurnPhase = TurnPhases.endPhase;
        break;
      case TurnPhases.endPhase:
        // Switch turn
        currentPlayer = currentPlayer == player1 ? player2 : player1;
        currentTurn += 1;
        currentTurnPhase = TurnPhases.drawPhase;
        break;
    }
  }

  void drawCard(bool isPlayer1){
    if (isPlayer1) {
      final drawedCard = player1.drawCard();
      final card = drawedCard == 33396948 ? exodia : normalMonsters[drawedCard]!;
      final cardComponent = CardComponent(
        card: card,
        isFaceUp: true,
        size: size.y * 0.3,
        position: Vector2(0, size.y * 0.475),
      );
      player1Hand.addCard(cardComponent);
    }
    else {
      final drawedCard = player2.drawCard();
      final card = drawedCard == 33396948 ? exodia : normalMonsters[drawedCard]!;
      final cardComponent = CardComponent(
        card: card,
        isFaceUp: true,
        size: size.y * 0.3,
        position: Vector2(0, size.y * 0.475),
      );
      player2Hand.addCard(cardComponent);
    }
    passPhase();
  }

  void selectCard(){}
}