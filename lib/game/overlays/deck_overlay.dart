part of '../../main.dart';

class DeckOverlay extends StatefulWidget {
  final DuelGame game;
  final bool isPlayer1;

  const DeckOverlay({
    super.key,
    required this.game,
    required this.isPlayer1,
  });

  @override
  State<DeckOverlay> createState() => _DeckOverlayState();
}

class _DeckOverlayState extends State<DeckOverlay> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;

    final cardSize = Vector2(screenHeight * 0.26 * 0.6875, screenHeight * 0.26);
    final cardImgSize = cardSize.y * 0.5166015625;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: widget.isPlayer1 ? null : 0,
          right: widget.isPlayer1 ? 0 : null,
          child: Container(
            width: cardSize.x * 1.3,
            height: screenHeight,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(95),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  widget.isPlayer1 ?
                    widget.game.player1.deck.length :
                    widget.game.player2.deck.length,
                  (index) {
                    final card = widget.isPlayer1 ?
                      appState.cards[widget.game.player1.deck[index]] :
                      appState.cards[widget.game.player2.deck[index]];

                    final image = appState.images[card?.id];

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: cardSize.y * 0.03),
                      child: SizedBox(
                        width: cardSize.x,
                        height: cardSize.y,
                        child: Stack(
                          children: [
                            image == null ?
                            Container() :
                            Positioned(
                              top: cardSize.y * 0.185,
                              left: cardSize.x * 0.125,
                              child: SizedBox(
                                width: cardImgSize,
                                height: cardImgSize,
                                child: Image.memory(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              width: cardSize.x,
                              height: cardSize.y,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    card?.id == 33396948 ?
                                      'assets/images/exodia_frame.png' :
                                      'assets/images/normal_frame.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}