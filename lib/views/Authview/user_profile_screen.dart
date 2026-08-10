import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/custom_appbar.dart';
import 'package:thinkdiecast/utils/custom_toast.dart';

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thinkdiecast/utils/custom_textfield.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserController controller;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserController());

    // Initialize text controllers
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    cityController = TextEditingController();
    bioController = TextEditingController();

    // Ensure user data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserProfile();
      Future.delayed(const Duration(milliseconds: 500), () {
        _populateControllers();
      });
    });
  }

  void _populateControllers() {
    final user = controller.currentUser;
    if (user != null) {
      nameController.text = user.name ?? '';
      emailController.text = user.email1 ?? '';
      phoneController.text = user.phone ?? '';
      cityController.text = user.city ?? '';
      bioController.text = user.plan ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    bioController.dispose();
    super.dispose();
  }



// void _populateControllers() {
//   nameController.text = controller.displayName;
//   emailController.text = controller.email;
//   phoneController.text = controller.userData?['phone'] ?? '';
//   cityController.text = controller.userData?['city'] ?? '';
//   bioController.text = controller.userData?['bio'] ?? '';
// }
//
// @override
// void dispose() {
//   nameController.dispose();
//   emailController.dispose();
//   phoneController.dispose();
//   cityController.dispose();
//   bioController.dispose();
//   super.dispose();
// }

void _showLogoutConfirmation() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return Obx(() {
    // Update controllers when data changes
    if (controller.currentUser != null && nameController.text.isEmpty) {
      _populateControllers();
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/auth_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : controller.currentUser == null
              ? _buildErrorState()
              : _buildProfileContent(),
        ),
      ),
    );
  });
}

Widget _buildErrorState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'Failed to load profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please try again',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => controller.fetchUserProfile(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

Widget _buildProfileContent() {
  return SingleChildScrollView(
    child: Column(
      children: [
        const CustomAppHeader(showBackButton: true),
        const SizedBox(height: 20),
        _buildProfilePictureSection(),
        const SizedBox(height: 30),
        _buildFormFields(),
        const SizedBox(height: 30),
        _buildUpdateButton(),
        const SizedBox(height: 20),
        _buildVersionInfo(),
        const SizedBox(height: 20),
        _buildSocialLinks(),
        const SizedBox(height: 40),
      ],
    ),
  );
}

Widget _buildHeaderProfilePictureSection() {
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
          child: ClipOval(child: _buildHeaderProfileImage()),
        ),
        if (controller.isLoading.value)
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

Widget _buildHeaderProfileImage() {
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
            child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildHeaderDefaultAvatar(),
    );
  }

  return _buildHeaderDefaultAvatar();
}

Widget _buildHeaderDefaultAvatar() {
  return Container(
    color: Colors.blue.withOpacity(0.1),
    child: Icon(
      Icons.person,
      size: 40,
      color: Colors.blue.withOpacity(0.7),
    ),
  );
}

Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.white,)),

            _buildHeaderProfilePictureSection(),

            const SizedBox(width: 15,),
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
                  controller.currentUser?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),

            // GestureDetector(
            //   onTap: _showLogoutConfirmation,
            //   child: Container(
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: Colors.white.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(
            //         color: Colors.white.withOpacity(0.2),
            //       ),
            //     ),
            //     child: const Icon(
            //       Icons.logout,
            //       color: Colors.white,
            //       size: 24,
            //     ),
            //   ),
            // ),
          ],
        ),
        _buildCurrentPlanIcon()
      ],
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
          // color: Colors.white,
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

Widget _buildProfilePictureSection() {
  return Stack(
    children: [
      Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: _buildProfileImage(),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: () => controller.showImagePickerOptions(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      if (controller.isLoading.value)
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.5),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
    ],
  );
}

Widget _buildProfileImage() {
  final path = controller.profileImagePath.value;
  if (path.isEmpty) {
    return _buildDefaultAvatar();
  }
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      fit: BoxFit.cover,
      width: 150,
      height: 150,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[800],
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
  return Image.file(
    File(path),
    fit: BoxFit.cover,
    width: 150,
    height: 150,
    errorBuilder: (context, error, stackTrace) {
      return _buildDefaultAvatar();
    },
  );
}

Widget _buildDefaultAvatar() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.3),
          Colors.purple.withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Icon(
      Icons.person,
      size: 36,
      color: Colors.white.withOpacity(0.7),
    ),
  );
}

Widget _buildFormFields() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        GradientBorderTextField(
          label: 'NAME',
          hintText: 'Enter your name',
          controller: nameController,
        ),
        GradientBorderTextField(
          label: 'EMAIL ADDRESS',
          hintText: 'Enter your email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          isEnabled: false,
        ),
        GradientBorderTextField(
          label: 'PHONE',
          hintText: 'Enter your phone number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
        ),
        GradientBorderTextField(
          label: 'CITY',
          hintText: 'Enter your city',
          controller: cityController,
        ),
        GradientBorderTextField(
          label: 'BIO',
          hintText: 'Tell us about yourself',
          controller: bioController,
        ),
      ],
    ),
  );
}

Widget _buildUpdateButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            AppColors.bright,
            AppColors.bright
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Update',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    ),
  );
}

Widget _buildVersionInfo() {
  return Column(
    children: [
      Text(
        'Think Diecast',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Version: 1.5.4 | Build: 200',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    ],
  );
}

Widget _buildSocialLinks() {
  return Column(
    children: [
      Text(
        'Follow Us On:',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSocialIcon(
            icon: Icons.camera_alt,
            color: const Color(0xFFE4405F),
            onTap: () {
              // Instagram link
            },
          ),
          const SizedBox(width: 20),
          _buildSocialIcon(
            icon: Icons.play_arrow,
            color: const Color(0xFFFF0000),
            onTap: () {
              // YouTube link
            },
          ),
        ],
      ),
    ],
  );
}

Widget _buildSocialIcon({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    ),
  );
}

void _updateProfile() async {
  if (nameController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneController.text.isEmpty ||
      cityController.text.isEmpty) {
    showCustomToast('Please fill all required fields', isSuccess: false);
    return;
  }

  try {
    await controller.updateUserProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      city: cityController.text.trim(),
    );
    showCustomToast('Profile updated successfully!', isSuccess: true);
  } catch (e) {
    showCustomToast('Failed to update profile: $e', isSuccess: false);
  }
}
}

