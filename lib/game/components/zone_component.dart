part of '../../main.dart';

enum ZoneType {
  deck,
  graveyard,
  monster,
  extraDeck
}

class ZoneComponent extends PositionComponent with HasGameReference {
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
}