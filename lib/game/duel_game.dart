part of '../main.dart';

enum GameMode {
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

  // IA
  late MinimaxAI aiPlayer;

  DuelGame({
    required this.normalMonsters,
    required this.exodia,
  }) : gameMode = GameMode.vsAI;

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

    world.add(background);

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

    // Inicializar IA
    aiPlayer = MinimaxAI(this);

    _startRandomBgm();
  }

  // SETUP SIEMPRE HUMANO vs IA
  void setupPlayers({
    required HandComponent player1Hand,
    required HandComponent player2Hand,
    int deckSize = 20,
  }) {
    player1 = PlayerData(playerType: PlayerType.human);
    player2 = PlayerData(playerType: PlayerType.ai); 
    
    player1.genDeckWithSize(normalMonsters, deckSize: deckSize);
    player1.genHand();
    player2.genDeckWithSize(normalMonsters, deckSize: deckSize);
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
      if (isPlayer1) overlays.add('DeckMenu1');
      else overlays.add('DeckMenu2');
    });
  }

  void showExtraDeckMenu(bool isPlayer1) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPlayer1) overlays.add('ExtraDeckMenu1');
      else overlays.add('ExtraDeckMenu2');
    });
  }

  void hideDeckMenu(bool isPlayer1) {
    if (isPlayer1) overlays.remove('DeckMenu1');
    else overlays.remove('DeckMenu2');
  }

  void hideExtraDeckMenu() {
    overlays.remove('ExtraDeckMenu1');
    overlays.remove('ExtraDeckMenu2');
  }

  void showDeck(bool isPlayer1) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPlayer1) overlays.add('Deck1');
      else overlays.add('Deck2');
    });
  }

  void showExtraDeck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlays.add('ExtraDeck');
    });
  }

  void hideDeck(bool isPlayer1) {
    if (isPlayer1) overlays.remove('Deck1');
    else overlays.remove('Deck2');
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

  // MÉTODO PASS PHASE MODIFICADO
  Future<void> passPhase() async {
    if (isPhaseDisplaying || isTurnDisplaying) return;

    final phaseSize = Vector2(size.x * 0.4, size.y * 0.1);
    final turnSize = Vector2(size.x, size.y * 0.2);
    final phasePos = Vector2.zero();

    switch (currentTurnPhase) {
      case TurnPhases.drawPhase:
        await animatePhaseChange("Standby Phase", phaseSize, phasePos, TurnPhases.standbyPhase);
        break;
      case TurnPhases.standbyPhase:
        await animatePhaseChange("Main Phase 1", phaseSize, phasePos, TurnPhases.mainPhase1);
        break;
      case TurnPhases.mainPhase1:
        if (currentTurn == 1) {
          await animatePhaseChange("End Phase", phaseSize, phasePos, TurnPhases.endPhase);
          endToNextTurn();
          break;
        }
        await animatePhaseChange("Battle Phase", phaseSize, phasePos, TurnPhases.battlePhase);
        break;
      case TurnPhases.battlePhase:
        await animatePhaseChange("Main Phase 2", phaseSize, phasePos, TurnPhases.mainPhase2);
        break;
      case TurnPhases.mainPhase2:
        await animatePhaseChange("End Phase", phaseSize, phasePos, TurnPhases.endPhase);
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
        currentTurnPhase = TurnPhases.drawPhase;
        
        if (currentPlayer == player2) {
          Future.delayed(Duration(milliseconds: 1500), () {
            executeAITurn(); 
          });
        }
        break;
    }
  }

  Future<void> animatePhaseChange(String title, Vector2 size, Vector2 position, TurnPhases turn) async {
    world.add(
      ChangePhaseComponent(
        isPlayer1: currentPlayer == player1,
        phase: title,
        size: size,
        position: position,
      )
    );

    await Future.delayed(const Duration(seconds: 2));
    currentTurnPhase = turn;
  }

  void drawCard(bool isPlayer1){
    if (isPlayer1) {
      player1.hasNormalSummonedThisTurn = false;
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
      final drawedCard = player2.drawCard();
      final card = drawedCard == 33396948 ? exodia : normalMonsters[drawedCard]!;
      final cardComponent = CardComponent(
        card: card,
        isFaceUp: true,
        size: size.y * 0.3,
        position: Vector2(0, -size.y * 0.475),
        player: player2,
      );
      player2Hand.addCard(cardComponent);
    }
    passPhase();
  }

  void selectCard(){}

  // ========== MÉTODO CLAVE: endPlayerTurn() ==========
  void endPlayerTurn() {
    print("Jugador termina turno - Pasando a IA");
    
    // Forzar pasar a End Phase
    currentTurnPhase = TurnPhases.endPhase;
    
    passPhase();
  }

  // Método auxiliar que necesita passPhase()
  void endToNextTurn() {
    currentPlayer = currentPlayer == player1 ? player2 : player1;
    currentTurn += 1;
    
    world.add(
      ChangeTurnComponent(
        isPlayer1: currentPlayer == player1,
        turn: currentTurn,
        size: Vector2(size.x, size.y * 0.2),
        position: Vector2.zero(),
      )
    );
    
    currentTurnPhase = TurnPhases.drawPhase;
  }

  // ============================================
  // MÉTODOS PARA LA IA
  // ============================================

  void executeAITurn() {
    if (currentPlayer != player2) return;

    final bestAction = aiPlayer.getBestAction();
    
    if (bestAction != null) {
      _applyAIAction(bestAction);
    } else {
      passPhase();
    }
  }

  void _applyAIAction(GameAction action) {
    switch (action.type) {
      case 'summon':
        _aiSummonCard(action);
        break;
      case 'attack':
        _aiAttack(action);
        break;
      case 'set':
        _aiSetCard(action);
        break;
      case 'pass':
        passPhase();
        break;
    }
  }

  void _aiSummonCard(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    final position = action.data?['position'] ?? 'attack';

    if (cardIndex < player2.hand.length) {
      final cardId = player2.hand[cardIndex];
      final card = cardId == 33396948 ? exodia : normalMonsters[cardId]!;

      // Buscar zona vacía
      final emptyZone = _findEmptyMonsterZone(player2);
      if (emptyZone != null) {
        _summonCardToZone(card, emptyZone, position == 'attack');
        player2.hand.removeAt(cardIndex);
        player2.field[emptyZone.zoneIndex] = card.id;
      }
    }
  }

  void _aiAttack(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    final direct = action.data?['direct'] ?? false;
    final targetIndex = action.targetIndex;

    final aiFieldCards = getPlayerFieldCards(player2);
    if (cardIndex < aiFieldCards.length) {
      final attacker = aiFieldCards[cardIndex];
      
      if (direct) {
        _inflictDirectDamage(attacker);
      } else if (targetIndex != null) {
        final humanFieldCards = getPlayerFieldCards(player1);
        if (targetIndex < humanFieldCards.length) {
          final target = humanFieldCards[targetIndex];
          _executeBattle(attacker, target);
        }
      }
    }
  }

  void _aiSetCard(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    
    if (cardIndex < player2.hand.length) {
      final cardId = player2.hand[cardIndex];
      final card = cardId == 33396948 ? exodia : normalMonsters[cardId]!;
      
      final emptyZone = _findEmptyMonsterZone(player2);
      if (emptyZone != null) {
        _setCardInDefense(card, emptyZone);
        player2.hand.removeAt(cardIndex);
        player2.field[emptyZone.zoneIndex] = card.id;
      }
    }
  }

  // Métodos auxiliares para la IA
  ZoneComponent? _findEmptyMonsterZone(PlayerData player) {
    final zones = field.children.whereType<ZoneComponent>();
    final isPlayer1 = player == player1;
    
    for (final zone in zones) {
      if (zone.isPlayer1 == isPlayer1 && 
          zone.type == ZoneType.monster && 
          player.field[zone.zoneIndex] == -1) {
        return zone;
      }
    }
    return null;
  }

  void _summonCardToZone(YGOCard card, ZoneComponent zone, bool isAttackPosition) {
    final cardComponent = CardComponent(
      card: card,
      isFaceUp: true,
      size: size.y * 0.3,
      position: zone.position,
      player: player2,
    );
    cardComponent.isInHand = false;
    cardComponent.isInDefensePosition = !isAttackPosition;
    
    // Remover de la mano
    final handCard = player2Hand.children.whereType<CardComponent>()
        .firstWhere((c) => c.card.id == card.id);
    player2Hand.remove(handCard);
    
    field.add(cardComponent);
  }

  void _setCardInDefense(YGOCard card, ZoneComponent zone) {
    final cardComponent = CardComponent(
      card: card,
      isFaceUp: false,
      size: size.y * 0.3,
      position: zone.position,
      player: player2,
    );
    cardComponent.isInHand = false;
    cardComponent.isInDefensePosition = true;
    
    final handCard = player2Hand.children.whereType<CardComponent>()
        .firstWhere((c) => c.card.id == card.id);
    player2Hand.remove(handCard);
    
    field.add(cardComponent);
  }

  void _inflictDirectDamage(CardComponent attacker) {
    final damage = attacker.card.atk ?? 0;
    player1.lifePoints = max(0, player1.lifePoints - damage);
    attacker.attackedThisTurn = true;
  }

  void _executeBattle(CardComponent attacker, CardComponent defender) {
    final attackerATK = attacker.card.atk ?? 0;
    final defenderATK = defender.card.atk ?? 0;
    final defenderDEF = defender.card.def ?? 0;
    
    if (defender.isInDefensePosition) {
      if (attackerATK > defenderDEF) {
        // Defensor destruido
        defender.removeFromParent();
      } else if (attackerATK < defenderDEF) {
        // Atacante recibe daño
        final damage = defenderDEF - attackerATK;
        player2.lifePoints = max(0, player2.lifePoints - damage);
      }
    } else {
      if (attackerATK > defenderATK) {
        // Defensor destruido
        final damage = attackerATK - defenderATK;
        player1.lifePoints = max(0, player1.lifePoints - damage);
        defender.removeFromParent();
      } else if (attackerATK < defenderATK) {
        // Atacante destruido
        final damage = defenderATK - attackerATK;
        player2.lifePoints = max(0, player2.lifePoints - damage);
        attacker.removeFromParent();
      } else {
        // Empate, ambos destruidos
        attacker.removeFromParent();
        defender.removeFromParent();
      }
    }
    
    attacker.attackedThisTurn = true;
  }

  // Método para obtener cartas del campo (usado por Minimax)
  List<CardComponent> getPlayerFieldCards(PlayerData player) {
    final List<CardComponent> fieldCards = [];
    final isPlayer1 = player == player1;
    
    for (final component in field.children.whereType<CardComponent>()) {
      if (component.player == player && !component.isInHand) {
        fieldCards.add(component);
      }
    }
    
    return fieldCards;
  }

  // Método para obtener el índice de zona de una carta
  int getZoneIndexForCardComponent(CardComponent cardComponent) {
    for (final zone in field.children.whereType<ZoneComponent>()) {
      if (zone.containsPoint(cardComponent.absoluteCenter)) {
        return zone.zoneIndex;
      }
    }
    return -1;
  }

  // Método para obtener carta en una zona específica
  CardComponent? getCardComponentAtZone(int zoneIndex, PlayerData player) {
    final zones = field.children.whereType<ZoneComponent>();
    final isPlayer1 = player == player1;
    
    for (final zone in zones) {
      if (zone.zoneIndex == zoneIndex && zone.isPlayer1 == isPlayer1) {
        for (final component in field.children.whereType<CardComponent>()) {
          if (component.player == player && 
              zone.containsPoint(component.absoluteCenter)) {
            return component;
          }
        }
      }
    }
    return null;
  }
}

