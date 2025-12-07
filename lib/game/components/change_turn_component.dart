part of '../../main.dart';

class ChangeTurnComponent extends PositionComponent with HasGameReference<DuelGame> {
  final bool isPlayer1;
  final int turn;

  ChangeTurnComponent({
    required this.isPlayer1,
    required this.turn,
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

    late final Sprite frame;

    if (isPlayer1) {
      frame = await Sprite.load('img_TunChange_bg01.png');
    }
    else {
      frame = await Sprite.load('img_TunChange_bg02.png');
    }

    final imageComponent = SpriteComponent(
      sprite: frame,
      size: size,
    );

    add(imageComponent);

    final textPainter = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: size.y * 0.4,
        fontWeight: FontWeight.bold,
      ),
    );

    final textComponent = TextComponent(
      text: "Turn $turn",
      textRenderer: textPainter,
      anchor: Anchor.center,
      position: size / 2,
    );

    add(textComponent);

    add(
        TimerComponent(
          period: 2.0,
          removeOnFinish: true,
          onTick: () {
            removeFromParent();
          },
        )
    );
  }
}