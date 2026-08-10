import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/utils/colors.dart';

void showCustomToast(String message, {bool isSuccess = true}) {
  Get.rawSnackbar(
    messageText: Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.grad1Clr, AppColors.grad2Clr],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(2.5), // Border thickness
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSuccess ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.transparent,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 350),
  );
}
