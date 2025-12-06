part of '../../main.dart';

class HandComponent extends PositionComponent with HasGameReference<DuelGame> {
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

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    super.onChildrenChanged(child, type);
    if (child is CardComponent) {
      _arrangeCards();
    }
  }

  void addCard(CardComponent card) {
    add(card);
  }

  void removeCard(CardComponent card) {
    card.removeFromParent();
  }

  void _arrangeCards() {
    final cardSize = Vector2(size.y * 0.6875, size.y);
    final cardCount = children.length;
    if (cardCount == 0) return;

    int index = 1;
    for (final child in children) {
      if (child is CardComponent) {
        final x = ((index - 1) * (size.x - cardSize.x) / (cardCount - 1)) + cardSize.x / 2;
        final y = cardSize.y / 2;
        child.position = Vector2(x, y);

        index++;
      }
    }
  }
}