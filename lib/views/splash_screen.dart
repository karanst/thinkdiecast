import 'package:thinkdiecast/controllers/splash_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get_state_manager/src/simple/get_state.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetBuilder(
      init: SplashController(),
      builder: (controller) {
        return Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(color: Color(0xff1C1B17)
                // gradient: LinearGradient(colors: [
                //   AppColors.primary3,
                //   AppColors.primary5,
                // ], begin: Alignment.topCenter),
                ),
            child: Center(child: Image.asset('assets/logo.png'))

            // SvgPicture.asset(
            //   'assets/svgs/logo.svgs',
            // )
            );
      },
    );
  }
}
