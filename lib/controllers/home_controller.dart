import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:get/get.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';

class ProductGroup {
  final String id;
  final String displayName;
  final String brandName;
  final String imageUrl;
  final int count;
  final List<String> productIds;
  final Map<String, dynamic> representativeProduct;

  ProductGroup({
    required this.id,
    required this.displayName,
    required this.brandName,
    required this.imageUrl,
    required this.count,
    required this.productIds,
    required this.representativeProduct,
  });
}

class HomeController extends GetxController {
  late ApiService _apiService;

  // Getter for ApiService (used by other screens/services)
  ApiService get apiService => _apiService;

  // Reactive variables
  final RxList<Map<String, dynamic>> productsList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> brands = <Map<String, dynamic>>[].obs;
  final RxList<ProductGroup> groupedProducts = <ProductGroup>[].obs;
  final RxString userId = ''.obs;
  final RxBool isLoading = false.obs;

  // Type counts for categories
  final RxInt carsCount = 0.obs;
  final RxInt bikesCount = 0.obs;
  final RxInt trucksCount = 0.obs;
  final RxInt planesCount = 0.obs;

  // Current applied filters
  final RxMap<String, dynamic> currentFilters = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = ApiService();
    fetchDetails().then((_) {
      getAllCategories();
      getAllBrands();
      loadProductCounts();
    });
  }

  /// Fetch user details from SharedPreferences
  Future<void> fetchDetails() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? id = preferences.getString('userId');
      if (id != null) {
        userId.value = id;
        print('[v0] Current userId: $id');
      }
    } catch (e) {
      print('[v0] Error fetching details: $e');
    }
  }

  /// Get all categories from API
  Future<void> getAllCategories() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get('/Categories/findAll');
      final List<Map<String, dynamic>> temp = [];

      if (response != null && response is List) {
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            temp.add(item);
          }
        }
      } else if (response is Map && response['data'] is List) {
        for (var item in response['data']) {
          if (item is Map<String, dynamic>) {
            temp.add(item);
          }
        }
      }
      categories.assignAll(temp);
      print('[v0] Loaded ${categories.length} categories');
    } catch (e) {
      print('[v0] Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all brands from API
  Future<void> getAllBrands() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get('/Brands/findAll');
      final List<Map<String, dynamic>> temp = [];

      if (response != null && response is List) {
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            temp.add(item);
          }
        }
      } else if (response is Map && response['data'] is List) {
        for (var item in response['data']) {
          if (item is Map<String, dynamic>) {
            temp.add(item);
          }
        }
      }
      brands.assignAll(temp);
      print('[v0] Loaded ${brands.length} brands');
    } catch (e) {
      print('[v0] Error loading brands: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all products from API
  Future<void> getAllProducts() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get('/Products/findAll');
      final List<Map<String, dynamic>> temp = [];

      if (response != null && response is List) {
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            temp.add(item);
          }
        }
      } else if (response is Map && response['data'] is List) {
        for (var item in response['data']) {
          if (item is Map<String, dynamic>) {
            temp.add(item);
          }
        }
      }
      productsList.assignAll(temp);
      _updateGroupedProducts();
      print('[v0] Loaded ${productsList.length} products');
    } catch (e) {
      print('[v0] Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load product counts by category type
  Future<void> loadProductCounts() async {
    try {
      await getAllProducts();

      // Count products by type/category
      carsCount.value = _countProductsByType('CARS');
      bikesCount.value = _countProductsByType('BIKES');
      trucksCount.value = _countProductsByType('TRUCKS');
      planesCount.value = _countProductsByType('PLANES');

      print('[v0] Product counts - Cars: ${carsCount.value}, Bikes: ${bikesCount.value}, Trucks: ${trucksCount.value}, Planes: ${planesCount.value}');
    } catch (e) {
      print('[v0] Error loading product counts: $e');
    }
  }

  /// Count products by type
  int _countProductsByType(String type) {
    int count = 0;
    for (var product in productsList) {
      String productType = (product['type'] ?? product['category'] ?? '').toString().toUpperCase();
      if (productType == type.toUpperCase()) {
        count++;
      }
    }
    return count;
  }

  /// Get products filtered by category/type
  List<Map<String, dynamic>> getProductsByType(String type) {
    List<Map<String, dynamic>> filtered = [];

    for (var product in productsList) {
      String productType = (product['type'] ?? product['category'] ?? '').toString().toUpperCase();
      if (type.toUpperCase() == 'ALL' || productType == type.toUpperCase()) {
        filtered.add(product);
      }
    }

    return filtered;
  }

  void _updateGroupedProducts() {
    List<Map<String, dynamic>> filtered = getFilteredProducts();
    List<ProductGroup> grouped = _groupProductsByName(filtered);
    groupedProducts.assignAll(grouped);
  }

  /// Apply filters for product search
  void applyFilters(Map<String, dynamic> filters) {
    currentFilters.value = Map.from(filters);
    print('[v0] Filters applied: $currentFilters');
    _updateGroupedProducts();
    update();
  }

  /// Clear all applied filters
  void clearFilters() {
    currentFilters.clear();
    print('[v0] Filters cleared');
    _updateGroupedProducts();
    update();
  }

  /// Get filtered products based on current filters
  List<Map<String, dynamic>> getFilteredProducts() {
    List<Map<String, dynamic>> filtered = List.from(productsList);

    // Filter by type/category
    final filterCategoryValue = currentFilters['type'] ?? currentFilters['category'];
    if (filterCategoryValue != null && filterCategoryValue.toString().isNotEmpty) {
      String filterType = filterCategoryValue.toString().toUpperCase();
      filtered = filtered.where((product) {
        String productType = (product['type'] ?? product['category'] ?? product['categoryName'] ?? '').toString().toUpperCase();
        return productType == filterType;
      }).toList();
    }

    // Filter by brand
    final filterBrandValue = currentFilters['name'] ?? currentFilters['brand'];
    if (filterBrandValue != null && filterBrandValue.toString().isNotEmpty) {
      String filterBrand = filterBrandValue.toString().toLowerCase();
      filtered = filtered.where((product) {
        String pBrand = (product['brandName'] ?? product['brand'] ?? '').toString().toLowerCase();
        return pBrand == filterBrand;
      }).toList();
    }

    // Filter by scale
    if (currentFilters['scale'] != null && currentFilters['scale'].toString().isNotEmpty) {
      String filterScale = currentFilters['scale'].toString().toLowerCase();
      filtered = filtered.where((product) {
        return (product['scale'] ?? '').toString().toLowerCase() == filterScale;
      }).toList();
    }

    // Filter by subcategory
    if (currentFilters['subCategory'] != null && currentFilters['subCategory'].toString().isNotEmpty) {
      String filterSub = currentFilters['subCategory'].toString().toLowerCase();
      filtered = filtered.where((product) {
        return (product['subCategory'] ?? '').toString().toLowerCase() == filterSub;
      }).toList();
    }

    // Filter by year
    if (currentFilters['year'] != null && currentFilters['year'].toString().isNotEmpty) {
      String filterYear = currentFilters['year'].toString().toLowerCase();
      filtered = filtered.where((product) {
        return (product['year'] ?? '').toString().toLowerCase() == filterYear;
      }).toList();
    }

    // Filter by yearRange
    if (currentFilters['yearRange'] != null && currentFilters['yearRange'] is List) {
      final List range = currentFilters['yearRange'] as List;
      if (range.length == 2) {
        int startYear = int.tryParse(range[0].toString()) ?? 0;
        int endYear = int.tryParse(range[1].toString()) ?? 9999;
        filtered = filtered.where((product) {
          int year = int.tryParse((product['year'] ?? '').toString()) ?? 0;
          if (year == 0) return true;
          return year >= startYear && year <= endYear;
        }).toList();
      }
    }

    // Filter by color
    if (currentFilters['color'] != null && currentFilters['color'].toString().isNotEmpty) {
      String filterColor = currentFilters['color'].toString().toLowerCase();
      filtered = filtered.where((product) {
        return (product['color'] ?? '').toString().toLowerCase() == filterColor;
      }).toList();
    }

    // Filter by price
    if (currentFilters['maxPrice'] != null) {
      double maxPrice = double.tryParse(currentFilters['maxPrice'].toString()) ?? double.infinity;
      filtered = filtered.where((product) {
        double price = double.tryParse(product['price'].toString()) ?? 0;
        return price <= maxPrice;
      }).toList();
    }

    return filtered;
  }

  /// Group filtered products by display name (for inventory grid)
  List<ProductGroup> _groupProductsByName(List<Map<String, dynamic>> products) {
    Map<String, List<Map<String, dynamic>>> groupedMap = {};

    for (var product in products) {
      String displayName = product['name']?.toString() ?? 'Unknown';
      if (!groupedMap.containsKey(displayName)) {
        groupedMap[displayName] = [];
      }
      groupedMap[displayName]!.add(product);
    }

    List<ProductGroup> groups = [];
    groupedMap.forEach((name, products) {
      groups.add(ProductGroup(
        id: products[0]['_id']?.toString() ?? '',
        displayName: name,
        brandName: (products[0]['brandName'] ?? products[0]['brand'] ?? '').toString(),
        imageUrl: (products[0]['imageUrl'] ?? products[0]['image'] ?? '').toString(),
        count: products.length,
        productIds: products.map((p) => p['_id']?.toString() ?? '').toList(),
        representativeProduct: products[0],
      ));
    });

    return groups;
  }

  /// Get filtered inventory as stream (used by screens)
  Stream<List<ProductGroup>> getFilteredInventory() {
    return Stream.fromFuture(Future.value(null)).asyncExpand((_) async* {
      yield groupedProducts;
      await for (final list in groupedProducts.stream) {
        yield list ?? [];
      }
    });
  }

  /// Get total product count
  int getTotalProductCount() {
    return productsList.length;
  }

  /// Get count by type as string
  String getCarsCount() => carsCount.value.toString();
  String getBikesCount() => bikesCount.value.toString();
  String getTrucksCount() => trucksCount.value.toString();
  String getPlanesCount() => planesCount.value.toString();

  /// Search products by name and brand
  List<ProductGroup> searchProducts(String query) {
    if (query.isEmpty) {
      return _groupProductsByName(productsList);
    }

    String searchQuery = query.toLowerCase();
    List<Map<String, dynamic>> results = productsList.where((product) {
      String name = (product['name'] ?? '').toString().toLowerCase();
      String brand = (product['brand'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery) || brand.contains(searchQuery);
    }).toList();

    return _groupProductsByName(results);
  }

  /// Get all products grouped by name
  List<ProductGroup> getAllGroupedProducts() {
    return _groupProductsByName(productsList);
  }

  /// Filter products by type
  List<ProductGroup> filterByType(String type) {
    List<Map<String, dynamic>> filtered = getProductsByType(type);
    return _groupProductsByName(filtered);
  }

  /// Filter products by brand
  List<ProductGroup> filterByBrand(String brand) {
    List<Map<String, dynamic>> filtered = productsList.where((product) {
      return (product['brand'] ?? '').toString().toLowerCase() == brand.toLowerCase();
    }).toList();
    return _groupProductsByName(filtered);
  }

  /// Get search results as stream
  Stream<List<ProductGroup>> searchProductsStream(String query) {
    return Stream.fromFuture(Future.microtask(() {
      return searchProducts(query);
    }));
  }

  /// Clear controller data
  void clear() {
    brands.clear();
    categories.clear();
    productsList.clear();
    currentFilters.clear();
    groupedProducts.clear();
    carsCount.value = 0;
    bikesCount.value = 0;
    trucksCount.value = 0;
    planesCount.value = 0;
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}

// class ProductGroup {
//   final String id;
//   final String displayName;
//   final String brandName;
//   final String imageUrl;
//   final int count;
//   final List<String> productIds;
//   final Map<String, dynamic> representativeProduct;
//
//   ProductGroup({
//     required this.id,
//     required this.displayName,
//     required this.brandName,
//     required this.imageUrl,
//     required this.count,
//     required this.productIds,
//     required this.representativeProduct,
//   });
// }
//
// class HomeController extends GetxController {
//   late ApiService _apiService;
//
//   // Reactive variables
//   final RxList<Map<String, dynamic>> productsList = <Map<String, dynamic>>[].obs;
//   final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
//   final RxList<Map<String, dynamic>> brands = <Map<String, dynamic>>[].obs;
//   final RxList<ProductGroup> groupedProducts = <ProductGroup>[].obs;
//   final RxString userId = ''.obs;
//   final RxBool isLoading = false.obs;
//
//   // Type counts for categories
//   final RxInt carsCount = 0.obs;
//   final RxInt bikesCount = 0.obs;
//   final RxInt trucksCount = 0.obs;
//   final RxInt planesCount = 0.obs;
//
//   // Current applied filters
//   final RxMap<String, dynamic> currentFilters = <String, dynamic>{}.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _apiService = ApiService();
//     fetchDetails().then((_) {
//       getAllCategories();
//       loadProductCounts();
//     });
//   }
//
//   /// Fetch user details from SharedPreferences
//   Future<void> fetchDetails() async {
//     try {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       String? id = preferences.getString('userId');
//       if (id != null) {
//         userId.value = id;
//         print('[v0] Current userId: $id');
//       }
//     } catch (e) {
//       print('[v0] Error fetching details: $e');
//     }
//   }
//
//   /// Get all categories from API
//   Future<void> getAllCategories() async {
//     try {
//       isLoading.value = true;
//
//       final response = await _apiService.get('/Categories/findAll');
//
//       if (response != null && response is List) {
//         categories.clear();
//         for (var item in response) {
//           if (item is Map<String, dynamic>) {
//             categories.add(item);
//           }
//         }
//         print('[v0] Loaded ${categories.length} categories');
//       } else if (response is Map && response['data'] is List) {
//         categories.clear();
//         for (var item in response['data']) {
//           if (item is Map<String, dynamic>) {
//             categories.add(item);
//           }
//         }
//         print('[v0] Loaded ${categories.length} categories from data field');
//       }
//     } catch (e) {
//       print('[v0] Error loading categories: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Get all brands from API
//   Future<void> getAllBrands() async {
//     try {
//       isLoading.value = true;
//
//       final response = await _apiService.get('/Brands/findAll');
//
//       if (response != null && response is List) {
//         brands.clear();
//         for (var item in response) {
//           if (item is Map<String, dynamic>) {
//             brands.add(item);
//           }
//         }
//         print('[v0] Loaded ${brands.length} brands');
//       } else if (response is Map && response['data'] is List) {
//         brands.clear();
//         for (var item in response['data']) {
//           if (item is Map<String, dynamic>) {
//             brands.add(item);
//           }
//         }
//         print('[v0] Loaded ${brands.length} brands from data field');
//       }
//     } catch (e) {
//       print('[v0] Error loading brands: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Get all products from API
//   Future<void> getAllProducts() async {
//     try {
//       isLoading.value = true;
//
//       final response = await _apiService.get('/Products/findAll');
//
//       productsList.clear();
//
//       if (response != null && response is List) {
//         for (var item in response) {
//           if (item is Map<String, dynamic>) {
//             productsList.add(item);
//           }
//         }
//         print('[v0] Loaded ${productsList.length} products');
//       } else if (response is Map && response['data'] is List) {
//         for (var item in response['data']) {
//           if (item is Map<String, dynamic>) {
//             productsList.add(item);
//           }
//         }
//         print('[v0] Loaded ${productsList.length} products from data field');
//       }
//     } catch (e) {
//       print('[v0] Error loading products: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Load product counts by category type
//   Future<void> loadProductCounts() async {
//     try {
//       await getAllProducts();
//
//       // Count products by type/category
//       carsCount.value = _countProductsByType('CARS');
//       bikesCount.value = _countProductsByType('BIKES');
//       trucksCount.value = _countProductsByType('TRUCKS');
//       planesCount.value = _countProductsByType('PLANES');
//
//       print('[v0] Product counts - Cars: ${carsCount.value}, Bikes: ${bikesCount.value}, Trucks: ${trucksCount.value}, Planes: ${planesCount.value}');
//     } catch (e) {
//       print('[v0] Error loading product counts: $e');
//     }
//   }
//
//   /// Count products by type
//   int _countProductsByType(String type) {
//     int count = 0;
//     for (var product in productsList) {
//       String productType = (product['type'] ?? product['category'] ?? '').toString().toUpperCase();
//       if (productType == type.toUpperCase()) {
//         count++;
//       }
//     }
//     return count;
//   }
//
//   /// Get products filtered by category/type
//   List<Map<String, dynamic>> getProductsByType(String type) {
//     List<Map<String, dynamic>> filtered = [];
//
//     for (var product in productsList) {
//       String productType = (product['type'] ?? product['category'] ?? '').toString().toUpperCase();
//       if (type.toUpperCase() == 'ALL' || productType == type.toUpperCase()) {
//         filtered.add(product);
//       }
//     }
//
//     return filtered;
//   }
//
//   /// Apply filters for product search
//   void applyFilters(Map<String, dynamic> filters) {
//     currentFilters.value = Map.from(filters);
//     print('[v0] Filters applied: $currentFilters');
//     update();
//   }
//
//   /// Clear all applied filters
//   void clearFilters() {
//     currentFilters.clear();
//     print('[v0] Filters cleared');
//     update();
//   }
//
//   /// Get filtered products based on current filters
//   List<Map<String, dynamic>> getFilteredProducts() {
//     List<Map<String, dynamic>> filtered = List.from(productsList);
//
//     // Filter by type/category
//     if (currentFilters['type'] != null && currentFilters['type'].toString().isNotEmpty) {
//       String filterType = currentFilters['type'].toString().toUpperCase();
//       filtered = filtered.where((product) {
//         String productType = (product['type'] ?? product['category'] ?? '').toString().toUpperCase();
//         return productType == filterType;
//       }).toList();
//     }
//
//     // Filter by brand/name
//     if (currentFilters['name'] != null && currentFilters['name'].toString().isNotEmpty) {
//       filtered = filtered.where((product) {
//         return (product['name'] ?? '').toString().toLowerCase() == currentFilters['name'].toString().toLowerCase();
//       }).toList();
//     }
//
//     // Filter by price
//     if (currentFilters['maxPrice'] != null) {
//       double maxPrice = double.tryParse(currentFilters['maxPrice'].toString()) ?? double.infinity;
//       filtered = filtered.where((product) {
//         double price = double.tryParse(product['price'].toString()) ?? 0;
//         return price <= maxPrice;
//       }).toList();
//     }
//
//     return filtered;
//   }
//
//   /// Group filtered products by display name (for inventory grid)
//   List<ProductGroup> _groupProductsByName(List<Map<String, dynamic>> products) {
//     Map<String, List<Map<String, dynamic>>> groupedMap = {};
//
//     for (var product in products) {
//       String displayName = product['name']?.toString() ?? 'Unknown';
//       if (!groupedMap.containsKey(displayName)) {
//         groupedMap[displayName] = [];
//       }
//       groupedMap[displayName]!.add(product);
//     }
//
//     List<ProductGroup> groups = [];
//     groupedMap.forEach((name, products) {
//       groups.add(ProductGroup(
//         id: products[0]['_id']?.toString() ?? '',
//         displayName: name,
//         brandName: products[0]['brand']?.toString() ?? '',
//         imageUrl: products[0]['image']?.toString() ?? '',
//         count: products.length,
//         productIds: products.map((p) => p['_id']?.toString() ?? '').toList(),
//         representativeProduct: products[0],
//       ));
//     });
//
//     return groups;
//   }
//
//   /// Get filtered inventory as stream (used by screens)
//   Stream<List<ProductGroup>> getFilteredInventory() {
//     return Stream.fromFuture(Future.microtask(() {
//       List<Map<String, dynamic>> filtered = getFilteredProducts();
//       List<ProductGroup> grouped = _groupProductsByName(filtered);
//       groupedProducts.value = grouped;
//       print('[v0] Filtered inventory: ${grouped.length} product groups');
//       return grouped;
//     }));
//   }
//
//   /// Get total product count
//   int getTotalProductCount() {
//     return productsList.length;
//   }
//
//   /// Get count by type as string
//   String getCarsCount() => carsCount.value.toString();
//   String getBikesCount() => bikesCount.value.toString();
//   String getTrucksCount() => trucksCount.value.toString();
//   String getPlanesCount() => planesCount.value.toString();
//
//   /// Search products by name and brand
//   List<ProductGroup> searchProducts(String query) {
//     if (query.isEmpty) {
//       return _groupProductsByName(productsList);
//     }
//
//     String searchQuery = query.toLowerCase();
//     List<Map<String, dynamic>> results = productsList.where((product) {
//       String name = (product['name'] ?? '').toString().toLowerCase();
//       String brand = (product['brand'] ?? '').toString().toLowerCase();
//       return name.contains(searchQuery) || brand.contains(searchQuery);
//     }).toList();
//
//     return _groupProductsByName(results);
//   }
//
//   /// Get all products grouped by name
//   List<ProductGroup> getAllGroupedProducts() {
//     return _groupProductsByName(productsList);
//   }
//
//   /// Filter products by type
//   List<ProductGroup> filterByType(String type) {
//     List<Map<String, dynamic>> filtered = getProductsByType(type);
//     return _groupProductsByName(filtered);
//   }
//
//   /// Filter products by brand
//   List<ProductGroup> filterByBrand(String brand) {
//     List<Map<String, dynamic>> filtered = productsList.where((product) {
//       return (product['brand'] ?? '').toString().toLowerCase() == brand.toLowerCase();
//     }).toList();
//     return _groupProductsByName(filtered);
//   }
//
//   /// Get search results as stream
//   Stream<List<ProductGroup>> searchProductsStream(String query) {
//     return Stream.fromFuture(Future.microtask(() {
//       return searchProducts(query);
//     }));
//   }
//
//   /// Clear controller data
//   void clear() {
//     brands.clear();
//     categories.clear();
//     productsList.clear();
//     currentFilters.clear();
//     carsCount.value = 0;
//     bikesCount.value = 0;
//     trucksCount.value = 0;
//     planesCount.value = 0;
//   }
//
//   @override
//   void onClose() {
//     clear();
//     super.onClose();
//   }
// }




// class HomeController extends GetxController {
//   List<Map<String, dynamic>> productsList = [];
//   List<Map<String, dynamic>> brands = [];
//   String? userId;
//
//   // Current applied filters
//   Map<String, dynamic> currentFilters = {};
//
//   fetchDetails() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     userId = preferences.getString('userId');
//     print('Current userId: $userId'); // Debug print
//     update();
//   }
//
//   void applyFilters(Map<String, dynamic> filters) {
//     currentFilters = Map.from(filters);
//     update();
//   }
//
//   void clearFilters() {
//     currentFilters.clear();
//     update();
//   }
//
//   // Main method to get filtered and grouped inventory
//   Stream<List<ProductGroup>> getFilteredInventory() {
//     // Ensure userId is available
//     if (userId == null) {
//       return Stream.value([]);
//     }
//
//     // Start with base query filtering by current user
//     Query query = FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId);
//
//     // Apply additional filters if any
//     if (currentFilters.isNotEmpty) {
//       // Apply brand filter
//       if (currentFilters['brand'] != null &&
//           currentFilters['brand'].toString().isNotEmpty) {
//         query = query.where('brand', isEqualTo: currentFilters['brand']);
//       }
//
//       // Apply category filter
//       if (currentFilters['category'] != null &&
//           currentFilters['category'].toString().isNotEmpty) {
//         query = query.where('category', isEqualTo: currentFilters['category']);
//       }
//
//       // Apply scale filter
//       if (currentFilters['scale'] != null &&
//           currentFilters['scale'].toString().isNotEmpty) {
//         query = query.where('scale', isEqualTo: currentFilters['scale']);
//       }
//
//       // Apply year filter
//       if (currentFilters['year'] != null &&
//           (currentFilters['year'] as String).isNotEmpty) {
//         query = query.where('year', isEqualTo: currentFilters['year']);
//       }
//       if (currentFilters['type'] != null &&
//           (currentFilters['type'] as String).isNotEmpty) {
//         query = query.where('type', isEqualTo: currentFilters['type']);
//       }
//
//       // Apply price filter
//       if (currentFilters['price'] != null &&
//           (currentFilters['price'] as String).isNotEmpty) {
//         double maxPrice = double.tryParse(currentFilters['price']) ?? double.infinity;
//         query = query.where('price', isLessThanOrEqualTo: maxPrice.toString());
//       }
//     }
//
//     return query.snapshots().map((snapshot) {
//       return _groupProducts(snapshot.docs);
//     });
//   }
//
//   // Helper method to group products
//   List<ProductGroup> _groupProducts(List<DocumentSnapshot> docs) {
//     Map<String, List<DocumentSnapshot>> groupedProducts = {};
//
//     for (DocumentSnapshot doc in docs) {
//       String uniqueKey = _createProductKey(doc);
//
//       if (groupedProducts.containsKey(uniqueKey)) {
//         groupedProducts[uniqueKey]!.add(doc);
//       } else {
//         groupedProducts[uniqueKey] = [doc];
//       }
//     }
//
//     // Convert to ProductGroup list and sort by name
//     List<ProductGroup> productGroups = groupedProducts.entries.map((entry) {
//       return ProductGroup(
//         products: entry.value,
//         count: entry.value.length,
//         representativeProduct: entry.value.first,
//         uniqueKey: entry.key,
//       );
//     }).toList();
//
//     // Sort by product name for consistent display
//     productGroups.sort((a, b) {
//       Map<String, dynamic> dataA = a.representativeProduct.data() as Map<String, dynamic>;
//       Map<String, dynamic> dataB = b.representativeProduct.data() as Map<String, dynamic>;
//       return (dataA['name'] ?? '').toString().compareTo((dataB['name'] ?? '').toString());
//     });
//
//     return productGroups;
//   }
//
//   // Create unique key for grouping products
//   String _createProductKey(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//     // Group by essential product characteristics
//     String name = (data['name'] ?? '').toString().toLowerCase().trim();
//     String brand = (data['brand'] ?? '').toString().toLowerCase().trim();
//     String category = (data['category'] ?? '').toString().toLowerCase().trim();
//     String scale = (data['scale'] ?? '').toString().toLowerCase().trim();
//     String year = (data['year'] ?? '').toString().trim();
//
//     return '${name}_${brand}_${category}_${scale}_${year}';
//   }
//
//   // Get all products for the current user (if needed elsewhere)
//   void getAllProducts() async {
//     if (userId == null) return;
//
//     productsList = [];
//     final snapshot = await FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId)
//         .get();
//
//     for (var document in snapshot.docs) {
//       productsList.add(document.data());
//     }
//     update();
//     print('User Products Count: ${productsList.length}');
//   }
//
//   Future<void> getAllCategories() async {
//     brands = [];
//     final snapshot = await FirebaseFirestore.instance.collection('Brand').get();
//     for (var document in snapshot.docs) {
//       brands.add(document.data());
//     }
//     update();
//   }
//
//   // Get total count of user's products
//   Future<int> getTotalProductCount() async {
//     if (userId == null) return 0;
//
//     final snapshot = await FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId)
//         .get();
//
//     return snapshot.docs.length;
//   }
//
//   // Get total count of unique products (groups)
//   Future<int> getUniqueProductCount() async {
//     if (userId == null) return 0;
//
//     final snapshot = await FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId)
//         .get();
//
//     return _groupProducts(snapshot.docs).length;
//   }
//
//   clear() {
//     brands.clear();
//     productsList.clear();
//     currentFilters.clear();
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDetails().then((_) {
//       getAllCategories();
//     });
//   }
// }

// Enhanced ProductGroup class


// class ProductGroup {
//   final List<DocumentSnapshot> products;
//   final int count;
//   final DocumentSnapshot representativeProduct;
//   final String uniqueKey;
//
//   ProductGroup({
//     required this.products,
//     required this.count,
//     required this.representativeProduct,
//     required this.uniqueKey,
//   });
//
//   // Get product data from representative product
//   Map<String, dynamic> get productData =>
//       representativeProduct.data() as Map<String, dynamic>;
//
//   // Get all product IDs in this group
//   List<String> get productIds => products.map((doc) => doc.id).toList();
//
//   // Get display name
//   String get displayName => productData['name'] ?? 'Unknown Product';
//
//   // Get brand name
//   String get brandName => productData['brand'] ?? 'Unknown Brand';
//
//   // Get image URL
//   String get imageUrl => productData['image'] ?? '';
//
//   // Get price
//   String get price => productData['price'] ?? '0';
// }


///
// class HomeController extends AppBaseController {
//   List<Map<String, dynamic>> productsList = [];
//   List<Map<String, dynamic>> brands = [];
//
//   String? userId;
//
//   fetchDetails() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     userId = preferences.getString('userId');
//     update();
//   }
//
//   Stream<QuerySnapshot>? _filteredStream;
//
//   void applyFilters(Map<String, dynamic> filters) {
//     Query query = FirebaseFirestore.instance.collection('Products');
//
//     // Apply brand filter
//     if (filters['brand'] != null && filters['brand'].toString().isNotEmpty) {
//       query = query.where('brand', isEqualTo: filters['brand']);
//     }
//
//     // Apply category filter
//     if (filters['category'] != null && filters['category'].toString().isNotEmpty) {
//       query = query.where('category', isEqualTo: filters['category']);
//     }
//
//     // Apply scale filter
//     if (filters['scale'] != null && filters['scale'].toString().isNotEmpty) {
//       query = query.where('scale', isEqualTo: filters['scale']);
//     }
//
//     // Apply year filter
//     if (filters['year'] != null && (filters['year'] as String).isNotEmpty) {
//       query = query.where('year', isEqualTo: filters['year']);
//     }
//
//     // Apply price filter
//     if (filters['price'] != null && (filters['price'] as String).isNotEmpty) {
//       double maxPrice = double.tryParse(filters['price']) ?? double.infinity;
//       query = query.where('price', isLessThanOrEqualTo: maxPrice.toString());
//     }
//
//     // Update the filtered stream
//     _filteredStream = query.snapshots();
//     update(); // Trigger rebuild
//   }
//
//   // Method to clear all filters and reset to original data
//   void clearFilters() {
//     _filteredStream = null;
//     update();
//   }
//
//   // Method to get filtered inventory
//   Stream<List<DocumentSnapshot>> getFilteredInventory() {
//     _filteredStream ??= FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId)
//         .snapshots();
//
//     return _filteredStream!.map((snapshot) => snapshot.docs);
//   }
//
//   void getAllProducts() async {
//     productsList = [];
//     final snapshot =
//     await FirebaseFirestore.instance.collection('Products').get();
//     snapshot.docs.forEach((document) {
//       productsList.add(document.data());
//     });
//     update();
//
//     print('Data: $productsList');
//   }
//
//   List<DocumentSnapshot> filteredDocs = [];
//
//   Stream<List<DocumentSnapshot>> getUserInventory() async* {
//     await for (var snapshot in FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId)
//         .snapshots()) {
//       filteredDocs.clear();
//       filteredDocs.addAll(snapshot.docs);
//
//       // Yield the filtered list of DocumentSnapshot objects
//       yield filteredDocs;
//     }
//   }
//
//   // Updated to return Future for pull-to-refresh
//   Future<void> getAllCategories() async {
//     brands = [];
//     final snapshot = await FirebaseFirestore.instance.collection('Brand').get();
//     for (var document in snapshot.docs) {
//       brands.add(document.data());
//     }
//     update();
//   }
//
//   clear() {
//     brands.clear();
//     productsList.clear();
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDetails();
//     getAllCategories();
//   }
// }
///
// class HomeController extends AppBaseController {
//   List<Map<String, dynamic>> productsList = [];
//   List<Map<String, dynamic>> brands = [];
//   String? userId;
//
//   Stream<QuerySnapshot>? _filteredStream;
//   bool _filtersApplied = false;
//
//   fetchDetails() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     userId = preferences.getString('userId');
//     update();
//   }
//
//   void applyFilters(Map<String, dynamic> filters) {
//     Query query = FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId); // Keep user filtering
//
//     bool hasFilters = false;
//
//     // Apply brand filter
//     if (filters['brand'] != null && filters['brand'].toString().isNotEmpty) {
//       query = query.where('brand', isEqualTo: filters['brand']);
//       hasFilters = true;
//     }
//
//     // Apply category filter
//     if (filters['category'] != null && filters['category'].toString().isNotEmpty) {
//       query = query.where('category', isEqualTo: filters['category']);
//       hasFilters = true;
//     }
//
//     // Apply scale filter
//     if (filters['scale'] != null && filters['scale'].toString().isNotEmpty) {
//       query = query.where('scale', isEqualTo: filters['scale']);
//       hasFilters = true;
//     }
//
//     // Apply year filter
//     if (filters['year'] != null && (filters['year'] as String).isNotEmpty) {
//       query = query.where('year', isEqualTo: filters['year']);
//       hasFilters = true;
//     }
//
//     // Apply price filter
//     if (filters['price'] != null && (filters['price'] as String).isNotEmpty) {
//       double maxPrice = double.tryParse(filters['price']) ?? double.infinity;
//       query = query.where('price', isLessThanOrEqualTo: maxPrice.toString());
//       hasFilters = true;
//     }
//
//     // Update the filtered stream
//     _filteredStream = query.snapshots();
//     _filtersApplied = hasFilters;
//     update(); // Trigger rebuild
//   }
//
//   // Clear filters method
//   void clearFilters() {
//     _filteredStream = null;
//     _filtersApplied = false;
//     update();
//   }
//
//   // Method to get filtered inventory
//   Stream<List<DocumentSnapshot>> getFilteredInventory() {
//     if (_filteredStream != null) {
//       return _filteredStream!.map((snapshot) => snapshot.docs);
//     }
//
//     // Default stream when no filters applied
//     return getUserInventory();
//   }
//
//   void getAllProducts() async {
//     productsList = [];
//     final snapshot =
//     await FirebaseFirestore.instance.collection('Products').get();
//     snapshot.docs.forEach((document) {
//       productsList.add(document.data());
//     });
//     update();
//     print('Data: $productsList');
//   }
//
//   List<DocumentSnapshot> filteredDocs = [];
//
//   Stream<List<DocumentSnapshot>> getUserInventory() async* {
//     await for (var snapshot in FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId)
//         .snapshots()) {
//       filteredDocs.clear();
//       filteredDocs.addAll(snapshot.docs);
//       yield filteredDocs;
//     }
//   }
//
//   void getAllCategories() async {
//     brands = [];
//     final snapshot = await FirebaseFirestore.instance.collection('Brand').get();
//     for (var document in snapshot.docs) {
//       brands.add(document.data());
//     }
//     update();
//   }
//
//   // Check if filters are applied
//   bool get hasFiltersApplied => _filtersApplied;
//
//   clear() {
//     brands.clear();
//     productsList.clear();
//     _filteredStream = null;
//     _filtersApplied = false;
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDetails();
//     getAllCategories();
//   }
// }

// class HomeController extends AppBaseController {
//   List<Map<String, dynamic>> productsList = [];
//
//   List<Map<String, dynamic>> brands = [];
//
//   String? userId;
//   fetchDetails() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     userId = preferences.getString('userId');
//     update();
//   }
//   Stream<QuerySnapshot>? _filteredStream;
//
//   // Your existing code...
//
//   void applyFilters(Map<String, dynamic> filters) {
//     Query query = FirebaseFirestore.instance.collection('Products');
//
//     // Apply brand filter
//     if (filters['brand'] != null && filters['brand'].toString().isNotEmpty) {
//       query = query.where('brand', isEqualTo: filters['brand']);
//     }
//
//     // Apply category filter
//     if (filters['category'] != null && filters['category'].toString().isNotEmpty) {
//       query = query.where('category', isEqualTo: filters['category']);
//     }
//
//     // Apply scale filter
//     if (filters['scale'] != null && filters['scale'].toString().isNotEmpty) {
//       query = query.where('scale', isEqualTo: filters['scale']);
//     }
//
//     // Apply year filter
//     if (filters['year'] != null && (filters['year'] as String).isNotEmpty) {
//       query = query.where('year', isEqualTo: filters['year']);
//     }
//
//     // Apply price filter
//     if (filters['price'] != null && (filters['price'] as String).isNotEmpty) {
//       double maxPrice = double.tryParse(filters['price']) ?? double.infinity;
//       query = query.where('price', isLessThanOrEqualTo: maxPrice.toString());
//     }
//
//     // Update the filtered stream
//     _filteredStream = query.snapshots();
//     update(); // Trigger rebuild
//   }
//
//   // Method to get filtered inventory
//   Stream<List<DocumentSnapshot>> getFilteredInventory() {
//     _filteredStream ??= FirebaseFirestore.instance.collection('Products').snapshots();
//
//     return _filteredStream!.map((snapshot) => snapshot.docs);
//   }
//
//   // Your existing getUserInventory method for reference
//   // Stream<List<DocumentSnapshot>> getUserInventory() {
//   //   return FirebaseFirestore.instance
//   //       .collection('Products')
//   //       .snapshots()
//   //       .map((snapshot) => snapshot.docs);
//   // }
//
//   // void applyFilters(Map<String, dynamic> filters) {
//   //   Query query = FirebaseFirestore.instance.collection('Products');
//   //
//   //   if (filters['brand'] != null) {
//   //     query = query.where('brand', isEqualTo: filters['brand']);
//   //   }
//   //   if (filters['category'] != null) {
//   //     query = query.where('category', isEqualTo: filters['category']);
//   //   }
//   //   if (filters['scale'] != null) {
//   //     query = query.where('scale', isEqualTo: filters['scale']);
//   //   }
//   //   if ((filters['year'] as String).isNotEmpty) {
//   //     query = query.where('year', isEqualTo: filters['year']);
//   //   }
//   //   if ((filters['price'] as String).isNotEmpty) {
//   //     double maxPrice = double.tryParse(filters['price']) ?? double.infinity;
//   //     query = query.where('price', isLessThanOrEqualTo: maxPrice.toString());
//   //   }
//   //
//   //
//   //   update(); // trigger rebuild
//   //   DashboardScreenState().stream = query.snapshots();
//   // }
//
//
//   void getAllProducts() async {
//     productsList = [];
//     final snapshot =
//         await FirebaseFirestore.instance.collection('Products').get();
//     snapshot.docs.forEach((document) {
//       productsList.add(document.data());
//     });
//     update();
//
//     print('Data: $productsList');
//   }
//
//   List<DocumentSnapshot> filteredDocs = [];
//
//   Stream<List<DocumentSnapshot>> getUserInventory() async* {
//     await for (var snapshot in FirebaseFirestore.instance
//         .collection('Products')
//         .where('createdBy', isEqualTo: userId)
//         .snapshots()) {
//       filteredDocs.clear();
//       filteredDocs.addAll(snapshot.docs);
//
//       // Yield the filtered list of DocumentSnapshot objects
//       yield filteredDocs;
//     }
//   }
//
//
//   void getAllCategories() async {
//     brands = [];
//     final snapshot = await FirebaseFirestore.instance.collection('Brand').get();
//     for (var document in snapshot.docs) {
//       brands.add(document.data());
//     }
//     update();
//   }
//
//   clear() {
//     brands.clear();
//     productsList.clear();
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDetails();
//     // getAllProducts();
//     getAllCategories();
//   }
// }
