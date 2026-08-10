import 'dart:async';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thinkdiecast/controllers/add_product_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:thinkdiecast/utils/custom_drop_down.dart';
import 'package:thinkdiecast/utils/custom_textfield.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;
  final bool isEditMode;

  const AddProductScreen({super.key, this.productData, this.isEditMode = false});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late AddProductController controller;
  late UserController userController;
  final ValueNotifier<double> _sheetSize = ValueNotifier<double>(0.5);

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddProductController());
    userController = Get.put(UserController());

    if (widget.isEditMode && widget.productData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.populateFieldsForEdit(widget.productData as Map<String, dynamic>? ?? {});
      });
    } else {
      controller.clearFields();
    }
  }

  // ---------------- Profile / plan header (unchanged) ----------------

  Widget _buildProfilePictureSection() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          if (userController.isLoading.value)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)),
              child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (userController.profileImagePath.value.isNotEmpty) {
      return Image.network(
        userController.profileImagePath.value,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.blue.withOpacity(0.1),
      child: Icon(Icons.person, size: 40, color: Colors.blue.withOpacity(0.7)),
    );
  }

  Widget _buildCurrentPlanIcon() {
    String currentPlan = userController.currentUser?.plan?.toString().toUpperCase() ?? 'FREE';
    String planIconPath = _getPlanIconPath(currentPlan);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [AppColors.bright, AppColors.bright2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: AppColors.bright.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Image.asset(
            planIconPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 24),
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

  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/auth_bg.png'), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _sheetSize,
              builder: (context, size, child) {
                return Column(
                  children: [
                    SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
                                    ),
                                    _buildProfilePictureSection(),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('WELCOME',
                                            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        Text(
                                          userController.currentUser?.name ?? 'User',
                                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                _buildCurrentPlanIcon(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Expanded(child: _buildImageUploadSection(size)),
                  ],
                );
              },
            ),
            _buildBottomSheetForm(),
            if (controller.isLoading.value) _buildLoadingOverlay(),
          ],
        ),
      ),
    ));
  }

  // ---------------- Image upload (unchanged) ----------------

  Widget _buildImageUploadSection(double sheetSize) {
    final double dynamicHeight = lerpDouble(280, 120, (sheetSize - 0.5) / (0.9 - 0.5)) ?? 280;
    final double dynamicWidth = lerpDouble(280, 120, (sheetSize - 0.5) / (0.9 - 0.5)) ?? 280;

    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: dynamicHeight,
            width: dynamicWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.grad1Clr.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(24), child: _buildImageContent()),
          ),
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: () {
                setState((){
                  controller.requestPermission(context);
                });
                },
              child: Container(
                height: 60,
                width: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.bright, AppColors.bright]),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderColor, width: 5),
                ),
                child: Image.asset('assets/camera.png', color: Colors.white, height: 28, width: 25, colorBlendMode: BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildImageContent() {
    if (controller.image.value != null) {
      return Stack(
        children: [
          Image.file(File(controller.image.value!.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          if (controller.isUploadingImage.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            _buildRemoveImageButton(),
        ],
      );
    }
    if (widget.isEditMode && controller.existingImageUrl.value.isNotEmpty) {
      return Stack(
        children: [
          Image.network(
            controller.existingImageUrl.value,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(color: AppColors.grad2Clr, strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
          _buildRemoveImageButton(),
        ],
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildRemoveImageButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: () {
          controller.image.value = null;
          controller.existingImageUrl.value = '';
          controller.uploadedImageUrl.value = '';
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), shape: BoxShape.circle),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.grad1Clr.withOpacity(0.2), AppColors.grad2Clr.withOpacity(0.2)]),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_photo_alternate, color: AppColors.grad1Clr, size: 40),
        ),
        const SizedBox(height: 12),
        const Text('Upload Image', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('JPG, PNG (Max 5MB)', style: TextStyle(fontSize: 12, color: Colors.black87.withOpacity(0.6))),
      ],
    );
  }

  // ---------------- Form ----------------

  Widget _buildBottomSheetForm() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            _sheetSize.value = notification.extent;
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, AppColors.primary]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              border: Border(top: BorderSide(color: AppColors.grad1Clr.withOpacity(0.3), width: 2)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 1,
                      decoration: BoxDecoration(color: AppColors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 32),
                    GradientBorderTextField(
                      label: 'MODEL',
                      controller: controller.titleNameController,
                      validator: (val) => val?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    GradientBorderTextField(
                      label: 'DESCRIPTION',
                      controller: controller.descriptionController,
                    ),
                    const SizedBox(height: 14),
                    // BRAND: displays the NAME but its dropdown value is the
                    // id. selectBrandById() sets both selectedBrandId
                    // (required by the backend) and selectedBrand (name).
                    _buildIdDropdown(
                      label: 'BRANDS',
                      options: controller.brands,
                      value: controller.selectedBrandId.value.isEmpty ? null : controller.selectedBrandId.value,
                      onChanged: (val) {
                        setState(() {

                        controller.selectBrandById(val);
                        });
                      }
                    ),
                    const SizedBox(height: 14),
                    // CATEGORY: same pattern as BRAND above.
                    _buildIdDropdown(
                      label: 'CATEGORIES',
                      options: controller.categories,
                      value: controller.selectedCategoryId.value.isEmpty ? null : controller.selectedCategoryId.value,
                      onChanged: (val) {
                        setState(() {
                        controller.selectCategoryById(val);
                        });
                      }
                    ),
                    const SizedBox(height: 14),
                    // TYPE is a fixed, static list — not fetched from an API.
                    _buildStaticDropdown(
                      label: 'TYPE',
                      options: AddProductController.typeOptions,
                      value: controller.selectedType.value.isEmpty ? null : controller.selectedType.value,
                      onChanged: (val) {
                        setState(() {


                      controller.selectedType.value = val ?? '';
                        });}
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNameDropdown(
                            label: 'SCALE',
                            options: controller.scales,
                            value: controller.selectedScale.value.isEmpty ? null : controller.selectedScale.value,
                            onChanged: (val) {
                              setState(() {

                              controller.selectedScale.value = val ?? '';
                              });}

                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: GradientBorderTextField(label: 'COLOR', controller: controller.colorController)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GradientBorderTextField(
                              label: 'YEAR', controller: controller.yearController, keyboardType: TextInputType.number),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GradientBorderTextField(
                              label: 'PRICE', controller: controller.priceController, keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Dropdown whose value is the entity's id, but the label shown is its
  /// name. Used for BRAND and CATEGORY — the backend requires brandId /
  /// categoryId, so the id has to be what's actually selected/sent, while
  /// the person still picks by name.
  Widget _buildIdDropdown({
    required String label,
    required List<Map<String, dynamic>> options,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Obx(() {
      if (controller.isLoadingDropdowns.value) {
        return GradientBorderDropdown(label: label, value: null, items: const [], onChanged: null, hintText: 'Loading...');
      }
      final items = options.map((e) {
        final id = (e['_id'] ?? e['id']).toString();
        final name = (e['name'] ?? '').toString();
        return DropdownMenuItem<String>(value: id, child: Text(name, style: const TextStyle(color: Colors.white)));
      }).toList();
      return GradientBorderDropdown(label: label, value: value, items: items, onChanged: onChanged, hintText: 'Select $label');
    });
  }

  /// Dropdown whose value IS the name itself. Used for SCALE — the product
  /// body stores scale as a plain string, not an id.
  Widget _buildNameDropdown({
    required String label,
    required List<Map<String, dynamic>> options,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Obx(() {
      if (controller.isLoadingDropdowns.value) {
        return GradientBorderDropdown(
            label: label, value: null, items: const [], onChanged: null, hintText: 'Loading...');
      }
      final items = options.map((e) {
        final name = (e['name'] ?? '').toString();
        return DropdownMenuItem<String>(value: name, child: Text(name, style: TextStyle(color: Colors.white),));
      }).toList();
      return GradientBorderDropdown(label: label, value: value, items: items, onChanged: onChanged, hintText: 'Select $label');
    });
  }

  /// Fixed dropdown for TYPE — Bikes / Cars / Trucks / Planes only.
  Widget _buildStaticDropdown({
    required String label,
    required List<String> options,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final items = options.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList();
    return GradientBorderDropdown(label: label, value: value, items: items, onChanged: onChanged, hintText: 'Select $label');
  }

  Widget _buildSubmitButton() {
    return Obx(() => Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [AppColors.grad1Clr, AppColors.grad2Clr], begin: Alignment.centerLeft, end: Alignment.centerRight),
        boxShadow: [BoxShadow(color: AppColors.grad1Clr.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: (controller.isLoading.value || controller.isUploadingImage.value) ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bright,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.isLoading.value)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            Text(
              widget.isEditMode ? 'Update' : 'Save',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.grad1Clr, AppColors.grad2Clr]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            const Text('Processing...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (widget.isEditMode) {
      await controller.updateProduct(widget.productData!['id'] ?? widget.productData!['_id'], context);
    } else {
      await controller.addProduct(context);
    }
  }
}

///
/// Latest
// class AddProductScreen extends StatefulWidget {
//   // final DocumentSnapshot? productData;
//   final Map<String, dynamic>? productData;
//   final bool isEditMode;
//
//   const AddProductScreen({
//     super.key,
//     this.productData,
//     this.isEditMode = false,
//   });
//
//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }
//
// class _AddProductScreenState extends State<AddProductScreen> {
//   late AddProductController controller;
//   late UserController userController;
//   final ValueNotifier<double> _sheetSize = ValueNotifier<double>(0.5);
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(AddProductController());
//     userController = Get.put(UserController());
//
//     if (widget.isEditMode && widget.productData != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _populateFieldsForEdit();
//       });
//     } else {
//       controller.clearFields();
//     }
//   }
//
//   void _populateFieldsForEdit() {
//     final data = widget.productData as Map<String, dynamic>? ?? {};
//     controller.populateFieldsForEdit(data);
//   }
//
//
//   Widget _buildProfilePictureSection() {
//     return Container(
//       height: 60,
//       width: 60,
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
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white,
//                 width: 2,
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
//           // Positioned(
//           //   bottom: 0,
//           //   right: 0,
//           //   child: GestureDetector(
//           //     onTap: () => controller.showImagePickerOptions(context),
//           //     child: Container(
//           //       padding: const EdgeInsets.all(8),
//           //       decoration: BoxDecoration(
//           //         color: Colors.blue,
//           //         shape: BoxShape.circle,
//           //         border: Border.all(
//           //           color: Colors.white,
//           //           width: 2,
//           //         ),
//           //         boxShadow: [
//           //           BoxShadow(
//           //             color: Colors.black.withOpacity(0.2),
//           //             blurRadius: 8,
//           //             offset: const Offset(0, 2),
//           //           ),
//           //         ],
//           //       ),
//           //       child: const Icon(
//           //         Icons.camera_alt,
//           //         color: Colors.white,
//           //         size: 16,
//           //       ),
//           //     ),
//           //   ),
//           // ),
//           if (userController.isLoading.value)
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
//     if (userController.profileImagePath.value.isNotEmpty) {
//       return Image.network(
//         userController.profileImagePath.value,
//         fit: BoxFit.cover,
//         width: 60,
//         height: 60,
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
//         size: 40,
//         color: Colors.blue.withOpacity(0.7),
//       ),
//     );
//   }
//
//   Widget _buildCurrentPlanIcon() {
//     String currentPlan = userController.currentUser?.plan?.toString().toUpperCase() ?? 'FREE';
//     String planIconPath = _getPlanIconPath(currentPlan);
//
//     return Container(
//       width: 40,
//       height: 40,
//
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: const LinearGradient(
//           colors: [
//             AppColors.bright,
//             AppColors.bright2,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.bright.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(5),
//         child: Center(
//           child: Image.asset(
//             planIconPath,
//             width: 28,
//             height: 28,
//             // color: Colors.white,
//             errorBuilder: (context, error, stackTrace) {
//               return const Icon(
//                 Icons.person,
//                 color: Colors.white,
//                 size: 24,
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getPlanIconPath(String planName) {
//     switch (planName) {
//       case 'NOOB':
//         return 'assets/noob.png';
//       case 'PRO':
//         return 'assets/pro.png';
//       case 'LEGEND':
//         return 'assets/legend.png';
//       case 'COLLECTOR':
//         return 'assets/collector.png';
//       case 'FREE':
//       default:
//         return 'assets/free.png';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/auth_bg.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Stack(
//           children: [
//             ValueListenableBuilder<double>(
//               valueListenable: _sheetSize,
//               builder: (context, size, child) {
//                 return Column(
//                   children: [
//                     SafeArea(
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [
//                                     IconButton(onPressed: (){
//                                       Navigator.pop(context);
//                                     },
//                                         icon: Icon(Icons.arrow_back_ios, color: AppColors.white,)),
//                                     // const SizedBox(width: 8,),
//                                     _buildProfilePictureSection(),
//                                     const SizedBox(width: 8,),
//                                     Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         const Text(
//                                           'WELCOME',
//                                           style: TextStyle(
//                                             color: Color(0xFF9E9E9E),
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                             letterSpacing: 1,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           userController.currentUser?.name ?? 'User',
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 2,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//
//                                 _buildCurrentPlanIcon()
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: _buildImageUploadSection(size),
//                     ),
//                   ],
//                 );
//               },
//             ),
//             _buildBottomSheetForm(),
//             if (controller.isLoading.value) _buildLoadingOverlay(),
//           ],
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//                 child: ClipOval(
//                   child: userController.profileImagePath.isNotEmpty
//                       ? Image.network(
//                     userController.profileImagePath.toString(),
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) =>
//                         _buildDefaultAvatar(),
//                   )
//                       : _buildDefaultAvatar(),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.isEditMode ? 'EDIT' : 'ADD NEW',
//                     style: const TextStyle(
//                       color: Color(0xFF9E9E9E),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.isEditMode ? 'PRODUCT' : 'COLLECTIBLE',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.grad1Clr, width: 2),
//                 color: Colors.white.withOpacity(0.1),
//               ),
//               child: const Icon(
//                 Icons.close,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   Widget _buildImageUploadSection(double sheetSize) {
//     // Dynamic height based on sheet position
//     // sheetSize range: 0.5 (min) to 0.9 (max)
//     // height range: 280 (when sheet 0.5) to 120 (when sheet 0.9)
//     final double dynamicHeight = lerpDouble(280, 120, (sheetSize - 0.5) / (0.9 - 0.5)) ?? 280;
//     final double dynamicWidth = lerpDouble(280, 120, (sheetSize - 0.5) / (0.9 - 0.5)) ?? 280;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 100),
//             height: dynamicHeight,
//             width: dynamicWidth,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.grad1Clr.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(24),
//               child: _buildImageContent(),
//             ),
//           ),
//           Positioned(
//             top: -10,
//             right: -10,
//             child: GestureDetector(
//               onTap: () => controller.requestPermission(context),
//               child: Container(
//                 height: 60,
//                 width: 60,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [AppColors.bright, AppColors.bright],
//                   ),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: AppColors.borderColor, width: 5),
//
//                 ),
//
//                 child:
//                 Image.asset('assets/camera.png',
//                   color: Colors.white,
//                   height: 28,
//                   width: 25,
//                   // Changes the color of the image
//                   colorBlendMode: BlendMode.srcIn,
//                 ),
//               ),
//
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImageContent() {
//     if (controller.image.value != null) {
//       return Stack(
//         children: [
//           Image.file(
//             File(controller.image.value!.path),
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           ),
//           Positioned(
//             top: 8,
//             right: 8,
//             child: GestureDetector(
//               onTap: () {
//                 controller.image.value = null;
//                 controller.existingImageUrl.value = '';
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.9),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.close,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//
//     if (widget.isEditMode && controller.existingImageUrl.value.isNotEmpty) {
//       return Stack(
//         children: [
//           Image.network(
//             controller.existingImageUrl.value,
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Container(
//                 color: Colors.grey[200],
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     color: AppColors.grad2Clr,
//                     strokeWidth: 2,
//                   ),
//                 ),
//               );
//             },
//             errorBuilder: (context, error, stackTrace) {
//               return _buildPlaceholder();
//             },
//           ),
//           Positioned(
//             top: 8,
//             right: 8,
//             child: GestureDetector(
//               onTap: () {
//                 controller.image.value = null;
//                 controller.existingImageUrl.value = '';
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.9),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.close,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//
//     return _buildPlaceholder();
//   }
//
//   Widget _buildPlaceholder() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 AppColors.grad1Clr.withOpacity(0.2),
//                 AppColors.grad2Clr.withOpacity(0.2),
//               ],
//             ),
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(
//             Icons.add_photo_alternate,
//             color: AppColors.grad1Clr,
//             size: 40,
//           ),
//         ),
//         const SizedBox(height: 12),
//         const Text(
//           'Upload Image',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'JPG, PNG (Max 5MB)',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.black87.withOpacity(0.6),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBottomSheetForm() {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.3,
//       minChildSize: 0.3,
//       maxChildSize: 0.8,
//       builder: (context, scrollController) {
//         return NotificationListener<DraggableScrollableNotification>(
//           onNotification: (notification) {
//             _sheetSize.value = notification.extent;
//             return true;
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   AppColors.primary,
//                   AppColors.primary,
//                 ],
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(32),
//                 topRight: Radius.circular(32),
//               ),
//               border: Border(
//                 top: BorderSide(
//                   color: AppColors.grad1Clr.withOpacity(0.3),
//                   width: 2,
//                 ),
//               ),
//             ),
//             child: SingleChildScrollView(
//               controller: scrollController,
//               padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
//               child: Form(
//                 key: controller.formKey,
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 74,
//                       height: 1,
//                       decoration: BoxDecoration(
//                         color: AppColors.white.withOpacity(0.6),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     GradientBorderTextField(
//                       label: 'MODEL',
//                       controller: controller.titleNameController,
//                       validator: (val) => val?.isEmpty == true ? 'Required' : null,
//                     ),
//                     const SizedBox(height: 14),
//                     _buildGradientDropdown(
//                         label: 'BRAND',
//                         collection: 'Brand',
//                         value: controller.selectedBrand.value.isEmpty
//                             ? null
//                             : controller.selectedBrand.value,
//                         onChanged: (val) { setState(() {
//                           controller.selectedBrand.value = val ?? '';
//                         });}
//                     ),
//                     const SizedBox(height: 14),
//                     _buildGradientDropdown(
//                         label: 'TYPE',
//                         collection: 'Type',
//                         value: controller.selectedType.value.isEmpty
//                             ? null
//                             : controller.selectedType.value,
//                         onChanged: (val) { setState(() {
//                           controller.selectedType.value = val ?? '';
//                         });}
//                     ),
//                     const SizedBox(height: 14),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildGradientDropdown(
//                               label: 'SCALE',
//                               collection: 'Scale',
//                               value: controller.selectedScale.value.isEmpty
//                                   ? null
//                                   : controller.selectedScale.value,
//                               onChanged: (val) {
//                                 setState(() {
//                                   controller.selectedScale.value = val ?? '';
//                                 });
//
//
//                               }
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: GradientBorderTextField(
//                             label: 'COLOR',
//                             controller: controller.colorController,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 14),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: GradientBorderTextField(
//                             label: 'YEAR',
//                             controller: controller.yearController,
//                             keyboardType: TextInputType.number,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: GradientBorderTextField(
//                             label: 'PRICE',
//                             controller: controller.priceController,
//                             keyboardType: TextInputType.number,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 40),
//                     _buildSubmitButton(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildGradientDropdown({
//     required String label,
//     required String collection,
//     String? value,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection(collection).snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return GradientBorderDropdown(
//             label: label,
//             value: null,
//             items: const [],
//             onChanged: null,
//             hintText: 'Loading...',
//           );
//         }
//
//         final items = snapshot.data!.docs.map((doc) {
//           return DropdownMenuItem<String>(
//             value: doc['name'] as String,
//             child: Text(doc['name'] as String),
//           );
//         }).toList();
//
//         return GradientBorderDropdown(
//           label: label,
//           value: value,
//           items: items,
//           onChanged: onChanged,
//           hintText: 'Select $label',
//         );
//       },
//     );
//   }
//   Widget _buildSubmitButton() {
//     return Obx(() => Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),
//         gradient: const LinearGradient(
//           colors: [AppColors.grad1Clr, AppColors.grad2Clr],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.grad1Clr.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: controller.isLoading.value ? null : _handleSubmit,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.bright,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(28),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (controller.isLoading.value)
//               const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               ),
//             // else
//             //   Icon(
//             //     widget.isEditMode ? Icons.check_circle : Icons.add_circle,
//             //     color: Colors.white,
//             //     size: 22,
//             //   ),
//             // const SizedBox(width: 10),
//             Text(
//               widget.isEditMode ?
//               'Update'
//                   :  'Save',
//               style:  TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 letterSpacing: 1.2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildLoadingOverlay() {
//     return Container(
//       color: Colors.black.withOpacity(0.7),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.grad1Clr, AppColors.grad2Clr],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 3,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Processing...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _handleSubmit() async {
//     if (widget.isEditMode) {
//       await controller.updateProduct(widget.productData!['id'], context);
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context, true);
//       }
//     } else {
//       await controller.addProduct(context);
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context, true);
//       }
//     }
//   }
// }
///
/// Latest
/*
class AddProductScreen extends StatefulWidget {
  final DocumentSnapshot? productData;
  final bool isEditMode;

  const AddProductScreen({
    super.key,
    this.productData,
    this.isEditMode = false,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late AddProductController controller;
  late UserProfileController userController;
  final ValueNotifier<double> _sheetSize = ValueNotifier<double>(0.5);

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddProductController());
    userController = Get.put(UserProfileController());

    if (widget.isEditMode && widget.productData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateFieldsForEdit();
      });
    }else{
      controller.clearFields();
    }
  }

  void _populateFieldsForEdit() {
    final data = widget.productData!.data() as Map<String, dynamic>;
    controller.populateFieldsForEdit(data);
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
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: GestureDetector(
          //     onTap: () => controller.showImagePickerOptions(context),
          //     child: Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: Colors.blue,
          //         shape: BoxShape.circle,
          //         border: Border.all(
          //           color: Colors.white,
          //           width: 2,
          //         ),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.2),
          //             blurRadius: 8,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: const Icon(
          //         Icons.camera_alt,
          //         color: Colors.white,
          //         size: 16,
          //       ),
          //     ),
          //   ),
          // ),
          if (userController.isLoading)
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
    if (userController.profileImage.value != null) {
      return Image.file(
        File(userController.profileImage.value!.path),
        fit: BoxFit.cover,
        width: 60,
        height: 60,
      );
    }

    if (userController.profilePictureUrl.isNotEmpty) {
      return Image.network(
        userController.profilePictureUrl,
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
    String currentPlan = userController.userData?['plan']?.toString().toUpperCase() ?? 'FREE';
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

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/auth_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _sheetSize,
              builder: (context, size, child) {
                return Column(
                  children: [
                    SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(onPressed: (){
                                      Navigator.pop(context);
                                    },
                                        icon: Icon(Icons.arrow_back_ios, color: AppColors.white,)),
                                    // const SizedBox(width: 8,),
                                    _buildProfilePictureSection(),
                                    const SizedBox(width: 8,),
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
                                          userController.displayName,
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildImageUploadSection(size),
                    ),
                  ],
                );
              },
            ),
            _buildBottomSheetForm(),
            if (controller.isLoading.value) _buildLoadingOverlay(),
          ],
        ),
      ),
    ));
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: userController.profilePictureUrl.isNotEmpty
                      ? Image.network(
                    userController.profilePictureUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultAvatar(),
                  )
                      : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEditMode ? 'EDIT' : 'ADD NEW',
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isEditMode ? 'PRODUCT' : 'COLLECTIBLE',
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grad1Clr, width: 2),
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildImageUploadSection(double sheetSize) {
    // Dynamic height based on sheet position
    // sheetSize range: 0.5 (min) to 0.9 (max)
    // height range: 280 (when sheet 0.5) to 120 (when sheet 0.9)
    final double dynamicHeight = lerpDouble(280, 120, (sheetSize - 0.5) / (0.9 - 0.5)) ?? 280;
    final double dynamicWidth = lerpDouble(280, 120, (sheetSize - 0.5) / (0.9 - 0.5)) ?? 280;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: dynamicHeight,
            width: dynamicWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grad1Clr.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildImageContent(),
            ),
          ),
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: () => controller.requestPermission(context),
              child: Container(
                height: 60,
                width: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.bright, AppColors.bright],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderColor, width: 5),

                ),

                child:
                Image.asset('assets/camera.png',
                color: Colors.white,
                  height: 28,
                    width: 25,
             // Changes the color of the image
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (controller.image.value != null) {
      return Stack(
        children: [
          Image.file(
            File(controller.image.value!.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                controller.image.value = null;
                controller.existingImageUrl.value = '';
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.isEditMode && controller.existingImageUrl.value.isNotEmpty) {
      return Stack(
        children: [
          Image.network(
            controller.existingImageUrl.value,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.grad2Clr,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                controller.image.value = null;
                controller.existingImageUrl.value = '';
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.grad1Clr.withOpacity(0.2),
                AppColors.grad2Clr.withOpacity(0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate,
            color: AppColors.grad1Clr,
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Upload Image',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG (Max 5MB)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheetForm() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            _sheetSize.value = notification.extent;
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.grad1Clr.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 1,
                      decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GradientBorderTextField(
                      label: 'MODEL',
                      controller: controller.titleNameController,
                      validator: (val) => val?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildGradientDropdown(
                      label: 'BRAND',
                      collection: 'Brand',
                      value: controller.selectedBrand.value.isEmpty
                          ? null
                          : controller.selectedBrand.value,
                      onChanged: (val) { setState(() {
                        controller.selectedBrand.value = val ?? '';
                      });}
                    ),
                    const SizedBox(height: 14),
                    _buildGradientDropdown(
                      label: 'TYPE',
                      collection: 'Type',
                      value: controller.selectedType.value.isEmpty
                          ? null
                          : controller.selectedType.value,
                      onChanged: (val) { setState(() {
                        controller.selectedType.value = val ?? '';
                      });}
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGradientDropdown(
                            label: 'SCALE',
                            collection: 'Scale',
                            value: controller.selectedScale.value.isEmpty
                                ? null
                                : controller.selectedScale.value,
                            onChanged: (val) {
                              setState(() {
                                controller.selectedScale.value = val ?? '';
                              });


                            }
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GradientBorderTextField(
                            label: 'COLOR',
                            controller: controller.colorController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GradientBorderTextField(
                            label: 'YEAR',
                            controller: controller.yearController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GradientBorderTextField(
                            label: 'PRICE',
                            controller: controller.priceController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientDropdown({
    required String label,
    required String collection,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GradientBorderDropdown(
            label: label,
            value: null,
            items: const [],
            onChanged: null,
            hintText: 'Loading...',
          );
        }

        final items = snapshot.data!.docs.map((doc) {
          return DropdownMenuItem<String>(
            value: doc['name'] as String,
            child: Text(doc['name'] as String),
          );
        }).toList();

        return GradientBorderDropdown(
          label: label,
          value: value,
          items: items,
          onChanged: onChanged,
          hintText: 'Select $label',
        );
      },
    );
  }
  Widget _buildSubmitButton() {
    return Obx(() => Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.grad1Clr, AppColors.grad2Clr],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grad1Clr.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bright,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.isLoading.value)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            // else
            //   Icon(
            //     widget.isEditMode ? Icons.check_circle : Icons.add_circle,
            //     color: Colors.white,
            //     size: 22,
            //   ),
            // const SizedBox(width: 10),
            Text(
              widget.isEditMode ?
                  'Update'
            :  'Save',
              style:  TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.grad1Clr, AppColors.grad2Clr],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Processing...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (widget.isEditMode) {
      await controller.updateProduct(widget.productData!.id, context);
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      await controller.addProduct(context);
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }
  }
}
*/

// class AddProductScreen extends StatefulWidget {
//   final DocumentSnapshot? productData;
//   final bool isEditMode;
//
//   const AddProductScreen({
//     super.key,
//     this.productData,
//     this.isEditMode = false,
//   });
//
//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }
//
// class _AddProductScreenState extends State<AddProductScreen> {
//   late AddProductController controller;
//   late UserProfileController userController;
//   final ValueNotifier<double> _sheetSize = ValueNotifier<double>(0.45);
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(AddProductController());
//     userController = Get.put(UserProfileController());
//
//     if (widget.isEditMode && widget.productData != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _populateFieldsForEdit();
//       });
//     }
//   }
//
//   void _populateFieldsForEdit() {
//     final data = widget.productData!.data() as Map<String, dynamic>;
//     controller.populateFieldsForEdit(data);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Scaffold(
//       backgroundColor: const Color(0xFF0A0E14),
//       body: Stack(
//         children: [
//           _buildBackgroundShapes(),
//           ValueListenableBuilder<double>(
//             valueListenable: _sheetSize,
//             builder: (context, size, child) {
//               return Column(
//                 children: [
//                   SafeArea(child: const GlobalHeader()),
//                   Expanded(
//                     child: Center(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 20),
//                             _buildImageUploadSection(size),
//                             const SizedBox(height: 40),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//           _buildBottomSheetForm(),
//           if (controller.isLoading.value) _buildLoadingOverlay(),
//         ],
//       ),
//     ));
//   }
//
//   Widget _buildBackgroundShapes() {
//     return Stack(
//       children: [
//         Positioned(
//           top: -100,
//           right: -80,
//           child: Container(
//             width: 200,
//             height: 200,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.05),
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 200,
//           left: -120,
//           child: Container(
//             width: 300,
//             height: 300,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.03),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBottomSheetForm() {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.45,
//       minChildSize: 0.45,
//       maxChildSize: 0.9,
//       builder: (context, scrollController) {
//         return NotificationListener<DraggableScrollableNotification>(
//           onNotification: (notification) {
//             _sheetSize.value = notification.extent;
//             return true;
//           },
//           child: Container(
//             decoration: const BoxDecoration(
//               color: Color(0xFF131B32),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(32),
//                 topRight: Radius.circular(32),
//               ),
//             ),
//             child: SingleChildScrollView(
//               controller: scrollController,
//               padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
//               child: Form(
//                 key: controller.formKey,
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     GradientBorderTextField(
//                       label: 'MODEL',
//                       controller: controller.titleNameController,
//                       validator: (val) => val?.isEmpty == true ? 'Required' : null,
//                     ),
//                     const SizedBox(height: 24),
//                     _buildGradientDropdown(
//                       label: 'BRAND',
//                       collection: 'Brand',
//                       value: controller.selectedBrand.value.isEmpty ? null : controller.selectedBrand.value,
//                       onChanged: (val) => controller.selectedBrand.value = val ?? '',
//                     ),
//                     const SizedBox(height: 24),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildGradientDropdown(
//                             label: 'SCALE',
//                             collection: 'Scale',
//                             value: controller.selectedScale.value.isEmpty ? null : controller.selectedScale.value,
//                             onChanged: (val) => controller.selectedScale.value = val ?? '',
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: GradientBorderTextField(
//                             label: 'COLOR',
//                             controller: controller.colorController,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: GradientBorderTextField(
//                             label: 'YEAR',
//                             controller: controller.yearController,
//                             keyboardType: TextInputType.number,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: GradientBorderTextField(
//                             label: 'PRICE',
//                             controller: controller.priceController,
//                             keyboardType: TextInputType.number,
//                             // prefix: '₹ ',
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 40),
//                     _buildSubmitButton(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildGradientDropdown({
//     required String label,
//     required String collection,
//     String? value,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return GradientBorderField(
//       label: label,
//       child: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection(collection).snapshots(),
//         builder: (context, snapshot) {
//           return DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: value,
//               isExpanded: true,
//               dropdownColor: const Color(0xFF131B32),
//               icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4A68FF)),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//               items: snapshot.hasData
//                   ? snapshot.data!.docs.map((doc) {
//                 return DropdownMenuItem(
//                   value: doc['name'] as String,
//                   child: Text(doc['name'] as String),
//                 );
//               }).toList()
//                   : [],
//               onChanged: onChanged,
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildImageUploadSection(double sheetSize) {
//     // sheetSize range: 0.45 (min) to 0.9 (max)
//     // height range: ~350 (when sheet 0.45) to ~150 (when sheet 0.9)
//     final double dynamicHeight = lerpDouble(350, 150, (sheetSize - 0.45) / (0.9 - 0.45)) ?? 320;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 100),
//             height: dynamicHeight,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(24),
//               child: _buildImageContent(),
//             ),
//           ),
//           Positioned(
//             top: 20,
//             right: -20,
//             child: GestureDetector(
//               onTap: () => controller.requestPermission(context),
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF4A68FF),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF4A68FF).withOpacity(0.4),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   return Obx(() => Scaffold(
//   //     backgroundColor: const Color(0xFFF5F5F5),
//   //     appBar: _buildAppBar(),
//   //     body: Stack(
//   //       children: [
//   //         _buildBody(),
//   //         if (controller.isLoading.value) _buildLoadingOverlay(),
//   //       ],
//   //     ),
//   //   ));
//   // }
//
// /*  PreferredSizeWidget _buildAppBar() {
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
//               title: Text(
//                 widget.isEditMode ? 'Edit Product' : 'Add New Product',
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               centerTitle: true,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // USING THE EntryLimitWidget HERE
//           if (!widget.isEditMode)
//             EntryLimitWidget(
//               showUpgradeButton: true,
//               onUpgradePressed: () {
//                 // Navigate to membership screen
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const MembershipScreen(showButton: false),
//                   ),
//                 );
//               },
//             ),
//
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: controller.formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildImageUploadSection(),
//                   const SizedBox(height: 24),
//
//                   _buildTextField(
//                     label: 'Product Title',
//                     controller: controller.titleNameController,
//                     validator: (val) => val?.isEmpty == true ? 'Please enter product title' : null,
//                     icon: Icons.title,
//                   ),
//                   const SizedBox(height: 24),
//
//                   _buildDropdownField(
//                     label: 'Brand',
//                     collection: 'Brand',
//                     value: controller.selectedBrand.value.isEmpty ? null : controller.selectedBrand.value,
//                     onChanged: (value) => controller.selectedBrand.value = value ?? '',
//                     icon: Icons.branding_watermark,
//                   ),
//                   const SizedBox(height: 24),
//
//                   _buildDropdownField(
//                     label: 'Scale',
//                     collection: 'Scale',
//                     value: controller.selectedScale.value.isEmpty ? null : controller.selectedScale.value,
//                     onChanged: (value) => controller.selectedScale.value = value ?? '',
//                     icon: Icons.straighten,
//                   ),
//                   const SizedBox(height: 24),
//
//                   _buildTextField(
//                     label: 'Year',
//                     controller: controller.yearController,
//                     keyboardType: TextInputType.number,
//                     maxLength: 4,
//                     validator: (val) => val?.isEmpty == true || (val?.length ?? 0) < 4
//                         ? 'Please enter valid year' : null,
//                     icon: Icons.calendar_today,
//                   ),
//                   const SizedBox(height: 24),
//
//                   _buildDropdownField(
//                     label: 'Category',
//                     collection: 'Category',
//                     value: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
//                     onChanged: (value) => controller.selectedCategory.value = value ?? '',
//                     icon: Icons.category,
//                   ),
//                   const SizedBox(height: 24),
//
//                   _buildTextField(
//                     label: 'Color',
//                     controller: controller.colorController,
//                     validator: (val) => val?.isEmpty == true ? 'Please enter color' : null,
//                     icon: Icons.palette,
//                   ),
//                   const SizedBox(height: 24),
//
//                   _buildTextField(
//                     label: 'Price',
//                     controller: controller.priceController,
//                     keyboardType: TextInputType.number,
//                     validator: (val) => val?.isEmpty == true ? 'Please enter price' : null,
//                     icon: Icons.attach_money,
//                     prefix: '₹ ',
//                   ),
//                   const SizedBox(height: 40),
//
//                   _buildSubmitButton(),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }*/
//
//   // Widget _buildImageUploadSection() {
//   //   return Obx(() => Container(
//   //     width: double.infinity,
//   //     height: 200,
//   //     decoration: BoxDecoration(
//   //       borderRadius: BorderRadius.circular(16),
//   //       border: Border.all(color: Colors.grey.withOpacity(0.3)),
//   //       color: Colors.white,
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.05),
//   //           blurRadius: 10,
//   //           offset: const Offset(0, 2),
//   //         ),
//   //       ],
//   //     ),
//   //     child: InkWell(
//   //       onTap: () => controller.requestPermission(context),
//   //       borderRadius: BorderRadius.circular(16),
//   //       child: Stack(
//   //         children: [
//   //           Container(
//   //             width: double.infinity,
//   //             padding: const EdgeInsets.all(20),
//   //             child: _buildImageContent(),
//   //           ),
//   //           if (controller.image.value != null || controller.existingImageUrl.value.isNotEmpty)
//   //             Positioned(
//   //               top: 8,
//   //               right: 8,
//   //               child: Row(
//   //                 mainAxisSize: MainAxisSize.min,
//   //                 children: [
//   //                   GestureDetector(
//   //                     onTap: () => controller.requestPermission(context),
//   //                     child: Container(
//   //                       padding: const EdgeInsets.all(6),
//   //                       decoration: BoxDecoration(
//   //                         color: Colors.blue.withOpacity(0.9),
//   //                         shape: BoxShape.circle,
//   //                       ),
//   //                       child: const Icon(
//   //                         Icons.edit,
//   //                         color: Colors.white,
//   //                         size: 16,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                   const SizedBox(width: 8),
//   //                   GestureDetector(
//   //                     onTap: () {
//   //                       controller.image.value = null;
//   //                       controller.existingImageUrl.value = '';
//   //                     },
//   //                     child: Container(
//   //                       padding: const EdgeInsets.all(6),
//   //                       decoration: BoxDecoration(
//   //                         color: Colors.red.withOpacity(0.9),
//   //                         shape: BoxShape.circle,
//   //                       ),
//   //                       child: const Icon(
//   //                         Icons.close,
//   //                         color: Colors.white,
//   //                         size: 16,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //         ],
//   //       ),
//   //     ),
//   //   ));
//   // }
//
//   Widget _buildImageContent() {
//     if (controller.image.value != null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Image.file(
//           File(controller.image.value!.path),
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: double.infinity,
//         ),
//       );
//     }
//
//     if (widget.isEditMode && controller.existingImageUrl.value.isNotEmpty) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Image.network(
//           controller.existingImageUrl.value,
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: double.infinity,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Container(
//               color: Colors.grey[200],
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.blue,
//                   strokeWidth: 2,
//                 ),
//               ),
//             );
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return Container(
//               color: Colors.grey[200],
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.error_outline,
//                     color: Colors.red,
//                     size: 40,
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Failed to load image',
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton(
//                     onPressed: () => controller.requestPermission(context),
//                     child: const Text(
//                       'Upload New Image',
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       );
//     }
//
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.blue.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(
//             Icons.add_photo_alternate,
//             color: Colors.blue,
//             size: 40,
//           ),
//         ),
//         const SizedBox(height: 12),
//         const Text(
//           'Tap to upload image',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.black87,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'JPG, PNG (Max 5MB)',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.black87.withOpacity(0.6),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     TextInputType? keyboardType,
//     int? maxLength,
//     String? Function(String?)? validator,
//     required IconData icon,
//     String? prefix,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 16, color: Colors.black87),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           height: 56,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.white,
//             border: Border.all(color: Colors.grey.withOpacity(0.3)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: TextFormField(
//             controller: controller,
//             keyboardType: keyboardType,
//             maxLength: maxLength,
//             validator: validator,
//             decoration: InputDecoration(
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               counterText: '',
//               prefixText: prefix,
//               prefixStyle: const TextStyle(
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 16,
//               ),
//               hintText: 'Enter $label',
//               hintStyle: TextStyle(
//                 color: Colors.black87.withOpacity(0.5),
//                 fontSize: 16,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.black87,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDropdownField({
//     required String label,
//     required String collection,
//     String? value,
//     required ValueChanged<String?> onChanged,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 16, color: Colors.black87),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           height: 56,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.white,
//             border: Border.all(color: Colors.grey.withOpacity(0.3)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance.collection(collection).snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Loading $label...',
//                         style: TextStyle(
//                           color: Colors.black87.withOpacity(0.5),
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               return DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   isExpanded: true,
//                   value: value,
//                   hint: Text(
//                     'Select $label',
//                     style: TextStyle(
//                       color: Colors.black87.withOpacity(0.5),
//                       fontSize: 16,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                   icon: const Icon(
//                     Icons.keyboard_arrow_down,
//                     color: Colors.black87,
//                     size: 20,
//                   ),
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   dropdownColor: Colors.white,
//                   items: snapshot.data!.docs.map<DropdownMenuItem<String>>((doc) {
//                     return DropdownMenuItem<String>(
//                       value: doc['name'],
//                       child: Text(
//                         doc['name'],
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: onChanged,
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSubmitButton() {
//     return Obx(() => Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           colors: [Colors.blue, Colors.blue.shade700],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: controller.isLoading.value ? null : _handleSubmit,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (controller.isLoading.value)
//               const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             else
//               Icon(
//                 widget.isEditMode ? Icons.update : Icons.add,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             const SizedBox(width: 8),
//             Text(
//               widget.isEditMode ? 'Update Product' : 'Add Product',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildLoadingOverlay() {
//     return Container(
//       color: Colors.black.withOpacity(0.3),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.blue),
//             SizedBox(height: 16),
//             Text(
//               'Processing...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _handleSubmit() async {
//     if (widget.isEditMode) {
//       await controller.updateProduct(widget.productData!.id, context);
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context, true);
//       }
//     } else {
//       await controller.addProduct(context);
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context, true);
//       }
//     }
//   }
// }


