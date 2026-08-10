import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';


class GradientBorderDropdown extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;

  const GradientBorderDropdown({
    Key? key,
    required this.label,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<GradientBorderDropdown> createState() =>
      _GradientBorderDropdownState();
}

class _GradientBorderDropdownState extends State<GradientBorderDropdown> {
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
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 🟣 Gradient Border with Transparent Center
          CustomPaint(
            painter: _GradientBorderPainter(
              borderRadius: 12,
              borderWidth: 2,
            ),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(

                  value: widget.value,
                  focusNode: _focusNode,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0A0E14),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFD1D5DB),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  // hint: Text(
                  //   widget.hintText ?? 'Select ${widget.label}',
                  //   style: const TextStyle(
                  //     color: Color(0xFF6B7280),
                  //     fontSize: 14,
                  //   ),
                  // ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  items: widget.items,
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ),

          // 🏷 Floating Label
          Positioned(
            left: 20,
            top: -10,
            child: Container(
              color: const Color(0xFF0A0E14),
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
    );
  }
}

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