// ============================================
// MINIMAX IMPLEMENTACIÓN
// ============================================

class GameState {
  final PlayerData humanPlayer;
  final PlayerData aiPlayer;
  final List<CardComponent> humanField;
  final List<CardComponent> aiField;
  final TurnPhases currentPhase;
  final bool isHumanTurn;
  GameAction? bestAction;

  GameState({
    required this.humanPlayer,
    required this.aiPlayer,
    required this.humanField,
    required this.aiField,
    required this.currentPhase,
    required this.isHumanTurn,
  });

  GameState copy() {
    return GameState(
      humanPlayer: _copyPlayer(humanPlayer),
      aiPlayer: _copyPlayer(aiPlayer),
      humanField: List.from(humanField),
      aiField: List.from(aiField),
      currentPhase: currentPhase,
      isHumanTurn: isHumanTurn,
    );
  }

  PlayerData _copyPlayer(PlayerData original) {
    final copy = PlayerData(
      playerType: original.playerType,
      initialLifePoints: original.lifePoints,
    );
    copy.deck = List.from(original.deck);
    copy.hand = List.from(original.hand);
    copy.graveyard = List.from(original.graveyard);
    copy.field = List.from(original.field);
    copy.availableExtraDeck = List.from(original.availableExtraDeck);
    copy.hasNormalSummonedThisTurn = original.hasNormalSummonedThisTurn;
    return copy;
  }

