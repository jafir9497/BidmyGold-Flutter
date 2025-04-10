import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This is a utility script to convert SVG to PNG for our app icon
/// To run it, use:
/// flutter run -d macos lib/app_icon_converter.dart (or another platform)

void main() {
  runApp(const IconConverterApp());
}

class IconConverterApp extends StatelessWidget {
  const IconConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IconConverter(),
    );
  }
}

class IconConverter extends StatefulWidget {
  @override
  _IconConverterState createState() => _IconConverterState();
}

class _IconConverterState extends State<IconConverter> {
  bool isConverting = false;
  String status = 'Ready to convert';

  @override
  void initState() {
    super.initState();
    // Auto-start conversion after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      convertSvgToPng();
    });
  }

  Future<void> convertSvgToPng() async {
    setState(() {
      isConverting = true;
      status = 'Converting SVG to PNG...';
    });

    try {
      final ByteData data = await rootBundle.load('assets/icons/app_icon.svg');
      final String svgString = String.fromCharCodes(data.buffer.asUint8List());

      // Create PictureInfo from SVG
      final PictureInfo pictureInfo =
          await vg.loadPicture(SvgStringLoader(svgString), null);

      final double iconSize = 1024; // PNG size in pixels
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Draw the SVG picture
      canvas.drawPicture(pictureInfo.picture);

      // Convert to image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image =
          await picture.toImage(iconSize.toInt(), iconSize.toInt());
      final ByteData? pngData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (pngData != null) {
        final Uint8List bytes = pngData.buffer.asUint8List();

        // Save to assets/icons/app_icon.png
        final File file = File('assets/icons/app_icon.png');
        await file.writeAsBytes(bytes);

        setState(() {
          status = 'Conversion complete!\nIcon saved to: ${file.path}';
        });
      } else {
        setState(() {
          status = 'Failed to get PNG data';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error: $e';
      });
    } finally {
      setState(() {
        isConverting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG to PNG Converter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isConverting)
              const CircularProgressIndicator()
            else
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: convertSvgToPng,
                tooltip: 'Convert Again',
              ),
            const SizedBox(height: 20),
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
