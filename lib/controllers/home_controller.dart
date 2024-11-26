import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thinkdiecast/controllers/appbase_controller.dart';

class HomeController extends AppBaseController {
  List<Map<String, dynamic>> productsList = [];

  List<Map<String, dynamic>> brands = [];

  String? userId;
  fetchDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('userId');
    update();
  }

  void getAllProducts() async {
    productsList = [];
    final snapshot =
        await FirebaseFirestore.instance.collection('Products').get();
    snapshot.docs.forEach((document) {
      productsList.add(document.data());
    });
    update();

    print('Data: $productsList');
  }

  List<DocumentSnapshot> filteredDocs = [];

  Stream<List<DocumentSnapshot>> getUserInventory() async* {
    filteredDocs.clear();

    await for (var snapshot
        in FirebaseFirestore.instance.collection('Products').snapshots()) {

      for (var document in snapshot.docs) {
        if (document['createdBy'] == userId) {
          filteredDocs.add(document); // Add the DocumentSnapshot to the list
        }
      }

      // Yield the filtered list of DocumentSnapshot objects
      yield filteredDocs;
    }
  }

  void getAllCategories() async {
    brands = [];
    final snapshot = await FirebaseFirestore.instance.collection('Brand').get();
    for (var document in snapshot.docs) {
      brands.add(document.data());
    }
    update();

    print('brands: $brands');
  }

  clear() {
    brands.clear();
    productsList.clear();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
    // getAllProducts();
    getAllCategories();
  }
}
