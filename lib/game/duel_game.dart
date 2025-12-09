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
    required this.normalMonsters,
    required this.exodia,
    TurnPhases initialPhase = TurnPhases.drawPhase,
  }) : 
    gameMode = GameMode.vsAI, 
    currentTurnPhaseNotifier = ValueNotifier<TurnPhases>(initialPhase);

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
    currentTurn = 1;
    field = GameField();
    world.add(field);
    initializeAIPlayer();
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
        currentTurnPhaseNotifier.value = TurnPhases.drawPhase;
        
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
    currentTurnPhaseNotifier.value = turn;
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
    // ¡SOLO para vsAI y turno del jugador!
    print("Jugador termina turno - Pasando a IA");
    
    // Forzar pasar a End Phase
    currentTurnPhaseNotifier.value = TurnPhases.endPhase;
    
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
    
    currentTurnPhaseNotifier.value = TurnPhases.drawPhase;
  }

  
}

// ============================================
// AQUÍ COPIAS TODO TU CÓDIGO DE MINIMAX COMPLETO
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

// 5. CLASE RESULTADO DE MINIMAX
class MinimaxResult {
  final int value;
  final GameAction? bestAction;

  MinimaxResult({required this.value, this.bestAction});
}


// 6. EXTENSIÓN PARA INTEGRAR LA IA EN DuelGame

// ============================================
// 6. EXTENSIÓN PARA INTEGRAR LA IA EN DuelGame
// ============================================

AIPlayer? aiPlayer;

@override
void update(double dt) {
  super.update(dt);
  
  if (aiPlayer != null && currentPlayer == player2) {
    aiPlayer!.update(dt);
  }
}

void initializeAIPlayer() {
  aiPlayer = AIPlayer(
    game: this,
    aiPlayer: player2,
    humanPlayer: player1,
  );
}

// MÉTODO QUE FALTA en tu passPhase()
void executeAITurn() {
  if (aiPlayer != null) {
    aiPlayer!.executeTurn();
  }
}

// MÉTODOS PARA QUE LA IA PUEDA ACTUAR
void aiSummonCard(YGOCard card, ZoneComponent zone) {
  if (player2.field[zone.zoneIndex] != -1) return;
  
  player2.field[zone.zoneIndex] = card.id;
  
  final cardComponent = CardComponent(
    card: card,
    isFaceUp: true,
    size: size.y * 0.3,
    position: zone.position,
    player: player2,
  );
  cardComponent.isInHand = false;
  
  final handCard = player2Hand.firstWhere(
    (c) => c.card.id == card.id,
  );
  player2Hand.remove(handCard);
  handCard.removeFromParent();
  
  field.add(cardComponent);
  currentPlayer.hasNormalSummonedThisTurn = true;
}

void aiAttackWithCard(CardComponent attacker, CardComponent target) {
  selectedCardComponent = attacker;
  battleZoneIndex = getZoneIndexForCardComponent(target);
  executeBattle();
  attacker.attackedThisTurn = true;
}

void aiSetCardInDefense(YGOCard card, ZoneComponent zone) {
  if (player2.field[zone.zoneIndex] != -1) return;
  
  player2.field[zone.zoneIndex] = card.id;
  
  final cardComponent = CardComponent(
    card: card,
    isFaceUp: false,
    size: size.y * 0.3,
    position: zone.position,
    player: player2,
  );
  cardComponent.isInHand = false;
  cardComponent.isInDefensePosition = true;
  
  final handCard = player2Hand.firstWhere(
    (c) => c.card.id == card.id,
  );
  player2Hand.remove(handCard);
  handCard.removeFromParent();
  
  field.add(cardComponent);
}

void aiActivateSpellCard(YGOCard spell, ZoneComponent zone) {
  if (player2.field[zone.zoneIndex] != -1) return;
  
  player2.field[zone.zoneIndex] = spell.id;
  
  final cardComponent = CardComponent(
    card: spell,
    isFaceUp: true,
    size: size.y * 0.3,
    position: zone.position,
    player: player2,
  );
  cardComponent.isInHand = false;
  
  final handCard = player2Hand.firstWhere(
    (c) => c.card.id == spell.id,
  );
  player2Hand.remove(handCard);
  handCard.removeFromParent();
  
  field.add(cardComponent);
}

// MÉTODO AUXILIAR FALTANTE
int getZoneIndexForCardComponent(CardComponent cardComponent) {
  for (final zone in field.children.whereType<ZoneComponent>()) {
    if (zone.containsPoint(cardComponent.absoluteCenter)) {
      return zone.zoneIndex;
    }
  }
  return -1;
}

