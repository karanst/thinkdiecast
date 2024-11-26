import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:thinkdiecast/ApiHandler/Services/api.dart';
import 'package:thinkdiecast/controllers/appbase_controller.dart';
import 'package:thinkdiecast/route_management/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
// import 'package:otp_text_field/otp_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:thinkdiecast/views/dashboard_screen.dart';

import '../utils/widgets.dart';

class LoginController extends AppBaseController {
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String pin = '';
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  int value1 = 0;
  bool isVisible = true;

  bool shoPass = true;
  bool shoPass2 = true;
  bool loading = false;

  @override
  void onInit() {
    super.onInit();
  }

  clear() {
    usernameController.clear();
    passwordController.clear();
  }

  //
  // List<Data> loginData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void login(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );
      final User user = userCredential.user!;

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('userId', user.uid);
      print("this is login status ${user.uid}");

      showSnackBar('User Logged in successfully!');

      // Successful login, navigate to another page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle login error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Login Failed"),
          content: Text(e.message!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void signUp(BuildContext context) async {
    loading = true;
    update();
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: usernameController.text.toString(),
        password: passwordController.text.toString(),
      )
          .then((user) async {
        await user.user?.updateDisplayName(nameController.text.toString());
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('userId', user.user!.uid);
        print("this is login status ${user.user!.uid}");
        await firestore.collection('Users').doc(user.user!.uid).set({
          'name': nameController.text.toString(),
          'email': usernameController.text.toString(),
          'pass': passwordController.text.toString() ?? '',
          'uid': user.user!.uid,
          'limit': '50',
          'entries': '0',
          'plan': 'free'
        });
        loading = false;
        update();
      });

      showSnackBar('User Created and Logged in successfully!');
      // Successful login, navigate to another page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle login error
      loading = false;
      update();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Login Failed"),
          content: Text(e.message!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Future<void> loginUser() async {
  //   setBusy(true);
  //   try {
  //     Map<String, String> body = {};
  //
  //     body['userName'] = usernameController.text.toString();
  //     body['password'] = passwordController.text.toString();
  //
  //     // SendOtpModel res = await api.loginUserApi(body);
  //     var res = await api.loginUserApi(body);
  //     if (res.status == true) {
  //       String authToken = res.items!.token.toString();
  //       SharedPreferences preferences = await SharedPreferences.getInstance();
  //       preferences.setString('token', authToken);
  //       // showSnackBar(res.message.toString());
  //       // otp = res.items!.otp.toString();
  //       // reqID = res.items!.reqId.toString();
  //       Get.toNamed(introScreen);
  //       setBusy(false);
  //       clear();
  //       update();
  //       // ShowMessage.showSnackBar('Server Res', '${res.message}');
  //     } else {
  //       showSnackBar(res.message.toString());
  //       // Fluttertoast.showToast(msg: "${res.message}");
  //       //ShowMessage.showSnackBar('Server Res', '${res.message}');
  //     }
  //   } catch (e) {
  //     showSnackBar('$e');
  //   } finally {
  //     setBusy(false);
  //     update();
  //   }
  // }
}
