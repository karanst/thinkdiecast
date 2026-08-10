import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';

class GradientBorderTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool? isEnabled;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const GradientBorderTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.isEnabled,
    this.textInputAction,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<GradientBorderTextField> createState() =>
      _GradientBorderTextFieldState();
}

class _GradientBorderTextFieldState extends State<GradientBorderTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                painter: _GradientBorderPainter(
                  borderRadius: 12,
                  borderWidth: 2,
                ),
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent, // transparent background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    // enabled: widget.isEnabled ?? false,
                    readOnly: widget.isEnabled ?? false,
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChanged,
                    textInputAction: widget.textInputAction,
                    onFieldSubmitted: widget.onSubmitted,
                    validator: (val) {
                      final err = widget.validator?.call(val);
                      if (err != _errorText) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _errorText = err;
                          });
                        });
                      }
                      return err;
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: widget.suffixIcon,
                      border: InputBorder.none,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                      contentPadding:
                      const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // 🏷 Floating Label
              Positioned(
                left: 20,
                top: -10,
                child: Container(
                  color: const Color(0xFF0A0E14), // same as background
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                _errorText!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 🎨 Custom Painter for Gradient Border
class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final RRect outer = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final RRect inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        borderWidth,
        borderWidth,
        size.width - borderWidth * 2,
        size.height - borderWidth * 2,
      ),
      Radius.circular(borderRadius - borderWidth),
    );

    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.grad1Clr,
          AppColors.grad2Clr,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final Path borderPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(outer),
      Path()..addRRect(inner),
    );

    canvas.drawPath(borderPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class GradientBorderField extends StatelessWidget {
  final String label;
  final Widget child;

  const GradientBorderField({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1425),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD32D7D).withOpacity(0.5),
                  const Color(0xFF4A68FF).withOpacity(0.5),
                ],
              ),
            ),
            // margin: const EdgeInsets.all(-1.5),
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1425),
                borderRadius: BorderRadius.circular(14.5),
              ),
              child: child,
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFF0D1425),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class GlobalHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final String profileUrl;

  const GlobalHeader({
    super.key,
    this.title = 'WELCOME',
    this.subtitle = 'DEEP',
    this.profileUrl = 'https://placeholder.svg?height=100&width=100&query=profile',
  });

  @override
  State<GlobalHeader> createState() => _GlobalHeaderState();
}

class _GlobalHeaderState extends State<GlobalHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(widget.profileUrl),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A68FF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFF4A68FF),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}



// class GradientBorderTextField extends StatefulWidget {
//   final String label;
//   final String? hintText;
//   final TextEditingController? controller;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final Function(String)? onChanged;
//   final Widget? suffixIcon;
//
//   const GradientBorderTextField({
//     Key? key,
//     required this.label,
//     this.hintText,
//     this.controller,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.onChanged,
//     this.suffixIcon,
//   }) : super(key: key);
//
//   @override
//   State<GradientBorderTextField> createState() =>
//       _GradientBorderTextFieldState();
// }
//
// class _GradientBorderTextFieldState extends State<GradientBorderTextField> {
//   late FocusNode _focusNode;
//   bool _isFocused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     _focusNode.addListener(_onFocusChange);
//   }
//
//   @override
//   void dispose() {
//     _focusNode.removeListener(_onFocusChange);
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   void _onFocusChange() {
//     setState(() {
//       _isFocused = _focusNode.hasFocus;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
//       child: Stack(
//         clipBehavior: Clip.none, // 👈 allows label to overflow above
//         children: [
//           // Gradient Border
//           Container(
//             height: 60,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: const LinearGradient(
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//                 colors: [
//                   AppColors.grad1Clr,
//                   Color(0xFF003D97),
//                 ],
//               ),
//             ),
//             padding: const EdgeInsets.all(2), // Border thickness
//             child: Container(
//               decoration: BoxDecoration(
//                 // color: Colors.transparent,
//                 color: const Color(0xFF0A0E14).withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: TextField(
//                 controller: widget.controller,
//                 focusNode: _focusNode,
//                 obscureText: widget.obscureText,
//                 keyboardType: widget.keyboardType,
//                 onChanged: widget.onChanged,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//                 decoration: InputDecoration(
//                   suffixIcon: widget.suffixIcon,
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
//                   hintText: widget.hintText,
//                   hintStyle: const TextStyle(
//                     color: Color(0xFF6B7280),
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // Floating Label (adjusted)
//           Positioned(
//             left: 20,
//             top: -10, // 👈 moves label slightly above the border
//             child: Container(
//               color: const Color(0xFF0A0E14), // same as background
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: Text(
//                 widget.label,
//                 style: const TextStyle(
//                   color: Color(0xFFD1D5DB),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   return SizedBox(
//   //     height: 120,
//   //     // margin: const EdgeInsets.only(top: 12.0),
//   //     child: Stack(
//   //       children: [
//   //         // Gradient Border Container
//   //         Container(
//   //           height: 60,
//   //           decoration: BoxDecoration(
//   //             borderRadius: BorderRadius.circular(12),
//   //             gradient: LinearGradient(
//   //               begin: Alignment.centerLeft,
//   //               end: Alignment.centerRight,
//   //               colors: [
//   //                 AppColors.grad1Clr, // Purple/Magenta
//   //                 Color(0xFF003D97), // Dark Blue
//   //               ],
//   //             ),
//   //           ),
//   //           padding: EdgeInsets.all(2), // Border thickness
//   //           child: Container(
//   //             decoration: BoxDecoration(
//   //               color: Color(0xFF0A0E14), // Dark background
//   //               borderRadius: BorderRadius.circular(10),
//   //             ),
//   //             child: TextField(
//   //               controller: widget.controller,
//   //               focusNode: _focusNode,
//   //               obscureText: widget.obscureText,
//   //               keyboardType: widget.keyboardType,
//   //               onChanged: widget.onChanged,
//   //               style: TextStyle(
//   //                 color: Colors.white,
//   //                 fontSize: 16,
//   //               ),
//   //               decoration: InputDecoration(
//   //                 suffixIcon: widget.suffixIcon,
//   //                 border: InputBorder.none,
//   //                 contentPadding:
//   //                 EdgeInsets.fromLTRB(20, 24, 20, 16),
//   //                 hintText: widget.hintText,
//   //                 hintStyle: TextStyle(
//   //                   color: Color(0xFF6B7280),
//   //                   fontSize: 14,
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //         // Floating Label
//   //         Positioned(
//   //           left: 20,
//   //           top: -5,
//   //           child: Container(
//   //             height: 25,
//   //             color: Color(0xFF0A0E14), // Match background
//   //             padding: EdgeInsets.symmetric(horizontal: 3),
//   //             child: Text(
//   //               widget.label,
//   //               style: TextStyle(
//   //                 color: Color(0xFFD1D5DB),
//   //                 fontSize: 12,
//   //                 fontWeight: FontWeight.w500,
//   //                 letterSpacing: 1.5,
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
// }

/*
class GradientBorderTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int maxLines;

  const GradientBorderTextField({
    Key? key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<GradientBorderTextField> createState() =>
      _GradientBorderTextFieldState();
}

class _GradientBorderTextFieldState extends State<GradientBorderTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        // Gradient border container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.grad1Clr, // Purple/Magenta
                Color(0xFF003D97), // Dark Blue
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: Color(0xFF0F1419), // Dark background
            ),
            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              validator: widget.validator,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: widget.suffixIcon,
                suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}*/
