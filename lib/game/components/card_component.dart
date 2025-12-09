part of '../../main.dart';

class CardComponent extends PositionComponent
  with TapCallbacks, DragCallbacks, HasGameReference<DuelGame> {
  final YGOCard card;
  final bool isFaceUp;
  late SpriteComponent faceDown;
  late bool isInHand;
  late bool isInDefensePosition;
  late bool attackedThisTurn;
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

    isInHand = true;
    isInDefensePosition = false;
    attackedThisTurn = false;

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

    if (game.currentTurnPhase != TurnPhases.battlePhase) {
      if (!isInHand || game.currentPlayer.hasNormalSummonedThisTurn) {
        return;
      }
    }
    else {
      if (isInHand || game.selectedCardComponent!.isInDefensePosition) {
        return;
      }
    }

    originalPosition.setFrom(position);
    final Vector2 worldPos = absolutePositionOf(Vector2.zero());
    position.setFrom(worldPos);

    scale = Vector2.all(1.1);
    parent = game.world;
    game.selectedCard = card;
    game.selectedCardComponent = this;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if (game.currentPlayer != player) {
      return;
    }

    if (game.currentTurnPhase != TurnPhases.battlePhase) {
      if (!isInHand || game.currentPlayer.hasNormalSummonedThisTurn) {
        return;
      }
    }
    else {
      if (isInHand || game.selectedCardComponent!.isInDefensePosition) {
        return;
      }
    }

    position += event.canvasDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (game.currentPlayer != player) {
      return;
    }

    if (game.currentTurnPhase != TurnPhases.battlePhase) {
      if (!isInHand || game.currentPlayer.hasNormalSummonedThisTurn) {
        return;
      }
    }
    else {
      if (isInHand || game.selectedCardComponent!.isInDefensePosition) {
        return;
      }
    }

    if (game.currentTurnPhase == TurnPhases.mainPhase1 ||
    game.currentTurnPhase == TurnPhases.mainPhase2) {

      game.selectedZone = findDroppedZone();
      game.selectedZoneIndex = game.selectedZone?.zoneIndex ?? -1;
      final selectedZone = game.selectedZone;

      if (selectedZone != null) {
        if (game.currentPlayer.field[selectedZone.zoneIndex] != -1) {
          returnToHand();
          return;
        }
        game.showSummonMenu();
        return;
      }
    }

    if (game.currentTurnPhase == TurnPhases.battlePhase && !game.selectedCardComponent!.attackedThisTurn) {
      final battleZone = findBattleZone();
      int selectedBattleZone = battleZone?.zoneIndex ?? -1;
      final opponent = game.currentPlayer == game.player1
          ? game.player2
          : game.player1;

      final thereIsATarget = opponent.field.any((zone) => zone != -1);

      if (!thereIsATarget) {
        game.inflictDirectDamage();
        returnToField();
        return;
      }

      if (opponent.field[selectedBattleZone] == -1 && thereIsATarget) {
        returnToField();
        return;
      }

      if (battleZone != null && thereIsATarget) {
        game.battleZone = battleZone;
        game.battleZoneIndex = selectedBattleZone;
        game.executeBattle();
        returnToField();
        return;
      }
    }

    if (game.currentTurnPhase != TurnPhases.battlePhase) {
      returnToHand();
    }
    else {
      returnToField();
    }
  }

  void returnToHand() {
    scale = Vector2.all(1.0);
    position.setFrom(originalPosition);

    if (player == game.player1) {
      game.player1Hand.add(this);
    } else {
      game.player2Hand.add(this);
    }
  }

  void returnToField() {
    scale = Vector2.all(1.0);
    position.setFrom(originalPosition);
  }

  ZoneComponent? findDroppedZone() {
    final zones = game.field.children.whereType<ZoneComponent>();
    ZoneComponent? targetZone;

    for (final zone in zones) {
      if (zone.isPlayer1 == (player == game.player1) &&
          zone.type == ZoneType.monster) {

        if (zone.containsPoint(absoluteCenter)) {
          targetZone = zone;
          break;
        }
      }
    }

    return targetZone;
  }

  ZoneComponent? findBattleZone() {
    final zones = game.field.children.whereType<ZoneComponent>();
    ZoneComponent? targetZone;

    for (final zone in zones) {
      if (zone.isPlayer1 != (player == game.player1) &&
          zone.type == ZoneType.monster) {

        if (zone.containsPoint(absoluteCenter)) {
          targetZone = zone;
          break;
        }
      }
    }

    return targetZone;
  }
}