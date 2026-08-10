import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/views/EntityManager/admin_membership_screen.dart';
import 'manage_entity_screen.dart';

/// Admin Manager screen — entry point for admins to navigate to
/// Categories, Brands, and Scale management screens.
///
/// Visual language matches HomeScreen:
/// - same auth_bg.png background
/// - same header block style (small grey label + big white title)
/// - same rounded gradient card-bg.png cards used for categories on HomeScreen
class AdminManagerScreen extends StatelessWidget {
  const AdminManagerScreen({super.key});

  void _openManageScreen(
      BuildContext context, {
        required String endpoint,
        required String entityLabel,
        required String tag,
        required bool hasImage,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageEntityScreen(
          endpoint: endpoint,
          entityLabel: entityLabel,
          tag: tag,
          hasImage: hasImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage('assets/auth_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER SECTION
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'MANAGER',
                          style: TextStyle(
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
              ),

              const SizedBox(height: 8),

              // SECTION LABEL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'MANAGE DIE-CAST DATA',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ADMIN CARDS - full width list, matches category card style
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildAdminCard(
                      context,
                      icon: Icons.category_rounded,
                      title: 'CATEGORIES',
                      subtitle: 'Add, edit or delete categories',
                      onTap: () => _openManageScreen(
                        context,
                        endpoint: '/Categories',
                        entityLabel: 'CATEGORIES',
                        tag: 'categories',
                        hasImage: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminCard(
                      context,
                      icon: Icons.local_offer_rounded,
                      title: 'BRANDS',
                      subtitle: 'Add, edit or delete brands',
                      onTap: () => _openManageScreen(
                        context,
                        endpoint: '/Brands',
                        entityLabel: 'BRANDS',
                        tag: 'brands',
                        hasImage: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminCard(
                      context,
                      icon: Icons.straighten_rounded,
                      title: 'SCALE',
                      subtitle: 'Add, edit or delete scales',
                      onTap: () => _openManageScreen(
                        context,
                        endpoint: '/Scales',
                        entityLabel: 'SCALES',
                        tag: 'scales',
                        hasImage: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminCard(
                      context,
                      icon: Icons.subscriptions_rounded,
                      title: 'MEMBERSHIP PLAN',
                      subtitle: 'Add, edit or delete plans',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminMembershipScreen(),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/card-bg.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.bright, AppColors.bright2],
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
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}