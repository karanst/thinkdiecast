import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thinkdiecast/utils/colors.dart';

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
