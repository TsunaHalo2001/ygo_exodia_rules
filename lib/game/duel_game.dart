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
  final ValueNotifier<TurnPhases> currentTurnPhaseNotifier;
  late YGOCard? selectedCard;
  late CardComponent? selectedCardComponent;
  late ZoneComponent? selectedZone;
  late ZoneComponent? battleZone;
  late int selectedZoneIndex;
  late int battleZoneIndex;

  late GameField field;

  late SpriteComponent background;

  late int currentBgm;
  late int currentTurn;

  late HandComponent player1Hand;
  late HandComponent player2Hand;

  static const double phaseDisplayDuration = 2.0;
  static const double turnDisplayDuration = 2.0;

  bool isPhaseDisplaying = false;
  bool isTurnDisplaying = false;

  DuelGame({
    required this.gameMode,
    required this.normalMonsters,
    required this.exodia,
    TurnPhases initialPhase = TurnPhases.drawPhase,
  }) : currentTurnPhaseNotifier = ValueNotifier<TurnPhases>(initialPhase);

  TurnPhases get currentTurnPhase => currentTurnPhaseNotifier.value;

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
        player: player1,
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
        player: player2,
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

  void showSummonMenu() {
    if (!overlays.isActive('SummonMenu')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        overlays.add('SummonMenu');
      });
    }
  }

  void hideSummonMenu() {
    overlays.remove('SummonMenu');
  }

  Future<void> passPhase() async {
    if (isPhaseDisplaying || isTurnDisplaying) {
      return;
    }

    final phaseSize = Vector2(size.x * 0.4, size.y * 0.1);
    final turnSize = Vector2(size.x, size.y * 0.2);
    final phasePos = Vector2.zero();

    switch (currentTurnPhase) {
      case TurnPhases.drawPhase:
        await animatePhaseChange(
          "Standby Phase",
          phaseSize,
          phasePos,
          TurnPhases.standbyPhase
        );
        standbyToMain();
        break;
      case TurnPhases.standbyPhase:
        await animatePhaseChange(
          "Main Phase 1",
          phaseSize,
          phasePos,
          TurnPhases.mainPhase1
        );
        break;
      case TurnPhases.mainPhase1:
        if (currentTurn == 1) {
          await animatePhaseChange(
              "End Phase",
              phaseSize,
              phasePos,
              TurnPhases.endPhase
          );
          endToNextTurn();
          break;
        }
        await animatePhaseChange(
          "Battle Phase",
          phaseSize,
          phasePos,
          TurnPhases.battlePhase
        );
        break;
      case TurnPhases.battlePhase:
        await animatePhaseChange(
          "Main Phase 2",
          phaseSize,
          phasePos,
          TurnPhases.mainPhase2
        );
        break;
      case TurnPhases.mainPhase2:
        await animatePhaseChange(
          "End Phase",
          phaseSize,
          phasePos,
          TurnPhases.endPhase
        );
        endToNextTurn();
        break;
      case TurnPhases.endPhase:
        currentPlayer = currentPlayer == player1 ? player2 : player1;
        currentTurn += 1;
        world.add(
          ChangeTurnComponent(
            isPlayer1: currentPlayer == player1,
            turn: currentTurn,
            size: turnSize,
            position: phasePos,
          )
        );
        await Future.delayed(const Duration(seconds: 2));
        currentTurnPhaseNotifier.value = TurnPhases.drawPhase;
        break;
    }
  }

  Future<void> animatePhaseChange (String title, Vector2 size, Vector2 position, TurnPhases turn) async {
    world.add(
      ChangePhaseComponent(
        isPlayer1: currentPlayer == player1,
        phase: title,
        size: size,
        position: position,
    ));

    await Future.delayed(const Duration(seconds: 2));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentTurnPhaseNotifier.value = turn;
    });
  }

  void drawCard(bool isPlayer1){
    if (isPlayer1) {
      //if (player1.hand.contains(33396948) && )
      player1.hasNormalSummonedThisTurn = false;
      for (final card in player1.fieldComponents) {
        if (card != null) {
          card.attackedThisTurn = false;
        }
      }
      if (currentTurn > 1) {
        final drawedCard = player1.drawCard();
        final card = drawedCard == 33396948 ? exodia : normalMonsters[drawedCard]!;
        final cardComponent = CardComponent(
          card: card,
          isFaceUp: true,
          size: size.y * 0.3,
          position: Vector2(0, size.y * 0.475),
          player: player1,
        );
        player1Hand.addCard(cardComponent);
      }
    }
    else {
      player2.hasNormalSummonedThisTurn = false;
      for (final card in player2.fieldComponents) {
        if (card != null) {
          card.attackedThisTurn = false;
        }
      }
      final drawedCard = player2.drawCard();
      final card = drawedCard == 33396948 ? exodia : normalMonsters[drawedCard]!;
      final cardComponent = CardComponent(
        card: card,
        isFaceUp: true,
        size: size.y * 0.3,
        position: Vector2(0, size.y * 0.475),
        player: player2,
      );
      player2Hand.addCard(cardComponent);
    }
    passPhase();
  }

  void normalSummonCard(YGOCard card, PlayerData player, int zoneIndex){
    selectedCardComponent?.position.setFrom(selectedZone!.absolutePosition);
    selectedCardComponent?.scale = Vector2.all(1.0);
    player.normalSummon(card, zoneIndex);
    player.normalSummonComp(selectedCardComponent!, zoneIndex);
    selectedCardComponent?.isInHand = false;
    hideSummonMenu();
  }

  void setCard(YGOCard card, PlayerData player, int zoneIndex){
    selectedCardComponent?.position.setFrom(selectedZone!.absolutePosition);
    selectedCardComponent?.scale = Vector2.all(1.0);
    selectedCardComponent?.angle = pi / 2;
    player.setCard(card, zoneIndex);
    player.normalSummonComp(selectedCardComponent!, zoneIndex);
    selectedCardComponent?.isInHand = false;
    selectedCardComponent?.isInDefensePosition = true;
    hideSummonMenu();
  }

  void cancelSummon(){
    selectedCardComponent?.returnToHand();
    hideSummonMenu();
  }

  void executeBattle(){
    final opponent = currentPlayer == player1 ? player2 : player1;
    final attackerComp = currentPlayer.fieldComponents[battleZoneIndex]!;
    final defenderComp = opponent.fieldComponents[battleZoneIndex]!;
    attackerComp.attackedThisTurn = true;

    if (defenderComp.isInDefensePosition) {
      if (attackerComp.card.atk! > defenderComp.card.def!) {
        opponent.fieldComponents[battleZoneIndex] = null;
        opponent.field[battleZoneIndex] = -1;
        opponent.graveyard.add(defenderComp.card.id);
        defenderComp.removeFromParent();
      }
      if (attackerComp.card.atk! < defenderComp.card.def!) {
        final damage = defenderComp.card.def! - attackerComp.card.atk!;
        currentPlayer.lifePoints -= damage;
      }
      if (attackerComp.card.atk! == defenderComp.card.def!) {
        // No damage
      }
    }
    if (!defenderComp.isInDefensePosition) {
      if (attackerComp.card.atk! > defenderComp.card.atk!) {
        final damage = attackerComp.card.atk! - defenderComp.card.atk!;
        opponent.lifePoints -= damage;
        opponent.fieldComponents[battleZoneIndex] = null;
        opponent.field[battleZoneIndex] = -1;
        opponent.graveyard.add(defenderComp.card.id);
        defenderComp.removeFromParent();
      }
      if (attackerComp.card.atk! < defenderComp.card.atk!) {
        final damage = defenderComp.card.atk! - attackerComp.card.atk!;
        currentPlayer.lifePoints -= damage;
        currentPlayer.fieldComponents[battleZoneIndex] = null;
        currentPlayer.field[battleZoneIndex] = -1;
        currentPlayer.graveyard.add(attackerComp.card.id);
        attackerComp.removeFromParent();
      }
      if (attackerComp.card.atk! == defenderComp.card.atk!) {
        currentPlayer.fieldComponents[battleZoneIndex] = null;
        currentPlayer.field[battleZoneIndex] = -1;
        currentPlayer.graveyard.add(attackerComp.card.id);
        attackerComp.removeFromParent();
        opponent.fieldComponents[battleZoneIndex] = null;
        opponent.field[battleZoneIndex] = -1;
        opponent.graveyard.add(defenderComp.card.id);
        defenderComp.removeFromParent();
      }
    }

    if (currentPlayer.lifePoints < 0) {
      currentPlayer.lifePoints = 0;
    }
    if (opponent.lifePoints < 0) {
      opponent.lifePoints = 0;
    }
  }

  void inflictDirectDamage(){
    final opponent = currentPlayer == player1 ? player2 : player1;
    final attackerComp = currentPlayer.fieldComponents[battleZoneIndex]!;

    opponent.lifePoints -= attackerComp.card.atk!;

    attackerComp.attackedThisTurn = true;

    if (opponent.lifePoints < 0) {
      opponent.lifePoints = 0;
    }
  }

  void standbyToMain(){
    passPhase();
  }

  void endToNextTurn(){
    passPhase();
  }
}