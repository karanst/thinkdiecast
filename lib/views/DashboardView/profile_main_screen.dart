import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/login_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/custom_appbar.dart';
import 'package:thinkdiecast/views/Authview/user_profile_screen.dart';
import 'package:thinkdiecast/views/EntityManager/admin_manager_screen.dart';
import 'package:thinkdiecast/views/EntityManager/manage_entity_screen.dart';
import 'package:thinkdiecast/views/membership_screen.dart';
import 'package:thinkdiecast/utils/widgets.dart';

class ProfileMainScreen extends StatefulWidget {
  const ProfileMainScreen({super.key});

  @override
  State<ProfileMainScreen> createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends State<ProfileMainScreen> {
  late UserController controller;
  @override
  void initState() {
    controller = Get.put(UserController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: LoginController(),
        builder: (controller) {
          return Container(
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
                const CustomAppHeader(showBackButton: false),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Account Settings Section
                          _buildMenuGroup([
                            _buildMenuItem('Edit Profile', () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UserProfileScreen()));
                            }),
                            _buildMenuItem('Change Password', () {}),
                          ]),
                          const SizedBox(height: 16),
                          // Information Section
                          _buildMenuGroup([
                            _buildMenuItem('Membership', () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MembershipScreen(
                                              showButton: true)));
                            }),
                          ]),
                          const SizedBox(height: 16),
                          // Legal Section
                          _buildMenuGroup([
                            _buildMenuItem('Terms & Conditions', () {}),
                            _buildMenuItem('Privacy Policy', () {}),
                          ]),
                          const SizedBox(height: 16),
                    _buildMenuGroup([
                          _buildMenuItem('Manage Entity Screen', () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AdminManagerScreen()));
                          }),
                ]),
                          const SizedBox(height: 16),
                          // Support & Feedback Section
                          _buildMenuGroup([
                            _buildMenuItem('Request Features', () {}),
                            _buildMenuItem('Report Bug', () {}),
                            _buildMenuItem('Support Think Diecast', () {}),
                            _buildMenuItem('Rate App', () {}),
                            _buildMenuItem('Share App', () {}),
                          ]),
                          const SizedBox(height: 40),
                          // Logout Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5B7FFF), Color(0xFF3B5FFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  showCustomConfirmDialog(
                                    context: context,
                                    message: 'Are you sure want to\nlogout',
                                    actionText: 'Yes, Logout',
                                    isLogout: true,
                                  ).then((confirmed) {
                                    if (confirmed == true) {
                                      controller.logout();
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: const Center(
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Delete Account
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Color(0xFFFF4444),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          // App Info Section
                          Column(
                            children: [
                              const Text(
                                'Think Diecast',
                                style: TextStyle(
                                  color: Color(0xFF808080),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Version: 1.5.4 | Build: 200',
                                style: TextStyle(
                                  color: Color(0xFF606060),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Follow Us On:',
                                style: TextStyle(
                                  color: Color(0xFF808080),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialIcon('instagram'),
                                  const SizedBox(width: 24),
                                  _buildSocialIcon('youtube'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildMenuGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.grad1Clr.withOpacity(0.4),
              AppColors.grad2Clr.withOpacity(0.4)
            ]),

        borderRadius: BorderRadius.circular(12),
        // border: Border.all(
        //   color: AppColors.grad1Clr.withOpacity(0.2),
        //   width: 1,
        // ),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String platform) {
    IconData icon =
        platform == 'instagram' ? Icons.camera_alt : Icons.play_arrow;
    Color bgColor = platform == 'instagram'
        ? const Color(0xFFE4405F)
        : const Color(0xFFFF0000);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