  bool isTerminal() {
    return humanPlayer.lifePoints <= 0 || aiPlayer.lifePoints <= 0;
  }
}

class GameAction {
  final String type;
  final dynamic data;
  final int? cardIndex;
  final int? targetIndex;

  GameAction(this.type, {this.data, this.cardIndex, this.targetIndex});

  @override
  String toString() => 'GameAction(type: $type, cardIndex: $cardIndex)';
}

class MinimaxAI {
  final DuelGame game;
  final Stopwatch stopwatch = Stopwatch();
  final int maxTimeMs = 1000;
  int nodesEvaluated = 0;

  MinimaxAI(this.game);

  GameAction? getBestAction() {
    stopwatch.start();
    nodesEvaluated = 0;

    try {
      final currentState = _createGameState();
      final maxDepth = _calculateOptimalDepth(currentState);

      final result = _minimax(
        currentState,
        0,
        false,
        -999999,
        999999,
        maxDepth,
      );

      return result.bestAction;
    } catch (e) {
      return null;
    } finally {
      stopwatch.stop();
      stopwatch.reset();
    }
  }

  MinimaxResult _minimax(
    GameState state,
    int depth,
    bool isMaximizing,
    int alpha,
    int beta,
    int maxDepth,
  ) {
    nodesEvaluated++;

    if (depth >= maxDepth || state.isTerminal() || _timeExceeded()) {
      return MinimaxResult(
        value: _evaluateState(state),
        bestAction: null,
      );
    }

    if (isMaximizing) {
      int maxEval = -999999;
      GameAction? bestAction;

      final actions = _generateAllActions(state, isHuman: true);

      for (var action in actions) {
        final newState = state.copy();
        _applyAction(newState, action, isHuman: true);

        final result = _minimax(newState, depth + 1, false, alpha, beta, maxDepth);

        if (result.value > maxEval) {
          maxEval = result.value;
          bestAction = action;
        }

        alpha = max(alpha, maxEval);
        if (beta <= alpha) break;
      }

      return MinimaxResult(value: maxEval, bestAction: bestAction);
    } else {
      int minEval = 999999;
      GameAction? bestAction;

      final actions = _generateAllActions(state, isHuman: false);

      for (var action in actions) {
        final newState = state.copy();
        _applyAction(newState, action, isHuman: false);

        final result = _minimax(newState, depth + 1, true, alpha, beta, maxDepth);

        if (result.value < minEval) {
          minEval = result.value;
          bestAction = action;
        }

        beta = min(beta, minEval);
        if (beta <= alpha) break;
      }

      return MinimaxResult(value: minEval, bestAction: bestAction);
    }
  }

