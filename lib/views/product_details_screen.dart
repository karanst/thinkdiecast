import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/shrink_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final DocumentSnapshot data;
  ProductDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final setWidth = MediaQuery.of(context).size.width;
    return GetBuilder(
      init: HomeController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
              // resizeToAvoidBottomInset: false,
              backgroundColor: AppColors.primaryLight,
              appBar: AppBar(),
              body: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(data['image'].toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8, top: 25, bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['name'],
                          style: const TextStyle(
                              color: AppColors.dark,
                              fontSize: 32,
                              fontWeight: FontWeight.w700),
                        ),

                        // const Row(
                        //   children: [
                        //     Text(
                        //       'EDIT',
                        //       style: TextStyle(
                        //           color: AppColors.bright,
                        //           fontWeight: FontWeight.w600,
                        //           fontSize: 16),
                        //     ),
                        //     SizedBox(
                        //       width: 10,
                        //     ),
                        //     Icon(
                        //       Icons.edit,
                        //       color: AppColors.bright,
                        //       size: 20,
                        //     )
                        //   ],
                        // )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            child: Column(
                              children: [
                                const Text(
                                  'Brand',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.dark),
                                ),
                                Text(
                                  data['brand'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark),
                                ),
                              ],
                            ),
                          ),
                          const DottedLine(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            lineLength: 100,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: AppColors.dark,
                            // dashGradient: [Colors.red, Colors.blue],
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: Colors.transparent,
                            // dashGapGradient: [Colors.red, Colors.blue],
                            dashGapRadius: 0.0,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            child: Column(
                              children: [
                                const Text(
                                  'Price',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.dark),
                                ),
                                Text(
                                  'Rs. ${data['price']}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark),
                                ),
                              ],
                            ),
                          ),
                          const DottedLine(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            lineLength: 100,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: AppColors.dark,
                            // dashGradient: [Colors.red, Colors.blue],
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: Colors.transparent,
                            // dashGapGradient: [Colors.red, Colors.blue],
                            dashGapRadius: 0.0,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            child: Column(
                              children: [
                                const Text(
                                  'Category',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.dark),
                                ),
                                Text(
                                  data['category'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 15),
                        child: DottedLine(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          // lineLength: 300,
                          lineThickness: 1.0,
                          dashLength: 4.0,
                          dashColor: AppColors.dark,
                          // dashGradient: [Colors.red, Colors.blue],
                          dashRadius: 0.0,
                          dashGapLength: 4.0,
                          dashGapColor: Colors.transparent,
                          // dashGapGradient: [Colors.red, Colors.blue],
                          dashGapRadius: 0.0,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            child: Column(
                              children: [
                                const Text(
                                  'Scale',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.dark),
                                ),
                                Text(
                                  data['scale'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark),
                                ),
                              ],
                            ),
                          ),
                          const DottedLine(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            lineLength: 100,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: AppColors.dark,
                            // dashGradient: [Colors.red, Colors.blue],
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: Colors.transparent,
                            // dashGapGradient: [Colors.red, Colors.blue],
                            dashGapRadius: 0.0,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            child: Column(
                              children: [
                                const Text(
                                  'Year',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.dark),
                                ),
                                Text(
                                  data['year'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark),
                                ),
                              ],
                            ),
                          ),
                          const DottedLine(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            lineLength: 100,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: AppColors.dark,
                            // dashGradient: [Colors.red, Colors.blue],
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: Colors.transparent,
                            // dashGapGradient: [Colors.red, Colors.blue],
                            dashGapRadius: 0.0,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            child: Column(
                              children: [
                                const Text(
                                  'Colour',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.dark),
                                ),
                                Text(
                                  data['color'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 15),
                        child: DottedLine(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          // lineLength: 300,
                          lineThickness: 1.0,
                          dashLength: 4.0,
                          dashColor: AppColors.dark,
                          // dashGradient: [Colors.red, Colors.blue],
                          dashRadius: 0.0,
                          dashGapLength: 4.0,
                          dashGapColor: Colors.transparent,
                          // dashGapGradient: [Colors.red, Colors.blue],
                          dashGapRadius: 0.0,
                        ),
                      ),
                    ],
                  )
                ],
              )),
        );
      },
    );
  }
}
