import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/add_product_controller.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/custom_appbar.dart';
import 'package:thinkdiecast/views/DialogWidgets/filter_dialog.dart';

import 'package:thinkdiecast/views/add_product_screen.dart';
import 'package:thinkdiecast/views/filter_bottom_sheet.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thinkdiecast/views/product_details_screen.dart';

class ItemsScreen extends StatefulWidget {

  const ItemsScreen({super.key, });

  @override
  ItemsScreenState createState() => ItemsScreenState();
}

class ItemsScreenState extends State<ItemsScreen> {
  final HomeController _homeController = Get.put(HomeController());
  // final UserProfileController _userController = Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    // Get.delete<HomeController>();
    // final hController = Get.put(HomeController());
    // hController.clearFilters();
    // if (_userController.userData == null) {
    //   _userController.fetchUserData();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
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
              child: Column(
                children: [
                  const CustomAppHeader(showBackButton: false),

                  Obx(() => _buildBrandBar(controller)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ITEMS LISTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),

                        IconButton(
                          onPressed: (){showFilterDialog(context);},
                          icon: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.bright,
                      child: StreamBuilder<List<ProductGroup>>(
                        stream: controller.getFilteredInventory(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final productGroups = snapshot.data ?? [];

                          if (productGroups.isEmpty) {
                            return _buildEmptyState();
                          }

                          // Dynamically determine crossAxisCount based on item count
                          int crossAxisCount = productGroups.length > 6 ? 3 : 2;

                          return MasonryGridView.count(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            itemCount: productGroups.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(productGroups[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ProductGroup group) {
    return InkWell(
      onTap: () => _showProductDialog(group),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Image.network(
                    group.imageUrl.isNotEmpty ? group.imageUrl : 'https://via.placeholder.com/200',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 150,
                        color: Colors.white.withOpacity(0.05),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.white10,
                      child: const Icon(Icons.image_not_supported, color: Colors.white24),
                    ),
                  ),
                  if (group.count > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bright,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${group.count}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cars in your collection yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first collectible!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildBrandBar(HomeController controller) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: controller.brands.length,
        itemBuilder: (context, index) {
          final isSelected = controller.currentFilters['name'] == controller.brands[index]['name'];

          return GestureDetector(
            onTap: () => controller.applyFilters({
              'name': isSelected ? null : controller.brands[index]['name']
            }),
            child: Container(
              height: 40,
              width: 105,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: isSelected ? Border.all(color: AppColors.bright, width: 2) : null,
                image: DecorationImage(
                  image: NetworkImage(controller.brands[index]['imageUrl'] ?? controller.brands[index]['image'] ?? ''),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    try {
      await _homeController.fetchDetails();
      await _homeController.getAllCategories();
      await _homeController.getAllProducts();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {});
    } catch (error) {
      // Handle error silently
    }
  }

  void _showProductDialog(ProductGroup productGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productGroup: productGroup,
          onEdit: () => _editProduct(productGroup),
          onDelete: () => _deleteProduct(productGroup),
          // data: productGroup, // Use current product instead of representative
        ),
      ),
    );

  }

  void _editProduct(ProductGroup productGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          productData: productGroup.representativeProduct,
          isEditMode: true,
        ),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  void _deleteProduct(ProductGroup productGroup) {
    if (productGroup.count > 1) {
      _showDeleteConfirmationDialog(productGroup);
    } else {
      _performDelete(productGroup.representativeProduct['id']);
    }
  }

  void _showDeleteConfirmationDialog(ProductGroup productGroup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${productGroup.displayName}'),
        content: Text(
          'This product has ${productGroup.count} items. Do you want to delete:\n\n'
              '• Just one item\n'
              '• All ${productGroup.count} items',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(productGroup.representativeProduct['id']);
            },
            child: const Text('Delete One'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllInGroup(productGroup);
            },
            child: Text('Delete All (${productGroup.count})'),
          ),
        ],
      ),
    );
  }

  void _performDelete(String productId) {
    AddProductController.deleteProduct(productId, context).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete error: $error')),
      );
    });
  }

  void _deleteAllInGroup(ProductGroup productGroup) async {
    try {
      for (String productId in productGroup.productIds) {
        await AddProductController.deleteProduct(productId, context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${productGroup.count} items successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete error: $error')),
      );
    }
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        onApply: (filters) {
          _homeController.applyFilters(filters);
        },),
    );
  }
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: Colors.white.withOpacity(0.9),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: FilterBottomSheet(
              onApply: (filters) {
                _homeController.applyFilters(filters);
              },
            ),
          ),
        ),
      ),
    );
  }
}



