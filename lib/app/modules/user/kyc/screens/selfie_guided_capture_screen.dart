import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:typed_data';

class SelfieGuidedCaptureScreen extends StatefulWidget {
  final Function(XFile) onComplete;

  const SelfieGuidedCaptureScreen({super.key, required this.onComplete});

  @override
  State<SelfieGuidedCaptureScreen> createState() =>
      _SelfieGuidedCaptureScreenState();
}

class _SelfieGuidedCaptureScreenState extends State<SelfieGuidedCaptureScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  int _currentStep = 0;
  bool _isProcessing = false;
  int _countdown = 3;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Face outline pulse animation
  late Animation<double> _pulseAnimation;

  // The instruction steps
  final List<Map<String, dynamic>> _steps = [
    {
      'instruction': 'turn_left',
      'icon': Icons.arrow_back,
      'duration': 3,
    },
    {
      'instruction': 'turn_right',
      'icon': Icons.arrow_forward,
      'duration': 3,
    },
    {
      'instruction': 'smile',
      'icon': Icons.sentiment_satisfied_alt,
      'duration': 3,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true); // Repeat for pulsing effect

    // Instruction animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Face outline pulse animation
    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.6).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
    _startInstructionSequence();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startInstructionSequence() {
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = _steps[_currentStep]['duration'];
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
        });

        if (_countdown > 0) {
          _startCountdown();
        } else {
          // Move to next step or finish
          if (_currentStep < _steps.length - 1) {
            setState(() {
              // Reset animation and start new step
              _animationController.stop();
              _animationController.reset();
              _currentStep++;
              _animationController.repeat(reverse: true);
            });
            _startCountdown();
          } else {
            // All steps completed, take picture
            _animationController.stop();
            _takeSelfie();
          }
        }
      }
    });
  }

  Future<void> _takeSelfie() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        // Show review screen instead of returning immediately
        setState(() {
          _isProcessing = false;
        });
        _showSelfieReviewScreen(image);
      } else {
        // User cancelled capture
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          Get.back();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture selfie: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        Get.back();
      }
    }
  }

  // Show a review screen for the captured selfie
  void _showSelfieReviewScreen(XFile image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSelfieReviewScreen(image),
    );
  }

  // Build the review screen widget
  Widget _buildSelfieReviewScreen(XFile image) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title:
                Text('review_selfie'.tr, style: const TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: FutureBuilder<Uint8List>(
              future: image.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading image',
                          style: TextStyle(color: Colors.white)));
                } else if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image preview
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            snapshot.data!,
                            height: MediaQuery.of(context).size.height * 0.5,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Looking good message
                      Text(
                        'looking_good'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _takeSelfie(); // Retake the selfie
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: Text('retake'.tr,
                                style: const TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Get.back(
                                  result:
                                      image); // Return to KYC screen with the image
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            child: Text('confirm_selfie'.tr),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Center(
                      child: Text('No image data',
                          style: TextStyle(color: Colors.white)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _skipToCamera() {
    _takeSelfie();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isProcessing
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Stack(
              children: [
                // Face outline guide
                Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 220,
                      height: 280,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: FaceOutlinePainter(
                              opacity: _pulseAnimation.value,
                              step: _currentStep,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Instructions
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _steps[_currentStep]['icon'],
                                  size: 100,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  _steps[_currentStep]['instruction'].tr,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$_countdown',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: LinearProgressIndicator(
                              value: (_currentStep + 1) / _steps.length,
                              minHeight: 8,
                              backgroundColor: Colors.grey[800],
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: _skipToCamera,
                                child: Text(
                                  'skip'.tr,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                onPressed: _skipToCamera,
                                icon: const Icon(Icons.camera_alt),
                                label: Text('camera'.tr),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// Custom painter for face outline
class FaceOutlinePainter extends CustomPainter {
  final double opacity;
  final int step;

  const FaceOutlinePainter({
    required this.opacity,
    this.step = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw face oval
    final RRect faceOval = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: size.height * 0.7,
      ),
      Radius.circular(size.width * 0.4),
    );

    // Draw dashed oval for the face
    _drawDashedRRect(canvas, faceOval, paint);

    // Add markers for eyes and mouth position
    final Paint markerPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Eye level line
    double eyeY = size.height * 0.35;
    canvas.drawLine(
      Offset(size.width * 0.2, eyeY),
      Offset(size.width * 0.8, eyeY),
      markerPaint,
    );

    // Mouth level line
    double mouthY = size.height * 0.65;
    canvas.drawLine(
      Offset(size.width * 0.3, mouthY),
      Offset(size.width * 0.7, mouthY),
      markerPaint,
    );

    // Step-specific guides
    Paint specialPaint = Paint()
      ..color = Colors.blue.withOpacity(opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (step == 0) {
      // Turn left instruction - draw arrow pointing left
      _drawLeftDirectionGuide(canvas, size, specialPaint);
    } else if (step == 1) {
      // Turn right instruction - draw arrow pointing right
      _drawRightDirectionGuide(canvas, size, specialPaint);
    } else if (step == 2) {
      // Smile instruction - draw smile guide
      _drawSmileGuide(canvas, size, specialPaint);
    }
  }

  // Helper to draw left direction guide
  void _drawLeftDirectionGuide(Canvas canvas, Size size, Paint paint) {
    double centerX = size.width * 0.3;
    double centerY = size.height * 0.5;
    double arrowSize = size.width * 0.15;

    // Draw left-pointing arrow
    Path path = Path()
      ..moveTo(centerX + arrowSize, centerY - arrowSize)
      ..lineTo(centerX, centerY)
      ..lineTo(centerX + arrowSize, centerY + arrowSize);

    canvas.drawPath(path, paint);
  }

  // Helper to draw right direction guide
  void _drawRightDirectionGuide(Canvas canvas, Size size, Paint paint) {
    double centerX = size.width * 0.7;
    double centerY = size.height * 0.5;
    double arrowSize = size.width * 0.15;

    // Draw right-pointing arrow
    Path path = Path()
      ..moveTo(centerX - arrowSize, centerY - arrowSize)
      ..lineTo(centerX, centerY)
      ..lineTo(centerX - arrowSize, centerY + arrowSize);

    canvas.drawPath(path, paint);
  }

  // Helper to draw smile guide
  void _drawSmileGuide(Canvas canvas, Size size, Paint paint) {
    double centerX = size.width * 0.5;
    double centerY = size.height * 0.65; // Mouth level
    double smileWidth = size.width * 0.4;
    double smileHeight = size.height * 0.1;

    // Draw smile arc
    Rect smileRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: smileWidth,
      height: smileHeight,
    );

    canvas.drawArc(
      smileRect,
      0, // Start angle (radians)
      math.pi, // Sweep angle (radians)
      false, // Don't include center point
      paint,
    );
  }

  // Helper to draw dashed RRect
  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final Path path = Path()..addRRect(rrect);

    // Create a dash path effect
    double dashWidth = 10, dashSpace = 5, distance = 0;
    final Path dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant FaceOutlinePainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.step != step;
  }
}
