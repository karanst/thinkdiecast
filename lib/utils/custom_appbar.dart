import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
// import 'package:thinkdiecast/controller/DashboardController/home_controller.dart';

import 'colors.dart';
import 'widgets.dart';

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
