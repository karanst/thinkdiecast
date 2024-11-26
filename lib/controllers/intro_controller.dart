import 'dart:convert';

import 'package:thinkdiecast/ApiHandler/Services/api.dart';
import 'package:thinkdiecast/controllers/appbase_controller.dart';
import 'package:thinkdiecast/route_management/routes.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
// import 'package:otp_text_field/otp_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../utils/widgets.dart';

class IntroController extends AppBaseController {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String pin = '';

  final formkey = GlobalKey<FormState>();
  int value1 = 0;
  bool isVisible = true;

  @override
  void onInit() {
    super.onInit();
    getAuthToken();
    // getUserCurrentLocation();
  }

  clear() {
    usernameController.clear();
    passwordController.clear();
  }

  //
  // List<Data> loginData = [];

  Api api = Api();

  String currentAddress = '';
  double homeLat = 0;
  double homeLong = 0;

  bool isAllowed = false;

  String? authToken;

  getAuthToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    authToken = preferences.getString('token');
    update();
    print('authToken--- $authToken');
    if (authToken != null || authToken != '') {
      update();
    }
  }

  Future<void> attendanceCheck() async {
    setBusy(true);
    try {
      var res =
          await api.checkAttendanceApi(homeLat, homeLong, authToken.toString());
      if (res.status == true) {
        isAllowed = res.items!.allowed!;

        setBusy(false);
        clear();
        update();
        if (!isAllowed) {
          showSnackBar('Permission denied at your location!');
        }
        // ShowMessage.showSnackBar('Server Res', '${res.message}');
      } else {
        isAllowed = false;
        showSnackBar(res.message.toString());
        // Fluttertoast.showToast(msg: "${res.message}");
        //ShowMessage.showSnackBar('Server Res', '${res.message}');
      }
    } catch (e) {
      showSnackBar('$e');
    } finally {
      setBusy(false);
      update();
    }
  }

  Future<void> employeePunch(String action) async {
    setBusy(true);
    try {
      var res = await api.punchInOutApi(action, authToken.toString());
      if (res.status == true) {
        showSnackBar(res.message.toString());
        Get.toNamed(homeScreen);
        setBusy(false);
        clear();
        update();
        // ShowMessage.showSnackBar('Server Res', '${res.message}');
      } else {
        showSnackBar(res.message.toString());
        // Fluttertoast.showToast(msg: "${res.message}");
        //ShowMessage.showSnackBar('Server Res', '${res.message}');
      }
    } catch (e) {
      showSnackBar('$e');
    } finally {
      setBusy(false);
      update();
    }
  }

  // Position? currentLocation;
  // LocationPermission? permission;
  //
  // Future<Position> determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   permission = await Geolocator.requestPermission();
  //
  //   if (permission == LocationPermission.denied) {
  //     return Future.error('Location permissions are denied');
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.low);
  //   print(position);
  //
  //   return await Geolocator.getCurrentPosition();
  // }
  //
  // Future getUserCurrentLocation() async {
  //   // _determinePosition();
  //   permission = await Geolocator.requestPermission();
  //   await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.medium)
  //       .then((position) {
  //     currentLocation = position;
  //     homeLat = currentLocation!.latitude;
  //     homeLong = currentLocation!.longitude;
  //     update();
  //     attendanceCheck();
  //   });
  //   print("LOCATION===" + currentLocation.toString());
  // }
}
