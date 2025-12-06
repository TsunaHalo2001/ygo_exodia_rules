part of '../../main.dart';

enum ZoneType {
  deck,
  graveyard,
  monster,
  extraDeck
}

class ZoneComponent extends PositionComponent with TapCallbacks, HasGameReference<DuelGame> {
  final ZoneType type;
  final bool isPlayer1;

  ZoneComponent({
    required this.type,
    required this.isPlayer1,
    required Vector2 size,
    required Vector2 position,
  }) : super(
    size: size,
    position: position,
    anchor: Anchor.center,
    );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    if (type == ZoneType.extraDeck || type == ZoneType.deck) {
      final sprite = await Sprite.load('face_down.png');

      final imageComponent = SpriteComponent(
        sprite: sprite,
        size: size,
      );

      add(imageComponent);
    }
    else {
      add(
        RectangleComponent(
          paint: Paint()
            ..color = isPlayer1 ? Colors.red : Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
          size: size,
        )
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (type == ZoneType.deck) {
      if(game.currentTurnPhase == TurnPhases.drawPhase
        && game.currentTurn % 2 == (isPlayer1 ? 1 : 0)){
        game.drawCard(isPlayer1);
      }
      else {
        game.showDeckMenu(isPlayer1);
      }

      event.handled = true;
    }

    if (type == ZoneType.extraDeck) {
      game.showExtraDeckMenu(isPlayer1);

      event.handled = true;
    }
  }
}