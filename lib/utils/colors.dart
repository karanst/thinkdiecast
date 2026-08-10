import 'dart:ui';

import 'package:flutter/material.dart';

ThemeData _lightTheme = ThemeData(
    // accentColor: Colors.pink,
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blue,
      disabledColor: Colors.grey,
    ));


class AppColors {
  ///LIGHT THEME COLORS
  static const Color primaryLight = Colors.white;
  static const Color buttonLight = Color(0xff595858);
  static const Color scaffoldLight = Colors.white;
  static const Color textLight = Color(0xffa1a1a1);
  static const Color fieldColor = Color(0xffdedede);
  static const Color grad1Clr = Color(0xFF840080);
  static const Color grad2Clr = Color(0xFF003D97);
  static const Color backgroundClr = Color(0xFFEBEEFF);
  static const Color cardBgClr = Color(0xffD4DBFF);
  static const Color borderColor = Color(0xff8598ff);

  // Color(0xFF003D97);
  static const Color primary = Color(0xff10266F);
  static const Color red = Color(0xffFB0606);


  ///DARK THEME COLORS
  static const Color primaryDark = Color(0xff64b500);
  static const Color buttonDark = Color(0xff64b500);
  static const Color scaffoldDark = Color(0xff595858);

  static const Color dark = Color(0xff595959);
  static const Color dark50 = Color(0xffACACAC);
  static const Color bright =Color(0xff3C5BFF);
  static const Color light = Color(0xfff2f2f2);
  static const Color white = Color(0xffffffff);
  static const Color text = Color(0xff071838);
  static const Color bright2 = Color(0xff243799);

  static const Color black = Colors.black;
}

class CurveClipper extends CustomClipper {
  @override
  Path getClip(Size size) {
    int curveHeight = 40;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);
    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}
