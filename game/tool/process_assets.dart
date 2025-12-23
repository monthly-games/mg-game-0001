import 'dart:io';
import 'package:image/image.dart';

void main() async {
  final files = [
    'assets/images/logo.png',
    'assets/images/ui_button_wide.png',
    'assets/images/frame_hud_top.png',
    'assets/images/ui_panel_glass.png',
    'assets/images/icon_gold.png',
    'assets/images/icon_gem.png',
    'assets/images/tower_base.png',
    'assets/images/tower_turret.png',
    'assets/images/monster.png',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (!await file.exists()) {
      print('File not found: $filePath');
      continue;
    }

    final bytes = await file.readAsBytes();
    final image = decodeImage(bytes);

    if (image == null) {
      print('Failed to decode image: $filePath');
      continue;
    }

    print('Processing $filePath...');

    // Process pixels: Flood Fill Transparency starting from (0,0)
    // We assume the pixel at (0,0) is the background color.
    if (image.width > 0 && image.height > 0) {
      final bgColor = image.getPixel(0, 0);
      final visited = List.generate(
        image.height,
        (_) => List.filled(image.width, false),
      );
      final queue = <Pt>[Pt(0, 0)];

      // Threshold for background similarity
      bool isBackground(Pixel p) {
        final dr = (p.r - bgColor.r).abs();
        final dg = (p.g - bgColor.g).abs();
        final db = (p.b - bgColor.b).abs();
        return dr < 40 && dg < 40 && db < 40;
      }

      visited[0][0] = true;

      while (queue.isNotEmpty) {
        final p = queue.removeLast();
        final int x = p.x;
        final int y = p.y;

        image.setPixelRgba(x, y, 0, 0, 0, 0); // Make Transparent

        final dirs = [Pt(x + 1, y), Pt(x - 1, y), Pt(x, y + 1), Pt(x, y - 1)];

        for (final d in dirs) {
          if (d.x >= 0 && d.x < image.width && d.y >= 0 && d.y < image.height) {
            if (!visited[d.y][d.x]) {
              final pixel = image.getPixel(d.x, d.y);
              if (isBackground(pixel)) {
                visited[d.y][d.x] = true;
                queue.add(d);
              }
            }
          }
        }
      }
    }

    // Save
    final newBytes = encodePng(image);
    await file.writeAsBytes(newBytes);
    print('Saved processed image to $filePath');
  }
}

class Pt {
  final int x;
  final int y;
  Pt(this.x, this.y);
}
