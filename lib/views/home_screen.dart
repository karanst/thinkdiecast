import 'dart:io';

import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/shrink_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();
// Pick an image.
  XFile? image;

  void requestPermission(
      BuildContext context, Function(Function()) setStat) async {
    return await showDialog<void>(
      context: context,
      // barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  bool permissionStatus;
                  // final deviceInfo = await DeviceInfoPlugin().androidInfo;
                  //
                  // if (deviceInfo.version.sdkInt > 32) {
                  //   permissionStatus =
                  //       await Permission.photos.request().isGranted;
                  // } else {
                  //   permissionStatus =
                  //       await Permission.storage.request().isGranted;
                  // }

                  // if (permissionStatus) {
                  // print("image permission access");
                  // getImage(ImageSource.gallery, context, i);
                  pickImage(true, setStat);
                  // getImageGallery(ImgSource.Gallery, context ,i);
                  // } else {
                  //   // Fluttertoast.showToast(msg: "Permission is required!");
                  // }
                  //
                },
                child: Container(
                  child: const ListTile(
                      title: Text("Gallery"),
                      leading: Icon(
                        Icons.image,
                        color: AppColors.primary,
                      )),
                ),
              ),
              Container(
                width: 200,
                height: 1,
                color: Colors.black12,
              ),
              InkWell(
                onTap: () async {
                  pickImage(false, setStat);
                },
                child: Container(
                  child: const ListTile(
                      title: Text("Camera"),
                      leading: Icon(
                        Icons.camera,
                        color: AppColors.primary,
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );

    ///
  }

  pickImage(bool isGallery, Function(Function()) setStat) async {
    if (isGallery) {
      image = await picker.pickImage(source: ImageSource.gallery);
      setStat(() {});
    } else {
      image = await picker.pickImage(source: ImageSource.camera);
      setStat(() {});
    }
    Navigator.pop(context);
  }

  DateTime? _selectedDate;

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //   }
  // }

  _openVisitBottomSheet(controller) {
    showModalBottomSheet(
      elevation: 2,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
            heightFactor: 0.70,
            child: StatefulBuilder(
              builder: (BuildContext context, Function(Function()) setStat) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Visit",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setStat(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Card(
                            elevation: 5,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  // border: Border.all(
                                  //     color: AppColors.primary),
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.white.withOpacity(0.4)),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.primary,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(_selectedDate == null
                                      ? 'Revisit Date'
                                      : DateFormat('dd-MM-yyyy')
                                          .format(_selectedDate!)
                                          .toString()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 60,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                // border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.white.withOpacity(0.4)),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.note_alt_outlined,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: TextFormField(
                                    // textAlign: TextAlign.center,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(top: 25),
                                        border: InputBorder.none,
                                        hintText: "Remarks"),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: InkWell(
                          onTap: () async {
                            requestPermission(context, setStat);
                          },
                          child: Stack(
                            children: [
                              Card(
                                elevation: 5,
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  height: MediaQuery.of(context).size.width / 2,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      // image: DecorationImage(
                                      //   image: Image.file(File(image!.path))
                                      // ),
                                      // border: Border.all(color: AppColors.primary),
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.white.withOpacity(0.4)),
                                  child: image == null
                                      ? const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              color: AppColors.primary,
                                              size: 120,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("Visit Image")
                                          ],
                                        )
                                      : Image.file(
                                          File(image!.path),
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                              image == null
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      right: -5,
                                      child: IconButton(
                                          onPressed: () {
                                            setStat(() {
                                              image = null;
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
                      // Spacer(),
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ShrinkButton(
                          // btnWidth: 120,
                          child: 'SUBMIT',
                          onPressed: () {
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              // _openVisitBottomSheet(context);
                            });
                          },
                          shrinkScale: 0.7,
                          btnHeight: 40,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ));
      },
    );
  }

  _openCollectionBottomSheet(controller) {
    showModalBottomSheet(
      elevation: 2,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
            heightFactor: 0.85,
            child: StatefulBuilder(
              builder: (BuildContext context, Function(Function()) setStat) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Collection",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 60,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                // border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.white.withOpacity(0.4)),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.payment,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: AppColors.white,
                                        // Initial Value
                                        value: controller.selectedMode,
                                        isExpanded: true,
                                        hint: Text("Mode of Collection"),
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.primary,
                                        ),
                                        // Array list of items
                                        items: ['COD', 'Online'].map((items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(
                                              items,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          );
                                        }).toList(),
                                        // After selecting the desired option,it will
                                        // change button value to selected value
                                        onChanged: (newValue) {
                                          setState(() {
                                            controller.selectedMode = newValue;
                                          });
                                        },
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 60,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                // border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.white.withOpacity(0.4)),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.money,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: TextFormField(
                                    // textAlign: TextAlign.center,

                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Amount"),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 60,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                // border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.white.withOpacity(0.4)),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.payments_rounded,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: TextFormField(
                                    // textAlign: TextAlign.center,

                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Translation ID"),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 60,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                // border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.white.withOpacity(0.4)),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.note_alt_outlined,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: TextFormField(
                                    // textAlign: TextAlign.center,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(top: 25),
                                        border: InputBorder.none,
                                        hintText: "Remarks"),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: InkWell(
                          onTap: () async {
                            requestPermission(context, setStat);
                          },
                          child: Stack(
                            children: [
                              Card(
                                elevation: 5,
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  height: MediaQuery.of(context).size.width / 2,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      // image: DecorationImage(
                                      //   image: Image.file(File(image!.path))
                                      // ),
                                      // border: Border.all(color: AppColors.primary),
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.white.withOpacity(0.4)),
                                  child: image == null
                                      ? const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              color: AppColors.primary,
                                              size: 120,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("Translation Image")
                                          ],
                                        )
                                      : Image.file(
                                          File(image!.path),
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                              image == null
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      right: -5,
                                      child: IconButton(
                                          onPressed: () {
                                            setStat(() {
                                              image = null;
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
                      // Spacer(),
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ShrinkButton(
                          // btnWidth: 120,
                          child: 'SUBMIT',
                          onPressed: () {
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              // _openVisitBottomSheet(context);
                            });
                          },
                          shrinkScale: 0.7,
                          btnHeight: 40,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final setWidth = MediaQuery.of(context).size.width;
    return GetBuilder(
      init: HomeController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: AppColors.primaryLight,
              body: SingleChildScrollView(
                // physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.all(10),
                    //   height: MediaQuery.of(context).size.height,
                    //   child: ListView.builder(
                    //       shrinkWrap: true,
                    //       itemCount: 10,
                    //       itemBuilder: (context, i) {
                    //         return Card(
                    //           child: Padding(
                    //             padding: const EdgeInsets.all(8.0),
                    //             child: Column(
                    //               children: [
                    //                 const Padding(
                    //                   padding: EdgeInsets.only(bottom: 25.0),
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.spaceBetween,
                    //                     children: [
                    //                       Text(
                    //                         "Nikit Dwivedi",
                    //                         style: TextStyle(
                    //                             fontWeight: FontWeight.w600,
                    //                             fontSize: 20),
                    //                       ),
                    //                       Text(
                    //                         "EQYPD98D",
                    //                         style: TextStyle(
                    //                             fontWeight: FontWeight.w600,
                    //                             fontSize: 20),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 Row(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.spaceBetween,
                    //                   children: [
                    //                     const Column(
                    //                       crossAxisAlignment:
                    //                           CrossAxisAlignment.start,
                    //                       children: [
                    //                         Text('Pending Amount: 5000'),
                    //                         Padding(
                    //                           padding: EdgeInsets.only(
                    //                               top: 10.0, bottom: 10),
                    //                           child: Text(
                    //                               'Revisit Date: 12/07/2024'),
                    //                         ),
                    //                         Text('Call Remark: Will pay on 12'),
                    //                       ],
                    //                     ),
                    //                     Column(
                    //                       children: [
                    //                         ShrinkButton(
                    //                           btnWidth: 120,
                    //                           child: 'Visit',
                    //                           onPressed: () {
                    //                             Future.delayed(
                    //                                 const Duration(
                    //                                     milliseconds: 200), () {
                    //                               _openVisitBottomSheet(
                    //                                   context);
                    //                             });
                    //                           },
                    //                           shrinkScale: 0.7,
                    //                           btnHeight: 40,
                    //                         ),
                    //                         const SizedBox(
                    //                           height: 20,
                    //                         ),
                    //                         ShrinkButton(
                    //                           btnWidth: 120,
                    //                           child: 'Collection',
                    //                           onPressed: () {
                    //                             Future.delayed(
                    //                                 const Duration(
                    //                                     milliseconds: 200), () {
                    //                               _openCollectionBottomSheet(
                    //                                   controller);
                    //                             });
                    //                           },
                    //                           shrinkScale: 0.7,
                    //                           btnHeight: 40,
                    //                         ),
                    //                       ],
                    //                     )
                    //                   ],
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //         );
                    //       }),
                    // ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
