import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';

/// Central controller that coordinates refreshes of all active controllers.
/// Using this, you can trigger data reload from anywhere in the app,
/// and it will automatically update the UI lists reactively.
class AppRefreshController extends GetxController {
  static AppRefreshController get to => Get.find<AppRefreshController>();

  /// Selected tab index for Dashboard Screen
  final RxInt selectedTab = 0.obs;

  /// Change active dashboard tab index
  void changeTab(int index) {
    selectedTab.value = index;
  }

  /// Refresh products list and category counts in HomeController
  Future<void> refreshProducts() async {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      await homeController.getAllProducts();
      await homeController.loadProductCounts();
    }
    await refreshUserProfile();
  }

  /// Refresh categories list in HomeController
  Future<void> refreshCategories() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().getAllCategories();
    }
  }

  /// Refresh brands list in HomeController
  Future<void> refreshBrands() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().getAllBrands();
    }
  }

  /// Refresh user profile and limits/entries in UserController
  Future<void> refreshUserProfile() async {
    if (Get.isRegistered<UserController>()) {
      await Get.find<UserController>().fetchUserProfile();
    }
  }

  /// Centralized refresh for all data (Products, Categories, Brands, User)
  Future<void> refreshAll() async {
    await Future.wait([
      refreshProducts(),
      refreshCategories(),
      refreshBrands(),
      refreshUserProfile(),
    ]);
  }
}
