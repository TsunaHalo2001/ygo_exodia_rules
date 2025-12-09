part of '../../main.dart';

class GameOverlay extends StatefulWidget {
  final DuelGame game;

  const GameOverlay({
    super.key,
    required this.game,
  });

  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

class _GameOverlayState extends State<GameOverlay> {
  bool isPhaseButtonSelected = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isLandscape = screenWidth > screenHeight;

    final lpWidth = isLandscape ? screenHeight * 0.35 : screenWidth * 0.35;
    final lpHeight = lpWidth * 0.350943396226415;
    final lpFont = isLandscape ? screenHeight * 0.05 : screenWidth * 0.05;

    final buttonWidth = isLandscape ? screenHeight * 0.1 : screenWidth * 0.1;

    return ValueListenableBuilder(
      valueListenable: widget.game.currentTurnPhaseNotifier,
      builder: (context, value, child) {
        String nextPhase = '';

        switch (value) {
          case TurnPhases.drawPhase:
            nextPhase = 'Standby';
            break;
          case TurnPhases.standbyPhase:
            nextPhase = 'Main 1';
            break;
          case TurnPhases.mainPhase1:
            if (widget.game.currentTurn == 1) {
              nextPhase = 'End';
              break;
            }
            nextPhase = 'Battle';
            break;
          case TurnPhases.battlePhase:
            nextPhase = 'Main 2';
            break;
          case TurnPhases.mainPhase2:
            nextPhase = 'End';
            break;
          case TurnPhases.endPhase:
            nextPhase = 'Draw';
            break;
        }

        if (widget.game.player1.lifePoints <= 0 || widget.game.player2.lifePoints <= 0) {
          appState.setState(1);
        }

        return Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: lpWidth,
        height: lpHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/png/GUI_LP_Red.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.005, screenHeight * 0.003, 0, 0),
                  child: Text(
                    'P1',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: lpFont / 1.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kafu Techno',
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${widget.game.player1.lifePoints}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: lpFont,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kafu Techno',
              ),
            ),
          ],
        ),
      ),
      Row(
        children: [
          SizedBox(
            width: buttonWidth * 2,
            height: buttonWidth * 1.5,
            child: Column(
              children: [
                Text(
                  nextPhase,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: lpFont / 1.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kafu Techno',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (TurnPhases.mainPhase1 == widget.game.currentTurnPhase ||
                        TurnPhases.mainPhase2 == widget.game.currentTurnPhase ||
                        TurnPhases.battlePhase == widget.game.currentTurnPhase) {
                      widget.game.passPhase();
                    }
                  },
                  onTapDown: (_) {
                    setState(() {
                      isPhaseButtonSelected = true;
                      FlameAudio.play('SE_MENU_DECIDE.ogg', volume: 0.7);
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      isPhaseButtonSelected = false;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      isPhaseButtonSelected = false;
                    });
                  },
                  child: Container(
                    width: buttonWidth,
                    height: buttonWidth,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage( isPhaseButtonSelected ?
                          'assets/png/phase_2.png' :
                          'assets/png/phase_1.png'
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // BOTÓN END TURN - SOLO en modo vsAI
          if (widget.game.gameMode == GameMode.vsAI)
            GestureDetector(
              onTap: () {
                // Solo si es turno del jugador humano
                if (widget.game.currentPlayer == widget.game.player1) {
                  widget.game.endPlayerTurn();
                }
              },
              onTapDown: (_) {
                setState(() {
                  isEndTurnSelected = true;
                  FlameAudio.play('SE_MENU_DECIDE.ogg', volume: 0.7);
                });
              },
              onTapUp: (_) {
                setState(() {
                  isEndTurnSelected = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  isEndTurnSelected = false;
                });
              },
              child: Container(
                width: buttonWidth * 1.5,
                height: buttonWidth,
                margin: EdgeInsets.only(right: 10), // Espacio antes del LP azul
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      isEndTurnSelected
                        ? 'assets/png/end_turn_2.png'
                        : 'assets/png/end_turn_1.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          
          Container(
            width: lpWidth,
            height: lpHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/png/GUI_LP_Blue.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.003, screenWidth * 0.005, 0),
                      child: Text(
                        'P2',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: lpFont / 1.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kafu Techno',
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${widget.game.player2.lifePoints}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: lpFont,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kafu Techno',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
);
      }
    );
  }
}