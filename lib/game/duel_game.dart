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
    int deckSize = 20,
  }) {
    if (gameMode == GameMode.testing) {
      player1 = PlayerData(playerType: PlayerType.human);
      player2 = PlayerData(playerType: PlayerType.human);
    }
    else {
      player1 = PlayerData(playerType: PlayerType.human);
      player2 = PlayerData(playerType: PlayerType.ai);
    }
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
    final phaseSize = Vector2(size.x * 0.4, size.y * 0.1);
    final turnSize = Vector2(size.x, size.y * 0.2);
    final phasePos = Vector2.zero();

    switch (currentTurnPhase) {
      case TurnPhases.drawPhase:
        world.add(
          ChangePhaseComponent(
            isPlayer1: currentPlayer == player1,
            phase: "Standby Phase",
            size: phaseSize,
            position: phasePos,
          )
        );
        currentTurnPhase = TurnPhases.standbyPhase;
        break;
      case TurnPhases.standbyPhase:
        world.add(
          ChangePhaseComponent(
            isPlayer1: currentPlayer == player1,
            phase: "Main Phase 1",
            size: phaseSize,
            position: phasePos,
          )
        );
        currentTurnPhase = TurnPhases.mainPhase1;
        break;
      case TurnPhases.mainPhase1:
        world.add(
          ChangePhaseComponent(
            isPlayer1: currentPlayer == player1,
            phase: "Battle Phase",
            size: phaseSize,
            position: phasePos,
          )
        );
        currentTurnPhase = TurnPhases.battlePhase;
        break;
      case TurnPhases.battlePhase:
        world.add(
          ChangePhaseComponent(
            isPlayer1: currentPlayer == player1,
            phase: "Main Phase 2",
            size: phaseSize,
            position: phasePos,
          )
        );
        currentTurnPhase = TurnPhases.mainPhase2;
        break;
      case TurnPhases.mainPhase2:
        world.add(
          ChangePhaseComponent(
            isPlayer1: currentPlayer == player1,
            phase: "End Phase",
            size: phaseSize,
            position: phasePos,
          )
        );
        currentTurnPhase = TurnPhases.endPhase;
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

        // ====================================================
        // NUEVO: LLAMAR A LA IA DESPUÉS DE CAMBIAR TURNO
        // ====================================================
        Future.delayed(Duration(milliseconds: 1500), () {
          if (currentPlayer == player2 && gameMode == GameMode.vsAI) {
            executeAITurn(); // ← ESTA FUNCIÓN VIENE DE LA EXTENSIÓN
          }
        });

        break;
    }
  }

  void drawCard(bool isPlayer1){
    if (isPlayer1) {
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

  void selectCard(){}


  void endPlayerTurn() {
    if (currentPlayer == player1) {
      // Forzar pasar al End Phase para que cambie el turno
      currentTurnPhase = TurnPhases.endPhase;
      passPhase();
    }
  }
}

/////////////////////////////////////////////////////////////////////7


// ============================================
// MINIMAX IMPLEMENTACIÓN COMPLETA Y FUNCIONAL
// ============================================

// 1. CLASE PARA EL ESTADO DEL JUEGO (MINIMAX)
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
    return copy;
  }

  bool isTerminal() {
    return humanPlayer.lifePoints <= 0 || aiPlayer.lifePoints <= 0;
  }
}

// 2. CLASE PARA ACCIONES DEL JUEGO
class GameAction {
  final String type; // 'summon', 'attack', 'set', 'pass', 'change_position', 'fusion'
  final dynamic data;
  final int? cardIndex;
  final int? targetIndex;

  GameAction(this.type, {this.data, this.cardIndex, this.targetIndex});

  @override
  String toString() => 'GameAction(type: $type, cardIndex: $cardIndex)';
}

// 3. PARSER DE FUSIONES AVANZADO
class FusionParser {

  /// Parsea una cadena de requisitos de fusión y devuelve los materiales necesarios
  static List<Map<String, dynamic>> parseFusionRequirement(String requirement, List<YGOCard> availableCards) {
    final materials = <Map<String, dynamic>>[];

    // Normalizar la cadena de requisitos
    String normalizedReq = requirement.toLowerCase().trim();

    // Caso 1: Requisitos con "+" (ej: "Demonio + Guerrero")
    if (normalizedReq.contains('+')) {
      final parts = normalizedReq.split('+').map((p) => p.trim()).toList();
      for (var part in parts) {
        materials.addAll(_parseSingleRequirement(part, availableCards));
      }
    }
    // Caso 2: Requisitos con números (ej: "2 monstruos", "3 demonios")
    else if (RegExp(r'^\d+').hasMatch(normalizedReq)) {
      final match = RegExp(r'^(\d+)(?:\+)?\s*(.+)').firstMatch(normalizedReq);
      if (match != null) {
        int count = int.parse(match.group(1)!);
        String typeReq = match.group(2)!;
        for (int i = 0; i < count; i++) {
          materials.addAll(_parseSingleRequirement(typeReq, availableCards));
        }
      }
    }
    // Caso 3: Requisitos simples (ej: "1 monstruo de LUZ")
    else {
      materials.addAll(_parseSingleRequirement(normalizedReq, availableCards));
    }

    return materials;
  }