/*class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserProfileController controller;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserProfileController());

    // Initialize text controllers
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    cityController = TextEditingController();
    bioController = TextEditingController();

    // Ensure user data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.userData == null) {
        controller.fetchUserData();
      } else {
        _populateControllers();
      }
    });
  }

  void _populateControllers() {
    nameController.text = controller.displayName;
    emailController.text = controller.email;
    phoneController.text = controller.userData?['phone'] ?? '';
    cityController.text = controller.userData?['city'] ?? '';
    bioController.text = controller.userData?['bio'] ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Update controllers when data changes
      if (controller.userData != null && nameController.text.isEmpty) {
        _populateControllers();
      }

      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/auth_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : controller.userData == null
                ? _buildErrorState()
                : _buildProfileContent(),
          ),
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.fetchUserData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildProfilePictureSection(),
          const SizedBox(height: 30),
          _buildFormFields(),
          const SizedBox(height: 30),
          _buildUpdateButton(),
          const SizedBox(height: 20),
          _buildVersionInfo(),
          const SizedBox(height: 20),
          _buildSocialLinks(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderProfilePictureSection() {
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
            child: ClipOval(child: _buildHeaderProfileImage()),
          ),
          if (controller.isLoading)
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

  Widget _buildHeaderProfileImage() {
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
              child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildHeaderDefaultAvatar(),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildHeaderDefaultAvatar() {
    return Container(
      color: Colors.blue.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.blue.withOpacity(0.7),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.white,)),

              _buildHeaderProfilePictureSection(),

              const SizedBox(width: 15,),
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

              // GestureDetector(
              //   onTap: _showLogoutConfirmation,
              //   child: Container(
              //     padding: const EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       color: Colors.white.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(
              //         color: Colors.white.withOpacity(0.2),
              //       ),
              //     ),
              //     child: const Icon(
              //       Icons.logout,
              //       color: Colors.white,
              //       size: 24,
              //     ),
              //   ),
              // ),
            ],
          ),
          _buildCurrentPlanIcon()
        ],
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
            // color: Colors.white,
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

  Widget _buildProfilePictureSection() {
    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: _buildProfileImage(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => controller.showImagePickerOptions(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        if (controller.isLoading)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.5),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (controller.profileImage.value != null) {
      return Image.file(
        File(controller.profileImage.value!.path),
        fit: BoxFit.cover,
        width: 150,
        height: 150,
      );
    }

    if (controller.profilePictureUrl.isNotEmpty) {
      return Image.network(
        controller.profilePictureUrl,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[800],
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person,
        size: 36,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GradientBorderTextField(
            label: 'NAME',
            hintText: 'Enter your name',
            controller: nameController,
          ),
          GradientBorderTextField(
            label: 'EMAIL ADDRESS',
            hintText: 'Enter your email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            isEnabled: true,
          ),
          GradientBorderTextField(
            label: 'PHONE',
            hintText: 'Enter your phone number',
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          GradientBorderTextField(
            label: 'CITY',
            hintText: 'Enter your city',
            controller: cityController,
          ),
          GradientBorderTextField(
            label: 'BIO',
            hintText: 'Tell us about yourself',
            controller: bioController,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
           AppColors.bright,
              AppColors.bright
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Update',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'Think Diecast',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version: 1.5.4 | Build: 200',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinks() {
    return Column(
      children: [
        Text(
          'Follow Us On:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              icon: Icons.camera_alt,
              color: const Color(0xFFE4405F),
              onTap: () {
                // Instagram link
              },
            ),
            const SizedBox(width: 20),
            _buildSocialIcon(
              icon: Icons.play_arrow,
              color: const Color(0xFFFF0000),
              onTap: () {
                // YouTube link
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _updateProfile() async {
    try {
      await controller.updateUserProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        city: cityController.text.trim(),
        bio: bioController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}*/

// Custom Painter for Gradient Border
class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF4C6EF5),
          Color(0xFF7C3AED),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// class UserProfileScreen extends StatefulWidget {
