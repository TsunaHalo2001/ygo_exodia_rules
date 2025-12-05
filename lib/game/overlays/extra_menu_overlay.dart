part of '../../main.dart';

class ExtraMenuOverlay extends StatefulWidget {
  final DuelGame game;
  final bool isPlayer1;

  const ExtraMenuOverlay({
    super.key,
    required this.game,
    required this.isPlayer1,
  });

  @override
  State<ExtraMenuOverlay> createState() => _ExtraMenuOverlayState();
}

class _ExtraMenuOverlayState extends State<ExtraMenuOverlay> {
  bool isDeckMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final yFactor = widget.isPlayer1 ? 1 : -1;
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isLandscape = screenWidth > screenHeight;

    final buttonWidth = isLandscape ? screenHeight * 0.1 : screenWidth * 0.1;
    final buttonDeckPos = Vector2(widget.game.size.x * 0.5 - (widget.game.size.x * 0.4 * yFactor) - buttonWidth / 2, widget.game.size.y * 0.5 + (widget.game.size.y * 0.3 * yFactor) - buttonWidth / 2);

    return Stack(
      children: [
        Positioned(
          top: buttonDeckPos.y,
          left: buttonDeckPos.x,
          child: GestureDetector(
            onTap: () {
              widget.game.hideExtraDeckMenu();
              widget.game.showExtraDeck();
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
      ]
    );
  }
}