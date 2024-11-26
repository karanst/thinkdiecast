import 'package:thinkdiecast/route_management/routes.dart';
import 'package:thinkdiecast/route_management/screen_bindings.dart';
import 'package:thinkdiecast/views/dashboard_screen.dart';
import 'package:thinkdiecast/views/home_screen.dart';
import 'package:thinkdiecast/views/intro_screen.dart';
import 'package:thinkdiecast/views/Authview/login_screen.dart';
import 'package:thinkdiecast/views/splash_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class AllPages {
  static List<GetPage> getPages() {
    return [
      GetPage(
          name: splashScreen,
          page: () => SplashScreen(),
          binding: ScreenBindings()),
      GetPage(
          name: loginScreen,
          page: () => const LoginScreen(),
          binding: ScreenBindings()),
      GetPage(
          name: introScreen,
          page: () => const IntroScreen(),
          binding: ScreenBindings()),
      GetPage(
          name: homeScreen,
          page: () => const HomeScreen(),
          binding: ScreenBindings()),
      GetPage(
          name: dashbord,
          page: () => const DashboardScreen(),
          binding: ScreenBindings()),

      // GetPage(
      //     name: introScreen,
      //     page: () => const IntroScreen(),
      //     binding: ScreenBindings()),
    ];
  }
}
