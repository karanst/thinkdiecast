import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:thinkdiecast/controllers/appbase_controller.dart';
import 'package:thinkdiecast/views/dashboard_screen.dart';
import 'package:thinkdiecast/views/intro_screen.dart';
import 'package:thinkdiecast/views/Authview/login_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends AppBaseController {
  String? userId;
  bool? isOnboard;

  getAuthToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('userId');
    // isOnboard = preferences.getBool('isOnboard');
    update();
    // print('authToken--->>> $isOnboard $authToken');
    // await Firebase.initializeApp();
  }

  Future<void> onInit() async {
    getAuthToken();

    Timer(const Duration(seconds: 4), () {
      if (userId == null || userId == '') {
        Get.offAll(const LoginScreen());
      } else {
        // if (isOnboard!) {
        //   // Get.offAll(const  ShopsScreen());
        // } else {
        Get.offAll(const DashboardScreen());
        // }
      }
    });
    super.onInit();
  }
}