//   const UserProfileScreen({super.key});
//
//   @override
//   State<UserProfileScreen> createState() => _UserProfileScreenState();
// }
//
// class _UserProfileScreenState extends State<UserProfileScreen> {
//   late UserProfileController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     // Get the controller that was already initialized in main.dart
//     controller = Get.put(UserProfileController());
//
//     // Ensure user data is loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (controller.userData == null) {
//         controller.fetchUserData();
//       }
//     });
//   }
//
//   void _showLogoutConfirmation() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Row(
//             children: [
//               Icon(Icons.logout, color: Colors.red, size: 28),
//               SizedBox(width: 12),
//               Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ],
//           ),
//           content: const Text(
//             'Are you sure you want to logout?',
//             style: TextStyle(fontSize: 16, color: Colors.black87),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 controller.logout(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: _buildAppBar(),
//       body: controller.isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.blue))
//           : controller.userData == null
//           ? _buildErrorState()
//           : _buildProfileContent(),
//     ));
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(70),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.white.withOpacity(0.8),
//               Colors.white.withOpacity(0.6),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(20),
//             bottomRight: Radius.circular(20),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(20),
//             bottomRight: Radius.circular(20),
//           ),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               title: const Text(
//                 'My Profile',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               centerTitle: true,
//               leading: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back,
//                     color: Colors.black87,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.error_outline,
//             size: 64,
//             color: Colors.red,
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Failed to load profile',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Please try again',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () => controller.fetchUserData(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfileContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           _buildProfilePictureSection(),
//           const SizedBox(height: 30),
//           _buildUserInfoCard(),
//           const SizedBox(height: 20),
//           _buildStatsCard(),
//           const SizedBox(height: 20),
//           _buildProgressCard(),
//           const SizedBox(height: 30),
//           _buildLogoutButton(),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfilePictureSection() {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white,
//                 width: 4,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: ClipOval(
//               child: _buildProfileImage(),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: GestureDetector(
//               onTap: () => controller.showImagePickerOptions(context),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.white,
//                     width: 2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.camera_alt,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ),
//           if (controller.isLoading)
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.black.withOpacity(0.5),
//               ),
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfileImage() {
//     if (controller.profileImage.value != null) {
//       return Image.file(
//         File(controller.profileImage.value!.path),
//         fit: BoxFit.cover,
//         width: 120,
//         height: 120,
//       );
//     }
//
//     if (controller.profilePictureUrl.isNotEmpty) {
//       return Image.network(
//         controller.profilePictureUrl,
//         fit: BoxFit.cover,
//         width: 120,
//         height: 120,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Container(
//             color: Colors.grey[200],
//             child: const Center(
//               child: CircularProgressIndicator(
//                 color: Colors.blue,
//                 strokeWidth: 2,
//               ),
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) {
//           return _buildDefaultAvatar();
//         },
//       );
//     }
//
//     return _buildDefaultAvatar();
//   }
//
//   Widget _buildDefaultAvatar() {
//     return Container(
//       color: Colors.blue.withOpacity(0.1),
//       child: Icon(
//         Icons.person,
//         size: 60,
//         color: Colors.blue.withOpacity(0.7),
//       ),
//     );
//   }
//
//   Widget _buildUserInfoCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white.withOpacity(0.9),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Column(
//             children: [
//               Text(
//                 controller.displayName,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.email,
//                       size: 16,
//                       color: Colors.blue,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       controller.email,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   Widget _buildStatItem(String label, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatsCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white.withOpacity(0.9),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _getUsageColor().withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       _getUsageIcon(),
//                       size: 16,
//                       color: _getUsageColor(),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       _getUsageText(),
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: _getUsageColor(),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildStatItem(
//                     'Entries',
//                     controller.entries,
//                     Icons.inventory,
//                     Colors.blue,
//                   ),
//                   Container(
//                     height: 40,
//                     width: 1,
//                     color: Colors.grey.withOpacity(0.3),
//                   ),
//                   _buildStatItem(
//                     'Limit',
//                     controller.limit,
//                     Icons.flag,
//                     Colors.orange,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProgressCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white.withOpacity(0.9),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Row(
//                 children: [
//                   Icon(
//                     Icons.trending_up,
//                     color: Colors.blue,
//                     size: 20,
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'Collection Progress',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4),
//                   color: Colors.grey[200],
//                 ),
//                 child: FractionallySizedBox(
//                   alignment: Alignment.centerLeft,
//                   widthFactor: controller.percentage.clamp(0.0, 1.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(4),
//                       gradient: const LinearGradient(
//                         colors: [Colors.blue, Color(0xFFF5F5F5)],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 '${(controller.percentage * 100).toStringAsFixed(1)}% Complete',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogoutButton() {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           colors: [
//             Colors.red.withOpacity(0.8),
//             Colors.red,
//           ],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.red.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: _showLogoutConfirmation,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.logout,
//               color: Colors.white,
//               size: 20,
//             ),
//             SizedBox(width: 8),
//             Text(
//               'Logout',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Color _getUsageColor() {
//     if (controller.percentage >= 0.9) return Colors.red;
//     if (controller.percentage >= 0.7) return Colors.orange;
//     return Colors.green;
//   }
//
//   IconData _getUsageIcon() {
//     if (controller.percentage >= 0.9) return Icons.warning;
//     if (controller.percentage >= 0.7) return Icons.info;
//     return Icons.check_circle;
//   }
//
//   String _getUsageText() {
//     if (controller.percentage >= 0.9) return 'Limit Almost Reached';
//     if (controller.percentage >= 0.7) return 'High Usage';
//     return 'Good Usage';
//   }
// }



/*
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserProfileController controller;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  StreamSubscription<QuerySnapshot>? _productsSubscription;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserProfileController());
    _setupRealTimeListeners();
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    _productsSubscription?.cancel();
    super.dispose();
  }

  void _setupRealTimeListeners() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      _userDataSubscription = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data() as Map<String, dynamic>;
          controller.updateUserDataFromSnapshot(data);
        }
      });

      _productsSubscription = FirebaseFirestore.instance
          .collection('Products')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        if (mounted) {
          final currentEntries = snapshot.docs.length;
          _updateEntriesCount(currentEntries);
        }
      });
    }
  }

  void _updateEntriesCount(int newCount) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .update({'entries': newCount.toString()});
      }
    } catch (e) {
      print('Error updating entries count: $e');
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.primaryLight,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    centerTitle: true,
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.dark,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: controller.isLoading
              ? const Center(
            child: CircularProgressIndicator(color: AppColors.bright),
          )
              : controller.userData == null
              ? _buildErrorState()
              : _buildProfileContent(),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.fetchUserData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bright,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfilePictureSection(),
          const SizedBox(height: 30),
          _buildUserInfoCard(),
          const SizedBox(height: 20),
          _buildStatsCard(),
          const SizedBox(height: 20),
          _buildProgressCard(),
          const SizedBox(height: 30),
          _buildLogoutButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.bright.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
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
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => controller.pickProfileImage(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bright,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
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
    if (controller.profileImage != null) {
      return Image.file(
        File(controller.profileImage!.path),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }

    if (controller.profilePictureUrl.isNotEmpty) {
      return Image.network(
        controller.profilePictureUrl,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.bright,
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
      color: AppColors.bright.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 60,
        color: AppColors.bright.withOpacity(0.7),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Text(
                controller.displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bright.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.email,
                      size: 16,
                      color: AppColors.bright,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.dark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getUsageColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getUsageIcon(),
                      size: 16,
                      color: _getUsageColor(),
                    ),
                    SizedBox(width: 6),
                    Text(
                      _getUsageText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getUsageColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Entries',
                    controller.entries.toString(),
                    Icons.inventory,
                    AppColors.bright,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    'Limit',
                    controller.limit,
                    Icons.flag,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppColors.bright,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Collection Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[200],
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: controller.percentage.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [AppColors.bright, AppColors.primaryLight],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(controller.percentage * 100).toStringAsFixed(1)}% Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.8),
            Colors.red,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _showLogoutConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUsageColor() {
    if (controller.percentage >= 0.9) return Colors.red;
    if (controller.percentage >= 0.7) return Colors.orange;
    return Colors.green;
  }

  IconData _getUsageIcon() {
    if (controller.percentage >= 0.9) return Icons.warning;
    if (controller.percentage >= 0.7) return Icons.info;
    return Icons.check_circle;
  }

  String _getUsageText() {
    if (controller.percentage >= 0.9) return 'Limit Almost Reached';
    if (controller.percentage >= 0.7) return 'High Usage';
    return 'Good Usage';
  }
}

*/

// class UserProfileScreen extends StatefulWidget {
//   const UserProfileScreen({super.key});
//
//   @override
//   State<UserProfileScreen> createState() => _UserProfileScreenState();
// }
//
// class _UserProfileScreenState extends State<UserProfileScreen> {
//   late UserProfileController controller;
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController nameController;
//   late TextEditingController phoneController;
//   late TextEditingController cityController;
//   late TextEditingController bioController;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(UserProfileController());
//
//     // Initialize controllers with current user data
//     nameController = TextEditingController(text: controller.displayName);
//     phoneController = TextEditingController(text: controller.userData?['phone'] ?? '');
//     cityController = TextEditingController(text: controller.userData?['city'] ?? '');
//     bioController = TextEditingController(text: controller.userData?['bio'] ?? '');
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (controller.userData == null) {
//         controller.fetchUserData();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     phoneController.dispose();
//     cityController.dispose();
//     bioController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         // Show loading indicator
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => const Center(
//             child: CircularProgressIndicator(color: Color(0xFF4169E1)),
//           ),
//         );
//
//         // Update user data in database
//         // await controller.updateUserProfile(
//         //   name: nameController.text.trim(),
//         //   phone: phoneController.text.trim(),
//         //   city: cityController.text.trim(),
//         //   bio: bioController.text.trim(),
//         // );
//
//         // Close loading dialog
//         Navigator.pop(context);
//
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile updated successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         // Close loading dialog
//         Navigator.pop(context);
//
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update profile: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: controller.isLoading
//           ? const Center(
//         child: CircularProgressIndicator(color: Color(0xFF4169E1)),
//       )
//           : Container(
//         decoration: const BoxDecoration(
//           color: Color(0xFF0A0E14),
//           image: DecorationImage(
//             image: AssetImage('assets/auth_bg.png'),
//             fit: BoxFit.cover,
//             opacity: 0.3,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 40),
//                   _buildHeader(),
//                   const SizedBox(height: 40),
//                   _buildProfilePictureSection(),
//                   const SizedBox(height: 40),
//                   _buildProfileForm(),
//                   const SizedBox(height: 100),
//                   _buildFooter(),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: _buildFloatingActionButton(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     ));
//   }
//
//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.white,
//                   width: 2,
//                 ),
//               ),
//               child: ClipOval(
//                 child: controller.profilePictureUrl.isNotEmpty
//                     ? Image.network(
//                   controller.profilePictureUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => _buildSmallAvatar(),
//                 )
//                     : _buildSmallAvatar(),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'WELCOME',
//                   style: TextStyle(
//                     color: Color(0xFF9E9E9E),
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   controller.displayName.toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: const Color(0xFF4169E1).withOpacity(0.2),
//             border: Border.all(
//               color: const Color(0xFF4169E1),
//               width: 1.5,
//             ),
//           ),
//           child: const Icon(
//             Icons.person,
//             color: Color(0xFF4169E1),
//             size: 20,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSmallAvatar() {
//     return Container(
//       color: const Color(0xFF4169E1).withOpacity(0.2),
//       child: const Icon(
//         Icons.person,
//         size: 30,
//         color: Color(0xFF4169E1),
//       ),
//     );
//   }
//
//   Widget _buildProfilePictureSection() {
//     return Stack(
//       children: [
//         Container(
//           width: 180,
//           height: 180,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.3),
//               width: 3,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF4169E1).withOpacity(0.3),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(21),
//             child: _buildProfileImage(),
//           ),
//         ),
//         Positioned(
//           bottom: 0,
//           right: 0,
//           child: GestureDetector(
//             onTap: () => controller.showImagePickerOptions(context),
//             child: Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFF4169E1),
//                 border: Border.all(
//                   color: const Color(0xFF0A0E14),
//                   width: 3,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF4169E1).withOpacity(0.5),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.camera_alt,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//           ),
//         ),
//         if (controller.isLoading)
//           Container(
//             width: 180,
//             height: 180,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(24),
//               color: Colors.black.withOpacity(0.5),
//             ),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 3,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildProfileImage() {
//     if (controller.profileImage.value != null) {
//       return Image.file(
//         File(controller.profileImage.value!.path),
//         fit: BoxFit.cover,
//         width: 180,
//         height: 180,
//       );
//     }
//
//     if (controller.profilePictureUrl.isNotEmpty) {
//       return Image.network(
//         controller.profilePictureUrl,
//         fit: BoxFit.cover,
//         width: 180,
//         height: 180,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Container(
//             color: const Color(0xFF1A1F2E),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF4169E1),
//                 strokeWidth: 3,
//               ),
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
//       );
//     }
//
//     return _buildDefaultAvatar();
//   }
//
//   Widget _buildDefaultAvatar() {
//     return Container(
//       color: const Color(0xFF4169E1).withOpacity(0.2),
//       child: const Icon(
//         Icons.person,
//         size: 80,
//         color: Color(0xFF4169E1),
//       ),
//     );
//   }
//
//   Widget _buildProfileForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           _buildGradientField(
//             label: 'NAME',
//             controller: nameController,
//             enabled: true,
//             validator: (val) {
//               if (val?.isEmpty ?? true) {
//                 return 'Please enter your name';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 20),
//           _buildGradientField(
//             label: 'EMAIL ADDRESS',
//             controller: TextEditingController(text: controller.email),
//             enabled: false,
//           ),
//           const SizedBox(height: 20),
//           _buildGradientField(
//             label: 'PHONE',
//             controller: phoneController,
//             enabled: true,
//             keyboardType: TextInputType.phone,
//             validator: (val) {
//               if (val?.isEmpty ?? true) {
//                 return 'Please enter phone number';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 20),
//           _buildGradientField(
//             label: 'CITY',
//             controller: cityController,
//             enabled: true,
//             validator: (val) {
//               if (val?.isEmpty ?? true) {
//                 return 'Please enter city';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 20),
//           _buildGradientField(
//             label: 'BIO',
//             controller: bioController,
//             enabled: true,
//             maxLines: 4,
//           ),
//           const SizedBox(height: 32),
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: ElevatedButton(
//               onPressed: _updateProfile,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF4169E1),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'Update',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGradientField({
//     required String label,
//     required TextEditingController controller,
//     bool enabled = true,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.7),
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 1,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               colors: [
//                 const Color(0xFF4169E1).withOpacity(0.3),
//                 const Color(0xFF00D4FF).withOpacity(0.3),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Container(
//             margin: const EdgeInsets.all(1.5),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0A0E14),
//               borderRadius: BorderRadius.circular(10.5),
//             ),
//             child: TextFormField(
//               controller: controller,
//               enabled: enabled,
//               keyboardType: keyboardType,
//               validator: validator,
//               maxLines: maxLines,
//               style: TextStyle(
//                 color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: maxLines > 1 ? 16 : 12,
//                 ),
//                 hintText: enabled ? 'Enter $label' : '',
//                 hintStyle: TextStyle(
//                   color: Colors.white.withOpacity(0.3),
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFooter() {
//     return Column(
//       children: [
//         const Text(
//           'Think Diecast',
//           style: TextStyle(
//             color: Color(0xFF9E9E9E),
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'Version: 1.5.4 | Build: 200',
//           style: TextStyle(
//             color: Color(0xFF6E7580),
//             fontSize: 10,
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Follow Us On:',
//           style: TextStyle(
//             color: Color(0xFF9E9E9E),
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildSocialIcon(
//               Icons.camera_alt,
//                   () {},
//               const Color(0xFFE4405F),
//             ),
//             const SizedBox(width: 16),
//             _buildSocialIcon(
//               Icons.play_arrow,
//                   () {},
//               const Color(0xFFFF0000),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSocialIcon(IconData icon, VoidCallback onTap, Color color) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: color,
//         ),
//         child: Icon(
//           icon,
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFloatingActionButton() {
//     return Container(
//       width: 64,
//       height: 64,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: const LinearGradient(
//           colors: [Color(0xFF4169E1), Color(0xFF00D4FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF4169E1).withOpacity(0.4),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: FloatingActionButton(
//         onPressed: () {
//           // Add item action
//         },
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         child: const Icon(
//           Icons.add,
//           size: 32,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomNavigationBar() {
//     return Container(
//       height: 70,
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1F2E),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavItem(Icons.home, 'HOME', false),
//           _buildNavItem(Icons.search, 'SEARCH', false),
//           const SizedBox(width: 64),
//           _buildNavItem(Icons.grid_view, 'ITEMS', false),
//           _buildNavItem(Icons.person, 'PROFILE', true),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, bool isActive) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           icon,
//           color: isActive ? const Color(0xFF4169E1) : const Color(0xFF6E7580),
//           size: 24,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             color: isActive ? const Color(0xFF4169E1) : const Color(0xFF6E7580),
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }
