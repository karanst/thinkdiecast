import 'dart:async';

import 'package:thinkdiecast/controllers/login_controller.dart';
import 'package:thinkdiecast/route_management/routes.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/views/Authview/login_screen.dart';

import '../../utils/shrink_button.dart';
import '../../utils/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final Timer timer;

  final values = ['a.png', 'b.png', 'c.png', 'd.png', 'e.png'];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _index++);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  final signUpKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColors.primaryLight,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 70.0, bottom: 30, left: 15, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          scale: 3,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'SIGN UP',
                    style: header1Style(18),
                  ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // GestureDetector(
                  //   onTap: () {},
                  //   child: Image.asset(
                  //     'assets/icons/google.png',
                  //     scale: 2,
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 55.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Container(
                  //         width: MediaQuery.of(context).size.width / 2 - 40,
                  //         height: 0.5,
                  //         color: AppColors.dark,
                  //       ),
                  //       Padding(
                  //         padding: const EdgeInsets.only(left: 10.0, right: 10),
                  //         child: Text(
                  //           'OR',
                  //           style: bodyStyle(),
                  //         ),
                  //       ),
                  //       Container(
                  //         width: MediaQuery.of(context).size.width / 2 - 40,
                  //         height: 0.5,
                  //         color: AppColors.dark,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40.0, right: 40, top: 10),
                    child: Form(
                      key: signUpKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, bottom: 2),
                            child: Text(
                              'Name',
                              style: labelStyle(),
                            ),
                          ),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.dark50)),
                            child: TextFormField(
                                // onChanged: (value) {
                                //   if (value.length == 10) {
                                //     // controller.loginUser();
                                //   } else {}
                                // },
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Please enter valid name';
                                  }
                                  return null;
                                },
                                // maxLength: 10,
                                keyboardType: TextInputType.name,
                                controller: controller.nameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 10),
                                  // counterText: '',
                                  // hintText: "Email",
                                  // hintStyle: hintTextStyle(14, FontWeight.w500),
                                )),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, bottom: 2),
                            child: Text(
                              'Email',
                              style: labelStyle(),
                            ),
                          ),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.dark50)),
                            child: TextFormField(
                                // onChanged: (value) {
                                //   if (value.length == 10) {
                                //     // controller.loginUser();
                                //   } else {}
                                // },
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Please enter valid email';
                                  }
                                  return null;
                                },
                                // maxLength: 10,
                                keyboardType: TextInputType.name,
                                controller: controller.usernameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 10),
                                  // counterText: '',
                                  // hintText: "Email",
                                  // hintStyle: hintTextStyle(14, FontWeight.w500),
                                )),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, bottom: 2),
                            child: Text(
                              'Password',
                              style: labelStyle(),
                            ),
                          ),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.dark50)),
                            child: TextFormField(
                                // onChanged: (value) {
                                //   if (value.isNotEmpty) {
                                //     controller.loginUser();
                                //   } else {}
                                // },
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Please enter valid password';
                                  }
                                  return null;
                                },
                                // maxLength: 10,
                                keyboardType: TextInputType.name,
                                obscureText: controller.shoPass,
                                obscuringCharacter: "*",
                                controller: controller.passwordController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          controller.shoPass =
                                              !controller.shoPass;
                                        });
                                      },
                                      icon: ImageIcon(
                                        controller.shoPass
                                            ? const AssetImage(
                                                'assets/icons/visible.png',
                                              )
                                            : const AssetImage(
                                                'assets/icons/visibleOff.png'),
                                        size: 18,
                                      )),

                                  contentPadding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  // counterText: '',
                                  // hintText: "Password",
                                  // hintStyle: hintTextStyle(14, FontWeight.w500),
                                )),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, bottom: 2),
                            child: Text(
                              'Confirm Password',
                              style: labelStyle(),
                            ),
                          ),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.dark50)),
                            child: TextFormField(
                                // onChanged: (value) {
                                //   if (value.isNotEmpty) {
                                //     controller.loginUser();
                                //   } else {}
                                // },
                                validator: (val) {
                                  if (val!.isEmpty ||
                                      val !=
                                          controller.passwordController.text) {
                                    return 'Confirm pass is empty or does not match with password!';
                                  }
                                  return null;
                                },
                                // maxLength: 10,
                                keyboardType: TextInputType.name,
                                obscureText: controller.shoPass2,
                                obscuringCharacter: "*",
                                controller:
                                    controller.confirmPasswordController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          controller.shoPass2 =
                                              !controller.shoPass2;
                                        });
                                      },
                                      icon: ImageIcon(
                                        controller.shoPass2
                                            ? const AssetImage(
                                                'assets/icons/visible.png',
                                              )
                                            : const AssetImage(
                                                'assets/icons/visibleOff.png'),
                                        size: 18,
                                      )),

                                  contentPadding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  // counterText: '',
                                  // hintText: "Password",
                                  // hintStyle: hintTextStyle(14, FontWeight.w500),
                                )),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: LoadingButton(
                              onPressed: () {
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  if (signUpKey.currentState!.validate()) {
                                    controller.signUp(context);
                                  } else {
                                    showSnackBar('Invalid Credentials!');
                                  }
                                });
                              },
                              shrinkScale: 0.7,
                              btnHeight: 60,
                              child: controller.loading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Sign Up',
                                        style: buttonStyle(),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()));
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ALREADY HAVE AN ACCOUNT? ',
                                      style: TextStyle(
                                          color: AppColors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'LOGIN',
                                      style: TextStyle(
                                          color: AppColors.dark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
