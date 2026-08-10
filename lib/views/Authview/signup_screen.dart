import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/login_controller.dart';
import 'package:thinkdiecast/utils/custom_textfield.dart';
import 'package:thinkdiecast/views/Authview/login_screen.dart';
import 'package:flutter/gestures.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   final signUpKey = GlobalKey<FormState>();
//
//   bool showPassword = false;
//   bool showConfirmPassword = false;
//   bool acceptTerms = false;
//
//   @override
//   void dispose() {
//     // Controllers are managed by GetX, no need to dispose
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder(
//         init: LoginController(),
//         builder: (controller) {
//           return Scaffold(
//             resizeToAvoidBottomInset: true,
//             body: Container(
//               // <CHANGE> Dark background with gradient overlay
//               decoration: BoxDecoration(
//                 color: Color(0xFF0A0E14),
//                 image: DecorationImage(
//                   image: AssetImage('assets/auth_bg.png'),
//                   fit: BoxFit.cover,
//                   opacity: 0.3,
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // <CHANGE> Header with SIGN UP text
//                       Padding(
//                         padding: EdgeInsets.only(top: 60.0, bottom: 40),
//                         child: Column(
//                           children: [
//                             Image.asset('assets/HELLO.png'),
//                             const Text(
//                               'SIGN UP',
//                               style: TextStyle(
//                                 fontFamily: 'Aharoni',
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 40,
//                                 letterSpacing: 8,
//                                 height: 1.0,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // <CHANGE> Form with gradient border fields
//                       Form(
//                         key: signUpKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Name Field
//                             GradientBorderTextField(
//                               label: 'NAME',
//                               controller: controller.nameController,
//                               keyboardType: TextInputType.name,
//                               validator: (val) {
//                                 if (val?.isEmpty ?? true) {
//                                   return 'Please enter your name';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             // Email Field
//                             GradientBorderTextField(
//                               label: 'EMAIL ADDRESS',
//                               controller: controller.usernameController,
//                               keyboardType: TextInputType.emailAddress,
//                               validator: (val) {
//                                 if (val?.isEmpty ?? true) {
//                                   return 'Please enter valid email';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             // Phone Field
//                             GradientBorderTextField(
//                               label: 'PHONE',
//                               controller: controller.phoneController,
//                               keyboardType: TextInputType.phone,
//                               validator: (val) {
//                                 if (val?.isEmpty ?? true) {
//                                   return 'Please enter phone number';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             // City Field
//                             GradientBorderTextField(
//                               label: 'CITY',
//                               controller: controller.cityController,
//                               keyboardType: TextInputType.text,
//                               validator: (val) {
//                                 if (val?.isEmpty ?? true) {
//                                   return 'Please enter city';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             // Password Field
//                             GradientBorderTextField(
//                               label: 'PASSWORD',
//                               controller: controller.passwordController,
//                               obscureText: !showPassword,
//                               validator: (val) {
//                                 if (val?.isEmpty ?? true) {
//                                   return 'Please enter password';
//                                 }
//                                 return null;
//                               },
//                               suffixIcon: Padding(
//                                 padding: const EdgeInsets.only(right: 12),
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       showPassword = !showPassword;
//                                     });
//                                   },
//                                   child: Icon(
//                                     showPassword
//                                         ? Icons.visibility
//                                         : Icons.visibility_off,
//                                     color: Colors.white.withOpacity(0.5),
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             // Confirm Password Field
//                             GradientBorderTextField(
//                               label: 'CONFIRM PASSWORD',
//                               controller: controller.confirmPasswordController,
//                               obscureText: !showConfirmPassword,
//                               validator: (val) {
//                                 if (val?.isEmpty ?? true) {
//                                   return 'Please confirm password';
//                                 }
//                                 if (val != controller.passwordController.text) {
//                                   return 'Passwords do not match';
//                                 }
//                                 return null;
//                               },
//                               suffixIcon: Padding(
//                                 padding: const EdgeInsets.only(right: 12),
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       showConfirmPassword =
//                                       !showConfirmPassword;
//                                     });
//                                   },
//                                   child: Icon(
//                                     showConfirmPassword
//                                         ? Icons.visibility
//                                         : Icons.visibility_off,
//                                     color: Colors.white.withOpacity(0.5),
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             // <CHANGE> Terms checkbox
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: Checkbox(
//                                     value: acceptTerms,
//                                     onChanged: (value) {
//                                       setState(() {
//                                         acceptTerms = value ?? false;
//                                       });
//                                     },
//                                     fillColor: MaterialStateProperty.all(
//                                       acceptTerms
//                                           ? Color(0xFF4169E1)
//                                           : Colors.transparent,
//                                     ),
//                                     side: BorderSide(
//                                       color: Colors.white.withOpacity(0.5),
//                                       width: 1.5,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(3),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: RichText(
//                                     text: TextSpan(
//                                       children: [
//                                         TextSpan(
//                                           text: 'I accept the ',
//                                           style: TextStyle(
//                                             color:
//                                             Colors.white.withOpacity(0.7),
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                         TextSpan(
//                                           text: 'Policy and Terms',
//                                           style: TextStyle(
//                                             color: Color(0xFF4169E1),
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                           recognizer: TapGestureRecognizer()
//                                             ..onTap = () {
//                                               // Handle policy and terms
//                                             },
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 28),
//                             // <CHANGE> Register Button
//                             SizedBox(
//                               width: double.infinity,
//                               height: 48,
//                               child: ElevatedButton(
//                                 onPressed: controller.isLoading.value
//                                     ? null
//                                     : () {
//                                   if (signUpKey.currentState!.validate() &&
//                                       acceptTerms) {
//                                     controller.register(
//                                       name: controller.nameController.text,
//                                       email: controller.usernameController.text,
//                                       password: controller.passwordController.text,
//                                       phone: controller.phoneController.text,
//                                       city: controller.cityController.text,
//                                     );
//                                   } else if (!acceptTerms) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           'Please accept the Policy and Terms',
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF4169E1),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(24),
//                                   ),
//                                   elevation: 0,
//                                   disabledBackgroundColor:
//                                   const Color(0xFF4169E1).withOpacity(0.6),
//                                 ),
//                                 child: controller.isLoading.value
//                                     ? const SizedBox(
//                                   width: 24,
//                                   height: 24,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2.5,
//                                     valueColor:
//                                     AlwaysStoppedAnimation<Color>(
//                                         Colors.white),
//                                   ),
//                                 )
//                                     : const Text(
//                                   'Register',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 28),
//                             // <CHANGE> OR divider
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Container(
//                                     height: 1,
//                                     color: Colors.white.withOpacity(0.2),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 12),
//                                   child: Text(
//                                     'or',
//                                     style: TextStyle(
//                                       color: Colors.white.withOpacity(0.5),
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Container(
//                                     height: 1,
//                                     color: Colors.white.withOpacity(0.2),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 24),
//                             // <CHANGE> Social login icons
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 _buildSocialButton(Icons.g_translate, () {}),
//                                 const SizedBox(width: 24),
//                                 _buildSocialButton(Icons.apple, () {}),
//                                 const SizedBox(width: 24),
//                                 _buildSocialButton(Icons.facebook, () {}),
//                               ],
//                             ),
//                             const SizedBox(height: 28),
//                             // <CHANGE> Login link at bottom
//                             Center(
//                               child: RichText(
//                                 text: TextSpan(
//                                   children: [
//                                     TextSpan(
//                                       text: 'Already have an account? ',
//                                       style: TextStyle(
//                                         color: Colors.white.withOpacity(0.6),
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: 'Login',
//                                       style: const TextStyle(
//                                         color: Color(0xFF4169E1),
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                       recognizer: TapGestureRecognizer()
//                                         ..onTap = () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                               const LoginScreen(),
//                                             ),
//                                           );
//                                         },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 32),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         });
//   }
//
//   Widget _buildSocialButton(IconData icon, VoidCallback onPressed) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: Colors.white.withOpacity(0.4),
//             width: 1.5,
//           ),
//         ),
//         child: Center(
//           child: Icon(
//             icon,
//             color: Colors.white,
//             size: 22,
//           ),
//         ),
//       ),
//     );
//   }
// }


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final signUpKey = GlobalKey<FormState>();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool acceptTerms = false;

  @override
  void dispose() {

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
              resizeToAvoidBottomInset: true,
            body: Container(
              // <CHANGE> Dark background with gradient overlay
              decoration: BoxDecoration(
                color: Color(0xFF0A0E14),
                image: DecorationImage(
                  image: AssetImage('assets/auth_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // <CHANGE> Header with SIGN UP text
                      Padding(
                        padding: EdgeInsets.only(top: 60.0, bottom: 40),
                        child: Column(
                          children: [
                            Image.asset('assets/HELLO.png'),
                            const Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontFamily: 'Aharoni',
                                fontWeight: FontWeight.w700,
                                fontSize: 40,
                                letterSpacing: 8,
                                height: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // <CHANGE> Form with gradient border fields
                      Form(
                        key: signUpKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name Field
                            GradientBorderTextField(
                              label: 'NAME',
                              controller: controller.nameController,
                              keyboardType: TextInputType.name,
                              validator: (val) {
                                if (val?.isEmpty ?? true) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
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
                            const SizedBox(height: 20),
                            // Phone Field
                            GradientBorderTextField(
                              label: 'PHONE',
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val?.isEmpty ?? true) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // City Field
                            GradientBorderTextField(
                              label: 'CITY',
                              controller: controller.cityController,
                              keyboardType: TextInputType.text,
                              validator: (val) {
                                if (val?.isEmpty ?? true) {
                                  return 'Please enter city';
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
                              validator: (val) {
                                if (val?.isEmpty ?? true) {
                                  return 'Please enter password';
                                }
                                if (val!.length < 8) {
                                  return 'Password must be at least 8 characters';
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
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(
                                'Password must be at least 8 characters',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Confirm Password Field
                            GradientBorderTextField(
                              label: 'CONFIRM PASSWORD',
                              controller: controller.confirmPasswordController,
                              obscureText: !showConfirmPassword,
                              validator: (val) {
                                if (val?.isEmpty ?? true) {
                                  return 'Please confirm password';
                                }
                                if (val != controller.passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                if (val!.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showConfirmPassword =
                                          !showConfirmPassword;
                                    });
                                  },
                                  child: Icon(
                                    showConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // <CHANGE> Terms checkbox
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: acceptTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        acceptTerms = value ?? false;
                                      });
                                    },
                                    fillColor: MaterialStateProperty.all(
                                      acceptTerms
                                          ? Color(0xFF4169E1)
                                          : Colors.transparent,
                                    ),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'I accept the ',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Policy and Terms',
                                          style: TextStyle(
                                            color: Color(0xFF4169E1),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // Handle policy and terms
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            // <CHANGE> Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: controller.loading
                                    ? null
                                    : () async {
                                  FocusScope.of(context).unfocus();
                                  print('hhhh ${controller.usernameController.text}');
                                  if (signUpKey.currentState!.validate() &&
                                      acceptTerms) {
                                    await controller.register(name: controller.nameController.text,
                                        email: controller.usernameController.text,
                                        password: controller.passwordController.text,
                                        city: controller.cityController.text,
                                        phone: controller.phoneController.text);
                                  } else if (!acceptTerms) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please accept the Policy and Terms',
                                        ),
                                      ),
                                    );
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
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
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
                            const SizedBox(height: 24),
                            // <CHANGE> Social login icons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(Icons.g_translate, () {}),
                                const SizedBox(width: 24),
                                _buildSocialButton(Icons.apple, () {}),
                                const SizedBox(width: 24),
                                _buildSocialButton(Icons.facebook, () {}),
                              ],
                            ),
                            const SizedBox(height: 28),
                            // <CHANGE> Login link at bottom
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Login',
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
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
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
//   final signUpKey = GlobalKey<FormState>();
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
//                     'SIGN UP',
//                     style: header1Style(18),
//                   ),
//                   // const SizedBox(
//                   //   height: 20,
//                   // ),
//                   // GestureDetector(
//                   //   onTap: () {},
//                   //   child: Image.asset(
//                   //     'assets/icons/google.png',
//                   //     scale: 2,
//                   //   ),
//                   // ),
//                   // Padding(
//                   //   padding: const EdgeInsets.only(top: 55.0),
//                   //   child: Row(
//                   //     mainAxisAlignment: MainAxisAlignment.center,
//                   //     children: [
//                   //       Container(
//                   //         width: MediaQuery.of(context).size.width / 2 - 40,
//                   //         height: 0.5,
//                   //         color: AppColors.dark,
//                   //       ),
//                   //       Padding(
//                   //         padding: const EdgeInsets.only(left: 10.0, right: 10),
//                   //         child: Text(
//                   //           'OR',
//                   //           style: bodyStyle(),
//                   //         ),
//                   //       ),
//                   //       Container(
//                   //         width: MediaQuery.of(context).size.width / 2 - 40,
//                   //         height: 0.5,
//                   //         color: AppColors.dark,
//                   //       ),
//                   //     ],
//                   //   ),
//                   // ),
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(left: 40.0, right: 40, top: 10),
//                     child: Form(
//                       key: signUpKey,
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
//                               'Name',
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
//                                     return 'Please enter valid name';
//                                   }
//                                   return null;
//                                 },
//                                 // maxLength: 10,
//                                 keyboardType: TextInputType.name,
//                                 controller: controller.nameController,
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
//                             height: 25,
//                           ),
//                           Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 5.0, bottom: 2),
//                             child: Text(
//                               'Confirm Password',
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
//                                   if (val!.isEmpty ||
//                                       val !=
//                                           controller.passwordController.text) {
//                                     return 'Confirm pass is empty or does not match with password!';
//                                   }
//                                   return null;
//                                 },
//                                 // maxLength: 10,
//                                 keyboardType: TextInputType.name,
//                                 obscureText: controller.shoPass2,
//                                 obscuringCharacter: "*",
//                                 controller:
//                                     controller.confirmPasswordController,
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   suffixIcon: IconButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           controller.shoPass2 =
//                                               !controller.shoPass2;
//                                         });
//                                       },
//                                       icon: ImageIcon(
//                                         controller.shoPass2
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
//                             child: LoadingButton(
//                               onPressed: () {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 200), () {
//                                   if (signUpKey.currentState!.validate()) {
//                                     controller.signUp(context);
//                                   } else {
//                                     showSnackBar('Invalid Credentials!');
//                                   }
//                                 });
//                               },
//                               shrinkScale: 0.7,
//                               btnHeight: 60,
//                               child: controller.loading
//                                   ? const Center(
//                                       child: CircularProgressIndicator(
//                                         color: AppColors.white,
//                                       ),
//                                     )
//                                   : Center(
//                                       child: Text(
//                                         'Sign Up',
//                                         style: buttonStyle(),
//                                       ),
//                                     ),
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
//                                           builder: (context) => LoginScreen()));
//                                 },
//                                 child: const Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       'ALREADY HAVE AN ACCOUNT? ',
//                                       style: TextStyle(
//                                           color: AppColors.red,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w700),
//                                     ),
//                                     Text(
//                                       'LOGIN',
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
