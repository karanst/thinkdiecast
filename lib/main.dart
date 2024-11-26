import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:thinkdiecast/route_management/all_pages.dart';
import 'package:thinkdiecast/route_management/routes.dart';
import 'package:thinkdiecast/route_management/screen_bindings.dart';

///      ॐ 卐 ॐ      ॐ 卐 ॐ      ॐ 卐 ॐ      श्री गणेश      ॐ 卐 ॐ      ॐ 卐 ॐ      ॐ 卐 ॐ      ///

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyAv2Qqwa19QYEvahofTVSIxYOfRDpQok-A',
    appId: '1:616596266798:android:d581ed5fb08591074c64bf',
    messagingSenderId: 'sendid',
    projectId: 'think-diecast',
    storageBucket: 'think-diecast.appspot.com',
  ));
  await FirebaseAppCheck.instance
      // Your personal reCaptcha public key goes here:
      .activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
    // webProvider: ReCaptchaV3Provider(kWebRecaptchaSiteKey),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.light,
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      initialRoute: splashScreen,
      getPages: AllPages.getPages(),
      initialBinding: ScreenBindings(),
      title: 'Fincoopers Collection ',
      theme: ThemeData(
          textTheme: GoogleFonts.openSansTextTheme(
            Theme.of(context).textTheme,
          ),
          // accentColor: Colors.pink,
          brightness: Brightness.light,
          primaryColor: AppColors.primaryLight,
          // textTheme:    GoogleFonts.kulimParkTextTheme(),
          scaffoldBackgroundColor: AppColors.scaffoldLight,
          buttonTheme: const ButtonThemeData(
            buttonColor: AppColors.buttonLight,
            disabledColor: Colors.grey,
          )),
      darkTheme: ThemeData(
          textTheme: GoogleFonts.openSansTextTheme(
            Theme.of(context).textTheme,
          ),
          // accentColor: Colors.red,
          brightness: Brightness.dark,
          primaryColor: AppColors.primaryDark,
          scaffoldBackgroundColor: AppColors.scaffoldDark,
          buttonTheme: const ButtonThemeData(
            buttonColor: AppColors.bright,
            disabledColor: Colors.grey,
          )),
    );
  }
}
