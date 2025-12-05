part of '../../main.dart';

class ExtraDeckOverlay extends StatefulWidget {
  final DuelGame game;

  const ExtraDeckOverlay({
    super.key,
    required this.game,
  });

  @override
  State<ExtraDeckOverlay> createState() => _ExtraDeckOverlayState();
}

class _ExtraDeckOverlayState extends State<ExtraDeckOverlay> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;

    final cardSize = Vector2(screenHeight * 0.26 * 0.6875, screenHeight * 0.26);
    final cardImgSize = cardSize.y * 0.5166015625;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => widget.game.hideExtraDeck(),
          child: Container(
            width: screenSize.width,
            height: screenHeight,
            color: Colors.transparent,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: cardSize.x * 1.3,
            height: screenHeight,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(95),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  appState.extraDeckList.length,
                  (index) {
                    final card = appState.extraDeckList[index];
                    final image = appState.images[card.id];

                    return GestureDetector(
                      onTap: () {
                        widget.game.hideExtraDeck();
                        widget.game.showCardInfo(card);
                      },
                      child: Padding(
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
                                      'assets/images/fusion_frame.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
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