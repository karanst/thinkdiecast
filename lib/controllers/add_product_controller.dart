import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thinkdiecast/ApiHandler/Services/api.dart';
import 'package:thinkdiecast/controllers/appbase_controller.dart';
import 'package:thinkdiecast/route_management/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
// import 'package:otp_text_field/otp_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:thinkdiecast/utils/colors.dart';

import '../utils/widgets.dart';

class AddProductController extends AppBaseController {
  TextEditingController titleNameController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String pin = '';
  String? selectedBrand, selectedCategory, selectedScale;

  final formKey = GlobalKey<FormState>();
  int value1 = 0;
  bool isVisible = true;

  bool shoPass = true;

  final ImagePicker picker = ImagePicker();
// Pick an image.
  XFile? image;

  String? userId;
  fetchDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('userId');
    update();
    getEntries();
  }

  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? userData;
  String? entries;

  void getEntries() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    for (var document in snapshot.docs) {
      users.add(document.data());

      if (document['uid'] == userId) {
        userData = document.data();
        entries = userData!['entries'];
      }
    }
    update();
  }

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
                  pickImage(true, setStat);
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

    Get.back();
  }

  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? docID;

  Future<void> uploadProductImage(File file, String userId) async {
    Reference db = FirebaseStorage.instance
        .ref()
        .child('Products/$userId/${DateTime.now().toString()}');
    await db.putFile(File(file.path));

    print('this is image is sending $db');

    final imageUrl = await db.getDownloadURL();

    DocumentReference docRef = await firestore.collection('Products').add({
      'image': imageUrl,
    });
    docID = docRef.id;
    update();
  }

  addProduct() async {
    if (selectedBrand == null ||
        selectedCategory == null ||
        selectedScale == null) {
      showSnackBar('Please fill all details first!');
    } else {
      await uploadProductImage(File(image!.path), userId.toString() ?? '');
      if (docID == '' || docID == null) {
        showSnackBar('Image not uploaded properly! Try to Re-upload');
      } else {
        await firestore.collection('Products').doc(docID).update({
          'brand': selectedBrand ?? '',
          'category': selectedCategory ?? '',
          'color': colorController.text.toString() ?? '',
          'name': titleNameController.text.toString(),
          'price': priceController.text.toString(),
          'scale': selectedScale ?? '',
          'year': yearController.text.toString(),
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': userId
        });
        entries = (int.parse(entries.toString()) + 1).toString();
        update();
        await firestore
            .collection('Users')
            .doc(userId)
            .update({'entries': entries});
        clear();
        Get.offAllNamed(dashbord);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  clear() {
    titleNameController.clear();
    colorController.clear();
    priceController.clear();
    yearController.clear();
    selectedScale = null;
    selectedCategory = null;
    selectedBrand = null;
    image = null;
    docID = null;
    update();
  }

  //
  // List<Data> loginData = [];
}
