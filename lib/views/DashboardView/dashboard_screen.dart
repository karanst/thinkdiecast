import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/controllers/refresh_controller.dart';
import 'package:thinkdiecast/views/DashboardView/home_screen.dart';
import 'package:thinkdiecast/views/DashboardView/items_screen.dart';
import 'package:thinkdiecast/views/DashboardView/profile_main_screen.dart';
import 'package:thinkdiecast/views/DashboardView/search_screen.dart';
import 'package:thinkdiecast/views/widgets/custom_bottom_bar.dart';








class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final refreshCtrl = AppRefreshController.to;
    return Obx(() => Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: refreshCtrl.selectedTab.value,
        onTap: (index) {
          refreshCtrl.changeTab(index);
          refreshCtrl.refreshAll();
        },
      ),
      body: Stack(
        children: [
          // TAB CONTENT
          _buildTabContent(refreshCtrl.selectedTab.value),

          // BOTTOM NAVIGATION BAR
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: CustomBottomNavigationBar(
          //     selectedIndex: _selectedIndex,
          //     onTap: (index) {
          //       setState(() {
          //         _selectedIndex = index;
          //       });
          //     },
          //   ),
          // ),
        ],
      ),
    ));
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const SearchScreen();
      case 3:
        return const ItemsScreen();
      case 4:
        return const ProfileMainScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tabName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Coming Soon...',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}


