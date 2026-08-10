import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';
import 'package:thinkdiecast/controllers/appbase_controller.dart';
import 'package:thinkdiecast/views/Authview/login_screen.dart';
import 'package:thinkdiecast/views/DashboardView/dashboard_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkdiecast/views/splash_screen.dart';

class SplashController extends AppBaseController {
  String? userId;
  bool? isOnboard;
  String? token;

  final ApiService _apiService = ApiService();

  getAuthToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('userId');
     token = await _apiService.getToken();
    // isOnboard = preferences.getBool('isOnboard');
    update();
    print('authToken--->>> $isOnboard $token');
    // await Firebase.initializeApp();
  }

  Future<void> onInit() async {
    getAuthToken();

    Timer(const Duration(seconds: 6), () {
      if (token == null || token == '') {
        // Get.offAll( const DashboardScreen());
        Get.offAll(const LoginScreen());
      } else {
        // if (isOnboard!) {
        //   // Get.offAll(const  ShopsScreen());
        // } else {
        Get.offAll( const DashboardScreen());
        // }
      }
    });
    super.onInit();
  }
}
