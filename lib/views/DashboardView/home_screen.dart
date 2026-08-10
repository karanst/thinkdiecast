
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/custom_appbar.dart';
import 'package:thinkdiecast/views/DashboardView/category_item_screen.dart';
import 'package:thinkdiecast/views/DashboardView/items_screen.dart';

/*class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserProfileController controller;
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserProfileController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.userData == null) {
        controller.fetchUserData();
      }
    });
  }

  // Navigate to ItemsScreen with category filter
  void _navigateToCategory(String category) {
    // Apply category filter to HomeController
    // if (category == null || category.toLowerCase() == 'all') {
      // Show all items - clear category filter
    //   _homeController.applyFilters({'category': null});
    // } else {
    //   // Apply specific category filter
    //   _homeController.applyFilters({'category': category});
    // }

    // Navigate to ItemsScreen (assuming it's in DashboardScreen at index 3)
    // If you're using a different navigation method, adjust accordingly
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  CategoryItemsScreen(
        categoryName: category,
      )),
    );
  }

  Widget _buildProfilePictureSection() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildProfileImage(),
            ),
          ),
          if (controller.isLoading)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (controller.profileImage.value != null) {
      return Image.file(
        File(controller.profileImage.value!.path),
        fit: BoxFit.cover,
        width: 60,
        height: 60,
      );
    }

    if (controller.profilePictureUrl.isNotEmpty) {
      return Image.network(
        controller.profilePictureUrl,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.blue.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.blue.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCurrentPlanIcon() {
    String currentPlan = controller.userData?['plan']?.toString().toUpperCase() ?? 'FREE';
    String planIconPath = _getPlanIconPath(currentPlan);

    return Container(
      width: 40,
      height: 40,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.bright,
            AppColors.bright2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.bright.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Image.asset(
            planIconPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              );
            },
          ),
        ),
      ),
    );
  }

  String _getPlanIconPath(String planName) {
    switch (planName) {
      case 'NOOB':
        return 'assets/noob.png';
      case 'PRO':
        return 'assets/pro.png';
      case 'LEGEND':
        return 'assets/legend.png';
      case 'COLLECTOR':
        return 'assets/collector.png';
      case 'FREE':
      default:
        return 'assets/free.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: AssetImage('assets/auth_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          // HEADER SECTION
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildProfilePictureSection(),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WELCOME',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildCurrentPlanIcon()
              ],
            ),
          ),

          // CIRCULAR PROGRESS INDICATOR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: GradientCirclePainter(
                      percentage: controller.percentage,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Usage',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.entries,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/${controller.limit}',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // DIE-CAST CATEGORIES SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DIE-CAST CATEGORIES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToCategory('All'), // Show all items
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.grad1Clr, AppColors.grad2Clr],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SHOW ALL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CATEGORY CARDS GRID - Now with tap handlers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryCard(
                        icon: 'assets/icons/cars.svg',
                        title: 'CARS',
                        count: controller.getCarsCount(),
                        w: 33,
                        h: 12,
                        onTap: () => _navigateToCategory('CARS'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryCard(
                        icon: 'assets/icons/bikes.svg',
                        title: 'BIKES',
                        count: controller.getBikesCount(),
                        w: 30,
                        h: 15,
                        onTap: () => _navigateToCategory('BIKES'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryCard(
                        icon: 'assets/icons/trucks.svg',
                        title: 'TRUCKS',
                        count: controller.getTrucksCount(),
                        w: 29,
                        h: 13,
                        onTap: () => _navigateToCategory('TRUCKS'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryCard(
                        icon: 'assets/icons/planes.svg',
                        title: 'PLANES',
                        count: controller.getPlanesCount(),
                        w: 18,
                        h: 18,
                        onTap: () => _navigateToCategory('PLANES'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ));
  }

  Widget _buildCategoryCard({
    required String icon,
    required String title,
    required String count,
    required double h,
    required double w,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/card-bg.png')),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: SvgPicture.asset(
                  icon,
                  width: w,
                  height: h,
                  color: Colors.white,
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserController controller;
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentUser == null) {
        controller.fetchUserProfile();
      }
    });
  }

  // Navigate to ItemsScreen with category filter
  void _navigateToCategory(String category) {
    // Apply category filter to HomeController
    // if (category == null || category.toLowerCase() == 'all') {
    // Show all items - clear category filter
    //   _homeController.applyFilters({'category': null});
    // } else {
    //   // Apply specific category filter
    //   _homeController.applyFilters({'category': category});
    // }

    // Navigate to ItemsScreen (assuming it's in DashboardScreen at index 3)
    // If you're using a different navigation method, adjust accordingly
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  CategoryItemsScreen(
        categoryName: category,
      )),
    );
  }

  Widget _buildProfilePictureSection() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildProfileImage(),
            ),
          ),
          if (controller.isLoading.value)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (controller.profileImagePath.value.isNotEmpty) {
      return Image.network(
        controller.profileImagePath.value,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.blue.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.blue.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCurrentPlanIcon() {
    String currentPlan = controller.currentUser?.plan?.toString().toUpperCase() ?? 'FREE';
    String planIconPath = _getPlanIconPath(currentPlan);

    return Container(
      width: 40,
      height: 40,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.bright,
            AppColors.bright2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.bright.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Image.asset(
            planIconPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              );
            },
          ),
        ),
      ),
    );
  }

  String _getPlanIconPath(String planName) {
    switch (planName) {
      case 'NOOB':
        return 'assets/noob.png';
      case 'PRO':
        return 'assets/pro.png';
      case 'LEGEND':
        return 'assets/legend.png';
      case 'COLLECTOR':
        return 'assets/collector.png';
      case 'FREE':
      default:
        return 'assets/free.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: AssetImage('assets/auth_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
          const CustomAppHeader(showBackButton: false),

          // CIRCULAR PROGRESS INDICATOR
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: GradientCirclePainter(
                      percentage: controller.percentage,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Usage',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.entries,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/${controller.limit}',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),

          // DIE-CAST CATEGORIES SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DIE-CAST CATEGORIES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToCategory('All'), // Show all items
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.grad1Clr, AppColors.grad2Clr],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SHOW ALL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CATEGORY CARDS GRID - Now with tap handlers
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryCard(
                        icon: 'assets/icons/cars.svg',
                        title: 'CARS',
                        count: _homeController.getCarsCount(),
                        w: 33,
                        h: 12,
                        onTap: () => _navigateToCategory('CARS'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryCard(
                        icon: 'assets/icons/bikes.svg',
                        title: 'BIKES',
                        count: _homeController.getBikesCount(),
                        w: 30,
                        h: 15,
                        onTap: () => _navigateToCategory('BIKES'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryCard(
                        icon: 'assets/icons/trucks.svg',
                        title: 'TRUCKS',
                        count: _homeController.getTrucksCount(),
                        w: 29,
                        h: 13,
                        onTap: () => _navigateToCategory('TRUCKS'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryCard(
                        icon: 'assets/icons/planes.svg',
                        title: 'PLANES',
                        count: _homeController.getPlanesCount(),
                        w: 18,
                        h: 18,
                        onTap: () => _navigateToCategory('PLANES'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

  Widget _buildCategoryCard({
    required String icon,
    required String title,
    required String count,
    required double h,
    required double w,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/card-bg.png')),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: SvgPicture.asset(
                  icon,
                  width: w,
                  height: h,
                  color: Colors.white,
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class GradientCirclePainter extends CustomPainter {
  final double percentage;

  GradientCirclePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle (dark)
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1E2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Create gradient shader
    final gradientShader = SweepGradient(
      colors: const [
        AppColors.grad1Clr,
        AppColors.grad2Clr,
        AppColors.grad1Clr,
      ],
      stops: const [0.0, 0.5, 1.0],
      startAngle: -3.14159 / 2, // Start from top
      endAngle: 3.14159 * 1.5, // Full circle
    ).createShader(rect);

    final progressPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    // Draw arc based on percentage
    final sweepAngle = 2 * 3.14159 * percentage.clamp(0.0, 1.0);

    canvas.drawArc(
      rect,
      -3.14159 / 2, // Start from top (-90 degrees)
      sweepAngle,
      false,
      progressPaint,
    );

    // Add glow effect at the end of the arc if percentage > 0
    if (percentage > 0) {
      final endAngle = -3.14159 / 2 + sweepAngle;
      final glowX = center.dx + radius * cos(endAngle);
      final glowY = center.dy + radius * sin(endAngle);
      final glowCenter = Offset(glowX, glowY);

      // Outer glow
      final glowPaint = Paint()
        ..color = AppColors.grad2Clr.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(glowCenter, 12, glowPaint);

      // Inner glow
      final innerGlowPaint = Paint()
        ..color = AppColors.grad2Clr
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(glowCenter, 6, innerGlowPaint);
    }
  }

  @override
  bool shouldRepaint(GradientCirclePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
// class GradientCirclePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//
//     // Background circle
//     final bgPaint = Paint()
//       ..color = const Color(0xFF1A1A2E)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 12;
//
//     canvas.drawCircle(center, radius, bgPaint);
//
//     // Gradient circle
//     final paint = Paint()
//       ..shader = SweepGradient(
//         colors: const [
//           AppColors.grad1Clr,
//           AppColors.grad2Clr,
//           AppColors.grad1Clr,
//         ],
//         stops: const [0.0, 0.5, 1.0],
//         startAngle: -3.14159 / 2,
//         endAngle: 3.14159 / 2,
//       ).createShader(Rect.fromCircle(center: center, radius: radius))
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 12
//       ..strokeCap = StrokeCap.round;
//
//     canvas.drawCircle(center, radius, paint);
//   }
//
//   @override
//   bool shouldRepaint(GradientCirclePainter oldDelegate) => false;
// }