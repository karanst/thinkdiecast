import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:io';
import 'package:thinkdiecast/controllers/add_product_controller.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/custom_appbar.dart';
import 'package:thinkdiecast/views/DialogWidgets/filter_dialog.dart';
import 'package:thinkdiecast/views/add_product_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thinkdiecast/views/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final HomeController _homeController = Get.put(HomeController());
  // final UserProfileController _userController = Get.put(UserProfileController());
  final TextEditingController _searchController = TextEditingController();
  List<ProductGroup> _searchResults = [];
  List<ProductGroup> _allProducts = [];
  int _resultCount = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    // if (_userController.userData == null) {
      // _userController.fetchUserData();
    // }
    _loadAllProducts();
  }

  void _loadAllProducts() {
    _homeController.clearFilters();
    _homeController.getAllProducts().then((_) {
      if (mounted) {
        setState(() {
          _allProducts = _homeController.groupedProducts;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _resultCount = 0;
      });
      return;
    }

    // Search from the already loaded products instead of streaming
    final results = _allProducts
        .where((product) =>
    product.displayName.toLowerCase().contains(query.toLowerCase()) ||
        product.brandName.toLowerCase().contains(query.toLowerCase()) ||
        product.toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _searchResults = results;
      _resultCount = results.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        _allProducts = controller.groupedProducts;
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
                  // _buildHeader(),
                  _buildSearchBar(),
                  Obx(() => _buildBrandBar(controller)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isSearching ? '$_resultCount RESULTS' : 'CAR LISTS',
                          style: const TextStyle(
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
                      child: _isSearching
                          ? (_searchResults.isEmpty
                          ? _buildNoResultsState()
                          : _buildSearchResultsGrid())
                          : _buildAllProductsGrid(),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            painter: _GradientBorderPainter(
              borderRadius: 24,
              borderWidth: 1.5,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _performSearch,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'SEARCH',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          )
                        : Icon(Icons.search, color: AppColors.bright, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllProductsGrid() {
    if (_allProducts.isEmpty) {
      return _buildEmptyState();
    }

    // Dynamically determine crossAxisCount based on item count
    int crossAxisCount = _allProducts.length > 6 ? 3 : 2;

    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: _allProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_allProducts[index]);
      },
    );
  }

  Widget _buildSearchResultsGrid() {
    int crossAxisCount = _searchResults.length > 6 ? 3 : 2;

    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_searchResults[index]);
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

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
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
}

// Gradient Border Painter
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

    final gradient = const LinearGradient(
      colors: [AppColors.bright, AppColors.bright2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
//
// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});
//
//   @override
//   SearchScreenState createState() => SearchScreenState();
// }
//
// class SearchScreenState extends State<SearchScreen> {
//   final HomeController _homeController = Get.put(HomeController());
//   final UserProfileController _userController = Get.put(UserProfileController());
//   final TextEditingController _searchController = TextEditingController();
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
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _performSearch(String query) {
//     _homeController.applyFilters({'search': query.isEmpty ? null : query});
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
//                   _buildSearchBar(),
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
//                           onPressed: (){showFilterDialog(context);},
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
//                           // Dynamically determine crossAxisCount based on item count
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
//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           CustomPaint(
//             painter: _GradientBorderPainter(
//               borderRadius: 24,
//               borderWidth: 1.5,
//             ),
//             child: Container(
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Colors.transparent,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: _performSearch,
//                       style: const TextStyle(color: Colors.white, fontSize: 14),
//                       decoration: InputDecoration(
//                         hintText: 'SEARCH',
//                         hintStyle: TextStyle(
//                           color: Colors.white.withOpacity(0.5),
//                           fontSize: 14,
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(right: 12),
//                     child: Icon(Icons.search, color: AppColors.bright, size: 20),
//                   ),
//                 ],
//               ),
//             ),
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
//               border: Border.all(color: Colors.white, width: 2),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: ClipOval(child: _buildProfileImage()),
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
//               child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
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
//     String currentPlan = _userController.userData?['plan']?.toString().toUpperCase() ?? 'FREE';
//     String planIconPath = _getPlanIconPath(currentPlan);
//
//     return Container(
//       width: 40,
//       height: 40,
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
//           _buildCurrentPlanIcon()
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
//
// // Gradient Border Painter
// class _GradientBorderPainter extends CustomPainter {
//   final double borderRadius;
//   final double borderWidth;
//
//   _GradientBorderPainter({
//     required this.borderRadius,
//     required this.borderWidth,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final rrect = RRect.fromRectAndRadius(
//       rect,
//       Radius.circular(borderRadius),
//     );
//
//     final gradient = const LinearGradient(
//       colors: [AppColors.bright, AppColors.bright2],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );
//
//     final paint = Paint()
//       ..shader = gradient.createShader(rect)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = borderWidth;
//
//     canvas.drawRRect(rrect, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }





