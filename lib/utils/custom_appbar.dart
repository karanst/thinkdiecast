import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
// import 'package:thinkdiecast/controller/DashboardController/home_controller.dart';

import 'colors.dart';
import 'widgets.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppHeader extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? customTitle; // Optional custom title instead of "WELCOME"

  const CustomAppHeader({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
    this.customTitle,
  });

  @override
  State<CustomAppHeader> createState() => _CustomAppHeaderState();
}

class _CustomAppHeaderState extends State<CustomAppHeader> {
  late UserController _userController;

  @override
  void initState() {
    super.initState();
    // Get existing controller or create new one
    _userController = Get.put(UserController());

    // Fetch user data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userController.currentUser == null) {
        _userController.fetchUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
                  onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                ),
              Obx(() => _buildProfilePictureSection()),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customTitle ?? 'WELCOME',
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    _userController.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  )),
                ],
              ),
            ],
          ),
          _buildCurrentPlanIcon()
        ],
      ),
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
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          if (_userController.isLoading.value)
            Container(
              width: 60,
              height: 60,
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
    final path = _userController.profileImagePath.value;
    if (path.isEmpty) {
      return _buildDefaultAvatar();
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      width: 60,
      height: 60,
      errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
    );
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
    return Obx(() {
      String currentPlan = _userController.currentUser?.plan?.toString().toUpperCase() ?? 'FREE';
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
    });
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
        return 'assets/noob.png';
    }
  }
}
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  String title;
  final bool show;
  CustomAppBar({Key? key, required this.title, required this.show})
      : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: LayoutBuilder(builder: (context, constraint) {
        final width = constraint.maxWidth * 8;
        return Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              // border:  Border( bottom : BorderSide(color: Theme.of(context).iconTheme.color!)),
              color: Theme.of(context).colorScheme.background,
              gradient: const LinearGradient(
                  colors: [AppColors.grad1Clr, AppColors.grad2Clr]),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: widget.show == false
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  widget.show
                      ? IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.white,
                          ))
                      : const SizedBox.shrink(),
                  Text(
                    widget.title,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ));
      }),
    );
  }

  Size get preferredSize => const Size.fromHeight(100.0);
}

class HomeAppbar extends StatefulWidget implements PreferredSizeWidget {
  HomeAppbar({Key? key}) : super(key: key);

  @override
  State<HomeAppbar> createState() => _HomeAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}

class _HomeAppbarState extends State<HomeAppbar> {
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: LayoutBuilder(builder: (context, constraint) {
        final width = constraint.maxWidth * 8;
        return GetBuilder(
            // init: HomeController(),
            builder: (controller) {
          return Container(
              padding: EdgeInsets.only(top: 30),
              width: width,
              height: width,
              decoration: BoxDecoration(
                // border:  Border( bottom : BorderSide(color: Theme.of(context).iconTheme.color!)),
                color: Theme.of(context).colorScheme.background,
                gradient: const LinearGradient(
                    colors: [AppColors.grad1Clr, AppColors.grad2Clr]),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => PlacePicker(
                  //             apiKey: Platform.isAndroid
                  //                 ? "AIzaSyB0uPBgryG9RisP8_0v50Meds1ZePMwsoY"
                  //                 : "AIzaSyB0uPBgryG9RisP8_0v50Meds1ZePMwsoY",
                  //             onPlacePicked: (result) {
                  //               print(result.formattedAddress);
                  //               setState(() {
                  //                 controller.currentAddress =
                  //                     result.formattedAddress.toString();
                  //                 controller.homelat =
                  //                     result.geometry!.location.lat;
                  //                 controller.homeLong =
                  //                     result.geometry!.location.lng;
                  //               });
                  //               Navigator.of(context).pop();
                  //             },
                  //             useCurrentLocation: true,
                  //             initialPosition: const LatLng(
                  //                 22.719568, 75.857727
                  //                 //   double.parse(widget.lat.toString()), double.parse(widget.long.toString()
                  //                 )),
                  //         // useCurrentLocation: true,
                  //       ),
                  //     );
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(left: 20.0, right: 20),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         // Image.asset('assets/icons/location.png', height: 35, width: 35,),
                  //         Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: [
                  //             Row(
                  //               children: [
                  //                 const Icon(
                  //                   Icons.location_on,
                  //                   size: 12,
                  //                 ),
                  //                 Text(
                  //                   controller.currentAddress
                  //                               .toString()
                  //                               .split(",")
                  //                               .length >=
                  //                           2
                  //                       ? '${controller.currentAddress.toString().split(" ")[0]} ${controller.currentAddress.toString().split(" ")[1]}'
                  //                       : controller.currentAddress
                  //                           .toString(),
                  //                   style: const TextStyle(
                  //                       fontSize: 14,
                  //                       fontWeight: FontWeight.w600),
                  //                   maxLines: 1,
                  //                 )
                  //               ],
                  //             ),
                  //             SizedBox(
                  //                 width: MediaQuery.of(context).size.width -
                  //                     120,
                  //                 child: Center(
                  //                   child: Text(
                  //                     controller.currentAddress.toString(),
                  //                     style: const TextStyle(
                  //                         fontSize: 12,
                  //                         fontWeight: FontWeight.w400),
                  //                     maxLines: 1,
                  //                   ),
                  //                 )),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // Icon(Icons.add_shopping_cart)
                ],
              ));
        });
      }),
    );
  }

  Size get preferredSize => const Size.fromHeight(100.0);
}
