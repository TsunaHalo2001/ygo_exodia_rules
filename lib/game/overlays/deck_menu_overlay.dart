part of '../../main.dart';

class DeckMenuOverlay extends StatefulWidget {
  final DuelGame game;
  final bool isPlayer1;

  const DeckMenuOverlay({
    super.key,
    required this.game,
    required this.isPlayer1,
  });

  @override
  State<DeckMenuOverlay> createState() => _DeckMenuOverlayState();
}

class _DeckMenuOverlayState extends State<DeckMenuOverlay> {
  bool isDeckMenuOpen = false;
  bool isSurrenderMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final yFactor = widget.isPlayer1 ? 1 : -1;
    final appState = context.watch<MyAppState>();
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isLandscape = screenWidth > screenHeight;

    final buttonWidth = isLandscape ? screenHeight * 0.1 : screenWidth * 0.1;
    final buttonDeckPos = Vector2(widget.game.size.x * 0.5 + (widget.game.size.x * 0.4 * yFactor) - buttonWidth / 2, widget.game.size.y * 0.5 + (widget.game.size.y * 0.3 * yFactor) - buttonWidth / 2);
    final buttonSurrenderPos = Vector2(buttonDeckPos.x + widget.game.size.x * 0.05 * yFactor, buttonDeckPos.y);

    return Stack(
      children: [
        Positioned(
          top: buttonDeckPos.y,
          left: buttonDeckPos.x,
          child: GestureDetector(
            onTap: () {
              setState(() {
                widget.game.hideDeckMenu(widget.isPlayer1);
                widget.game.showDeck(widget.isPlayer1);
              });
            },
            onTapDown: (_) {
              setState(() {
                FlameAudio.play('SE_MENU_DECIDE.ogg', volume: 0.7);
                isDeckMenuOpen = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                isDeckMenuOpen = false;
              });
            },
            onTapCancel: () {
              setState(() {
                isDeckMenuOpen = false;
              });
            },
            child: Container(
              width: buttonWidth,
              height: buttonWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: isDeckMenuOpen ?
                    AssetImage('assets/png/decklist_2.png') :
                    AssetImage('assets/png/decklist_1.png'),
                  fit: BoxFit.cover,
                )
              )
            ),
          ),
        ),
        Positioned(
          top: buttonSurrenderPos.y,
          left: buttonSurrenderPos.x,
          child: GestureDetector(
            onTap: () {
              setState(() {
                appState.setState(1);
              });
            },
            onTapDown: (_) {
              setState(() {
                isSurrenderMenuOpen = true;
                FlameAudio.play('SE_DUEL_CANCEL.ogg', volume: 0.7);
              });
            },
            onTapUp: (_) {
              setState(() {
                isSurrenderMenuOpen = false;
              });
            },
            onTapCancel: () {
              setState(() {
                isSurrenderMenuOpen = false;
              });
            },
            child: Container(
              width: buttonWidth,
              height: buttonWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: isSurrenderMenuOpen ?
                    AssetImage('assets/png/surrender_2.png') :
                    AssetImage('assets/png/surrender_1.png'),
                  fit: BoxFit.cover,
                )
              )
            ),
          ),
        ),
      ]
    );
  }
}