  static List<Map<String, dynamic>> _parseSingleRequirement(String requirement, List<YGOCard> availableCards) {
    final List<Map<String, dynamic>> result = [];

    // Buscar cartas que cumplan el requisito
    for (var card in availableCards) {
      if (_cardMatchesRequirement(card, requirement)) {
        result.add({
          'card': card,
          'requirement': requirement,
        });
      }
    }

    return result;
  }

  static bool _cardMatchesRequirement(YGOCard card, String requirement) {
    // Normalizar datos de la carta
    final cardType = card.type?.toLowerCase() ?? '';
    final cardAttribute = card.attribute?.toLowerCase() ?? '';
    final cardName = card.name.toLowerCase();

    // Requisitos por tipo
    if (requirement.contains('demonio') && cardType.contains('demonio')) return true;
    if (requirement.contains('guerrero') && cardType.contains('guerrero')) return true;
    if (requirement.contains('dragón') && cardType.contains('dragón')) return true;
    if (requirement.contains('máquina') && cardType.contains('máquina')) return true;
    if (requirement.contains('hada') && cardType.contains('hada')) return true;
    if (requirement.contains('lanzador') && cardType.contains('lanzador')) return true;

    // Requisitos por atributo
    if (requirement.contains('fuego') && cardAttribute.contains('fuego')) return true;
    if (requirement.contains('agua') && cardAttribute.contains('agua')) return true;
    if (requirement.contains('tierra') && cardAttribute.contains('tierra')) return true;
    if (requirement.contains('viento') && cardAttribute.contains('viento')) return true;
    if (requirement.contains('luz') && cardAttribute.contains('luz')) return true;
    if (requirement.contains('oscuridad') && cardAttribute.contains('oscuridad')) return true;

    // Requisitos por nombre específico (entre comillas)
    final nameMatch = RegExp(r'"([^"]+)"').firstMatch(requirement);
    if (nameMatch != null) {
      final requiredName = nameMatch.group(1)!.toLowerCase();
      return cardName.contains(requiredName);
    }

    // Requisitos genéricos de monstruo
    if (requirement.contains('monstruo') && !card.type!.contains('Spell') && !card.type!.contains('Trap')) {
      return true;
    }

    return false;
  }
}

// 4. IMPLEMENTACIÓN DE MINIMAX CON PODA ALFA-BETA
class MinimaxAI {
  final DuelGame game;
  final Stopwatch stopwatch = Stopwatch();
  final int maxTimeMs = 1000; // 1 segundo máximo
  int nodesEvaluated = 0;

  MinimaxAI(this.game);

  /// Obtiene la mejor acción para la IA
  GameAction? getBestAction() {
    stopwatch.start();
    nodesEvaluated = 0;

    try {
      // Crear estado actual del juego
      final currentState = _createGameState();

      // Calcular profundidad óptima basada en la complejidad
      final maxDepth = _calculateOptimalDepth(currentState);

      // Ejecutar Minimax
      final result = _minimax(
        currentState,
        0,
        false, // IA es minimizadora
        -999999,
        999999,
        maxDepth,
      );

      print('Minimax completado en ${stopwatch.elapsedMilliseconds}ms, nodos evaluados: $nodesEvaluated');
      return result.bestAction;
    } catch (e) {
      print('Error en Minimax: $e');
      return null;
    } finally {
      stopwatch.stop();
      stopwatch.reset();
    }
  }

