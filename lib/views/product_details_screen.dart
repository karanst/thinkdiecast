import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thinkdiecast/controllers/add_product_controller.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/shrink_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:thinkdiecast/views/add_product_screen.dart';
import 'package:thinkdiecast/utils/widgets.dart';

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*class ProductDetailsScreen extends StatefulWidget {
  final ProductGroup productGroup;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ProductDetailsScreen({
    super.key,
    required this.productGroup,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late UserProfileController userController;
  final ValueNotifier<double> _sheetSize = ValueNotifier<double>(0.5);
  bool show = false;

  @override
  void initState() {
    super.initState();
    userController = Get.put(UserProfileController());
  }

  @override
  void dispose() {
    _sheetSize.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context) {
    if (widget.productGroup.count > 1) {
      _showDeleteMultipleDialog(context);
    } else {
      _showDeleteSingleDialog(context);
    }
  }

  void _showDeleteSingleDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Delete Item',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete this item?',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Item: ${widget.productGroup.displayName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
                Navigator.of(context).pop();
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteMultipleDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(
                'Delete ${widget.productGroup.displayName}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This product has ${widget.productGroup.count} items. Do you want to delete:',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                '• Just one item',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                '• All ${widget.productGroup.count} items',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
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
                Navigator.of(context).pop();
                _deleteOne();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete One',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Delete All (${widget.productGroup.count})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteOne() {
    AddProductController.deleteProduct(
      widget.productGroup.representativeProduct.id,
      context,
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
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
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          if (userController.isLoading)
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
    if (userController.profileImage.value != null) {
      return Image.file(
        File(userController.profileImage.value!.path),
        fit: BoxFit.cover,
      );
    }

    if (userController.profilePictureUrl.isNotEmpty) {
      return Image.network(
        userController.profilePictureUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
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
        ),
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCurrentPlanIcon() {
    String currentPlan =
        userController.userData?['plan']?.toString().toUpperCase() ?? 'FREE';
    String planIconPath = _getPlanIconPath(currentPlan);

    return Container(
      width: 40,
      height: 40,
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
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Image.asset(
            planIconPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, color: Colors.white, size: 24);
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
    return Scaffold(
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
                          _buildHeader(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildProductImageSection(size),
                    ),
                  ],
                );
              },
            ),
            _buildBottomSheetDetails(),
          ],
        ),
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
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.white,),
                onPressed: () => Navigator.pop(context),
              ),
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
          _buildCurrentPlanIcon(),
        ],
      ),
    );
  }

  Widget _buildProductImageSection(double sheetSize) {
    final double dynamicHeight =
        lerpDouble(280, 120, (sheetSize - 0.5) / (0.8 - 0.5)) ?? 280;
    final double dynamicWidth =
        lerpDouble(280, 120, (sheetSize - 0.5) / (0.8 - 0.5)) ?? 280;

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
              child: Image.network(
                widget.productGroup.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.grad1Clr,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          // Positioned(
          //   top: -10,
          //   right: -10,
          //   child: Row(
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           Navigator.of(context).pop();
          //           if (widget.onEdit != null) {
          //             widget.onEdit!();
          //           }
          //         },
          //         child: Container(
          //           height: 50,
          //           width: 50,
          //           padding: const EdgeInsets.all(12),
          //           decoration: BoxDecoration(
          //             gradient: const LinearGradient(
          //               colors: [AppColors.bright, AppColors.bright],
          //             ),
          //             shape: BoxShape.circle,
          //             border: Border.all(color: AppColors.borderColor, width: 4),
          //           ),
          //           child: const Icon(
          //             Icons.edit,
          //             color: Colors.white,
          //             size: 20,
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       GestureDetector(
          //         onTap: () => _showDeleteConfirmation(context),
          //         child: Container(
          //           height: 50,
          //           width: 50,
          //           padding: const EdgeInsets.all(12),
          //           decoration: BoxDecoration(
          //             color: Colors.red,
          //             shape: BoxShape.circle,
          //             border: Border.all(color: AppColors.borderColor, width: 4),
          //           ),
          //           child: const Icon(
          //             Icons.delete,
          //             color: Colors.white,
          //             size: 20,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetDetails() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            _sheetSize.value = notification.extent;
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primary],
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
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 74,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productGroup.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.productGroup
                                  .representativeProduct['category'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if(!show)
                      IconButton(
                          onPressed: () {
                            setState(() {
                              show = !show;
                            });
                          },
                          icon: const Icon(
                            Icons.more_vert_sharp,
                            color: AppColors.white,
                          )),
                     if (show)
                      Container(
                        height: 40,
                        // width: 105,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.white.withOpacity(0.6))),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                if (widget.onEdit != null) {
                                  widget.onEdit!();
                                }
                              },
                              child: Container(
                                  height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: const BoxDecoration(
                                    color: AppColors.bright,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    )),
                                child: SvgPicture.asset('assets/icons/edit.svg', width: 20,
                                  height: 20,
                                )


                              ),
                            ),

                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  if (widget.onDelete != null) {
                                    widget.onDelete!();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SvgPicture.asset('assets/icons/delete.svg',
                                    height: 20,
                                    width: 16,
                                  ),
                                )),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    show = !show;
                                  });
                                },
                                icon: const Icon(
                                  Icons.more_vert_sharp,
                                  color: AppColors.white,
                                ))
                          ],
                        ),
                      ),
                      if (widget.productGroup.count > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.bright, AppColors.bright2],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.productGroup.count} Items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildDetailRow(
                    'Brand',
                    widget.productGroup.representativeProduct['brand'],
                    'Scale',
                    widget.productGroup.representativeProduct['scale'],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Year',
                    widget.productGroup.representativeProduct['year'],
                    'Color',
                    widget.productGroup.representativeProduct['color'],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Price',
                    'Rs. ${widget.productGroup.representativeProduct['price']}',
                    'Type',
                    widget.productGroup.representativeProduct['type'],
                  ),
                  // _buildSingleDetail(
                  //   'Price',
                  //   'Rs. ${widget.productGroup.representativeProduct['price']}',
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildDetailItem(label1, value1),
        ),
        const SizedBox(width: 50),
        Expanded(
          child: _buildDetailItem(label2, value2),
        ),
      ],
    );
  }

  Widget _buildSingleDetail(String label, String value) {
    return _buildDetailItem(label, value);
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      // decoration: BoxDecoration(
      //   color: Colors.white.withOpacity(0.05),
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: Colors.white.withOpacity(0.1),
      //   ),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}*/

class ProductDetailsScreen extends StatefulWidget {
  final ProductGroup productGroup;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ProductDetailsScreen({
    super.key,
    required this.productGroup,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late UserController userController;
  final ValueNotifier<double> _sheetSize = ValueNotifier<double>(0.5);
  bool show = false;

  @override
  void initState() {
    super.initState();
    userController = Get.put(UserController());
  }

  @override
  void dispose() {
    _sheetSize.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCustomConfirmDialog(
      context: context,
      message: 'Are you sure want to\ndelete this card',
      actionText: 'Yes, Delete',
    ).then((confirmed) {
      if (confirmed == true) {
        if (widget.onDelete != null) {
          widget.onDelete!();
        }
      }
    });
  }

  void _showDeleteSingleDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Delete Item',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete this item?',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Item: ${widget.productGroup.displayName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
                Navigator.of(context).pop();
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteMultipleDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(
                'Delete ${widget.productGroup.displayName}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This product has ${widget.productGroup.count} items. Do you want to delete:',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                '• Just one item',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                '• All ${widget.productGroup.count} items',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
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
                Navigator.of(context).pop();
                _deleteOne();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete One',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Delete All (${widget.productGroup.count})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteOne() {
    AddProductController.deleteProduct(
      widget.productGroup.representativeProduct['id'],
      context,
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
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
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          if (userController.isLoading.value)
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
    if (userController.profileImagePath.value.isNotEmpty) {
      return Image.network(
        userController.profileImagePath.value,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
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
        ),
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCurrentPlanIcon() {
    String currentPlan =
        userController.currentUser?.plan?.toString().toUpperCase() ?? 'FREE';
    String planIconPath = _getPlanIconPath(currentPlan);

    return Container(
      width: 40,
      height: 40,
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
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Image.asset(
            planIconPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, color: Colors.white, size: 24);
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
    return Scaffold(
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
                          _buildHeader(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * size - 20),
                        child: Center(
                          child: _buildProductImageSection(size),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            _buildBottomSheetDetails(),
          ],
        ),
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
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.white,),
                onPressed: () => Navigator.pop(context),
              ),
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
                    userController.currentUser?.name ?? 'User',
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
          _buildCurrentPlanIcon(),
        ],
      ),
    );
  }

  Widget _buildProductImageSection(double sheetSize) {
    final double dynamicHeight =
        (lerpDouble(280, 120, (sheetSize - 0.5) / (0.8 - 0.5)) ?? 280).clamp(120.0, 280.0);
    final double dynamicWidth =
        (lerpDouble(280, 120, (sheetSize - 0.5) / (0.8 - 0.5)) ?? 280).clamp(120.0, 280.0);

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
              child: Image.network(
                widget.productGroup.imageUrl.startsWith('http://') ||
                        widget.productGroup.imageUrl.startsWith('https://')
                    ? widget.productGroup.imageUrl
                    : 'https://via.placeholder.com/200',
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.grad1Clr,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          // Positioned(
          //   top: -10,
          //   right: -10,
          //   child: Row(
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           Navigator.of(context).pop();
          //           if (widget.onEdit != null) {
          //             widget.onEdit!();
          //           }
          //         },
          //         child: Container(
          //           height: 50,
          //           width: 50,
          //           padding: const EdgeInsets.all(12),
          //           decoration: BoxDecoration(
          //             gradient: const LinearGradient(
          //               colors: [AppColors.bright, AppColors.bright],
          //             ),
          //             shape: BoxShape.circle,
          //             border: Border.all(color: AppColors.borderColor, width: 4),
          //           ),
          //           child: const Icon(
          //             Icons.edit,
          //             color: Colors.white,
          //             size: 20,
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       GestureDetector(
          //         onTap: () => _showDeleteConfirmation(context),
          //         child: Container(
          //           height: 50,
          //           width: 50,
          //           padding: const EdgeInsets.all(12),
          //           decoration: BoxDecoration(
          //             color: Colors.red,
          //             shape: BoxShape.circle,
          //             border: Border.all(color: AppColors.borderColor, width: 4),
          //           ),
          //           child: const Icon(
          //             Icons.delete,
          //             color: Colors.white,
          //             size: 20,
          //           ),
          //         ),
          //       ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetDetails() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            _sheetSize.value = notification.extent;
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primary],
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
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 74,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productGroup
                                  .representativeProduct['name'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.productGroup
                                  .representativeProduct['categoryName'].toString(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if(!show)
                        IconButton(
                            onPressed: () {
                              setState(() {
                                show = !show;
                              });
                            },
                            icon: const Icon(
                              Icons.more_vert_sharp,
                              color: AppColors.white,
                            )),
                      if (show)
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.white.withOpacity(0.6))),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (widget.onEdit != null) {
                                    widget.onEdit!();
                                  }
                                },
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: const BoxDecoration(
                                        color: AppColors.bright,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                        )),
                                    child: SvgPicture.asset('assets/icons/edit.svg', width: 20,
                                      height: 20,
                                    )
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    if (widget.onDelete != null) {
                                      widget.onDelete!();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: SvgPicture.asset('assets/icons/delete.svg',
                                      height: 20,
                                      width: 16,
                                    ),
                                  )),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      show = !show;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.more_vert_sharp,
                                    color: AppColors.white,
                                  ))
                            ],
                          ),
                        ),
                      if (widget.productGroup.count > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.bright, AppColors.bright2],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.productGroup.count} Items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildDetailRow(
                    'Brand',
                    widget.productGroup.representativeProduct['brandName'].toString(),
                    'Scale',
                    widget.productGroup.representativeProduct['scale'],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Year',
                    widget.productGroup.representativeProduct['year'].toString(),
                    'Color',
                    widget.productGroup.representativeProduct['color'],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Price',
                    'Rs. ${widget.productGroup.representativeProduct['price']}',
                    'Type',
                    widget.productGroup.representativeProduct['type'],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildDetailItem(label1, value1),
        ),
        const SizedBox(width: 50),
        Expanded(
          child: _buildDetailItem(label2, value2),
        ),
      ],
    );
  }

  Widget _buildSingleDetail(String label, String value) {
    return _buildDetailItem(label, value);
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      // decoration: BoxDecoration(
      //   color: Colors.white.withOpacity(0.05),
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: Colors.white.withOpacity(0.1),
      //   ),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}



//
// class ProductDetailsScreen extends StatefulWidget {
//   final DocumentSnapshot data;
//   const ProductDetailsScreen({super.key, required this.data,});
//
//   @override
//   State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
// }
//
// class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
//
//   Widget _buildIconCircleButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     Color iconColor = Colors.white,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.grey.withOpacity(0.2),
//           border: Border.all(color: Colors.grey.withOpacity(0.3)),
//         ),
//         child: Icon(icon, color: iconColor, size: 22),
//       ),
//     );
//   }
//   void _showDeleteConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Row(
//             children: const [
//               Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
//               SizedBox(width: 12),
//               Text(
//                 'Delete Item',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Are you sure you want to delete this item?',
//                 style: TextStyle(fontSize: 16, color: Colors.black87),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Item: ${widget.data['name'] ?? 'Unknown'}',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'This action cannot be undone.',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.red,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
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
//                 Navigator.of(context).pop(); // Close confirm
//                 Navigator.of(context).pop(); // Close main dialog
//                _deleteProduct(widget.data);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _editProduct(DocumentSnapshot productData) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddProductScreen(
//           productData: productData,
//           isEditMode: true,
//         ),
//       ),
//     ).then((result) {
//       if (result == true) {
//         setState(() {
//           // Your refresh logic
//         });
//       }
//     });
//   }
//
//   void _deleteProduct(DocumentSnapshot productData) {
//     AddProductController.deleteProduct(productData.id, context).then((_) {
//       setState(() {
//         // Your refresh logic
//       });
//     }).catchError((error) {
//       print('Delete error: $error');
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     final setWidth = MediaQuery.of(context).size.width;
//     return GetBuilder(
//       init: HomeController(),
//       builder: (controller) {
//         return SafeArea(
//           child: Scaffold(
//               // resizeToAvoidBottomInset: false,
//               backgroundColor: AppColors.primaryLight,
//               appBar: PreferredSize(
//                 preferredSize: const Size.fromHeight(80),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.8),
//                         Colors.white.withOpacity(0.6),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(20),
//                       bottomRight: Radius.circular(20),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(20),
//                       bottomRight: Radius.circular(20),
//                     ),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                       child: AppBar(
//                         backgroundColor: Colors.transparent,
//                         elevation: 0,
//                         // title:  Text(
//                         //   '',
//                         //   // widget.isEditMode ? 'Edit Product' : 'Add New Product',
//                         //   style: const TextStyle(
//                         //     fontSize: 24,
//                         //     fontWeight: FontWeight.bold,
//                         //     color: AppColors.dark,
//                         //   ),
//                         // ),
//                         centerTitle: true,
//                         actions: [
//                           Padding(
//                             padding: const EdgeInsets.only(top: 10, right: 10),
//                             child: Row(
//                               children: [
//                                 _buildIconCircleButton(
//                                   icon: Icons.edit,
//                                   iconColor: AppColors.bright,
//                                   onTap: () {
//                                     Navigator.of(context).pop();
//                                     _editProduct(widget.data);
//                                   },
//                                 ),
//                                 const SizedBox(width: 8),
//                                 _buildIconCircleButton(
//                                   icon: Icons.delete,
//                                   iconColor: Colors.red,
//                                   onTap: () => _showDeleteConfirmation(context),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // IconButton(
//                           //   onPressed: _showFilterBottomSheet,
//                           //   icon: const Icon(
//                           //     Icons.filter_alt_outlined,
//                           //     color: AppColors.bright,
//                           //     size: 28,
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               body: Column(
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.of(context).size.width,
//                     width: MediaQuery.of(context).size.width,
//                     child: Image.network(widget.data['image'].toString()),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         left: 8.0, right: 8, top: 25, bottom: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.data['name'],
//                           style: const TextStyle(
//                               color: AppColors.dark,
//                               fontSize: 32,
//                               fontWeight: FontWeight.w700),
//                         ),
//
//                         // const Row(
//                         //   children: [
//                         //     Text(
//                         //       'EDIT',
//                         //       style: TextStyle(
//                         //           color: AppColors.bright,
//                         //           fontWeight: FontWeight.w600,
//                         //           fontSize: 16),
//                         //     ),
//                         //     SizedBox(
//                         //       width: 10,
//                         //     ),
//                         //     Icon(
//                         //       Icons.edit,
//                         //       color: AppColors.bright,
//                         //       size: 20,
//                         //     )
//                         //   ],
//                         // )
//                       ],
//                     ),
//                   ),
//                   Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width / 3 - 10,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Brand',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400,
//                                       color: AppColors.dark),
//                                 ),
//                                 Text(
//                                   widget.data['brand'],
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColors.dark),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const DottedLine(
//                             direction: Axis.vertical,
//                             alignment: WrapAlignment.center,
//                             lineLength: 100,
//                             lineThickness: 1.0,
//                             dashLength: 4.0,
//                             dashColor: AppColors.dark,
//                             // dashGradient: [Colors.red, Colors.blue],
//                             dashRadius: 0.0,
//                             dashGapLength: 4.0,
//                             dashGapColor: Colors.transparent,
//                             // dashGapGradient: [Colors.red, Colors.blue],
//                             dashGapRadius: 0.0,
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width / 3 - 10,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Price',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400,
//                                       color: AppColors.dark),
//                                 ),
//                                 Text(
//                                   'Rs. ${widget.data['price']}',
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColors.dark),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const DottedLine(
//                             direction: Axis.vertical,
//                             alignment: WrapAlignment.center,
//                             lineLength: 100,
//                             lineThickness: 1.0,
//                             dashLength: 4.0,
//                             dashColor: AppColors.dark,
//                             // dashGradient: [Colors.red, Colors.blue],
//                             dashRadius: 0.0,
//                             dashGapLength: 4.0,
//                             dashGapColor: Colors.transparent,
//                             // dashGapGradient: [Colors.red, Colors.blue],
//                             dashGapRadius: 0.0,
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width / 3 - 10,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Category',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400,
//                                       color: AppColors.dark),
//                                 ),
//                                 Text(
//                                   widget.data['category'],
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColors.dark),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.only(left: 15.0, right: 15),
//                         child: DottedLine(
//                           direction: Axis.horizontal,
//                           alignment: WrapAlignment.center,
//                           // lineLength: 300,
//                           lineThickness: 1.0,
//                           dashLength: 4.0,
//                           dashColor: AppColors.dark,
//                           // dashGradient: [Colors.red, Colors.blue],
//                           dashRadius: 0.0,
//                           dashGapLength: 4.0,
//                           dashGapColor: Colors.transparent,
//                           // dashGapGradient: [Colors.red, Colors.blue],
//                           dashGapRadius: 0.0,
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width / 3 - 10,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Scale',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400,
//                                       color: AppColors.dark),
//                                 ),
//                                 Text(
//                                   widget.data['scale'],
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColors.dark),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const DottedLine(
//                             direction: Axis.vertical,
//                             alignment: WrapAlignment.center,
//                             lineLength: 100,
//                             lineThickness: 1.0,
//                             dashLength: 4.0,
//                             dashColor: AppColors.dark,
//                             // dashGradient: [Colors.red, Colors.blue],
//                             dashRadius: 0.0,
//                             dashGapLength: 4.0,
//                             dashGapColor: Colors.transparent,
//                             // dashGapGradient: [Colors.red, Colors.blue],
//                             dashGapRadius: 0.0,
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width / 3 - 10,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Year',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400,
//                                       color: AppColors.dark),
//                                 ),
//                                 Text(
//                                   widget.data['year'],
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColors.dark),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const DottedLine(
//                             direction: Axis.vertical,
//                             alignment: WrapAlignment.center,
//                             lineLength: 100,
//                             lineThickness: 1.0,
//                             dashLength: 4.0,
//                             dashColor: AppColors.dark,
//                             // dashGradient: [Colors.red, Colors.blue],
//                             dashRadius: 0.0,
//                             dashGapLength: 4.0,
//                             dashGapColor: Colors.transparent,
//                             // dashGapGradient: [Colors.red, Colors.blue],
//                             dashGapRadius: 0.0,
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width / 3 - 10,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Colour',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400,
//                                       color: AppColors.dark),
//                                 ),
//                                 Text(
//                                   widget.data['color'],
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColors.dark),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.only(left: 15.0, right: 15),
//                         child: DottedLine(
//                           direction: Axis.horizontal,
//                           alignment: WrapAlignment.center,
//                           // lineLength: 300,
//                           lineThickness: 1.0,
//                           dashLength: 4.0,
//                           dashColor: AppColors.dark,
//                           // dashGradient: [Colors.red, Colors.blue],
//                           dashRadius: 0.0,
//                           dashGapLength: 4.0,
//                           dashGapColor: Colors.transparent,
//                           // dashGapGradient: [Colors.red, Colors.blue],
//                           dashGapRadius: 0.0,
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               )),
//         );
//       },
//     );
//   }
// }
