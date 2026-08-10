import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:thinkdiecast/controllers/add_product_controller.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/custom_appbar.dart';
import 'package:thinkdiecast/views/DialogWidgets/filter_dialog.dart';

import 'package:thinkdiecast/views/add_product_screen.dart';
import 'package:thinkdiecast/views/filter_bottom_sheet.dart';
import 'package:thinkdiecast/views/product_details_screen.dart';



/*class CategoryItemsScreen extends StatefulWidget {
  final String? categoryName;
  const CategoryItemsScreen({super.key, this.categoryName});

  @override
  CategoryItemsScreenState createState() => CategoryItemsScreenState();
}

class CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final HomeController _homeController = Get.put(HomeController());
  final UserProfileController _userController = Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    if (_userController.userData == null) {
      _userController.fetchUserData();
    }

    // Apply category filter when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyCategoryFilter();
    });
  }

  void _applyCategoryFilter() {
    if (widget.categoryName != null && widget.categoryName!.toLowerCase() != 'all') {
      // Apply specific category filter
      _homeController.applyFilters({'type': widget.categoryName});
    } else {
      // Clear category filter to show all items
      _homeController.applyFilters({'type': null});
    }
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
                  const CustomAppHeader(showBackButton: true),
                  _buildBrandBar(controller),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getCategoryTitle(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showFilterDialog(context);
                          },
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

  // Get dynamic title based on category
  String _getCategoryTitle() {
    if (widget.categoryName == null || widget.categoryName!.toLowerCase() == 'all') {
      return 'ALL ITEMS';
    }
    return '${widget.categoryName!.toUpperCase()} LISTS';
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
            _getEmptyStateMessage(),
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

  String _getEmptyStateMessage() {
    if (widget.categoryName == null || widget.categoryName!.toLowerCase() == 'all') {
      return 'No items in your collection yet';
    }
    return 'No ${widget.categoryName!.toLowerCase()} in your collection yet';
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
                  fit: BoxFit.fill,
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
      await Future.delayed(const Duration(milliseconds: 500));
      _applyCategoryFilter(); // Re-apply category filter after refresh
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
      _performDelete(productGroup.representativeProduct.id);
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
              _performDelete(productGroup.representativeProduct.id);
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
        },
      ),
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
}*/

class CategoryItemsScreen extends StatefulWidget {
  final String? categoryName;
  const CategoryItemsScreen({super.key, this.categoryName});

  @override
  CategoryItemsScreenState createState() => CategoryItemsScreenState();
}

class CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final HomeController _homeController = Get.put(HomeController());
  final UserController _userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    if (_userController.currentUser == null) {
      _userController.fetchUserProfile();
    }

    // Apply category filter when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyCategoryFilter();
    });
  }

  void _applyCategoryFilter() {
    if (widget.categoryName != null && widget.categoryName!.toLowerCase() != 'all') {
      // Apply specific category filter
      _homeController.applyFilters({'type': widget.categoryName});
    } else {
      // Clear category filter to show all items
      _homeController.applyFilters({'type': null});
    }
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
                  const CustomAppHeader(showBackButton: true),
                  Obx(() => _buildBrandBar(controller)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getCategoryTitle(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showFilterDialog(context);
                          },
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

  // Get dynamic title based on category
  String _getCategoryTitle() {
    if (widget.categoryName == null || widget.categoryName!.toLowerCase() == 'all') {
      return 'ALL ITEMS';
    }
    return '${widget.categoryName!.toUpperCase()} LISTS';
  }

  Widget _buildProductCard(ProductGroup group) {
    return InkWell(
      onTap: () {
        print('this is my product data ${group.displayName}');
        _showProductDialog(group);} ,
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
            _getEmptyStateMessage(),
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

  String _getEmptyStateMessage() {
    if (widget.categoryName == null || widget.categoryName!.toLowerCase() == 'all') {
      return 'No items in your collection yet';
    }
    return 'No ${widget.categoryName!.toLowerCase()} in your collection yet';
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
                  fit: BoxFit.fill,
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
      await Future.delayed(const Duration(milliseconds: 500));
      _applyCategoryFilter(); // Re-apply category filter after refresh
      setState(() {});
    } catch (error) {
      // Handle error silently
    }
  }

  void _showProductDialog(ProductGroup productGroup) {
    print('this is my product group data ${productGroup.brandName}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productGroup: productGroup,
          onEdit: () => _editProduct(productGroup),
          onDelete: () => _deleteProduct(productGroup),
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
        },
      ),
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



// class CategoryItemsScreen extends StatefulWidget {
//   final String? categoryName; // 'Cars', 'Bikes', 'All', etc.
//   final String? categoryType; // Optional: for more specific filtering
//
//   const CategoryItemsScreen({
//     Key? key,
//     this.categoryName,
//     this.categoryType,
//   }) : super(key: key);
//
//   @override
//   State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
// }
//
// class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
//   final HomeController _homeController = Get.put(HomeController());
//   final UserProfileController _userController = Get.put(UserProfileController());
//
//   @override
//   void initState() {
//     super.initState();
//     if (_userController.userData == null) {
//       _userController.fetchUserData();
//     }
//
//     // Apply category filter on init
//     _applyCategoryFilter();
//   }
//
//   void _applyCategoryFilter() {
//     if (widget.categoryName != null && widget.categoryName!.toLowerCase() != 'all') {
//       _homeController.applyFilters({'type': widget.categoryName});
//     } else {
//       _homeController.applyFilters({'type': null});
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
//                   _buildCategoryTitle(),
//                   _buildBrandBar(controller),
//                   _buildFilterBar(controller),
//                   Expanded(
//                     child: RefreshIndicator(
//                       onRefresh: _onRefresh,
//                       color: AppColors.bright,
//                       child: StreamBuilder<List<ProductGroup>>(
//                         stream: controller.getFilteredInventory(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return const Center(
//                               child: CircularProgressIndicator(
//                                 color: AppColors.bright,
//                               ),
//                             );
//                           }
//
//                           final productGroups = snapshot.data ?? [];
//
//                           if (productGroups.isEmpty) {
//                             return _buildEmptyState();
//                           }
//
//                           int crossAxisCount = productGroups.length > 6 ? 3 : 2;
//
//                           return MasonryGridView.count(
//                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                             crossAxisCount: crossAxisCount,
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
//
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           // Back button
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                 ),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'MY COLLECTION',
//                   style: TextStyle(
//                     color: Color(0xFF9E9E9E),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Obx(() => Text(
//                   _userController.displayName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 )),
//               ],
//             ),
//           ),
//           _buildProfilePictureSection(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategoryTitle() {
//     String displayCategory = widget.categoryName ?? 'All Items';
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [AppColors.bright, AppColors.bright2],
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               _getCategoryIcon(displayCategory),
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               displayCategory.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 2,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _getCategoryIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'cars':
//         return Icons.directions_car;
//       case 'bikes':
//         return Icons.two_wheeler;
//       case 'trucks':
//         return Icons.local_shipping;
//       case 'all items':
//       default:
//         return Icons.grid_view;
//     }
//   }
//
//   Widget _buildBrandBar(HomeController controller) {
//     if (controller.brands.isEmpty) return const SizedBox.shrink();
//
//     return Container(
//       height: 40,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         scrollDirection: Axis.horizontal,
//         itemCount: controller.brands.length,
//         itemBuilder: (context, index) {
//           final isSelected = controller.currentFilters['name'] == controller.brands[index]['name'];
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
//                 border: isSelected ? Border.all(color: AppColors.bright, width: 2) : null,
//                 image: DecorationImage(
//                   image: NetworkImage(controller.brands[index]['image']),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildFilterBar(HomeController controller) {
//     final hasActiveFilter = controller.currentFilters['category'] != null ||
//         controller.currentFilters['name'] != null;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           if (hasActiveFilter)
//             GestureDetector(
//               onTap: () {
//                 controller.applyFilters({
//                   'category': widget.categoryName?.toLowerCase() != 'all' ? widget.categoryName : null,
//                   'name': null,
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppColors.bright.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: AppColors.bright),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     Icon(Icons.clear_all, color: Colors.white, size: 16),
//                     SizedBox(width: 6),
//                     Text(
//                       'CLEAR FILTERS',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             const Text(
//               'RESULTS',
//               style: TextStyle(
//                 color: Color(0xFF9E9E9E),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 letterSpacing: 1,
//               ),
//             ),
//           Row(
//             children: [
//               StreamBuilder<List<ProductGroup>>(
//                 stream: controller.getFilteredInventory(),
//                 builder: (context, snapshot) {
//                   final count = snapshot.data?.length ?? 0;
//                   return Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '$count',
//                       style: const TextStyle(
//                         color: AppColors.bright,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 onPressed: () => showFilterDialog(context),
//                 icon: const Icon(Icons.tune, color: Colors.white),
//               ),
//             ],
//           ),
//         ],
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
//           color: Colors.white.withOpacity(0.05),
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
//                         child: const Center(
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppColors.bright,
//                           ),
//                         ),
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
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
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
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inventory_2_outlined,
//             size: 80,
//             color: Colors.white.withOpacity(0.3),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No ${widget.categoryName ?? "items"} found',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Try adjusting your filters or add new items',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.white.withOpacity(0.5),
//             ),
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton.icon(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.arrow_back),
//             label: const Text('Go Back'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.bright,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfilePictureSection() {
//     return Container(
//       height: 45,
//       width: 45,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white, width: 2),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.bright.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ClipOval(child: _buildProfileImage()),
//     );
//   }
//
//   Widget _buildProfileImage() {
//     if (_userController.profileImage.value != null) {
//       return Image.file(
//         File(_userController.profileImage.value!.path),
//         fit: BoxFit.cover,
//         width: 45,
//         height: 45,
//       );
//     }
//
//     if (_userController.profilePictureUrl.isNotEmpty) {
//       return Image.network(
//         _userController.profilePictureUrl,
//         fit: BoxFit.cover,
//         width: 45,
//         height: 45,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Container(
//             color: Colors.grey[200],
//             child: const Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.bright,
//                 strokeWidth: 2,
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
//       color: AppColors.bright.withOpacity(0.2),
//       child: Icon(
//         Icons.person,
//         size: 30,
//         color: AppColors.bright.withOpacity(0.7),
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
//       // Handle error silently
//     }
//   }
//
//   void _showProductDialog(ProductGroup productGroup) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProductDetailsScreen(
//           productGroup: productGroup,
//           onEdit: () => _editProduct(productGroup),
//           onDelete: () => _deleteProduct(productGroup),
//         ),
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
//   void showFilterDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => FilterDialog(
//         onApply: (filters) {
//           _homeController.applyFilters(filters);
//         },
//       ),
//     );
//   }
// }