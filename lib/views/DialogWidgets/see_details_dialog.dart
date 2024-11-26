import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/views/product_details_screen.dart';


class SeeDetailsDialog extends StatelessWidget {
  final DocumentSnapshot data;
  SeeDetailsDialog({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      // backgroundColor: AppColors.black.withOpacity(0.7),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 120.0, bottom: 120),
                  child: Container(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(data['image'].toString()),
                  ),
                ), // Replace with your image asset
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(data: data)));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SEE DETAILS',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.bright,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withOpacity(0.33)),
                  child: const Icon(Icons.close, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}


// class SeeDetailsDialog extends StatelessWidget {
//   final DocumentSnapshot data;
//   SeeDetailsDialog({Key? key, required this.data}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       // backgroundColor: AppColors.black.withOpacity(0.7),
//       insetPadding: EdgeInsets.zero,
//       child: Stack(
//         alignment: Alignment.center,
//         children: <Widget>[
//           Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(0),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.only(top: 90.0, bottom: 90),
//                   child: Container(
//                     height: MediaQuery.of(context).size.width,
//                     width: MediaQuery.of(context).size.width,
//                     child: Image.network(data['image'].toString()),
//                   ),
//                 ), // Replace with your image asset
//                 const SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 ProductDetailScreen(data: data)));
//                   },
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'SEE DETAILS',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Icon(
//                         Icons.arrow_forward,
//                         color: AppColors.bright,
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: 10,
//             right: 10,
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//               child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: AppColors.white.withOpacity(0.33)),
//                   child: const Icon(Icons.close, color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
