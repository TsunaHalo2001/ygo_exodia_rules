part of '../../main.dart';

class SummonMenuOverlay extends StatefulWidget {
  final DuelGame game;
  final YGOCard card;
  final ZoneComponent zone;
  final Vector2 position;

  const SummonMenuOverlay({
    super.key,
    required this.game,
    required this.card,
    required this.zone,
    required this.position,
  });

  @override
  State<SummonMenuOverlay> createState() => _SummonMenuOverlayState();
}

class _SummonMenuOverlayState extends State<SummonMenuOverlay> {
  bool isSummonSelected = false;
  bool isSetSelected = false;
  bool isCancelSelected = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isLandscape = screenWidth > screenHeight;

    final buttonWidth = isLandscape ? screenHeight * 0.1 : screenWidth * 0.1;

    return Center(
      child: Card(
        color: Colors.black87,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:
            _buildRow(
              () => widget.game.normalSummonCard(widget.card, widget.game.currentPlayer, widget.game.selectedZoneIndex),
              () => widget.game.setCard(widget.card, widget.game.currentPlayer, widget.game.selectedZoneIndex),
              () => widget.game.cancelSummon(),
              buttonWidth,
            ),
        ),
      ),
    );
  }

  List<Widget> _buildRow(
    VoidCallback onSummonPressed,
    VoidCallback onSetPressed,
    VoidCallback onCancelPressed,
    double buttonWidth,
  ) {
    return [
      GestureDetector(
        onTap: onSummonPressed,
        onTapDown: (_) {
          setState(() {
            FlameAudio.play('SE_MENU_DECIDE.ogg', volume: 0.7);
            isSummonSelected = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            isSummonSelected = false;
          });
        },
        onTapCancel: () {
          setState(() {
            isSummonSelected = false;
          });
        },
        child: Container(
            width: buttonWidth,
            height: buttonWidth,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: isSummonSelected ?
                  AssetImage('assets/png/normal_2.png') :
                  AssetImage('assets/png/normal_1.png'),
                  fit: BoxFit.cover,
                )
            )
        ),
      ),
      GestureDetector(
        onTap: onSetPressed,
        onTapDown: (_) {
          setState(() {
            FlameAudio.play('SE_MENU_DECIDE.ogg', volume: 0.7);
            isSetSelected = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            isSetSelected = false;
          });
        },
        onTapCancel: () {
          setState(() {
            isSetSelected = false;
          });
        },
        child: Container(
            width: buttonWidth,
            height: buttonWidth,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: isSetSelected ?
                  AssetImage('assets/png/set_2.png') :
                  AssetImage('assets/png/set_1.png'),
                  fit: BoxFit.cover,
                )
            )
        ),
      ),
      GestureDetector(
        onTap: onCancelPressed,
        onTapDown: (_) {
          setState(() {
            FlameAudio.play('SE_MENU_DECIDE.ogg', volume: 0.7);
            isCancelSelected = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            isCancelSelected = false;
          });
        },
        onTapCancel: () {
          setState(() {
            isCancelSelected = false;
          });
        },
        child: Container(
            width: buttonWidth,
            height: buttonWidth,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: isCancelSelected ?
                  AssetImage('assets/png/cancel_2.png') :
                  AssetImage('assets/png/cancel_1.png'),
                  fit: BoxFit.cover,
                )
            )
        ),
      ),
    ];
  }
}