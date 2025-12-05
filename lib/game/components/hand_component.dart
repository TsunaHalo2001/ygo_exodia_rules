part of '../../main.dart';

class HandComponent extends PositionComponent with HasGameReference<DuelGame> {
  static const double totalAngle = pi / 3;
  static const double fanRadius = 300;
  static const double verticalOffset = 10;

  HandComponent({
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
  }

  void addCard(CardComponent card) {
    add(card);
    _arrangeCards();
  }

  void removeCard(CardComponent card) {
    card.removeFromParent();
    _arrangeCards();
  }

  void _arrangeCards() {
    final cardCount = children.length;
    if (cardCount == 0) return;

    final angleStep = cardCount > 1 ?
      totalAngle / (cardCount - 1) :
      0;
    final startAngle = -totalAngle / 2;

    int index = 0;
    for (final child in children) {
      if (child is CardComponent) {
        final angle = startAngle + index * angleStep;
        final x = fanRadius * sin(angle);
        final y = fanRadius * cos(angle) - verticalOffset;

        child.position = Vector2(x, y);
        child.angle = angle;

        index++;
      }
    }
  }
}