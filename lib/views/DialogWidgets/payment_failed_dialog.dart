
import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/shrink_button.dart';

class PaymentFailedDialog extends StatelessWidget {
  const PaymentFailedDialog({super.key});

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
              padding: const EdgeInsets.only(top: 150, bottom: 160, left: 25, right: 25),
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
                    Image.asset('assets/failed.png'),
                    const Padding(
                      padding:  EdgeInsets.only(top: 20.0, bottom: 10),
                      child:  Text(
                        'Payment Failed!',
                        style: TextStyle(
                            color: AppColors.bright,
                            fontWeight: FontWeight.w700,
                            fontSize: 36),
                      ),
                    ),
                   const  Text(
                      'Don’t worry your money is safe!',
                      style: TextStyle(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w400,
                          fontSize: 18),
                    ),

                    const  Padding(
                      padding:  EdgeInsets.only(top: 8, bottom: 30.0),
                      child: Text(
                        'If your money is debited from your account it will be refunded In 5-6 working days',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.dark,
                            fontWeight: FontWeight.w400,
                            fontSize: 18),
                      ),
                    ),
                    ShrinkButton(
                        btnHeight: 60,
                        btnWidth: 286,
                        child: 'RETRY', onPressed: (){
                      Navigator.pop(context);
                    },
                      color: AppColors.red,
                    ),

                  ],
                ),
              )));
    });
  }
}
