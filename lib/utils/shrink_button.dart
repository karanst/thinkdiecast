import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/widgets.dart';
// import 'package:google_fonts/google_fonts.dart';

class ShrinkButton extends StatefulWidget {
  final String child;
  final Function onPressed;
  final double shrinkScale;
  final double? btnWidth;
  final double? btnHeight;
  final double? fSize;
  final Color? color;

  ShrinkButton(
      {required this.child,
      required this.onPressed,
      this.shrinkScale = 0.9,
      this.btnWidth,
      this.btnHeight,
      this.fSize,
        this.color});

  @override
  _ShrinkButtonState createState() => _ShrinkButtonState();
}

class _ShrinkButtonState extends State<ShrinkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward();
        Future.delayed(Duration(milliseconds: 200), () {
          _controller.reverse();
        });
        widget.onPressed();
      },
      child: ScaleTransition(
          scale: Tween<double>(
            begin: 1.0,
            end: widget.shrinkScale,
          ).animate(_controller),
          child: Container(
              height: widget.btnHeight ?? 60,
              width: widget.btnWidth ?? MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: widget.color ?? AppColors.bright,
                  borderRadius: BorderRadius.circular(40)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.child,
                    style: buttonStyle(),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 14.0, right: 5),
                  //   child: ImageIcon(const AssetImage('assets/icons/arrow.png'), size: 12,color: Theme.of(context).colorScheme.background,),
                  // )
                ],
              ))),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LoadingButton extends StatefulWidget {
  final Widget child;
  final Function onPressed;
  final double shrinkScale;
  final double? btnWidth;
  final double? btnHeight;
  final double? fSize;


  LoadingButton(
      {required this.child,
      required this.onPressed,
      this.shrinkScale = 0.9,
      this.btnWidth,
      this.btnHeight,
      this.fSize,});

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward();
        Future.delayed(Duration(milliseconds: 200), () {
          _controller.reverse();
        });
        widget.onPressed();
      },
      child: ScaleTransition(
          scale: Tween<double>(
            begin: 1.0,
            end: widget.shrinkScale,
          ).animate(_controller),
          child: Container(
              height: widget.btnHeight ?? 60,
              width: widget.btnWidth ?? MediaQuery.of(context).size.width,
              // color:  AppColors.bright ,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.bright, AppColors.bright]),
                  borderRadius: BorderRadius.circular(40)),
              child: widget.child
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       widget.child,
              //       style: buttonStyle(),
              //     ),
              //     // Padding(
              //     //   padding: const EdgeInsets.only(bottom: 14.0, right: 5),
              //     //   child: ImageIcon(const AssetImage('assets/icons/arrow.png'), size: 12,color: Theme.of(context).colorScheme.background,),
              //     // )
              //   ],
              // )
              )),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
