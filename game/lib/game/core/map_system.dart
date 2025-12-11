import 'dart:ui';
import 'package:flame/components.dart';

class MapSystem extends Component {
  static const double tileSize = 64.0;

  // 0: Empty (Buildable), 1: Path (Walkable for enemies)
  final List<List<int>> grid = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0], // Start (0,1) -> (3,1)
    [0, 0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 0, 0], // (3,3) -> (5,3)
    [0, 0, 0, 0, 0, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 0, 0], // (5,5) -> End
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  /// Get world position center for a grid coordinate
  Vector2 getPosition(int x, int y) {
    return Vector2(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2);
  }

  /// Get list of waypoints (world positions) for the path
  /// Simple hardcoded extraction for this specific grid for now
  List<Vector2> getPath() {
    return [
      getPosition(0, 1),
      getPosition(3, 1),
      getPosition(3, 3),
      getPosition(5, 3),
      getPosition(5, 5),
      getPosition(2, 5), // Loop back slightly
    ];
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        final rect = Rect.fromLTWH(
          x * tileSize,
          y * tileSize,
          tileSize,
          tileSize,
        );

        if (grid[y][x] == 1) {
          paint.color = const Color(0xFF554433); // Path color
          canvas.drawRect(
            rect,
            Paint()..color = const Color(0xFF221100),
          ); // Fill
        } else {
          paint.color = const Color(0xFF444444); // Grid line
        }
        canvas.drawRect(rect, paint);
      }
    }
  }
}
