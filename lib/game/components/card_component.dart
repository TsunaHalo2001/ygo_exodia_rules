part of '../../main.dart';

class CardComponent extends PositionComponent
  with TapCallbacks, DragCallbacks, HasGameReference<DuelGame> {
  final YGOCard card;
  final bool isFaceUp;
  late SpriteComponent faceDown;
  late SpriteComponent frame;
  late SpriteComponent image;
  Vector2 originalPosition = Vector2.zero();
  final PlayerData player;

  CardComponent({
    required this.card,
    required this.isFaceUp,
    required double size,
    required Vector2 position,
    required this.player,
  }) : super(
    size: Vector2(size * 0.6875, size),
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final imageSize = Vector2(size.y * 0.5166015625, size.y * 0.5166015625);
    originalPosition = Vector2.zero();
    final imagePos = Vector2(imageSize.x * 0.667, imageSize.y * 0.86);

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

    final imageSprite = await Sprite.load('cards/${card.id}.jpg');
    image = SpriteComponent(
      sprite: imageSprite,
      size: imageSize,
      position: imagePos,
      anchor: Anchor.center,
    );
    add(image);

    final frameSprite = card.id == 33396948 ?
    await Sprite.load('exodia_frame.png') :
    card.type.contains('Normal Monster') ?
    await Sprite.load('normal_frame.png') :
    await Sprite.load('fusion_frame.png');

    frame = SpriteComponent(
      sprite: frameSprite,
      size: size,
      position: originalPosition,
    );
    add(frame);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    game.showCardInfo(card);
    event.handled = true;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    if (game.currentPlayer != player) {
      return;
    }
    originalPosition.setFrom(position);
    final Vector2 worldPos = absolutePositionOf(Vector2.zero());
    position.setFrom(worldPos);

    scale = Vector2.all(1.1);
    parent = game.world;
    game.selectedCard = card;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if (game.currentPlayer != player) {
      return;
    }

    position += event.canvasDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (game.currentPlayer != player) {
      return;
    }

    scale = Vector2.all(1.0);
    position.setFrom(originalPosition);

    if (player == game.player1) {
      game.player1Hand.add(this);
    } else {
      game.player2Hand.add(this);
    }
  }
}