import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
// import 'package:thinkdiecast/controller/splash_controller.dart';
// import 'package:thinkdiecast/model/ShopViewModel/shops_list_model.dart';
// import 'package:thinkdiecast/view/Auth_View/login_screen.dart';
// import 'package:thinkdiecast/view/Dashboard/dashboard_screen.dart';
// import 'package:thinkdiecast/view/Shop/shops_screen.dart';

import 'package:thinkdiecast/controllers/refresh_controller.dart';
import 'package:thinkdiecast/controllers/network_controller.dart';

class ScreenBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(AppRefreshController(), permanent: true);
    Get.put(NetworkController(), permanent: true);
  }
}