  int _evaluateState(GameState state) {
    int score = 0;

    score += (state.humanPlayer.lifePoints - state.aiPlayer.lifePoints) ~/ 10;

    for (var cardComp in state.humanField) {
      final card = cardComp.card;
      if (cardComp.isFaceUp) {
        score += card.atk ~/ 50;
        score += card.def ~/ 100;
      } else {
        score += 50;
      }
    }

    for (var cardComp in state.aiField) {
      final card = cardComp.card;
      if (cardComp.isFaceUp) {
        score -= card.atk ~/ 50;
        score -= card.def ~/ 100;
      } else {
        score -= 50;
      }
    }

    score += state.humanPlayer.hand.length * 30;
    score -= state.aiPlayer.hand.length * 30;

    final fieldControl = state.humanField.length - state.aiField.length;
    score += fieldControl * 20;

    return score;
  }

  List<GameAction> _generateAllActions(GameState state, {required bool isHuman}) {
    final actions = <GameAction>[];
    final player = isHuman ? state.humanPlayer : state.aiPlayer;
    final field = isHuman ? state.humanField : state.aiField;
    final opponentField = isHuman ? state.aiField : state.humanField;

    if (!_isActionAllowedInPhase(state.currentPhase)) {
      actions.add(GameAction('pass'));
      return actions;
    }

    if (_canSummonInPhase(state.currentPhase)) {
      if (field.length < 5) {
        for (int i = 0; i < player.hand.length; i++) {
          actions.add(GameAction('summon', cardIndex: i, data: {'position': 'attack'}));
          actions.add(GameAction('summon', cardIndex: i, data: {'position': 'defense'}));
          actions.add(GameAction('set', cardIndex: i));
        }
      }
    }

    if (state.currentPhase == TurnPhases.battlePhase) {
      for (int i = 0; i < field.length; i++) {
        final card = field[i];
        if (card.isFaceUp && !card.isInDefensePosition) {
          if (opponentField.isEmpty) {
            actions.add(GameAction('attack', cardIndex: i, data: {'direct': true}));
          } else {
            for (int j = 0; j < opponentField.length; j++) {
              actions.add(GameAction('attack', cardIndex: i, targetIndex: j, data: {'direct': false}));
            }
          }
        }
      }
    }

    actions.add(GameAction('pass'));
    return actions;
  }