// class ItemsScreen extends StatefulWidget {
//   const ItemsScreen({super.key});
//
//   @override
//   ItemsScreenState createState() => ItemsScreenState();
// }
//
// class ItemsScreenState extends State<ItemsScreen> {
//   final HomeController _homeController = Get.put(HomeController());
//   final UserProfileController _userController = Get.put(UserProfileController());
//
//   @override
//   void initState() {
//     super.initState();
//     if (_userController.userData == null) {
//       _userController.fetchUserData();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HomeController>(
//       builder: (controller) {
//         return Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/auth_bg.png'),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Scaffold(
//             backgroundColor: Colors.transparent,
//             body: SafeArea(
//               child: Column(
//                 children: [
//                   _buildHeader(),
//                   _buildBrandBar(controller),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'CAR LISTS',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.5,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: _showFilterBottomSheet,
//                           icon: const Icon(Icons.tune, color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: RefreshIndicator(
//                       onRefresh: _onRefresh,
//                       color: AppColors.bright,
//                       child: StreamBuilder<List<ProductGroup>>(
//                         stream: controller.getFilteredInventory(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return const Center(child: CircularProgressIndicator());
//                           }
//
//                           final productGroups = snapshot.data ?? [];
//
//                           if (productGroups.isEmpty) {
//                             return _buildEmptyState();
//                           }
//
//                           return _buildCustomMasonryGrid(productGroups);
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildCustomMasonryGrid(List<ProductGroup> productGroups) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Column(
//         children: _buildMasonryRows(productGroups),
//       ),
//     );
//   }
//
//   List<Widget> _buildMasonryRows(List<ProductGroup> products) {
//     List<Widget> rows = [];
//     int index = 0;
//
//     while (index < products.length) {
//       // Pattern 1: Three small cards in a row
//       if (index < products.length) {
//         rows.add(_buildThreeSmallCardsRow(products, index));
//         index += 3;
//       }
//
//       // Pattern 2: Two small cards on left + one large card on right
//       if (index < products.length) {
//         rows.add(_buildTwoSmallOneLargeRow(products, index));
//         index += 3;
//       }
//     }
//
//     return rows;
//   }
//
//   Widget _buildThreeSmallCardsRow(List<ProductGroup> products, int startIndex) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         children: [
//           if (startIndex < products.length)
//             Expanded(
//               child: _buildSmallCard(products[startIndex]),
//             ),
//           if (startIndex < products.length) const SizedBox(width: 16),
//           if (startIndex + 1 < products.length)
//             Expanded(
//               child: _buildSmallCard(products[startIndex + 1]),
//             ),
//           if (startIndex + 1 < products.length) const SizedBox(width: 16),
//           if (startIndex + 2 < products.length)
//             Expanded(
//               child: _buildSmallCard(products[startIndex + 2]),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTwoSmallOneLargeRow(List<ProductGroup> products, int startIndex) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left column: Two small cards stacked
//           Expanded(
//             child: Column(
//               children: [
//                 if (startIndex < products.length)
//                   _buildSmallCard(products[startIndex]),
//                 if (startIndex < products.length) const SizedBox(height: 16),
//                 if (startIndex + 1 < products.length)
//                   _buildSmallCard(products[startIndex + 1]),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           // Right column: One large card
//           if (startIndex + 2 < products.length)
//             Expanded(
//               child: _buildLargeCard(products[startIndex + 2]),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSmallCard(ProductGroup group) {
//     return InkWell(
//       onTap: () => _showProductDialog(group),
//       child: Container(
//         height: 140,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white.withOpacity(0.05),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             children: [
//               Image.network(
//                 group.imageUrl.isNotEmpty ? group.imageUrl : 'https://via.placeholder.com/200',
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//                 loadingBuilder: (context, child, progress) {
//                   if (progress == null) return child;
//                   return Container(
//                     color: Colors.white.withOpacity(0.05),
//                     child: const Center(
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   );
//                 },
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   color: Colors.white10,
//                   child: const Icon(Icons.image_not_supported, color: Colors.white24),
//                 ),
//               ),
//               if (group.count > 1)
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppColors.bright,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${group.count}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLargeCard(ProductGroup group) {
//     return InkWell(
//       onTap: () => _showProductDialog(group),
//       child: Container(
//         height: 296, // Height to match two small cards (140 + 16 + 140)
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white.withOpacity(0.05),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             children: [
//               Image.network(
//                 group.imageUrl.isNotEmpty ? group.imageUrl : 'https://via.placeholder.com/400',
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//                 loadingBuilder: (context, child, progress) {
//                   if (progress == null) return child;
//                   return Container(
//                     color: Colors.white.withOpacity(0.05),
//                     child: const Center(
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   );
//                 },
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   color: Colors.white10,
//                   child: const Icon(
//                     Icons.image_not_supported,
//                     color: Colors.white24,
//                     size: 48,
//                   ),
//                 ),
//               ),
//               if (group.count > 1)
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: AppColors.bright,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${group.count}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inventory_2_outlined,
//             size: 64,
//             color: Colors.white.withOpacity(0.5),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No cars in your collection yet',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Add your first collectible!',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.white.withOpacity(0.5),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
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
//           if (_userController.isLoading)
//             Container(
//               width: 60,
//               height: 60,
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
//     if (_userController.profileImage.value != null) {
//       return Image.file(
//         File(_userController.profileImage.value!.path),
//         fit: BoxFit.cover,
//         width: 60,
//         height: 60,
//       );
//     }
//
//     if (_userController.profilePictureUrl.isNotEmpty) {
//       return Image.network(
//         _userController.profilePictureUrl,
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
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               _buildProfilePictureSection(),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'WELCOME',
//                     style: TextStyle(
//                       color: Color(0xFF9E9E9E),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Obx(() => Text(
//                     _userController.displayName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                     ),
//                   )),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBrandBar(HomeController controller) {
//     return Container(
//       height: 40,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         scrollDirection: Axis.horizontal,
//         itemCount: controller.brands.length,
//         itemBuilder: (context, index) {
//           final brand = controller.brands[index];
//           final isSelected = controller.currentFilters['name'] ==
//               controller.brands[index]['name'];
//
//           return GestureDetector(
//             onTap: () => controller.applyFilters({
//               'name': isSelected ? null : controller.brands[index]['name']
//             }),
//             child: Container(
//               height: 40,
//               width: 105,
//               margin: const EdgeInsets.only(right: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 border: isSelected
//                     ? Border.all(color: AppColors.bright, width: 2)
//                     : null,
//                 image: DecorationImage(
//                   image: NetworkImage(controller.brands[index]['image']),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _onRefresh() async {
//     try {
//       await _homeController.fetchDetails();
//       await _homeController.getAllCategories();
//       await Future.delayed(const Duration(milliseconds: 500));
//       setState(() {});
//     } catch (error) {
//       // Handle error
//     }
//   }
//
//   void _showProductDialog(ProductGroup productGroup) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) => SeeDetailsDialog(
//         productGroup: productGroup,
//         onEdit: () => _editProduct(productGroup),
//         onDelete: () => _deleteProduct(productGroup),
//       ),
//     );
//   }
//
//   void _editProduct(ProductGroup productGroup) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddProductScreen(
//           productData: productGroup.representativeProduct,
//           isEditMode: true,
//         ),
//       ),
//     ).then((result) {
//       if (result == true) {
//         setState(() {});
//       }
//     });
//   }
//
//   void _deleteProduct(ProductGroup productGroup) {
//     if (productGroup.count > 1) {
//       _showDeleteConfirmationDialog(productGroup);
//     } else {
//       _performDelete(productGroup.representativeProduct.id);
//     }
//   }
//
//   void _showDeleteConfirmationDialog(ProductGroup productGroup) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete ${productGroup.displayName}'),
//         content: Text(
//           'This product has ${productGroup.count} items. Do you want to delete:\n\n'
//               '• Just one item\n'
//               '• All ${productGroup.count} items',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _performDelete(productGroup.representativeProduct.id);
//             },
//             child: const Text('Delete One'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteAllInGroup(productGroup);
//             },
//             child: Text('Delete All (${productGroup.count})'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _performDelete(String productId) {
//     AddProductController.deleteProduct(productId, context).then((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product deleted successfully')),
//       );
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Delete error: $error')),
//       );
//     });
//   }
//
//   void _deleteAllInGroup(ProductGroup productGroup) async {
//     try {
//       for (String productId in productGroup.productIds) {
//         await AddProductController.deleteProduct(productId, context);
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Deleted ${productGroup.count} items successfully')),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Delete error: $error')),
//       );
//     }
//   }
//
//   void _showFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           color: Colors.white.withOpacity(0.9),
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: FilterBottomSheet(
//               onApply: (filters) {
//                 _homeController.applyFilters(filters);
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// class ItemsScreen extends StatefulWidget {
//   const ItemsScreen({super.key});
//
//   @override
//   ItemsScreenState createState() => ItemsScreenState();
// }
//
// class ItemsScreenState extends State<ItemsScreen> {
//
//   final HomeController _homeController = Get.put(HomeController());
//   final UserProfileController _userController = Get.put(UserProfileController());
//
//   @override
//   void initState() {
//     super.initState();
//     // Ensure user data is loaded for the header
//     if (_userController.userData == null) {
//       _userController.fetchUserData();
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HomeController>(
//       builder: (controller) {
//         return Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/auth_bg.png'),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Scaffold(
//             backgroundColor: Colors.transparent,
//             // bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
//             body: SafeArea(
//               child: Column(
//                 children: [
//                   _buildHeader(),
//
//                   _buildBrandBar(controller),
//
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'CAR LISTS',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.5,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: _showFilterBottomSheet,
//                           icon: const Icon(Icons.tune, color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   Expanded(
//                     child: RefreshIndicator(
//                       onRefresh: _onRefresh,
//                       color: AppColors.bright,
//                       child: StreamBuilder<List<ProductGroup>>(
//                         stream: controller.getFilteredInventory(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return const Center(child: CircularProgressIndicator());
//                           }
//
//                           final productGroups = snapshot.data ?? [];
//
//                           if (productGroups.isEmpty) {
//                             // return _buildEmptyState(controller);
//                           }
//
//                           return MasonryGridView.count(
//                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                             crossAxisCount: 2,
//                             mainAxisSpacing: 16,
//                             crossAxisSpacing: 16,
//                             itemCount: productGroups.length,
//                             itemBuilder: (context, index) {
//                               return _buildProductCard(productGroups[index]);
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
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
//           if (_userController.isLoading)
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
//     if (_userController.profileImage.value != null) {
//       return Image.file(
//         File(_userController.profileImage.value!.path),
//         fit: BoxFit.cover,
//         width: 60,
//         height: 60,
//       );
//     }
//
//     if (_userController.profilePictureUrl.isNotEmpty) {
//       return Image.network(
//         _userController.profilePictureUrl,
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
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               _buildProfilePictureSection(),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'WELCOME',
//                     style: TextStyle(
//                       color: Color(0xFF9E9E9E),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Obx(() => Text(
//                     _userController.displayName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                     ),
//                   )),
//                 ],
//               ),
//             ],
//           ),
//           // _buildAchievementBadge(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBrandBar(HomeController controller) {
//     return Container(
//       height: 40,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         scrollDirection: Axis.horizontal,
//         itemCount: controller.brands.length,
//         itemBuilder: (context, index) {
//           final brand = controller.brands[index];
//           final isSelected = controller.currentFilters['name'] ==
//               controller.brands[index]['name'];
//
//           return GestureDetector(
//             onTap: () => controller.applyFilters({'name': isSelected
//                 ? null : controller.brands[index]['name']}),
//             child: Container(
//               height: 40,
//               width: 105,
//               margin: const EdgeInsets.only(right: 12),
//               // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 border: isSelected ? Border.all(color: AppColors.bright, width: 2) : null,
//                 image: DecorationImage(image: NetworkImage(controller.brands[index]['image']))
//               ),
//               // child: Image.network(
//               //   controller.brands[index]['image'],
//               //   height: 30,
//               //   fit: BoxFit.contain,
//               //   errorBuilder: (_, __, ___) => Center(child: Text(controller.brands[index]['image'])),
//               // ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildProductCard(ProductGroup group) {
//     return InkWell(
//       onTap: () => _showProductDialog(group),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white.withOpacity(0.05), // Subtle background for card
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Stack(
//                 children: [
//                   Image.network(
//                     group.imageUrl.isNotEmpty ? group.imageUrl : 'https://via.placeholder.com/200',
//                     fit: BoxFit.cover,
//                     loadingBuilder: (context, child, progress) {
//                       if (progress == null) return child;
//                       return Container(
//                         height: 150,
//                         color: Colors.white.withOpacity(0.05),
//                         child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
//                       );
//                     },
//                     errorBuilder: (context, error, stackTrace) => Container(
//                       height: 150,
//                       color: Colors.white10,
//                       child: const Icon(Icons.image_not_supported, color: Colors.white24),
//                     ),
//                   ),
//                   if (group.count > 1)
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: AppColors.bright,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           '${group.count}',
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   // Pull to refresh function
//   Future<void> _onRefresh() async {
//     try {
//       // Refresh user details and categories
//       await _homeController.fetchDetails();
//       await _homeController.getAllCategories();
//
//       // Add a small delay to show the refresh indicator
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       // Update the UI
//       setState(() {});
//
//       // Show success message
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(
//       //     content: Text('Collection refreshed successfully!'),
//       //     backgroundColor: Colors.green,
//       //     duration: Duration(seconds: 2),
//       //   ),
//       // );
//     } catch (error) {
//       // Show error message
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(
//       //     content: Text('Failed to refresh: $error'),
//       //     backgroundColor: Colors.red,
//       //     duration: const Duration(seconds: 3),
//       //   ),
//       // );
//     }
//   }
//
//   void _showProductDialog(ProductGroup productGroup) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) => SeeDetailsDialog(
//         productGroup: productGroup,
//         onEdit: () => _editProduct(productGroup),
//         onDelete: () => _deleteProduct(productGroup),
//       ),
//     );
//   }
//
//   void _editProduct(ProductGroup productGroup) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddProductScreen(
//           productData: productGroup.representativeProduct,
//           isEditMode: true,
//         ),
//       ),
//     ).then((result) {
//       if (result == true) {
//         setState(() {
//           // Refresh will happen automatically due to stream
//         });
//       }
//     });
//   }
//
//   void _deleteProduct(ProductGroup productGroup) {
//     // Show confirmation dialog for multiple items
//     if (productGroup.count > 1) {
//       _showDeleteConfirmationDialog(productGroup);
//     } else {
//       _performDelete(productGroup.representativeProduct.id);
//     }
//   }
//
//   void _showDeleteConfirmationDialog(ProductGroup productGroup) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete ${productGroup.displayName}'),
//         content: Text(
//           'This product has ${productGroup.count} items. Do you want to delete:\n\n'
//               '• Just one item\n'
//               '• All ${productGroup.count} items',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _performDelete(productGroup.representativeProduct.id);
//             },
//             child: const Text('Delete One'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteAllInGroup(productGroup);
//             },
//             child: Text('Delete All (${productGroup.count})'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _performDelete(String productId) {
//     AddProductController.deleteProduct(productId, context).then((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product deleted successfully')),
//       );
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Delete error: $error')),
//       );
//     });
//   }
//
//   void _deleteAllInGroup(ProductGroup productGroup) async {
//     try {
//       for (String productId in productGroup.productIds) {
//         await AddProductController.deleteProduct(productId, context);
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Deleted ${productGroup.count} items successfully')),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Delete error: $error')),
//       );
//     }
//   }
//
//   void _showFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           color: Colors.white.withOpacity(0.9),
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: FilterBottomSheet(
//               onApply: (filters) {
//                 _homeController.applyFilters(filters);
//               },
//               // onClear: () {
//               //   _homeController.clearFilters();
//               // },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   return GetBuilder<HomeController>(
//   //     init: HomeController(),
//   //     builder: (controller) {
//   //       return Scaffold(
//   //         appBar: PreferredSize(
//   //           preferredSize: const Size.fromHeight(70),
//   //           child: Container(
//   //             decoration: BoxDecoration(
//   //               gradient: LinearGradient(
//   //                 colors: [
//   //                   Colors.white.withOpacity(0.8),
//   //                   Colors.white.withOpacity(0.6),
//   //                 ],
//   //                 begin: Alignment.topLeft,
//   //                 end: Alignment.bottomRight,
//   //               ),
//   //               borderRadius: const BorderRadius.only(
//   //                 bottomLeft: Radius.circular(20),
//   //                 bottomRight: Radius.circular(20),
//   //               ),
//   //               boxShadow: [
//   //                 BoxShadow(
//   //                   color: Colors.black.withOpacity(0.1),
//   //                   blurRadius: 10,
//   //                   offset: const Offset(0, 2),
//   //                 ),
//   //               ],
//   //             ),
//   //             child: ClipRRect(
//   //               borderRadius: const BorderRadius.only(
//   //                 bottomLeft: Radius.circular(20),
//   //                 bottomRight: Radius.circular(20),
//   //               ),
//   //               child: BackdropFilter(
//   //                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//   //                 child: AppBar(
//   //                   backgroundColor: Colors.transparent,
//   //                   elevation: 0,
//   //                   title: const Text(
//   //                     'My Collection',
//   //                     style: TextStyle(
//   //                       fontSize: 24,
//   //                       fontWeight: FontWeight.bold,
//   //                       color: AppColors.dark,
//   //                     ),
//   //                   ),
//   //                   centerTitle: true,
//   //                   actions: [
//   //                     // Clear filters button (show only when filters are applied)
//   //                     if (controller.currentFilters.isNotEmpty)
//   //                       IconButton(
//   //                         onPressed: () {
//   //                           controller.clearFilters();
//   //                         },
//   //                         icon: const Icon(
//   //                           Icons.clear,
//   //                           color: AppColors.bright,
//   //                           size: 24,
//   //                         ),
//   //                       ),
//   //                     IconButton(
//   //                       onPressed: _showFilterBottomSheet,
//   //                       icon: Icon(
//   //                         controller.currentFilters.isNotEmpty
//   //                             ? Icons.filter_alt
//   //                             : Icons.filter_alt_outlined,
//   //                         color: AppColors.bright,
//   //                         size: 28,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //         extendBody: true,
//   //         body: RefreshIndicator(
//   //           onRefresh: _onRefresh,
//   //           color: AppColors.bright,
//   //           backgroundColor: Colors.white,
//   //           strokeWidth: 2.5,
//   //           displacement: 40,
//   //           child: Stack(
//   //             alignment: Alignment.bottomCenter,
//   //             children: [
//   //               Column(
//   //                 children: [
//   //                   // Stats row
//   //                   // _buildStatsRow(),
//   //
//   //                   // Products grid
//   //                   Expanded(
//   //                     child: StreamBuilder<List<ProductGroup>>(
//   //                       stream: controller.getFilteredInventory(),
//   //                       builder: (BuildContext context, snapshot) {
//   //                         if (snapshot.hasError) {
//   //                           return RefreshIndicator(
//   //                             onRefresh: _onRefresh,
//   //                             child: SingleChildScrollView(
//   //                               physics: const AlwaysScrollableScrollPhysics(),
//   //                               child: Container(
//   //                                 height: MediaQuery.of(context).size.height * 0.7,
//   //                                 child: Center(
//   //                                   child: Column(
//   //                                     mainAxisAlignment: MainAxisAlignment.center,
//   //                                     children: [
//   //                                       const Icon(Icons.error, size: 64, color: Colors.red),
//   //                                       const SizedBox(height: 16),
//   //                                       Text('Error: ${snapshot.error}'),
//   //                                       const SizedBox(height: 16),
//   //                                       ElevatedButton(
//   //                                         onPressed: () {
//   //                                           setState(() {});
//   //                                         },
//   //                                         child: const Text('Retry'),
//   //                                       ),
//   //                                     ],
//   //                                   ),
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                           );
//   //                         }
//   //
//   //                         if (snapshot.connectionState == ConnectionState.waiting) {
//   //                           return const Center(child: CircularProgressIndicator());
//   //                         }
//   //
//   //                         List<ProductGroup> productGroups = snapshot.data ?? [];
//   //
//   //                         if (productGroups.isEmpty) {
//   //                           return RefreshIndicator(
//   //                             onRefresh: _onRefresh,
//   //                             child: SingleChildScrollView(
//   //                               physics: const AlwaysScrollableScrollPhysics(),
//   //                               child: Container(
//   //                                 height: MediaQuery.of(context).size.height * 0.7,
//   //                                 child: Center(
//   //                                   child: Column(
//   //                                     mainAxisAlignment: MainAxisAlignment.center,
//   //                                     children: [
//   //                                       Icon(
//   //                                         Icons.inventory_2_outlined,
//   //                                         size: 64,
//   //                                         color: Colors.grey[400],
//   //                                       ),
//   //                                       const SizedBox(height: 16),
//   //                                       Text(
//   //                                         controller.currentFilters.isNotEmpty
//   //                                             ? 'No products match your filters'
//   //                                             : 'No products in your collection yet',
//   //                                         style: TextStyle(
//   //                                           fontSize: 18,
//   //                                           color: Colors.grey[600],
//   //                                         ),
//   //                                       ),
//   //                                       const SizedBox(height: 8),
//   //                                       Text(
//   //                                         controller.currentFilters.isNotEmpty
//   //                                             ? 'Try adjusting your filters'
//   //                                             : 'Add your first collectible!',
//   //                                         style: TextStyle(
//   //                                           fontSize: 14,
//   //                                           color: Colors.grey[500],
//   //                                         ),
//   //                                       ),
//   //                                       const SizedBox(height: 16),
//   //                                       Text(
//   //                                         'Pull down to refresh',
//   //                                         style: TextStyle(
//   //                                           fontSize: 12,
//   //                                           color: Colors.grey[400],
//   //                                           fontStyle: FontStyle.italic,
//   //                                         ),
//   //                                       ),
//   //                                     ],
//   //                                   ),
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                           );
//   //                         }
//   //
//   //                         return Padding(
//   //                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//   //                           child: GridView.builder(
//   //                             physics: const AlwaysScrollableScrollPhysics(),
//   //                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//   //                               crossAxisCount: 2,
//   //                               mainAxisSpacing: 15.0,
//   //                               crossAxisSpacing: 4.0,
//   //                               childAspectRatio: 0.8,
//   //                             ),
//   //                             itemCount: productGroups.length,
//   //                             itemBuilder: (context, index) {
//   //                               ProductGroup productGroup = productGroups[index];
//   //
//   //                               return InkWell(
//   //                                 onTap: () {
//   //                                   _showProductDialog(productGroup);
//   //                                 },
//   //                                 child: Container(
//   //                                   decoration: BoxDecoration(
//   //                                     borderRadius: BorderRadius.circular(12),
//   //                                     boxShadow: [
//   //                                       BoxShadow(
//   //                                         color: Colors.black.withOpacity(0.1),
//   //                                         blurRadius: 8,
//   //                                         offset: const Offset(0, 2),
//   //                                       ),
//   //                                     ],
//   //                                   ),
//   //                                   child: Stack(
//   //                                     children: [
//   //                                       // Product image
//   //                                       Container(
//   //                                         decoration: BoxDecoration(
//   //                                           borderRadius: BorderRadius.circular(12),
//   //                                           image: DecorationImage(
//   //                                             image: NetworkImage(
//   //                                               productGroup.imageUrl.isNotEmpty
//   //                                                   ? productGroup.imageUrl
//   //                                                   : 'https://via.placeholder.com/200x200?text=No+Image',
//   //                                             ),
//   //                                             fit: BoxFit.cover,
//   //                                             onError: (exception, stackTrace) {
//   //                                               // Handle image loading error
//   //                                             },
//   //                                           ),
//   //                                         ),
//   //                                       ),
//   //
//   //                                       // Count badge (only show if count > 1)
//   //                                       if (productGroup.count > 1)
//   //                                         Positioned(
//   //                                           top: 8,
//   //                                           right: 8,
//   //                                           child: Container(
//   //                                             padding: const EdgeInsets.symmetric(
//   //                                               horizontal: 8,
//   //                                               vertical: 4,
//   //                                             ),
//   //                                             decoration: BoxDecoration(
//   //                                               color: AppColors.bright,
//   //                                               borderRadius: BorderRadius.circular(20),
//   //                                               boxShadow: [
//   //                                                 BoxShadow(
//   //                                                   color: Colors.black.withOpacity(0.3),
//   //                                                   blurRadius: 4,
//   //                                                   offset: const Offset(0, 2),
//   //                                                 ),
//   //                                               ],
//   //                                             ),
//   //                                             child: Text(
//   //                                               '${productGroup.count}',
//   //                                               style: const TextStyle(
//   //                                                 color: Colors.white,
//   //                                                 fontSize: 12,
//   //                                                 fontWeight: FontWeight.bold,
//   //                                               ),
//   //                                             ),
//   //                                           ),
//   //                                         ),
//   //                                     ],
//   //                                   ),
//   //                                 ),
//   //                               );
//   //                             },
//   //                           ),
//   //                         );
//   //                       },
//   //                     ),
//   //                   ),
//   //                   const SizedBox(height: 80),
//   //                 ],
//   //               ),
//   //
//   //               // Brand selection bar
//   //               Padding(
//   //                 padding: const EdgeInsets.fromLTRB(10, 0, 10, 70),
//   //                 child: Card(
//   //                   elevation: 4,
//   //                   shape: RoundedRectangleBorder(
//   //                     borderRadius: BorderRadius.circular(25),
//   //                   ),
//   //                   child: Container(
//   //                     width: MediaQuery.of(context).size.width,
//   //                     height: 65,
//   //                     decoration: BoxDecoration(
//   //                       borderRadius: BorderRadius.circular(25),
//   //                       color: Colors.white,
//   //                     ),
//   //                     child: controller.brands.isNotEmpty
//   //                         ? ListView.builder(
//   //                       scrollDirection: Axis.horizontal,
//   //                       itemCount: controller.brands.length,
//   //                       itemBuilder: (context, index) {
//   //                         return Padding(
//   //                           padding: const EdgeInsets.only(left: 15.0),
//   //                           child: InkWell(
//   //                             onTap: () {
//   //                               Navigator.push(
//   //                                 context,
//   //                                 MaterialPageRoute(
//   //                                   builder: (context) => SearchListScreen(
//   //                                     searchKeyword:
//   //                                     controller.brands[index]['name'],
//   //                                   ),
//   //                                 ),
//   //                               );
//   //                             },
//   //                             child: Container(
//   //                               height: 50,
//   //                               width: 70,
//   //                               child: Image.network(
//   //                                 controller.brands[index]['image'],
//   //                                 errorBuilder: (context, error, stackTrace) {
//   //                                   return const Icon(Icons.image_not_supported);
//   //                                 },
//   //                               ),
//   //                             ),
//   //                           ),
//   //                         );
//   //                       },
//   //                     )
//   //                         : const Center(
//   //                       child: Text('Loading brands...'),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //         bottomNavigationBar: Container(
//   //           decoration: BoxDecoration(
//   //             gradient: LinearGradient(
//   //               colors: [
//   //                 Colors.white.withOpacity(0.8),
//   //                 Colors.white.withOpacity(0.6),
//   //               ],
//   //               begin: Alignment.topLeft,
//   //               end: Alignment.bottomRight,
//   //             ),
//   //             borderRadius: const BorderRadius.only(
//   //               topLeft: Radius.circular(20),
//   //               topRight: Radius.circular(20),
//   //             ),
//   //             boxShadow: [
//   //               BoxShadow(
//   //                 color: Colors.black.withOpacity(0.1),
//   //                 blurRadius: 10,
//   //                 offset: const Offset(0, -2),
//   //               ),
//   //             ],
//   //           ),
//   //           child: ClipRRect(
//   //             borderRadius: const BorderRadius.only(
//   //               topLeft: Radius.circular(20),
//   //               topRight: Radius.circular(20),
//   //             ),
//   //             child: BackdropFilter(
//   //               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//   //               child: Container(
//   //                 padding: const EdgeInsets.only(top: 8, bottom: 8),
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.white.withOpacity(0.1),
//   //                 ),
//   //                 child: Row(
//   //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //                   children: [
//   //                     InkWell(
//   //                       onTap: () {
//   //                         showDialog(
//   //                           context: context,
//   //                           builder: (BuildContext context) {
//   //                             return SearchDialogWidget();
//   //                           },
//   //                         );
//   //                       },
//   //                       child: Container(
//   //                         height: 50,
//   //                         width: 50,
//   //                         child: Image.asset('assets/icons/search.png'),
//   //                       ),
//   //                     ),
//   //                     InkWell(
//   //                       onTap: () {
//   //                         Navigator.push(
//   //                           context,
//   //                           MaterialPageRoute(
//   //                             builder: (context) => AddProductScreen(),
//   //                           ),
//   //                         );
//   //                       },
//   //                       child: Container(
//   //                         height: 50,
//   //                         width: 50,
//   //                         decoration: const BoxDecoration(
//   //                           color: AppColors.bright,
//   //                           shape: BoxShape.circle,
//   //                         ),
//   //                         child: const Icon(
//   //                           Icons.add,
//   //                           color: AppColors.white,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                     IconButton(
//   //                       onPressed: () {
//   //                         showDialog(
//   //                           context: context,
//   //                           builder: (BuildContext context) {
//   //                             return SettingMenuDialog();
//   //                           },
//   //                         );
//   //                       },
//   //                       icon: const Icon(
//   //                         Icons.menu,
//   //                         color: AppColors.dark,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
// }
