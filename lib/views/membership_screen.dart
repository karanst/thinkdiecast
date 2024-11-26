import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkdiecast/ApiHandler/Services/razorpay_manager.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/shrink_button.dart';


class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  MembershipScreenState createState() => MembershipScreenState();
}

class MembershipScreenState extends State<MembershipScreen> {
  late List<Widget> _screens;

  bool active = false;
  final HomeController _homeController = Get.put(HomeController());
  late RazorpayManager _razorpayManager;

  @override
  void initState() {
    super.initState();
    _razorpayManager = RazorpayManager(
      context,
      onPaymentSuccessCallback: updatePlan, // Pass the callback
    );
    _razorpayManager = RazorpayManager(context);
    _razorpayManager.initialize();
    stream = FirebaseFirestore.instance.collection('Membership').snapshots();
    fetchDetails();

  }

  @override
  void dispose() {
    _razorpayManager.dispose();
    super.dispose();
  }

  void startPayment(int amount) {
    _razorpayManager.openCheckout(
      apiKey: 'rzp_live_zVxJxUNbIpRrBA',
      amount: amount,
      name: 'Think Diecast',
      description: 'Payment for Think DieCast Subscription',
      contact: '',
      email: '',
    );
  }

  String? userId;

  fetchDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userId = preferences.getString('userId');
    });

    getUsers();
  }

  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? userData;

  void getUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    for (var document in snapshot.docs) {
      setState(() {
        users.add(document.data());
      });
      if (document['uid'] == userId) {
        userData = document.data();
        percentage = (double.parse(userData!['entries'].toString()) /
            double.parse(userData!['limit'].toString()));
      }
    }

    print('Data:  $userData $percentage');
  }

  void updatePlan() async {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
          'plan' : selectedDoc!['name'],
          'limit': selectedDoc!['limit'],
        });
    getUsers();
  }

  final PageController pageController = PageController(initialPage: 0);

  DocumentSnapshot? selectedDoc;
  double percentage = 0;

  Stream<QuerySnapshot>? stream;

  int selIndex = -1;
  int selectedAmount = 0 ;
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.bright,
              title: const Text('Membership'),
              centerTitle: true,
            ),
            extendBody: true,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height * 0.26,
                    decoration: BoxDecoration(
                        color: AppColors.bright,
                        borderRadius: BorderRadius.circular(20)),
                    child: userData == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Current Plan',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  userData!['plan'] == 'free'
                                      ? 'Free'
                                      : userData!['plan'],
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5.0, right: 10),
                                    child: Text(
                                      textAlign: TextAlign.right,
                                      '${userData!['entries']}/${userData!['limit']}',
                                      style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 50,
                                lineHeight: 8.0,
                                barRadius: Radius.circular(4),
                                percent: percentage,
                                backgroundColor: Colors.white,
                                progressColor: AppColors.dark,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 5.0, bottom: 12, left: 8),
                                child: Text(
                                  'INVENTORY UPLOADED',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  userData!['name'] == 'Free' ?
                                  'Note: \nonly ${userData!['limit']} uploads allowed in free plan'
                                  : 'Note: \nonly ${userData!['limit']} uploads allowed in ${userData!['plan']} plan',
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.53,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError)
                            return Text('Something went wrong');
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) return Text("Loading");
                          List<DocumentSnapshot> documents =
                              snapshot.data!.docs;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 15.0,
                                      crossAxisSpacing: 15.0,
                                      childAspectRatio: 0.9),
                              itemCount: documents.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                DocumentSnapshot document = documents[index];
                                return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selIndex = index;
                                        selectedAmount = int.parse(document['price'].toString());
                                        selectedDoc = document;
                                      });
                                     },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      height:
                                          MediaQuery.of(context).size.width /
                                                  2 -
                                              30,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              width: selIndex == index ? 2 : 1,
                                              color: selIndex == index
                                                  ? AppColors.bright
                                                  : Color(0xffCBC0C0))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            document['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 18),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0, bottom: 25),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5.0),
                                                      child: Text(
                                                        'Rs.',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${document['price']}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 36),
                                                    ),
                                                  ],
                                                ),
                                                const Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Text(
                                                    '/ Year',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            document['name'] == 'COLLECTOR'
                                                ? '• Unlimited upload allowed'
                                                : '• Upto ${document['limit']} upload \n allowed',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ));
                              },
                            ),
                          );
                        }),
                  ),
                  selIndex != -1
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 10, right: 10, bottom: 30),
                          child: ShrinkButton(
                              child: 'Update Plan', onPressed: (){
                                int amount = selectedAmount * 100 ;

                                startPayment(amount);
                          }
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          );
        });
  }
}


