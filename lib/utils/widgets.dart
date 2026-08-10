import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

SnackbarController showSnackBar(String msg) {
  return Get.showSnackbar(
    GetSnackBar(
      backgroundColor: AppColors.primary,
      // title: msg,
      message: msg,

      icon: const Icon(Icons.refresh),
      duration: const Duration(seconds: 3),
    ),
  );
}

TextStyle hintTextStyle(double? fSize, FontWeight? fWeight) {
  return TextStyle(
      fontSize: fSize ?? 12, fontWeight: fWeight ?? FontWeight.w600);
}

TextStyle normalTextStyle(double? fSize, FontWeight? fWeight, Color? color) {
  return TextStyle(
      fontSize: fSize ?? 12,
      fontWeight: fWeight ?? FontWeight.w500,
      color: color ?? Colors.black);
}

TextStyle header1Style(double? fSize) {
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: fSize ?? 36,
          color: AppColors.dark,
          fontWeight: FontWeight.w700));
}

TextStyle header2Style() {
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: 18, color: Color(0xffCBC0C0), fontWeight: FontWeight.w600));
}

TextStyle subtitleStyle() {
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: 14, color: AppColors.dark, fontWeight: FontWeight.w700));
}

TextStyle bodyStyle() {
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: 18, color: AppColors.text, fontWeight: FontWeight.w400));
}

TextStyle buttonStyle() {
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: 20, color: AppColors.white, fontWeight: FontWeight.w700));
}

TextStyle labelStyle() {
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: 15, color: AppColors.text, fontWeight: FontWeight.w500));
}

TextStyle linkStyle() {
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: 14, color: AppColors.bright, fontWeight: FontWeight.w700));
}

TextStyle captionStyle() {
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w400));
}

String getTrimmedString(String inputString, int maxCharacter) {
  String truncatedText = inputString.length > maxCharacter
      ? '${inputString.substring(0, maxCharacter)}...'
      : inputString;
  return truncatedText;
}

Future<bool?> showCustomConfirmDialog({
  required BuildContext context,
  required String message,
  required String actionText,
  bool isLogout = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FD),
                borderRadius: BorderRadius.circular(36),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLogout
                      ? const Icon(
                          Icons.power_settings_new_rounded,
                          size: 90,
                          color: Color(0xFFEF5350),
                        )
                      : SvgPicture.asset(
                          'assets/icons/delete.svg',
                          width: 90,
                          height: 90,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFEF5350),
                            BlendMode.srcIn,
                          ),
                        ),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1E2022),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5350),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          actionText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