  void _applyAction(GameState state, GameAction action, {required bool isHuman}) {
    final player = isHuman ? state.humanPlayer : state.aiPlayer;
    final field = isHuman ? state.humanField : state.aiField;

    switch (action.type) {
      case 'summon':
        final cardIndex = action.cardIndex ?? 0;
        if (cardIndex < player.hand.length && field.length < 5) {
          player.hand.removeAt(cardIndex);
        }
        break;
      case 'attack':
        _applyAttack(state, action, isHuman: isHuman);
        break;
      case 'set':
        final cardIndex = action.cardIndex ?? 0;
        if (cardIndex < player.hand.length && field.length < 5) {
          player.hand.removeAt(cardIndex);
        }
        break;
    }
  }

  void _applyAttack(GameState state, GameAction action, {required bool isHuman}) {
    final field = isHuman ? state.humanField : state.aiField;
    final opponentField = isHuman ? state.aiField : state.humanField;
    final attackerIndex = action.cardIndex ?? 0;
    final direct = action.data?['direct'] ?? false;
    final targetIndex = action.targetIndex;

    if (attackerIndex >= field.length) return;

    final attacker = field[attackerIndex];
    
    if (direct) {
      final opponent = isHuman ? state.aiPlayer : state.humanPlayer;
      opponent.lifePoints = max(0, opponent.lifePoints - (attacker.card.atk ?? 0));
    } else if (targetIndex != null && targetIndex < opponentField.length) {
      final defender = opponentField[targetIndex];
      _simulateBattle(attacker, defender, state, isHuman: isHuman);
    }
  }