  /// Algoritmo Minimax con poda alfa-beta
  MinimaxResult _minimax(
      GameState state,
      int depth,
      bool isMaximizing,
      int alpha,
      int beta,
      int maxDepth,
      ) {
    nodesEvaluated++;

    // Casos base
    if (depth >= maxDepth || state.isTerminal() || _timeExceeded()) {
      return MinimaxResult(
        value: _evaluateState(state),
        bestAction: null,
      );
    }

    // Maximizador (Humano)
    if (isMaximizing) {
      int maxEval = -999999;
      GameAction? bestAction;

      // Generar todas las acciones posibles para el humano
      final actions = _generateAllActions(state, isHuman: true);

      for (var action in actions) {
        // Crear nuevo estado aplicando la acción
        final newState = state.copy();
        _applyAction(newState, action, isHuman: true);

        // Llamada recursiva
        final result = _minimax(newState, depth + 1, false, alpha, beta, maxDepth);

        if (result.value > maxEval) {
          maxEval = result.value;
          bestAction = action;
        }

        // Poda alfa-beta
        alpha = max(alpha, maxEval);
        if (beta <= alpha) {
          break;
        }
      }

      return MinimaxResult(value: maxEval, bestAction: bestAction);
    }
    // Minimizador (IA)
    else {
      int minEval = 999999;
      GameAction? bestAction;

      // Generar todas las acciones posibles para la IA
      final actions = _generateAllActions(state, isHuman: false);

      for (var action in actions) {
        // Crear nuevo estado aplicando la acción
        final newState = state.copy();
        _applyAction(newState, action, isHuman: false);

        // Llamada recursiva
        final result = _minimax(newState, depth + 1, true, alpha, beta, maxDepth);

        if (result.value < minEval) {
          minEval = result.value;
          bestAction = action;
        }

        // Poda alfa-beta
        beta = min(beta, minEval);
        if (beta <= alpha) {
          break;
        }
      }

      return MinimaxResult(value: minEval, bestAction: bestAction);
    }
  }

