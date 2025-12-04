part of '../../main.dart';

class GameField extends PositionComponent with HasGameReference<DuelGame>{
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final screenWidth = game.size.x;
    final screenHeight = game.size.y;
    final isLandscape = screenWidth > screenHeight;

    final zoneWidth = isLandscape ? screenHeight * 0.28 : screenWidth * 0.28;
    final zoneHeight = zoneWidth;
    final zoneSize = Vector2(zoneWidth, zoneHeight);

    final handSpace = isLandscape ? screenHeight * 0.1 : screenWidth * 0.01;

    final centerRowY = screenHeight / 2;

    placePlayerZone(
      isPlayer1: true,
      zoneSize: zoneSize,
      fieldCenterY: centerRowY,
      handSpace: handSpace,
    );

    placePlayerZone(
      isPlayer1: false,
      zoneSize: zoneSize,
      fieldCenterY: centerRowY,
      handSpace: handSpace,
    );
  }


  void placePlayerZone({
    required bool isPlayer1,
    required Vector2 zoneSize,
    required double fieldCenterY,
    required double handSpace,
  }) {
    final yFactor = isPlayer1 ? 1 : -1;

    final cardSize = Vector2(zoneSize.y * 0.685714285714285, zoneSize.y);

    final deckPos = Vector2(game.size.x / 2.35 * yFactor, game.size.y / 2.123 * yFactor);
    final gyPos = Vector2(deckPos.x, deckPos.y / 3.105);
    final extraPos = Vector2(- deckPos.x, deckPos.y);
    final monsterY = game.size.y / 4.56 * yFactor;
    final spacing = game.size.x * 0.0045;
    double currentX = (- zoneSize.x - spacing) * 3;

    add(
      ZoneComponent(
        type: ZoneType.deck,
        isPlayer1: isPlayer1,
        size: cardSize,
        position: deckPos,
      )
    );

    add(
      ZoneComponent(
        type: ZoneType.graveyard,
        isPlayer1: isPlayer1,
        size: cardSize,
        position: gyPos,
      )
    );

    add(
      ZoneComponent(
        type: ZoneType.extraDeck,
        isPlayer1: isPlayer1,
        size: cardSize,
        position: extraPos
      )
    );

    for (int i = 0; i < 5; i++) {
      final xPos = currentX + zoneSize.x + spacing;

      add(
        ZoneComponent(
          type: ZoneType.monster,
          isPlayer1: isPlayer1,
          size: zoneSize,
          position: Vector2(xPos, monsterY),
        )
      );

      currentX = xPos;
    }
  }
}