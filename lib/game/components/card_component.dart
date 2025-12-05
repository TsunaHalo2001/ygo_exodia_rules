part of '../../main.dart';

class CardComponent extends PositionComponent
  with TapCallbacks, DragCallbacks, HasGameReference<DuelGame> {
  final YGOCard card;
  final bool isFaceUp;
  late SpriteComponent faceDown;
  late SpriteComponent frame;
  late SpriteComponent image;

  CardComponent({
    required this.card,
    required this.isFaceUp,
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

    if (!isFaceUp) {
      final faceDownSprite = await Sprite.load('face_down.png');
      faceDown = SpriteComponent(
        sprite: faceDownSprite,
        size: size,
        position: Vector2.zero(),
      );
      add(faceDown);
      return;
    }
    final frameSprite = card.id == 33396948 ?
      await Sprite.load('exodia_frame.png') :
      card.type.contains('Normal Monster') ?
        await Sprite.load('normal_frame.png') :
        await Sprite.load('fusion_frame.png');

    frame = SpriteComponent(
      sprite: frameSprite,
      size: size,
      position: Vector2.zero(),
    );
    add(frame);

    final imageSprite = await Sprite.load('cards/${card.id}.jpg');
    image = SpriteComponent(
      sprite: imageSprite,
      size: Vector2(size.x * 0.9, size.y * 0.7),
      position: Vector2(0, - size.y * 0.05),
      anchor: Anchor.center,
    );
    add(image);
  }
}