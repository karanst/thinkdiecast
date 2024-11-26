import 'dart:async';

import 'package:thinkdiecast/controllers/add_product_controller.dart';
import 'package:thinkdiecast/controllers/login_controller.dart';
import 'package:thinkdiecast/route_management/routes.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/shrink_button.dart';
import '../utils/widgets.dart';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    // timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   setState(() => _index++);
    // });
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: AddProductController(),
      builder: (controller) {
        return Scaffold(
            appBar: AppBar(),
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColors.primaryLight,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: InkWell(
                          onTap: () async {
                            controller.requestPermission(context, setState);
                          },
                          child: Stack(
                            children: [
                              Card(
                                elevation: 5,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width / 2,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.light),
                                  child: controller.image == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.bright),
                                              child: const Icon(
                                                Icons.file_upload_outlined,
                                                color: AppColors.white,
                                                size: 30,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text("Tap to upload")
                                          ],
                                        )
                                      : Image.file(
                                          File(controller.image!.path),
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                              controller.image == null
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      right: -5,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              controller.image = null;
                                            });
                                          },
                                          icon: Card(
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: Icon(
                                                Icons.delete_forever,
                                                color: Colors.red,
                                              ),
                                            ),
                                          )),
                                    )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                        child: Text(
                          'Title',
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
                            controller: controller.titleNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 10),
                              // counterText: '',
                              // hintText: "Email",
                              // hintStyle: hintTextStyle(14, FontWeight.w500),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                        child: Text(
                          'Brand',
                          style: labelStyle(),
                        ),
                      ),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.dark50)),
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Brand')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    padding: const EdgeInsets.only(left: 8),
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    hint: const Text(
                                      'Select Brand',
                                      style: TextStyle(
                                          color: AppColors.dark50,
                                          fontSize: 18),
                                    ),
                                    value: controller.selectedBrand,
                                    // Step 4.
                                    items: snapshot.data!.docs
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value['name'],
                                        child: Text(
                                          value['name'],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.dark),
                                        ),
                                      );
                                    }).toList(),
                                    // Step 5.
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        controller.selectedBrand = newValue!;
                                      });
                                    },
                                  ),
                                );
                              } else {
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    padding: const EdgeInsets.only(left: 8),
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    hint: const Text(
                                      'Select Brand',
                                      style: TextStyle(
                                          color: AppColors.dark50,
                                          fontSize: 18),
                                    ),
                                    value: controller.selectedBrand,
                                    // Step 4.
                                    items: []
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.dark),
                                        ),
                                      );
                                    }).toList(),
                                    // Step 5.
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        controller.selectedBrand = newValue!;
                                      });
                                    },
                                  ),
                                );
                              }
                            }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                        child: Text(
                          'Scale',
                          style: labelStyle(),
                        ),
                      ),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.dark50)),
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Scale')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    padding: const EdgeInsets.only(left: 8),
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    hint: const Text(
                                      'Select Scale',
                                      style: TextStyle(
                                          color: AppColors.dark50,
                                          fontSize: 18),
                                    ),
                                    value: controller.selectedScale,
                                    // Step 4.
                                    items: snapshot.data!.docs
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value['name'],
                                        child: Text(
                                          value['name'],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.dark),
                                        ),
                                      );
                                    }).toList(),
                                    // Step 5.
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        controller.selectedScale = newValue!;
                                      });
                                    },
                                  ),
                                );
                              } else {
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    padding: const EdgeInsets.only(left: 8),
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    hint: const Text(
                                      'Select Scale',
                                      style: TextStyle(
                                          color: AppColors.dark50,
                                          fontSize: 18),
                                    ),
                                    value: controller.selectedScale,
                                    // Step 4.
                                    items: []
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.dark),
                                        ),
                                      );
                                    }).toList(),
                                    // Step 5.
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        controller.selectedScale = newValue!;
                                      });
                                    },
                                  ),
                                );
                              }
                            }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                        child: Text(
                          'Year',
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
                              if (val!.isEmpty || val.length < 3) {
                                return 'Please enter valid year';
                              }
                              return null;
                            },
                            maxLength: 4,
                            keyboardType: TextInputType.name,
                            controller: controller.yearController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 10),
                              counterText: '',
                              // hintText: "Email",
                              // hintStyle: hintTextStyle(14, FontWeight.w500),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                        child: Text(
                          'Category',
                          style: labelStyle(),
                        ),
                      ),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.dark50)),
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Category')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    padding: const EdgeInsets.only(left: 8),
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    hint: const Text(
                                      'Select Category',
                                      style: TextStyle(
                                          color: AppColors.dark50,
                                          fontSize: 18),
                                    ),
                                    // Step 3.
                                    value: controller.selectedCategory,
                                    // Step 4.
                                    items: snapshot.data!.docs
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value['name'],
                                        child: Text(
                                          value['name'],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.dark),
                                        ),
                                      );
                                    }).toList(),
                                    // Step 5.
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        controller.selectedCategory = newValue!;
                                      });
                                    },
                                  ),
                                );
                              } else {
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    padding: const EdgeInsets.only(left: 8),
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    hint: const Text(
                                      'Select Category',
                                      style: TextStyle(
                                          color: AppColors.dark50,
                                          fontSize: 18),
                                    ),
                                    value: controller.selectedCategory,
                                    // Step 4.
                                    items: []
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.dark),
                                        ),
                                      );
                                    }).toList(),
                                    // Step 5.
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        controller.selectedCategory = newValue!;
                                      });
                                    },
                                  ),
                                );
                              }
                            }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                        child: Text(
                          'Colour',
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
                                return 'Please enter colour';
                              }
                              return null;
                            },
                            // maxLength: 10,
                            keyboardType: TextInputType.name,
                            controller: controller.colorController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 10),
                              // counterText: '',
                              // hintText: "Email",
                              // hintStyle: hintTextStyle(14, FontWeight.w500),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                        child: Text(
                          'Price',
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
                                return 'Please enter valid price';
                              }
                              return null;
                            },
                            // maxLength: 10,
                            keyboardType: TextInputType.name,
                            controller: controller.priceController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 10),
                              // counterText: '',
                              // hintText: "Email",
                              // hintStyle: hintTextStyle(14, FontWeight.w500),
                            )),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: ShrinkButton(
                          child: 'Add Entry',
                          onPressed: () {
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              // Get.offAll(const IntroScreen());

                              if (controller.formKey.currentState!.validate()) {
                                controller.addProduct();
                              } else {
                                showSnackBar('Please enter valid details!');
                              }
                            });
                          },
                          shrinkScale: 0.7,
                          btnHeight: 50,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}
