part of '../../main.dart';

class ChangePhaseComponent extends PositionComponent with HasGameReference<DuelGame> {
  final bool isPlayer1;
  final String phase;

  ChangePhaseComponent({
    required this.isPlayer1,
    required this.phase,
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
      frame = await Sprite.load('img_Phase_near.png');
    }
    else {
      frame = await Sprite.load('img_Phase_far.png');
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
      text: phase,
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