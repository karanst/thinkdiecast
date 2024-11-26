import 'package:thinkdiecast/controllers/intro_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/shrink_button.dart';
import 'package:thinkdiecast/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    final setWidth = MediaQuery.of(context).size.width;
    return GetBuilder(
      init: IntroController(),
      builder: (controller) {
        return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColors.primaryLight,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png'),
                  const SizedBox(
                    height: 120,
                  ),
                  controller.isAllowed
                      ? GestureDetector(
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              controller.employeePunch('in');
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.width / 2,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary),
                            child: const Center(
                                child: Text(
                              "PUNCH IN",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            )),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ));
      },
    );
  }
}
