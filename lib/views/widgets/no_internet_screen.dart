import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/network_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _carBounceAnimation;
  late Animation<double> _roadScrollAnimation;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Car vibration/bounce animation
    _carBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -3).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -3, end: 0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    // Continuous road offset
    _roadScrollAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
    });

    // Request manual ping recheck
    await NetworkController.to.forceRecheck();

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
      if (NetworkController.to.isConnected.value) {
        Get.snackbar(
          'Connected',
          'Internet connection restored!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Offline',
          'Still no internet access. Please check your connection.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/auth_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // neon signal loss icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bright.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 48,
                      color: AppColors.bright,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'CONNECTION LOST',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Please check your internet connection to continue collecting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.65),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ANIMATED MOVEMENT BOX
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Speed lines scrolling past
                            CustomPaint(
                              painter: SpeedLinesPainter(_roadScrollAnimation.value),
                              size: const Size(double.infinity, 100),
                            ),

                            // Bouncing Neon sports car
                            Transform.translate(
                              offset: Offset(0, _carBounceAnimation.value),
                              child: CustomPaint(
                                painter: NeonCarPainter(),
                                size: const Size(200, 60),
                              ),
                            ),

                            // Dashed moving road line
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: CustomPaint(
                                painter: DashedRoadPainter(_roadScrollAnimation.value),
                                size: const Size(double.infinity, 6),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // GLASSMORPHIC RETRY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _handleRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: AppColors.bright.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.bright.withOpacity(0.2),
                              AppColors.bright2.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isChecking
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'TRY AGAIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
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
      ),
    );
  }
}

class DashedRoadPainter extends CustomPainter {
  final double animValue;
  DashedRoadPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double dashWidth = 16;
    double dashSpace = 10;
    double startX = -(animValue * (dashWidth + dashSpace));

    while (startX < size.width) {
      if (startX + dashWidth >= 0) {
        canvas.drawLine(
          Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2),
          paint,
        );
      }
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedRoadPainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}

class SpeedLinesPainter extends CustomPainter {
  final double animValue;
  SpeedLinesPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bright.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw three speed lines at different Y-offsets
    final lines = [
      {'y': size.height * 0.25, 'length': 36.0, 'speedMult': 1.6},
      {'y': size.height * 0.45, 'length': 50.0, 'speedMult': 2.2},
      {'y': size.height * 0.65, 'length': 28.0, 'speedMult': 1.3},
    ];

    for (var line in lines) {
      double y = line['y'] as double;
      double len = line['length'] as double;
      double mult = line['speedMult'] as double;
      double startX = size.width - ((animValue * size.width * mult) % (size.width + len));
      canvas.drawLine(Offset(startX, y), Offset(startX + len, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpeedLinesPainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}

class NeonCarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Glowing paint
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.bright, AppColors.bright2],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw body path
    final path = Path();
    // Start from front bumper
    path.moveTo(10, height - 20);
    path.quadraticBezierTo(22, height - 30, 44, height - 30); // hood
    path.quadraticBezierTo(65, height - 52, 95, height - 55); // windshield
    path.quadraticBezierTo(120, height - 57, 135, height - 52); // roof
    path.quadraticBezierTo(160, height - 25, 175, height - 25); // rear window/trunk
    path.lineTo(190, height - 20); // rear bumper
    path.lineTo(172, height - 20);
    
    // Back wheel arch
    path.arcToPoint(Offset(138, height - 20), radius: const Radius.circular(17), clockwise: false);
    path.lineTo(72, height - 20);
    
    // Front wheel arch
    path.arcToPoint(Offset(38, height - 20), radius: const Radius.circular(17), clockwise: false);
    path.close();

    // Underglow paint
    final underglowPaint = Paint()
      ..color = AppColors.bright.withOpacity(0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(Offset(68, height - 16), Offset(132, height - 16), underglowPaint);

    canvas.drawPath(path, paint);

    // Draw glowing wheels
    final wheelPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final innerWheelPaint = Paint()
      ..color = AppColors.bright.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    // Front wheel (center at 55, height-20)
    canvas.drawCircle(Offset(55, height - 20), 13, wheelPaint);
    canvas.drawCircle(Offset(55, height - 20), 6, innerWheelPaint);

    // Rear wheel (center at 155, height-20)
    canvas.drawCircle(Offset(155, height - 20), 13, wheelPaint);
    canvas.drawCircle(Offset(155, height - 20), 6, innerWheelPaint);
  }

  @override
  bool shouldRepaint(covariant NeonCarPainter oldDelegate) => false;
}
