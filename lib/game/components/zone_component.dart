part of '../../main.dart';

enum ZoneType {
  deck,
  graveyard,
  monster,
}

class ZoneComponent extends RectangleComponent {
  final ZoneType type;
  final bool isPlayer1;

  ZoneComponent({
    required this.type,
    required this.isPlayer1,
    required Vector2 size,
    required Vector2 position,
  }) : super(
    size: size,
    position: position,
    anchor: Anchor.center,
    ) {
      paint = Paint()
        ..color = isPlayer1 ? Colors.red : Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
    }
}