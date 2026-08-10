
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/views/add_product_screen.dart';
import 'package:thinkdiecast/utils/custom_toast.dart';
import 'package:thinkdiecast/views/membership_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {

  late UserController controller;

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


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: const Color(0xFFF5F1FF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 10,
        //     offset: const Offset(0, -5),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // HOME TAB
                _buildNavItem(
                  label: 'HOME',
                  index: 0,
                  isSelected: widget.selectedIndex == 0,
                  onTap: widget.onTap,
                  icon: NavIcons.homeIcon,
                  iconName: 'assets/icons/home.svg'
                ),
                // SEARCH TAB
                _buildNavItem(
                  label: 'SEARCH',
                  index: 1,
                  isSelected: widget.selectedIndex == 1,
                  onTap: widget.onTap,
                  icon: NavIcons.searchIcon,
                    iconName: 'assets/icons/search.svg'
                ),
                // CENTER EMPTY SPACE FOR FAB
                SizedBox(width: 60),
                // ITEMS TAB
                _buildNavItem(
                  label: 'ITEMS',
                  index: 3,
                  isSelected: widget.selectedIndex == 3,
                  onTap: widget.onTap,
                  icon: NavIcons.itemsIcon,
                    iconName: 'assets/icons/item.svg'
                ),
                // PROFILE TAB
                _buildNavItem(
                  label: 'PROFILE',
                  index: 4,
                  isSelected: widget.selectedIndex == 4,
                  onTap: widget.onTap,
                  icon: NavIcons.profileIcon,
                    iconName: 'assets/icons/profile.svg'
                ),
              ],
            ),
            // FLOATING ACTION BUTTON IN CENTER - Centered curved add button
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 30,
              top: -30,
              child: GestureDetector(
                onTap: () {
                  if (controller.getRemainingEntries() == 0) {
                    Get.rawSnackbar(
                      titleText: const Text(
                        'Limit Reached',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      messageText: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Upgrade your plan to add more products.',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              Get.to(() => const MembershipScreen(showButton: true));
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.bright,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('UPGRADE', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E2436),
                      margin: const EdgeInsets.all(15),
                      borderRadius: 12,
                      duration: const Duration(seconds: 6),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(
                          productData: null,
                          isEditMode: false,
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        // Refresh
                      }
                    });
                  }
                },
                child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.bright,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bright.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: AppColors.white, size: 30,)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required int index,
    required bool isSelected,
    required Function(int) onTap,
    required Widget Function({required Color color, required double size}) icon,
    required String iconName,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 58,
        height: 58,
        decoration: isSelected
            ? BoxDecoration(
          gradient:   LinearGradient(
            colors: [AppColors.grad1Clr, AppColors.grad2Clr],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:  AppColors.grad1Clr.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        )
            : BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.7),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: isSelected ?icon(

                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF9E9E9E),
                  size: 24,
                )
                : SvgPicture.asset(iconName,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : AppColors.bright,
                  BlendMode.srcIn,
                ),),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: AppColors.black
                  // isSelected
                  //     ?  AppColors.grad1Clr
                  //     : const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BottomNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5F1FF)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // Left side with rounded corner
    path.lineTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);

    // Move to left side of notch
    final notchLeft = size.width / 2 - 40;
    path.lineTo(notchLeft, 0);

    // Create the curved notch
    path.quadraticBezierTo(
      notchLeft + 10, 0,
      notchLeft + 15, 10,
    );

    path.quadraticBezierTo(
      notchLeft + 20, 20,
      notchLeft + 25, 25,
    );

    // Top of the notch (circular curve)
    path.arcToPoint(
      Offset(size.width / 2 + 25, 25),
      radius: const Radius.circular(25),
      clockwise: false,
    );

    path.quadraticBezierTo(
      size.width / 2 + 30, 20,
      size.width / 2 + 35, 10,
    );

    path.quadraticBezierTo(
      size.width / 2 + 40, 0,
      size.width / 2 + 50, 0,
    );

    // Right side with rounded corner
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);

    // Bottom right
    path.lineTo(size.width, size.height);
    path.close();

    // Draw shadow
    canvas.drawPath(path, shadowPaint);

    // Draw the main shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class GradientSvgAsset extends StatelessWidget {
  final String assetName;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final double width;
  final double height;

  const GradientSvgAsset({
    Key? key,
    required this.assetName,
    required this.colors,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    this.width = 100,
    this.height = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: SvgPicture.asset(
        assetName,
        width: width,
        height: height,
        // The color property in SvgPicture.asset can tint with a solid color,
        // but for gradients, ensure the original SVG paths have a color (e.g., white or black)
        // so the ShaderMask can apply its effect correctly.
        // If your SVG is already colored, you might need to use a ColorMapper or
        // ensure the blend mode works with the mask. Using a white/placeholder color
        // in the SVG itself often works best with this ShaderMask approach.
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

class NavIcons {
  // HOME icon SVG
  static Widget homeIcon({required Color color, required double size}) {
    return  GradientSvgAsset(
      assetName: 'assets/icons/home.svg',
      colors: [AppColors.grad1Clr, AppColors.grad1Clr],
      width: size,
      height: size,
    );

    //   GradientSvgAsset(
    //   'assets/icons/home.svg',
    //   width: size,
    //   height: size,
    //   colorFilter: GradientC,
    //   color: color,
    // );
  }

  // SEARCH icon SVG
  static Widget searchIcon({required Color color, required double size}) {
    return GradientSvgAsset(
      assetName: 'assets/icons/search.svg',
      colors: [AppColors.grad1Clr, AppColors.grad1Clr],
      width: size,
      height: size,
    );
      // SvgPicture.asset(
      // 'assets/icons/search.svg',
      // width: size,
      // height: size,
      // color: color,
    // );
  }

  // ITEMS icon SVG
  static Widget itemsIcon({required Color color, required double size}) {
    return GradientSvgAsset(
      assetName: 'assets/icons/item.svg',
      colors: [AppColors.grad1Clr, AppColors.grad1Clr],
      width: size,
      height: size,
    );
    //   SvgPicture.string(
    //   'assets/icons/item.svg',
    //   width: size,
    //   height: size,
    //   color: color,
    // );
  }

  // PROFILE icon SVG
  static Widget profileIcon({required Color color, required double size}) {
    return GradientSvgAsset(
      assetName: 'assets/icons/profile.svg',
      colors: [AppColors.grad1Clr, AppColors.grad1Clr],
      width: size,
      height: size,
    );
    //   SvgPicture.asset(
    //   'assets/icons/profile.svg',
    //   width: size,
    //   height: size,
    //   color: color,
    // );
  }

  // ADD icon SVG
  static Widget addIcon({required Color color, required double size}) {
    return SvgPicture.string(
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
        <line x1="12" y1="5" x2="12" y2="19"></line>
        <line x1="5" y1="12" x2="19" y2="12"></line>
      </svg>''',
      width: size,
      height: size,
      color: color,
    );
  }
}