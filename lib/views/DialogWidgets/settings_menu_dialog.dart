import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/views/membership_screen.dart';

class SettingMenuDialog extends StatelessWidget {
  SettingMenuDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      // backgroundColor: AppColors.black.withOpacity(0.7),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 90.0, bottom: 90),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20)),
                    height: MediaQuery.of(context).size.width / 2,
                    width: MediaQuery.of(context).size.width / 2,
                    child: ListView(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MembershipScreen()));
                          },
                          title: const Text(
                            'Membership',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: AppColors.bright,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          trailing: const Icon(
                            Icons.person,
                            color: AppColors.bright,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => MembershipScreen()));
                          },
                          title: const Text(
                            'Settings',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: AppColors.bright,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          trailing: const Icon(
                            Icons.settings,
                            color: AppColors.bright,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => MembershipScreen()));
                          },
                          title: const Text(
                            'About',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: AppColors.bright,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          trailing: Icon(
                            Icons.info_outline,
                            color: AppColors.bright,
                          ),
                        ),
                      ],
                    ),
                  ),
                ), // Replace with your image asset
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withOpacity(0.33)),
                  child: const Icon(Icons.close, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
