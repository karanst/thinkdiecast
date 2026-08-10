
import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/shrink_button.dart';

class PaymentSuccessDialog extends StatelessWidget {
  const PaymentSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setStat) {
      return Dialog(
        backgroundColor: Colors.transparent,
        // backgroundColor: AppColors.black.withOpacity(0.7),
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(top: 150, bottom: 200, left: 25, right: 25),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height /2,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/success.png'),
                const Padding(
                  padding:  EdgeInsets.only(top: 20.0, bottom: 10),
                  child:  Text(
                    'Congratulation',
                    style: TextStyle(
                        color: AppColors.bright,
                        fontWeight: FontWeight.w700,
                        fontSize: 36),
                  ),
                ),
                const  Padding(
                   padding:  EdgeInsets.only(bottom: 30.0),
                   child: Text(
                    'You\'ve successfully subscribed',
                    style: TextStyle(
                        color: AppColors.dark,
                        fontWeight: FontWeight.w400,
                        fontSize: 18),
                                   ),
                 ),
                ShrinkButton(
                  btnHeight: 60,
                    btnWidth: 286,
                    child: 'DONE', onPressed: (){
                      Navigator.pop(context);
                }
                ),

                  ],
                ),
              )));
    });
  }
}
