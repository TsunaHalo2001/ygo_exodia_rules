part of '../../main.dart';

class GameField extends PositionComponent with HasGameReference<DuelGame>{
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final screenWidth = game.size.x;
    final screenHeight = game.size.y;
    final isLandscape = screenWidth > screenHeight;

    final zoneWidth = isLandscape ? screenHeight * 0.26 : screenWidth * 0.26;
    final zoneHeight = zoneWidth;
    final zoneSize = Vector2(zoneWidth, zoneHeight);

    final centerRowY = screenHeight / 2;

    placePlayerZone(
      isPlayer1: true,
      zoneSize: zoneSize,
      fieldCenterY: centerRowY,
    );

    placePlayerZone(
      isPlayer1: false,
      zoneSize: zoneSize,
      fieldCenterY: centerRowY,
    );
  }


  void placePlayerZone({
    required bool isPlayer1,
    required Vector2 zoneSize,
    required double fieldCenterY,
  }) {
    final yFactor = isPlayer1 ? 1 : -1;

    final cardSize = Vector2(zoneSize.y * 0.685714285714285, zoneSize.y);

    final deckPos = Vector2(game.size.x / 2.353 * yFactor, game.size.y / 2.354 * yFactor);
    final gyPos = Vector2(deckPos.x, deckPos.y / 3.105);
    final extraPos = Vector2(- deckPos.x, deckPos.y);
    final monsterY = game.size.y / 5.13 * yFactor;
    double currentX = - zoneSize.x * 3;

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
      final xPos = currentX + zoneSize.x;

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