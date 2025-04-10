import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// A simple utility to generate a PNG icon for the app
/// Run this file with: dart run lib/app_icon_generator.dart

void main() {
  generateAppIcon();
}

void generateAppIcon() {
  // Create a 1024x1024 image with a blue background
  final icon = img.Image(width: 1024, height: 1024);

  // Fill with navy blue background
  final navyBlue = img.ColorRgba8(26, 35, 126, 255); // #1A237E
  img.fill(icon, color: navyBlue);

  // Draw a gold circle in the middle
  final centerX = icon.width ~/ 2;
  final centerY = icon.height ~/ 2;
  final radius = (icon.width * 0.35).toInt();

  final goldColor = img.ColorRgba8(255, 215, 0, 255); // #FFD700 - Gold
  img.fillCircle(
    icon,
    x: centerX,
    y: centerY,
    radius: radius,
    color: goldColor,
  );

  // Create a simple gradient effect for the circle
  for (int y = 0; y < icon.height; y++) {
    for (int x = 0; x < icon.width; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < radius) {
        // Inside the circle - add a gradient
        final distanceRatio = distance / radius;
        final brightnessAdjustment = (1.0 - distanceRatio) * 80;
        final pixel = icon.getPixel(x, y);

        // Make top-left part brighter
        if (x < centerX && y < centerY) {
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;

          // Brighten color
          final newR = (r + brightnessAdjustment).clamp(0, 255).toInt();
          final newG = (g + brightnessAdjustment).clamp(0, 255).toInt();
          final newB = (b + brightnessAdjustment).clamp(0, 255).toInt();

          icon.setPixel(x, y, img.ColorRgba8(newR, newG, newB, 255));
        }
      }
    }
  }

  // Draw "BG" text in the circle
  final textColor = navyBlue;

  // Draw 'B' - simplified
  drawVerticalLine(icon, centerX - 100, centerY - 150, 300, 20, textColor);
  drawHorizontalLine(icon, centerX - 100, centerY - 150, 120, 20, textColor);
  drawHorizontalLine(icon, centerX - 100, centerY, 120, 20, textColor);
  drawHorizontalLine(icon, centerX - 100, centerY + 150, 120, 20, textColor);
  drawVerticalLine(icon, centerX + 40, centerY - 150, 300, 20, textColor);

  // Draw 'G' - simplified
  drawVerticalLine(icon, centerX + 80, centerY - 150, 300, 20, textColor);
  drawHorizontalLine(icon, centerX + 80, centerY - 150, 120, 20, textColor);
  drawHorizontalLine(icon, centerX + 80, centerY + 150, 120, 20, textColor);
  drawVerticalLine(icon, centerX + 200, centerY, 150, 20, textColor);
  drawHorizontalLine(icon, centerX + 140, centerY, 60, 20, textColor);

  // Save the icon as PNG
  final directory = Directory('assets/icons');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final iconFile = File('assets/icons/app_icon.png');
  iconFile.writeAsBytesSync(img.encodePng(icon));

  print('App icon generated successfully at: ${iconFile.path}');
}

// Helper to draw a vertical line
void drawVerticalLine(
    img.Image image, int x, int y, int length, int thickness, img.Color color) {
  for (int i = 0; i < length; i++) {
    for (int t = 0; t < thickness; t++) {
      final iy = y + i;
      final ix = x + t;
      if (ix >= 0 && ix < image.width && iy >= 0 && iy < image.height) {
        image.setPixel(ix, iy, color);
      }
    }
  }
}

// Helper to draw a horizontal line
void drawHorizontalLine(
    img.Image image, int x, int y, int length, int thickness, img.Color color) {
  for (int i = 0; i < length; i++) {
    for (int t = 0; t < thickness; t++) {
      final ix = x + i;
      final iy = y + t;
      if (ix >= 0 && ix < image.width && iy >= 0 && iy < image.height) {
        image.setPixel(ix, iy, color);
      }
    }
  }
}
