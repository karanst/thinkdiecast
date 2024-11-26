import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/views/DialogWidgets/search_dialog_widget.dart';
import 'package:thinkdiecast/views/DialogWidgets/settings_menu_dialog.dart';
import 'package:thinkdiecast/views/add_product_screen.dart';
import 'package:thinkdiecast/views/home_screen.dart';
import 'package:thinkdiecast/views/membership_screen.dart';
import 'package:thinkdiecast/views/product_details_screen.dart';
import 'package:thinkdiecast/views/search_list_screen.dart';

import 'DialogWidgets/see_details_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late List<Widget> _screens;

  bool active = false;
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    // _homeController.getAllProducts();
    stream = FirebaseFirestore.instance.collection('Products').snapshots();

    // _pageIndex = widget.pageIndex;
    //
    // _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const HomeScreen(),
      const HomeScreen(),
    ];
  }

  final PageController pageController = PageController(initialPage: 0);
  late int _selectedIndex = 0;

  Stream<QuerySnapshot>? stream;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
              // appBar: AppBar(
              //   title: const Text('Bottom Navigation Bar'),
              //   centerTitle: true,
              // ),
              extendBody: true,
              body: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  StreamBuilder<List<DocumentSnapshot>>(
                      stream: controller.getUserInventory(),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        List<DocumentSnapshot> documents = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15.0,
                                    crossAxisSpacing: 4.0,
                                    childAspectRatio: 0.8),
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot document = documents[index];
                              return InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SeeDetailsDialog(data: document);
                                      },
                                    );
                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=> SeeDetails()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                document['image']!))),
                                    // child: Image.network(
                                    //     document['image']!),
                                  ));
                            },
                          ),
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 70),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 65,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.brands.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchListScreen(
                                                        searchKeyword:
                                                            controller.brands[
                                                                    index]
                                                                ['name'])));
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 70,
                                        child: Image.network(
                                            controller.brands[index]['image']),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.filter_alt_outlined,
                                color: AppColors.bright,
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // bottomSheet:
              bottomNavigationBar: Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SearchDialogWidget();
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          child: Image.asset('assets/icons/search.png'),
                        )),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddProductScreen()));
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                            color: AppColors.bright, shape: BoxShape.circle),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SettingMenuDialog();
                            },
                          );
                        },
                        icon: Icon(Icons.menu)),
                  ],
                ),
              ));
        });
  }
}