// MÉTODO AUXILIAR FALTANTE
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

// MÉTODO FALTANTE: Para obtener cartas del campo
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

// MÉTODO FALTANTE: Para obtener zonas vacías
List<ZoneComponent> getEmptyMonsterZones(PlayerData player) {
  final List<ZoneComponent> emptyZones = [];
  final zones = field.children.whereType<ZoneComponent>();
  final isPlayer1 = player == player1;
  
  for (final zone in zones) {
    if (zone.isPlayer1 == isPlayer1 && 
        zone.type == ZoneType.monster && 
        player.field[zone.zoneIndex] == -1) {
      emptyZones.add(zone);
    }
  }
  
  return emptyZones;
}


// ========================

AIPlayer? aiPlayer;

@override
void update(double dt) {
  super.update(dt);
  
  if (aiPlayer != null && currentPlayer == player2) {
    aiPlayer!.update(dt);
  }
}

void initializeAIPlayer() {
  aiPlayer = AIPlayer(
    game: this,
    aiPlayer: player2,
    humanPlayer: player1,
  );
}

void aiSummonCard(YGOCard card, ZoneComponent zone) {
  if (player2.field[zone.zoneIndex] != -1) return;
  
  player2.field[zone.zoneIndex] = card.id;
  
  final cardComponent = CardComponent(
    card: card,
    isFaceUp: true,
    size: 200,
    position: zone.position,
    player: player2,
  );
  cardComponent.isInHand = false;
  
  final handCard = player2Hand.firstWhere(
    (c) => c.card.id == card.id,
  );
  player2Hand.remove(handCard);
  handCard.removeFromParent();
  
  field.add(cardComponent);
  currentPlayer.hasNormalSummonedThisTurn = true;
}

void aiAttackWithCard(CardComponent attacker, CardComponent target) {
  selectedCardComponent = attacker;
  battleZoneIndex = getZoneIndexForCardComponent(target);
  executeBattle();
  attacker.attackedThisTurn = true;
}

void aiSetCardInDefense(YGOCard card, ZoneComponent zone) {
  if (player2.field[zone.zoneIndex] != -1) return;
  
  player2.field[zone.zoneIndex] = card.id;
  
  final cardComponent = CardComponent(
    card: card,
    isFaceUp: false,
    size: 200,
    position: zone.position,
    player: player2,
  );
  cardComponent.isInHand = false;
  cardComponent.isInDefensePosition = true;
  
  final handCard = player2Hand.firstWhere(
    (c) => c.card.id == card.id,
  );
  player2Hand.remove(handCard);
  handCard.removeFromParent();
  
  field.add(cardComponent);
}

void aiActivateSpellCard(YGOCard spell, ZoneComponent zone) {
  if (player2.field[zone.zoneIndex] != -1) return;
  
  player2.field[zone.zoneIndex] = spell.id;
  
  final cardComponent = CardComponent(
    card: spell,
    isFaceUp: true,
    size: 200,
    position: zone.position,
    player: player2,
  );
  cardComponent.isInHand = false;
  
  final handCard = player2Hand.firstWhere(
    (c) => c.card.id == spell.id,
  );
  player2Hand.remove(handCard);
  handCard.removeFromParent();
  
  field.add(cardComponent);
  
  // Aquí ejecutarías el efecto de la carta mágica
  // Por ahora solo la coloca en el campo
}

int getZoneIndexForCardComponent(CardComponent cardComponent) {
  for (final zone in field.children.whereType<ZoneComponent>()) {
    if (zone.containsPoint(cardComponent.absoluteCenter)) {
      return zone.zoneIndex;
    }
  }
  return -1;
}

CardComponent? getCardComponentAtZone(int zoneIndex, PlayerData player) {
  final zones = field.children.whereType<ZoneComponent>();
  final zone = zones.firstWhere(
    (z) => z.zoneIndex == zoneIndex && z.isPlayer1 == (player == player1),
    orElse: () => throw Exception('Zona no encontrada'),
  );
  
  for (final component in field.children.whereType<CardComponent>()) {
    if (component.player == player && 
        zone.containsPoint(component.absoluteCenter)) {
      return component;
    }
  }
  return null;
}


// 7. EXTENSIÓN PARA CONFIGURAR NÚMERO DE CARTAS
extension DeckConfig on PlayerData {
  /// Configura el número de cartas en el deck (15-40 cartas)
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

// ============================================
// 8. CLASE AIPlayer (FALTANTE)
// ============================================

class AIPlayer {
  final DuelGame game;
  final PlayerData aiPlayer;
  final PlayerData humanPlayer;
  final MinimaxAI minimaxAI;
  