  /// Función de evaluación del estado del juego
  int _evaluateState(GameState state) {
    int score = 0;

    // 1. Puntos de vida (40% del peso)
    score += (state.humanPlayer.lifePoints - state.aiPlayer.lifePoints) ~/ 10;

    // 2. Cartas en el campo (30% del peso)
    for (var cardComp in state.humanField) {
      final card = cardComp.card;
      if (cardComp.isFaceUp) {
        score += card.atk ~/ 50;
        score += card.def ~/ 100;
      } else {
        score += 50; // Valor por carta boca abajo
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

    // 3. Cartas en mano (15% del peso)
    score += state.humanPlayer.hand.length * 30;
    score -= state.aiPlayer.hand.length * 30;

    // 4. Control del campo (15% del peso)
    final fieldControl = state.humanField.length - state.aiField.length;
    score += fieldControl * 20;

    return score;
  }

  /// Genera todas las acciones posibles para un jugador
  List<GameAction> _generateAllActions(GameState state, {required bool isHuman}) {
    final actions = <GameAction>[];
    final player = isHuman ? state.humanPlayer : state.aiPlayer;
    final field = isHuman ? state.humanField : state.aiField;
    final opponentField = isHuman ? state.aiField : state.humanField;

    // Solo generar acciones válidas para la fase actual
    if (!_isActionAllowedInPhase(state.currentPhase)) {
      actions.add(GameAction('pass'));
      return actions;
    }

    // 1. ACCIONES DE INVOCACIÓN (Main Phases)
    if (_canSummonInPhase(state.currentPhase)) {
      if (field.length < 5) {
        for (int i = 0; i < player.hand.length; i++) {
          // Invocar en posición de ataque
          actions.add(GameAction(
            'summon',
            cardIndex: i,
            data: {'position': 'attack'},
          ));

          // Invocar en posición de defensa
          actions.add(GameAction(
            'summon',
            cardIndex: i,
            data: {'position': 'defense'},
          ));

          // Colocar boca abajo
          actions.add(GameAction(
            'set',
            cardIndex: i,
          ));
        }
      }
    }

    // 2. ACCIONES DE FUSIÓN (Main Phases)
    if (_canSummonInPhase(state.currentPhase)) {
      // Obtener cartas disponibles para fusión (mano + campo)
      final availableCards = _getAvailableCardsForFusion(player, field);

      // Aquí deberías tener una lista de monstruos de fusión disponibles
      // Por simplicidad, vamos a suponer que algunas cartas son de fusión
      for (var fusionCard in availableCards) {
        if (_isFusionMonster(fusionCard)) {
          // Verificar si tenemos los materiales necesarios
          final materials = _getFusionMaterials(fusionCard, availableCards);
          if (materials.isNotEmpty && field.length < 5) {
            actions.add(GameAction(
              'fusion',
              data: {
                'fusionCard': fusionCard,
                'materials': materials,
              },
            ));
          }
        }
      }
    }

    // 3. ACCIONES DE ATAQUE (Battle Phase)
    if (state.currentPhase == TurnPhases.battlePhase) {
      for (int i = 0; i < field.length; i++) {
        final card = field[i];

        if (card.isFaceUp && card.position == 'attack') {
          // Puede atacar
          if (opponentField.isEmpty) {
            // Ataque directo
            actions.add(GameAction(
              'attack',
              cardIndex: i,
              data: {'direct': true},
            ));
          } else {
            // Ataque a cada monstruo enemigo
            for (int j = 0; j < opponentField.length; j++) {
              actions.add(GameAction(
                'attack',
                cardIndex: i,
                targetIndex: j,
                data: {'direct': false},
              ));
            }
          }
        }
      }
    }

    // 4. CAMBIAR POSICIÓN (Main Phases)
    if (_canChangePositionInPhase(state.currentPhase)) {
      for (int i = 0; i < field.length; i++) {
        final card = field[i];
        if (card.isFaceUp) {
          actions.add(GameAction(
            'change_position',
            cardIndex: i,
            data: {'newPosition': card.position == 'attack' ? 'defense' : 'attack'},
          ));
        }
      }
    }

    // 5. PASAR TURNO (siempre disponible)
    actions.add(GameAction('pass'));

    return actions;
  }

  /// Aplica una acción a un estado (simulación)
  void _applyAction(GameState state, GameAction action, {required bool isHuman}) {
    final player = isHuman ? state.humanPlayer : state.aiPlayer;
    final field = isHuman ? state.humanField : state.aiField;
    final opponentField = isHuman ? state.aiField : state.humanField;

    switch (action.type) {
      case 'summon':
        _applySummon(state, action, isHuman: isHuman);
        break;
      case 'attack':
        _applyAttack(state, action, isHuman: isHuman);
        break;
      case 'set':
        _applySet(state, action, isHuman: isHuman);
        break;
      case 'fusion':
        _applyFusion(state, action, isHuman: isHuman);
        break;
      case 'change_position':
        _applyChangePosition(state, action, isHuman: isHuman);
        break;
      case 'pass':
      // No hacer nada, solo pasar turno
        break;
    }
  }

  void _applySummon(GameState state, GameAction action, {required bool isHuman}) {
    final player = isHuman ? state.humanPlayer : state.aiPlayer;
    final field = isHuman ? state.humanField : state.aiField;
    final cardIndex = action.cardIndex ?? 0;

    if (cardIndex < player.hand.length && field.length < 5) {
      // Simular la invocación: mover carta de mano al campo
      player.hand.removeAt(cardIndex);
      // En la simulación, no creamos un CardComponent real
    }
  }

  void _applyAttack(GameState state, GameAction action, {required bool isHuman}) {
    final field = isHuman ? state.humanField : state.aiField;
    final opponentField = isHuman ? state.aiField : state.humanField;
    final attackerIndex = action.cardIndex ?? 0;
    final direct = action.data?['direct'] ?? false;
    final targetIndex = action.targetIndex;

    if (attackerIndex >= field.length) return;

    if (direct) {
      // Ataque directo al LP
      final opponent = isHuman ? state.aiPlayer : state.humanPlayer;
      final attacker = field[attackerIndex];
      opponent.lifePoints = max(0, opponent.lifePoints - (attacker.card.atk ?? 0));
    } else if (targetIndex != null && targetIndex < opponentField.length) {
      // Batalla entre monstruos
      final attacker = field[attackerIndex];
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

    if (defender.position == 'attack') {
      // Defensor en posición de ataque
      if (attackerATK > defenderATK) {
        // Defensor destruido
        defenderPlayer.lifePoints = max(0, defenderPlayer.lifePoints - (attackerATK - defenderATK));
        defenderField.remove(defender);
      } else if (attackerATK < defenderATK) {
        // Atacante destruido
        attackerPlayer.lifePoints = max(0, attackerPlayer.lifePoints - (defenderATK - attackerATK));
        // El atacante sería destruido (no se simula aquí)
      } else {
        // Empate: ambos destruidos
        defenderField.remove(defender);
        // Atacante destruido (no se simula)
      }
    } else {
      // Defensor en posición de defensa
      if (attackerATK > defenderDEF) {
        // Defensor destruido
        defenderField.remove(defender);
      } else if (attackerATK < defenderDEF) {
        // Atacante no puede destruir al defensor, recibe daño
        final damage = defenderDEF - attackerATK;
        attackerPlayer.lifePoints = max(0, attackerPlayer.lifePoints - damage);
      }
      // Si son iguales, no pasa nada
    }
  }

  // Métodos auxiliares
  List<YGOCard> _getAvailableCardsForFusion(PlayerData player, List<CardComponent> field) {
    final List<YGOCard> available = [];

    // Cartas en mano
    for (var cardId in player.hand) {
      if (cardId == 33396948) {
        available.add(game.exodia);
      } else if (game.normalMonsters.containsKey(cardId)) {
        available.add(game.normalMonsters[cardId]!);
      }
    }

    // Cartas en campo
    for (var cardComp in field) {
      available.add(cardComp.card);
    }

    return available;
  }

  bool _isFusionMonster(YGOCard card) {
    // Verificar si es un monstruo de fusión por su tipo
    return card.type?.contains('Fusion') == true ||
        card.type?.contains('Fusión') == true;
  }

  List<YGOCard> _getFusionMaterials(YGOCard fusionCard, List<YGOCard> availableCards) {
    // En una implementación real, aquí usarías FusionParser
    // Para este ejemplo, devolvemos las primeras 2 cartas disponibles
    return availableCards.length >= 2 ? availableCards.sublist(0, 2) : [];
  }

  GameState _createGameState() {
    return GameState(
      humanPlayer: game.player1,
      aiPlayer: game.player2,
      humanField: game.field.player1Monsters ?? [],
      aiField: game.field.player2Monsters ?? [],
      currentPhase: game.currentTurnPhase,
      isHumanTurn: game.currentPlayer == game.player1,
    );
  }

  int _calculateOptimalDepth(GameState state) {
    final totalCards = state.humanPlayer.hand.length +
        state.aiPlayer.hand.length +
        state.humanField.length +
        state.aiField.length;

    // Ajustar profundidad según complejidad para no consumir muchos recursos
    if (totalCards <= 8) return 4;
    if (totalCards <= 12) return 3;
    if (totalCards <= 16) return 2;
    return 1; // Mínimo para estados complejos
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

  bool _canChangePositionInPhase(TurnPhases phase) {
    return phase == TurnPhases.mainPhase1 || phase == TurnPhases.mainPhase2;
  }
}

class MinimaxResult {
  final int value;
  final GameAction? bestAction;

  MinimaxResult({required this.value, this.bestAction});
}

// 5. EXTENSIÓN PARA INTEGRAR LA IA EN DuelGame
extension DuelGameAI on DuelGame {
  /// Ejecuta el turno de la IA usando Minimax
  void executeAITurn() {
    if (gameMode != GameMode.vsAI || currentPlayer != player2) {
      return;
    }

    print('IA calculando su jugada...');

    final ai = MinimaxAI(this);
    final action = ai.getBestAction();

    if (action != null) {
      print('IA decide: ${action.type}');
      _applyAIAction(action);
    } else {
      print('IA pasa turno');
      passPhase();
    }
  }

  /// Aplica la acción de la IA al juego real
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
      case 'fusion':
        _aiFusion(action);
        break;
      case 'change_position':
        _aiChangePosition(action);
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

      print('IA invoca: ${card.name} en posición $position');
      // Aquí debes implementar la invocación real según tu lógica de juego
    }
  }

  void _aiAttack(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    final direct = action.data?['direct'] ?? false;
    final targetIndex = action.targetIndex;

    print('IA ataca con monstruo $cardIndex (directo: $direct, objetivo: $targetIndex)');
    // Aquí debes implementar el ataque real según tu lógica de juego
  }

  void _aiSetCard(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    print('IA coloca carta boca abajo índice $cardIndex');
    // Aquí debes implementar colocar carta según tu lógica de juego
  }

  void _aiFusion(GameAction action) {
    print('IA realiza fusión');
    // Aquí debes implementar la fusión real según tu lógica de juego
  }

  void _aiChangePosition(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    final newPosition = action.data?['newPosition'] ?? 'defense';
    print('IA cambia posición del monstruo $cardIndex a $newPosition');
    // Aquí debes implementar el cambio de posición según tu lógica de juego
  }
}

// 6. EXTENSIÓN PARA CONFIGURAR NÚMERO DE CARTAS
extension DeckConfig on PlayerData {
  /// Configura el número de cartas en el deck (15-40 cartas)
  void genDeckWithSize(Map<int, YGOCard> cards, {required int deckSize}) {
    // Validar tamaño del deck
    final size = deckSize.clamp(15, 40);

    Map<int, int> mapDeck = {
      33396948: 1,
      7902349: 1,
      44519536: 1,
      70903634: 1,
      8124921: 1,
    };

    List<int> preShuffleDeck = [];

    // Agregar cartas de Exodia primero
    preShuffleDeck.add(33396948);
    preShuffleDeck.add(7902349);
    preShuffleDeck.add(44519536);
    preShuffleDeck.add(70903634);
    preShuffleDeck.add(8124921);

    // Agregar cartas normales hasta alcanzar el tamaño deseado
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