  void _simulateBattle(CardComponent attacker, CardComponent defender, GameState state, {required bool isHuman}) {
    final attackerPlayer = isHuman ? state.humanPlayer : state.aiPlayer;
    final defenderPlayer = isHuman ? state.aiPlayer : state.humanPlayer;
    final defenderField = isHuman ? state.aiField : state.humanField;

    final attackerATK = attacker.card.atk ?? 0;
    final defenderATK = defender.card.atk ?? 0;
    final defenderDEF = defender.card.def ?? 0;

    if (defender.isInDefensePosition) {
      if (attackerATK > defenderDEF) {
        defenderField.remove(defender);
      } else if (attackerATK < defenderDEF) {
        final damage = defenderDEF - attackerATK;
        attackerPlayer.lifePoints = max(0, attackerPlayer.lifePoints - damage);
      }
    } else {
      if (attackerATK > defenderATK) {
        defenderPlayer.lifePoints = max(0, defenderPlayer.lifePoints - (attackerATK - defenderATK));
        defenderField.remove(defender);
      } else if (attackerATK < defenderATK) {
        attackerPlayer.lifePoints = max(0, attackerPlayer.lifePoints - (defenderATK - attackerATK));
      } else {
        defenderField.remove(defender);
      }
    }
  }

  GameState _createGameState() {
    final humanField = game.getPlayerFieldCards(game.player1);
    final aiField = game.getPlayerFieldCards(game.player2);
    
    return GameState(
      humanPlayer: game.player1,
      aiPlayer: game.player2,
      humanField: humanField,
      aiField: aiField,
      currentPhase: game.currentTurnPhase,
      isHumanTurn: game.currentPlayer == game.player1,
    );
  }

  int _calculateOptimalDepth(GameState state) {
    final totalCards = state.humanPlayer.hand.length +
        state.aiPlayer.hand.length +
        state.humanField.length +
        state.aiField.length;

    if (totalCards <= 8) return 3;
    if (totalCards <= 12) return 2;
    return 1;
  }

  bool _timeExceeded() => stopwatch.elapsedMilliseconds > maxTimeMs;

  bool _isActionAllowedInPhase(TurnPhases phase) {
    return phase == TurnPhases.mainPhase1 ||
        phase == TurnPhases.battlePhase ||
        phase == TurnPhases.mainPhase2;
  }

  bool _canSummonInPhase(TurnPhases phase) {
    return phase == TurnPhases.mainPhase1 || phase == TurnPhases.mainPhase2;
  }
}

class MinimaxResult {
  final int value;
  final GameAction? bestAction;

  MinimaxResult({required this.value, this.bestAction});
}

// EXTENSIÓN PARA CONFIGURAR DECK
extension DeckConfig on PlayerData {
  void genDeckWithSize(Map<int, YGOCard> cards, {required int deckSize}) {
    final size = deckSize.clamp(15, 40);

    Map<int, int> mapDeck = {
      33396948: 1,
      7902349: 1,
      44519536: 1,
      70903634: 1,
      8124921: 1,
    };

    List<int> preShuffleDeck = [];

    preShuffleDeck.add(33396948);
    preShuffleDeck.add(7902349);
    preShuffleDeck.add(44519536);
    preShuffleDeck.add(70903634);
    preShuffleDeck.add(8124921);

    for (int i = 0; i < size - 5; i++) {
      final randomIndex = Random().nextInt(cards.length);
      final card = cards.values.elementAt(randomIndex);

      if (mapDeck.containsKey(card.id)) {
        if (mapDeck[card.id]! > 3) {
          i--;
          continue;
        }
        mapDeck[card.id] = mapDeck[card.id]! + 1;
        preShuffleDeck.add(card.id);
      } else {
        mapDeck[card.id] = 1;
        preShuffleDeck.add(card.id);
      }
    }

    deck = preShuffleDeck;
    deck.shuffle();
  }
}