
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/app_exceptions.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/auth_services.dart';
import 'package:thinkdiecast/controllers/appbase_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkdiecast/views/Authview/login_screen.dart';
import 'package:thinkdiecast/views/DashboardView/dashboard_screen.dart';
import 'package:thinkdiecast/views/DashboardView/home_screen.dart';
import '../utils/widgets.dart';


import 'package:get/get.dart';

import '../models/user_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  // Observables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final currentUser = Rxn<User>();
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }


  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      isLoggedIn.value = isAuth;

      if (isAuth) {
        final user = await _authService.getCurrentUser();
        currentUser.value = user;
      }
    } catch (e) {
      debugPrint('[LoginController] Auth check error: $e');
    }
  }

  /// Login with email and password
  ///
  /// Parameters:
  /// - email: User's email address
  /// - password: User's password
  ///
  /// Returns: true if login successful, false otherwise
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      update();

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Email and password are required';
        showSnackBar(errorMessage.value);
        return false;
      }

      if (!email.contains('@')) {
        errorMessage.value = 'Please enter a valid email address';
        showSnackBar(errorMessage.value);
        return false;
      }

      // Call auth service
      final authResponse = await _authService.login(
        email1: email,
        password: password,
      );

      print('this is my login response $authResponse');

      // Update state
      currentUser.value = authResponse.user;
      isLoggedIn.value = true;
      successMessage.value = 'Login successful';
      showSnackBar('Logged in successfully!');

      _goToHome();
      return true;
    } catch (e, stack) {
      debugPrint('[LoginController] RAW ERROR: $e');
      debugPrint('[LoginController] STACK TRACE: $stack');
      // classifyError turns SocketException/401/etc into one clean,
      // specific message instead of the old nested
      // "network error: unauthorised" mess.
      final appError = classifyError(e);
      debugPrint('[LoginController] Login error: $appError');

      errorMessage.value = appError.message;
      isLoggedIn.value = false;
      showSnackBar(errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
      update();
    }
  }

  /// Register a new user, then automatically log them in and navigate
  /// to the home/dashboard screen.
  ///
  /// Parameters:
  /// - name: User's full name
  /// - email: User's email address
  /// - password: User's password
  /// - city: User's city
  /// - phone: User's phone number
  ///
  /// Returns: true if registration (and the follow-up login) succeeded
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String city,
    required String phone,
  }) async {
    print('this is name $name');
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      update();

      // Validate inputs
      if (name.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          city.isEmpty ||
          phone.isEmpty) {
        errorMessage.value = 'All fields are required';
        showSnackBar(errorMessage.value);
        return false;
      }

      if (!email.contains('@')) {
        errorMessage.value = 'Please enter a valid email address';
        showSnackBar(errorMessage.value);
        return false;
      }

      if (password.length < 6) {
        errorMessage.value = 'Password must be at least 6 characters';
        showSnackBar(errorMessage.value);
        return false;
      }

      print('this is email $email');
      // Call auth service to create the account
      await _authService.register(
        name: name,
        email1: email,
        password: password,
        city: city,
        phone: phone,
        plan: 'free',
        limit: 5,
        entries: 0,
      );

      successMessage.value = 'Registration successful. Logging you in...';
      update();

      // Auto-login right after a successful signup, then navigate.
      // login() sets its own isLoading/errorMessage and will show a
      // snackbar + navigate to home if it succeeds.
      final loggedIn = await login(email: email, password: password);
      return loggedIn;
    } catch (e) {
      final appError = classifyError(e);
      debugPrint('[LoginController] Register error: $appError');

      errorMessage.value = appError.message;
      showSnackBar(errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
      update();
    }
  }
  clear(){
    nameController.clear();
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    cityController.clear();
    update();
  }

  /// Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      update();

      await _authService.logout();

      // Update state
      currentUser.value = null;
      isLoggedIn.value = false;
      successMessage.value = 'Logout successful';

      // TODO: swap in your actual LoginScreen import/class if this
      // controller lives alongside it.
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      final appError = classifyError(e);
      errorMessage.value = appError.message;
      showSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  /// Navigate to the home/dashboard screen after a successful login
  /// (whether that login was explicit, or the auto-login that follows
  /// a successful signup). Uses GetX navigation so it works without a
  /// BuildContext, keeping LoginScreen/SignUpScreen untouched.
  void _goToHome() {
    // TODO: replace HomeScreen with your actual dashboard widget.
    Get.offAll(() => const DashboardScreen());
  }

  /// Clear error message
  void clearErrorMessage() {
    errorMessage.value = '';
  }

  /// Clear success message
  void clearSuccessMessage() {
    successMessage.value = '';
  }

  /// Get current user
  User? get user => currentUser.value;

  /// Check if user is authenticated
  bool get authenticated => isLoggedIn.value;

  /// Check if loading
  bool get loading => isLoading.value;

  /// Get error message
  String get error => errorMessage.value;

  /// Get success message
  String get success => successMessage.value;
}

