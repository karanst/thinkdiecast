import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/login_controller.dart';
import 'package:thinkdiecast/utils/custom_textfield.dart';
import 'package:thinkdiecast/utils/widgets.dart';
import 'package:thinkdiecast/views/Authview/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    // Controllers are initialized in GetBuilder, no need to initialize here
  }

  @override
  void dispose() {
    // Controllers are managed by GetX, no need to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: LoginController(),
        builder: (controller) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/auth_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Header with WELCOME and LOGIN text
                      Padding(
                        padding: const EdgeInsets.only(top: 80.0, bottom: 40),
                        child: Column(
                          children: [
                            Image.asset('assets/WELCOME.png'),
                            Transform.translate(
                              offset: const Offset(0, -12),
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontFamily: 'Aharoni',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36,
                                  letterSpacing: 6,
                                  height: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Form
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Form(
                          key: loginKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email Field
                              GradientBorderTextField(
                                label: 'EMAIL ADDRESS',
                                controller: controller.usernameController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (val) {
                                  if (val?.isEmpty ?? true) {
                                    return 'Please enter valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Password Field
                              GradientBorderTextField(
                                label: 'PASSWORD',
                                controller: controller.passwordController,
                                obscureText: !showPassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                validator: (val) {
                                  if (val?.isEmpty ?? true) {
                                    return 'Please enter valid password';
                                  }
                                  return null;
                                },
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                    child: Icon(
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Forgot Password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Handle forgot password
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: SizedBox(
                                  width: 200,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: controller.loading
                                        ? null
                                        : () {
                                      FocusScope.of(context).unfocus();
                                      print('this is email and pass ${controller.usernameController.text}');
                                      if (loginKey.currentState!.validate()) {
                                        controller.login(email: controller.usernameController.text, password: controller.passwordController.text);
                                      } else {
                                        showSnackBar('Invalid Credentials!');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4169E1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 0,
                                      disabledBackgroundColor: const Color(0xFF4169E1).withOpacity(0.6),
                                    ),
                                    child: controller.loading
                                        ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                        : const Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // OR divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Social login icons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                      'assets/icons/google.png', () {}),
                                  const SizedBox(width: 24),
                                  _buildSocialButton(
                                      'assets/icons/apple.png', () {}),
                                  const SizedBox(width: 24),
                                  _buildSocialButton(
                                      'assets/icons/facebook.png', () {}),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Sign up link at bottom
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Don\'t have account? ',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                    color: Color(0xFF4169E1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      controller.clear();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const SignUpScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildSocialButton(String icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        child: Image.asset(icon),
        // Center(
        //   child: Icon(
        //     icon,
        //     color: Colors.white,
        //     size: 22,
        //   ),
        // ),
      ),
    );
  }
}

/*class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: LoginController(),
        builder: (controller) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Container(
              // <CHANGE> Dark background with gradient overlay
              decoration: const BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage('assets/auth_bg.png'),
                  fit: BoxFit.cover,
                  // opacity: 0.3,
                ),
              ),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // <CHANGE> Header with WELCOME and LOGIN text
                      Padding(
                        padding: const EdgeInsets.only(top: 160.0, bottom: 50),
                        child: Column(
                          children: [
                            Image.asset('assets/WELCOME.png'),
                            // StrokeText(
                            //   text: "WELCOME",
                            //   textStyle: const TextStyle(
                            //     fontFamily: 'Aharoni',
                            //     fontWeight: FontWeight.w700,
                            //     fontSize: 52, // from your spec
                            //     height: 1.0, // 100% line-height
                            //     letterSpacing: 9.36, // 18% of 52px ≈ 9.36
                            //     color: Colors.transparent, // fill transparent for hollow
                            //   ),
                            //   strokeColor: Colors.white70, // #FFFFFF
                            //   strokeWidth: 1, // use 1 for crisp sharp edge like border:1px solid
                            //   textAlign: TextAlign.center,
                            // ),

                            // Text(
                            //   'WELCOME',
                            //   style: TextStyle(
                            //     fontFamily: 'Aharoni',
                            //     fontWeight: FontWeight.w700,
                            //     fontSize: 48,
                            //     letterSpacing: 8,
                            //     height: 1.0,
                            //     color: Colors.white.withOpacity(0.25),
                            //   ),
                            // ),
                            Transform.translate(
                              offset: const Offset(0, -12),
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontFamily: 'Aharoni',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36,
                                  letterSpacing: 6,
                                  height: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // <CHANGE> Form with gradient border fields
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Form(
                            key: loginKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Field
                                GradientBorderTextField(
                                  label: 'EMAIL ADDRESS',
                                  controller: controller.usernameController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) {
                                    if (val?.isEmpty ?? true) {
                                      return 'Please enter valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                // Password Field
                                GradientBorderTextField(
                                  label: 'PASSWORD',
                                  controller: controller.passwordController,
                                  obscureText: !showPassword,
                                  validator: (val) {
                                    if (val?.isEmpty ?? true) {
                                      return 'Please enter valid password';
                                    }
                                    return null;
                                  },
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showPassword = !showPassword;
                                        });
                                      },
                                      child: Icon(
                                        showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Forgot Password link
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Handle forgot password
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: SizedBox(
                                    width: 200,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: controller.loading
                                          ? null
                                          : () {
                                        if (loginKey.currentState!.validate()) {
                                          controller.login(controller.usernameController.text, controller.passwordController.text);
                                        } else {
                                          showSnackBar('Invalid Credentials!');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4169E1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        elevation: 0,
                                        disabledBackgroundColor: const Color(0xFF4169E1).withOpacity(0.6),
                                      ),
                                      child: controller.loading
                                          ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                          : const Text(
                                        'Log in',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),
                                // <CHANGE> OR divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        'or',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                // <CHANGE> Social login icons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSocialButton(
                                        'assets/icons/google.png', () {}),
                                    const SizedBox(width: 24),
                                    _buildSocialButton(
                                        'assets/icons/apple.png', () {}),
                                    const SizedBox(width: 24),
                                    _buildSocialButton(
                                        'assets/icons/facebook.png', () {}),
                                  ],
                                ),
                                const SizedBox(height: 28),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // <CHANGE> Sign up link at bottom
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Don\'t have account? ',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                    color: Color(0xFF4169E1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildSocialButton(String icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        child: Image.asset(icon),
        // Center(
        //   child: Icon(
        //     icon,
        //     color: Colors.white,
        //     size: 22,
        //   ),
        // ),
      ),
    );
  }
}*/



// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   late final Timer timer;
//
//   final values = ['a.png', 'b.png', 'c.png', 'd.png', 'e.png'];
//   int _index = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() => _index++);
//     });
//   }
//
//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }
//
//   final loginKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder(
//       init: LoginController(),
//       builder: (controller) {
//         return Scaffold(
//             resizeToAvoidBottomInset: true,
//             backgroundColor: AppColors.primaryLight,
//             body: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         top: 70.0, bottom: 30, left: 15, right: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           'assets/logo.png',
//                           scale: 3,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Text(
//                     'SIGN IN WITH',
//                     style: header1Style(18),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Image.asset(
//                       'assets/icons/google.png',
//                       scale: 2,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 55.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: MediaQuery.of(context).size.width / 2 - 40,
//                           height: 0.5,
//                           color: AppColors.dark,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 10.0, right: 10),
//                           child: Text(
//                             'OR',
//                             style: bodyStyle(),
//                           ),
//                         ),
//                         Container(
//                           width: MediaQuery.of(context).size.width / 2 - 40,
//                           height: 0.5,
//                           color: AppColors.dark,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(left: 40.0, right: 40, top: 10),
//                     child: Form(
//                       key: loginKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(
//                             height: 25,
//                           ),
//                           Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 5.0, bottom: 2),
//                             child: Text(
//                               'Email',
//                               style: labelStyle(),
//                             ),
//                           ),
//                           Container(
//                             height: 60,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: AppColors.dark50)),
//                             child: TextFormField(
//                                 // onChanged: (value) {
//                                 //   if (value.length == 10) {
//                                 //     // controller.loginUser();
//                                 //   } else {}
//                                 // },
//                                 validator: (val) {
//                                   if (val!.isEmpty) {
//                                     return 'Please enter valid email';
//                                   }
//                                   return null;
//                                 },
//                                 // maxLength: 10,
//                                 keyboardType: TextInputType.name,
//                                 controller: controller.usernameController,
//                                 decoration: const InputDecoration(
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.only(left: 10),
//                                   // counterText: '',
//                                   // hintText: "Email",
//                                   // hintStyle: hintTextStyle(14, FontWeight.w500),
//                                 )),
//                           ),
//                           const SizedBox(
//                             height: 25,
//                           ),
//                           Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 5.0, bottom: 2),
//                             child: Text(
//                               'Password',
//                               style: labelStyle(),
//                             ),
//                           ),
//                           Container(
//                             height: 60,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: AppColors.dark50)),
//                             child: TextFormField(
//                                 // onChanged: (value) {
//                                 //   if (value.isNotEmpty) {
//                                 //     controller.loginUser();
//                                 //   } else {}
//                                 // },
//                                 validator: (val) {
//                                   if (val!.isEmpty) {
//                                     return 'Please enter valid password';
//                                   }
//                                   return null;
//                                 },
//                                 // maxLength: 10,
//                                 keyboardType: TextInputType.name,
//                                 obscureText: controller.shoPass,
//                                 obscuringCharacter: "*",
//                                 controller: controller.passwordController,
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   suffixIcon: IconButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           controller.shoPass =
//                                               !controller.shoPass;
//                                         });
//                                       },
//                                       icon: ImageIcon(
//                                         controller.shoPass
//                                             ? const AssetImage(
//                                                 'assets/icons/visible.png',
//                                               )
//                                             : const AssetImage(
//                                                 'assets/icons/visibleOff.png'),
//                                         size: 18,
//                                       )),
//
//                                   contentPadding:
//                                       const EdgeInsets.only(left: 10, top: 10),
//                                   // counterText: '',
//                                   // hintText: "Password",
//                                   // hintStyle: hintTextStyle(14, FontWeight.w500),
//                                 )),
//                           ),
//                           const SizedBox(
//                             height: 30,
//                           ),
//                           Center(
//                             child: ShrinkButton(
//                               child: 'Sign In',
//                               onPressed: () {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 200), () {
//                                   // Get.toNamed(dashbord);
//                                   // Get.offAll(const IntroScreen());
//                                   if (loginKey.currentState!.validate()) {
//                                     controller.login(context);
//                                     // setState(() {
//                                     //   controller.isResend = false;
//                                     // });
//                                     // Get.toNamed(otpScreen);
//                                     // controller.loginUser();
//                                   } else {
//                                     showSnackBar('Invalid Credentials!');
//                                   }
//                                 });
//                               },
//                               shrinkScale: 0.7,
//                               btnHeight: 50,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 15,
//                           ),
//                           Center(
//                             child: TextButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               SignUpScreen()));
//                                 },
//                                 child: const Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       'DON\u0027T HAVE AN ACCOUNT? ',
//                                       style: TextStyle(
//                                           color: AppColors.red,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w700),
//                                     ),
//                                     Text(
//                                       'REGISTER',
//                                       style: TextStyle(
//                                           color: AppColors.dark,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w700),
//                                     ),
//                                   ],
//                                 )),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ));
//       },
//     );
//   }
// }
