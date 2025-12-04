part of '../../main.dart';

class GameField extends PositionComponent with HasGameReference<DuelGame>{
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final screenWidth = size.x;
    final screenHeight = size.y;
    final isLandscape = screenWidth > screenHeight;

    final zoneWidth = isLandscape ? screenHeight * 0.2 : screenWidth * 0.2;
    final zoneHeight = zoneWidth;
    final zoneSize = Vector2(zoneWidth, zoneHeight);

    final handSpace = isLandscape ? screenHeight * 0.1 : screenWidth * 0.01;

    final centerRowY = screenHeight / 2;

    placePlayerZone(
      isPlayer1: true,
      zoneSize: zoneSize,
      fieldCenterY: centerRowY,
      offsetX: screenWidth * 0.1,
      handSpace: handSpace,
      spacing: screenWidth * 0.02
    );

    placePlayerZone(
        isPlayer1: false,
        zoneSize: zoneSize,
        fieldCenterY: centerRowY,
        offsetX: screenWidth * 0.1,
        handSpace: handSpace,
        spacing: screenWidth * 0.02
    );
  }


  void placePlayerZone({
    required bool isPlayer1,
    required Vector2 zoneSize,
    required double fieldCenterY,
    required double offsetX,
    required double handSpace,
    required double spacing,
  }) {
    final yFactor = isPlayer1 ? 1 : -1;
    final fieldCenterYOffset = isPlayer1 ? fieldCenterY + 10 : fieldCenterY - 10;

    double currentX = offsetX;

    final sideY = fieldCenterYOffset + (zoneSize.y * 1.5 * yFactor);

    add(
        ZoneComponent(
          type: ZoneType.deck,
          isPlayer1: isPlayer1,
          size: zoneSize,
          position: Vector2(zoneSize.x - offsetX, sideY),
        )
    );

    add(
        ZoneComponent(
          type: ZoneType.graveyard,
          isPlayer1: isPlayer1,
          size: zoneSize,
          position: Vector2(offsetX, sideY),
        )
    );

    final monsterY = fieldCenterYOffset + (zoneSize.y * 0.5 * yFactor);

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