  AIPlayer({
    required this.game,
    required this.aiPlayer,
    required this.humanPlayer,
  }) : minimaxAI = MinimaxAI(game);
  
  void update(double dt) {
    // Lógica de actualización por frame
  }
  
  void executeTurn() {
    // Ejecutar el turno completo de la IA
    switch (game.currentTurnPhase) {
      case TurnPhases.drawPhase:
        _executeDrawPhase();
        break;
      case TurnPhases.standbyPhase:
        _executeStandbyPhase();
        break;
      case TurnPhases.mainPhase1:
        _executeMainPhase();
        break;
      case TurnPhases.battlePhase:
        _executeBattlePhase();
        break;
      case TurnPhases.mainPhase2:
        _executeMainPhase();
        break;
      case TurnPhases.endPhase:
        _executeEndPhase();
        break;
    }
  }
  
  void _executeDrawPhase() {
    // La IA roba carta
    game.drawCard(false); // false = player2 (IA)
  }
  
  void _executeStandbyPhase() {
    // Pasar directamente a Main Phase 1
    Future.delayed(Duration(milliseconds: 500), () {
      game.passPhase();
    });
  }
  
  void _executeMainPhase() {
    // Usar Minimax para decidir qué hacer
    final bestAction = minimaxAI.getBestAction();
    
    if (bestAction != null) {
      _executeAction(bestAction);
    } else {
      // Si no hay acción buena, pasar fase
      Future.delayed(Duration(milliseconds: 1000), () {
        game.passPhase();
      });
    }
  }
  
  void _executeBattlePhase() {
    // Decidir ataques usando Minimax
    final bestAction = minimaxAI.getBestAction();
    
    if (bestAction != null && bestAction.type == 'attack') {
      _executeAction(bestAction);
    } else {
      // Si no hay ataques buenos, pasar fase
      Future.delayed(Duration(milliseconds: 1000), () {
        game.passPhase();
      });
    }
  }
  
  void _executeEndPhase() {
    // Pasar al siguiente turno
    Future.delayed(Duration(milliseconds: 500), () {
      game.passPhase();
    });
  }
  
  void _executeAction(GameAction action) {
    switch (action.type) {
      case 'summon':
        _executeSummon(action);
        break;
      case 'attack':
        _executeAttack(action);
        break;
      case 'set':
        _executeSet(action);
        break;
      case 'pass':
        game.passPhase();
        break;
    }
  }
  
  void _executeSummon(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    final position = action.data?['position'] ?? 'attack';
    
    if (cardIndex < aiPlayer.hand.length) {
      final cardId = aiPlayer.hand[cardIndex];
      final card = cardId == 33396948 ? game.exodia : game.normalMonsters[cardId]!;
      
      final emptyZones = game.getEmptyMonsterZones(aiPlayer);
      if (emptyZones.isNotEmpty) {
        final zone = emptyZones.first;
        
        if (position == 'attack') {
          game.aiSummonCard(card, zone);
        } else {
          game.aiSetCardInDefense(card, zone);
        }
      }
    }
    
    // Después de invocar, pasar fase si ya no puede hacer más
    Future.delayed(Duration(milliseconds: 1000), () {
      game.passPhase();
    });
  }
  
  void _executeAttack(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    final targetIndex = action.targetIndex;
    final direct = action.data?['direct'] ?? false;
    
    final fieldCards = game.getPlayerFieldCards(aiPlayer);
    if (cardIndex < fieldCards.length) {
      final attacker = fieldCards[cardIndex];
      
      if (direct) {
        // Ataque directo
        game.selectedCardComponent = attacker;
        game.inflictDirectDamage();
        attacker.attackedThisTurn = true;
      } else if (targetIndex != null) {
        final humanField = game.getPlayerFieldCards(humanPlayer);
        if (targetIndex < humanField.length) {
          final target = humanField[targetIndex];
          game.aiAttackWithCard(attacker, target);
        }
      }
    }
  }
  
  void _executeSet(GameAction action) {
    final cardIndex = action.cardIndex ?? 0;
    
    if (cardIndex < aiPlayer.hand.length) {
      final cardId = aiPlayer.hand[cardIndex];
      final card = cardId == 33396948 ? game.exodia : game.normalMonsters[cardId]!;
      
      final emptyZones = game.getEmptyMonsterZones(aiPlayer);
      if (emptyZones.isNotEmpty) {
        final zone = emptyZones.first;
        game.aiSetCardInDefense(card, zone);
      }
    }
  }
}