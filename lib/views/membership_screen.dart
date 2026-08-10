import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';


class MembershipScreen extends StatefulWidget {
  final bool showButton;
  const MembershipScreen({super.key, required this.showButton});

  @override
  MembershipScreenState createState() => MembershipScreenState();
}

class MembershipScreenState extends State<MembershipScreen> {
  late UserController userController;
  late HomeController homeController;
  late Razorpay _razorpay;

  Map<String, dynamic>? selectedPlan;
  int selIndex = -1;
  int selectedAmount = 0;
  List<Map<String, dynamic>> membershipPlans = [];
  bool isProcessingPayment = false;
  bool isLoadingPlans = false;

  // Plan icons mapping
  final Map<String, String> planIcons = {
    'NOOB': 'assets/noob.png',
    'PRO': 'assets/pro.png',
    'LEGEND': 'assets/legend.png',
    'COLLECTOR': 'assets/collector.png',
  };

  @override
  void initState() {
    super.initState();
    userController = Get.put(UserController());
    homeController = Get.put(HomeController());
    _initializeRazorpay();
    _loadMembershipPlans();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadMembershipPlans() async {
    try {
      setState(() => isLoadingPlans = true);

      // Fetch membership plans from API
      final response = await homeController.apiService.get('/Membership/findAll');

      if (response != null && response is List) {
        setState(() {
          membershipPlans = List<Map<String, dynamic>>.from(
              response.map((item) => item as Map<String, dynamic>)
          );
        });
      }
    } catch (e) {
      print('[v0] Error loading membership plans: $e');
      _showError('Failed to load membership plans. Please try again.');
    } finally {
      setState(() => isLoadingPlans = false);
    }
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // void _setupUserDataListener() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String? userId = preferences.getString('userId');
  //
  //   if (userId != null) {
  //     _userDataSubscription = FirebaseFirestore.instance
  //         .collection('Users')
  //         .doc(userId)
  //         .snapshots()
  //         .listen((DocumentSnapshot snapshot) {
  //       if (snapshot.exists && mounted) {
  //         final data = snapshot.data() as Map<String, dynamic>;
  //         userController.updateUserDataFromSnapshot(data);
  //       }
  //     });
  //   }
  // }

  void startPayment(int amount) {
    if (selectedPlan == null || userController.currentUser == null) {
      _showError('Please select a plan and try again');
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    var options = {
      'key': 'rzp_live_zVxJxUNbIpRrBA',
      'amount': amount,
      'name': 'ThinkDieCast',
      'description': '${selectedPlan!['name']} Plan Upgrade',
      'prefill': {
        'contact': userController.currentUser?.phone ?? '',
        'email': userController.currentUser?.email1 ?? ''
      },
      'theme': {'color': '#2196F3'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
      });
      _showError('Error opening payment gateway: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      isProcessingPayment = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Payment Successful!\nUpdating your plan...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    updatePlan(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isProcessingPayment = false;
    });

    String errorMessage = 'Payment failed. Please try again.';
    if (response.message != null) {
      errorMessage = response.message!;
    }

    _showPaymentFailedDialog(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      isProcessingPayment = false;
    });
    _showError('External wallet selected: ${response.walletName}');
  }

  void updatePlan(String? paymentId) async {
    try {
      if (selectedPlan != null && userController.userId != null) {
        // Update plan via API
        await userController.updatePlan(
          selectedPlan!['name'],
          int.parse(selectedPlan!['limit'].toString()),
        );

        // Update user entries to the new plan limit
        await userController.fetchUserProfile();

        Navigator.of(context).pop();
        _showPlanUpdateSuccess();

        setState(() {
          selIndex = -1;
          selectedPlan = null;
          selectedAmount = 0;
        });
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showError('Failed to update plan: $e');
    }
  }

  void _showPlanUpdateSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Plan Upgraded Successfully!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${selectedPlan?['name'] ?? 'new'} plan is now active.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentFailedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (selectedAmount > 0) {
                        startPayment(selectedAmount * 100);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/auth_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCircularProgress(),
              Expanded(
                child: _buildMembershipBottomSheet(),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.arrow_back_ios, color: AppColors.white,)),
              _buildProfilePictureSection(),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WELCOME',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userController.currentUser?.name ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          _buildCurrentPlanIcon()
        ],
      ),
    );
  }

  Widget _buildCurrentPlanIcon() {
    String currentPlan = userController.currentUser?.plan?.toString().toUpperCase() ?? 'FREE';
    String planIconPath = _getPlanIconPath(currentPlan);

    return Container(
      width: 40,
      height: 40,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.bright,
            AppColors.bright2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.bright.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          planIconPath,
          width: 28,
          height: 28,
          // color: Colors.white,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            );
          },
        ),
      ),
    );
  }

  String _getPlanIconPath(String planName) {
    switch (planName) {
      case 'NOOB':
        return 'assets/noob.png';
      case 'PRO':
        return 'assets/pro.png';
      case 'LEGEND':
        return 'assets/legend.png';
      case 'COLLECTOR':
        return 'assets/collector.png';
      case 'FREE':
      default:
        return 'assets/free.png';
    }
  }

  Widget _buildProfilePictureSection() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          if (userController.isLoading.value)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (userController.profileImagePath.value.isNotEmpty) {
      return Image.network(
        userController.profileImagePath.value,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: GradientCirclePainter(
              percentage: userController.percentage,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Total Usage',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userController.entries,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 2,
              width: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 4),
            Text(
              userController.limit,
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipBottomSheet() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'UPGRADE YOUR MEMBERSHIP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildMembershipPlans(),
          ),
          if (selIndex != -1 && _canUpgrade()) _buildUpgradeButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMembershipPlans() {
    if (isLoadingPlans) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (membershipPlans.isEmpty) {
      return const Center(
        child: Text(
          'No membership plans available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: membershipPlans.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> plan = membershipPlans[index];
        bool isCurrentPlan = userController.currentUser != null &&
            userController.currentUser!.plan == plan['name'];
        bool isSelected = selIndex == index;

        return _buildPlanCard(
          plan: plan,
          isCurrentPlan: isCurrentPlan,
          isSelected: isSelected,
          onTap: () {
            if (!isCurrentPlan && !isProcessingPayment) {
              setState(() {
                selIndex = index;
                selectedAmount = int.parse(plan['price']?.toString() ?? '0');
                selectedPlan = plan;
              });
            }
          },
        );
      },
    );
  }

  Widget _buildPlanCard({
    required Map<String, dynamic> plan,
    required bool isCurrentPlan,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    String planName = plan['name'];
    String iconPath = planIcons[planName] ?? 'assets/noob.png';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card Container
            Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.fromLTRB(50, 20, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCurrentPlan
                      ? [AppColors.bright, AppColors.bright2]
                      : isSelected
                      ? [
                    AppColors.bright, AppColors.bright2
                  ]
                      : [Colors.transparent, Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrentPlan ? Colors.green :AppColors.bright,
                  width: isCurrentPlan || isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan['name'] == 'COLLECTOR'
                              ? 'UNLIMITED uploads allowed'
                              : 'Upto ${plan['limit']} uploads allowed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Rs. ',
                        style:  TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${plan['price']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding:  EdgeInsets.only(top: 20.0),
                        child: Text(
                          ' /yr',
                          style:  TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  )

                ],
              ),
            ),

            // Hexagonal Icon positioned half outside
            Positioned(
              left: -5,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/hexa-bg.png'),
                      fit: BoxFit.fill,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.bright.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      iconPath,
                      width: 35,
                      height: 35,
                      // color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isProcessingPayment
                ? [Colors.grey, Colors.grey.shade400]
                : [AppColors.bright, AppColors.bright],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isProcessingPayment ? Colors.grey : Colors.blue)
                  .withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isProcessingPayment
              ? null
              : () {
            int amount = selectedAmount * 100;
            startPayment(amount);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isProcessingPayment
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Processing...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          )
              : const Text(
            'Upgrade',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  bool _canUpgrade() {
    if (userController.currentUser == null ||

        selectedPlan == null ||
        isProcessingPayment) {
      return false;
    }
    return userController.currentUser!.plan != selectedPlan!['name'];
  }
}

/*
class MembershipScreen extends StatefulWidget {
  final bool showButton;
  const MembershipScreen({super.key, required this.showButton});

  @override
  MembershipScreenState createState() => MembershipScreenState();
}

class MembershipScreenState extends State<MembershipScreen> {
  late UserProfileController userController;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  late Razorpay _razorpay;

  DocumentSnapshot? selectedDoc;
  int selIndex = -1;
  int selectedAmount = 0;
  Stream<QuerySnapshot>? stream;
  bool isProcessingPayment = false;

  // Plan icons mapping
  final Map<String, String> planIcons = {
    'NOOB': 'assets/noob.png',
    'PRO': 'assets/pro.png',
    'LEGEND': 'assets/legend.png',
    'COLLECTOR': 'assets/collector.png',
  };

  @override
  void initState() {
    super.initState();
    userController = Get.put(UserProfileController());
    stream = FirebaseFirestore.instance.collection('Membership').snapshots();
    _setupUserDataListener();
    _initializeRazorpay();
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _setupUserDataListener() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('userId');

    if (userId != null) {
      _userDataSubscription = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data() as Map<String, dynamic>;
          userController.updateUserDataFromSnapshot(data);
        }
      });
    }
  }

  void startPayment(int amount) {
    if (selectedDoc == null || userController.userData == null) {
      _showError('Please select a plan and try again');
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    var options = {
      'key': 'rzp_live_zVxJxUNbIpRrBA',
      'amount': amount,
      'name': 'ThinkDieCast',
      'description': '${selectedDoc!['name']} Plan Upgrade',
      'prefill': {
        'contact': userController.userData!['phone'] ?? '',
        'email': userController.userData!['email'] ?? ''
      },
      'theme': {'color': '#2196F3'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
      });
      _showError('Error opening payment gateway: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      isProcessingPayment = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Payment Successful!\nUpdating your plan...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    updatePlan(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isProcessingPayment = false;
    });

    String errorMessage = 'Payment failed. Please try again.';
    if (response.message != null) {
      errorMessage = response.message!;
    }

    _showPaymentFailedDialog(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      isProcessingPayment = false;
    });
    _showError('External wallet selected: ${response.walletName}');
  }

  void updatePlan(String? paymentId) async {
    try {
      if (selectedDoc != null && userController.userId != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userController.userId)
            .update({
          'plan': selectedDoc!['name'],
          'limit': int.parse(selectedDoc!['limit'].toString()),
          'lastPaymentId': paymentId,
          'planUpdatedAt': FieldValue.serverTimestamp(),
        });

        await userController.updatePlan(
          selectedDoc!['name'],
          int.parse(selectedDoc!['limit'].toString()),
        );

        Navigator.of(context).pop();
        _showPlanUpdateSuccess();

        setState(() {
          selIndex = -1;
          selectedDoc = null;
          selectedAmount = 0;
        });
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showError('Failed to update plan: $e');
    }
  }

  void _showPlanUpdateSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Plan Upgraded Successfully!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${selectedDoc?['name'] ?? 'new'} plan is now active.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentFailedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (selectedAmount > 0) {
                        startPayment(selectedAmount * 100);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/auth_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildCircularProgress(),
                  Expanded(
                    child: _buildMembershipBottomSheet(),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.arrow_back_ios, color: AppColors.white,)),
              _buildProfilePictureSection(),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WELCOME',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userController.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          _buildCurrentPlanIcon()
        ],
      ),
    );
  }

  Widget _buildCurrentPlanIcon() {
    String currentPlan = userController.userData?['plan']?.toString().toUpperCase() ?? 'FREE';
    String planIconPath = _getPlanIconPath(currentPlan);

    return Container(
      width: 40,
      height: 40,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.bright,
            AppColors.bright2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.bright.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          planIconPath,
          width: 28,
          height: 28,
          // color: Colors.white,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            );
          },
        ),
      ),
    );
  }

  String _getPlanIconPath(String planName) {
    switch (planName) {
      case 'NOOB':
        return 'assets/noob.png';
      case 'PRO':
        return 'assets/pro.png';
      case 'LEGEND':
        return 'assets/legend.png';
      case 'COLLECTOR':
        return 'assets/collector.png';
      case 'FREE':
      default:
        return 'assets/free.png';
    }
  }

  Widget _buildProfilePictureSection() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          if (userController.isLoading)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (userController.profileImage.value != null) {
      return Image.file(
        File(userController.profileImage.value!.path),
        fit: BoxFit.cover,
      );
    }

    if (userController.profilePictureUrl.isNotEmpty) {
      return Image.network(
        userController.profilePictureUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: GradientCirclePainter(
              percentage: userController.percentage,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Total Usage',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userController.entries,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 2,
              width: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 4),
            Text(
              userController.limit,
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipBottomSheet() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'UPGRADE YOUR MEMBERSHIP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildMembershipPlans(),
          ),
          if (selIndex != -1 && _canUpgrade()) _buildUpgradeButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMembershipPlans() {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = documents[index];
            bool isCurrentPlan = userController.userData != null &&
                userController.userData!['plan'] == document['name'];
            bool isSelected = selIndex == index;

            return _buildPlanCard(
              document: document,
              isCurrentPlan: isCurrentPlan,
              isSelected: isSelected,
              onTap: () {
                if (!isCurrentPlan && !isProcessingPayment) {
                  setState(() {
                    selIndex = index;
                    selectedAmount = int.parse(document['price'].toString());
                    selectedDoc = document;
                  });
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlanCard({
    required DocumentSnapshot document,
    required bool isCurrentPlan,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    String planName = document['name'];
    String iconPath = planIcons[planName] ?? 'assets/noob.png';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card Container
            Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.fromLTRB(50, 20, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCurrentPlan
                      ? [AppColors.bright, AppColors.bright2]
                      : isSelected
                          ? [
                            AppColors.bright, AppColors.bright2
                            ]
                          : [Colors.transparent, Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrentPlan ? Colors.green :AppColors.bright,
                  width: isCurrentPlan || isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          document['name'] == 'COLLECTOR'
                              ? 'UNLIMITED uploads allowed'
                              : 'Upto ${document['limit']} uploads allowed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Rs. ',
                        style:  TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${document['price']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding:  EdgeInsets.only(top: 20.0),
                        child: Text(
                          ' /yr',
                          style:  TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  )

                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  //     Row(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'Rs.',
                  //           style: TextStyle(
                  //             color: Colors.white.withOpacity(0.7),
                  //             fontSize: 14,
                  //           ),
                  //         ),
                  //         Text(
                  //           '${document['price']}',
                  //           style: const TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 28,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     Text(
                  //       '/yr',
                  //       style: TextStyle(
                  //         color: Colors.white.withOpacity(0.7),
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),

            // Hexagonal Icon positioned half outside
            Positioned(
              left: -5,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/hexa-bg.png'),
                      fit: BoxFit.fill,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.bright.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      iconPath,
                      width: 35,
                      height: 35,
                      // color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isProcessingPayment
                ? [Colors.grey, Colors.grey.shade400]
                : [AppColors.bright, AppColors.bright],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isProcessingPayment ? Colors.grey : Colors.blue)
                  .withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isProcessingPayment
              ? null
              : () {
                  int amount = selectedAmount * 100;
                  startPayment(amount);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isProcessingPayment
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Upgrade',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }

  bool _canUpgrade() {
    if (userController.userData == null ||
        selectedDoc == null ||
        isProcessingPayment) {
      return false;
    }
    return userController.userData!['plan'] != selectedDoc!['name'];
  }
}
*/

// Gradient Circle Painter (reuse from HomeScreen)
class GradientCirclePainter extends CustomPainter {
  final double percentage;

  GradientCirclePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient progress circle
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [
        const Color(0xFFB845F5),
        const Color(0xFF7C3AED),
        const Color(0xFFB845F5),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -1.5708, // Start from top (-90 degrees in radians)
      2 * 3.14159 * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/*
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';


class MembershipScreen extends StatefulWidget {
  final bool showButton;
  const MembershipScreen({super.key, required this.showButton});

  @override
  MembershipScreenState createState() => MembershipScreenState();
}

class MembershipScreenState extends State<MembershipScreen> {
  late UserProfileController userController;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  late Razorpay _razorpay;

  DocumentSnapshot? selectedDoc;
  int selIndex = -1;
  int selectedAmount = 0;
  Stream<QuerySnapshot>? stream;
  bool isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    userController = Get.put(UserProfileController());
    stream = FirebaseFirestore.instance.collection('Membership').snapshots();
    _setupUserDataListener();
    _initializeRazorpay();
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _setupUserDataListener() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('userId');

    if (userId != null) {
      _userDataSubscription = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data() as Map<String, dynamic>;
          userController.updateUserDataFromSnapshot(data);
        }
      });
    }
  }


  void startPayment(int amount) {
    if (selectedDoc == null || userController.userData == null) {
      _showError('Please select a plan and try again');
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    var options = {
      'key': 'rzp_live_zVxJxUNbIpRrBA', // Replace with your Razorpay key
      'amount': amount, // Amount in paise
      'name': 'ThinkDieCast',
      'description': '${selectedDoc!['name']} Plan Upgrade',
      'prefill': {
        'contact': userController.userData!['phone'] ?? '',
        'email': userController.userData!['email'] ?? ''
      },
      'theme': {
        'color': '#2196F3'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
      });
      _showError('Error opening payment gateway: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      isProcessingPayment = false;
    });

    // Show success dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Payment Successful!\nUpdating your plan...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    // Update plan after successful payment
    updatePlan(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isProcessingPayment = false;
    });

    String errorMessage = 'Payment failed. Please try again.';
    if (response.message != null) {
      errorMessage = response.message!;
    }

    _showPaymentFailedDialog(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      isProcessingPayment = false;
    });
    _showError('External wallet selected: ${response.walletName}');
  }

  void updatePlan(String? paymentId) async {
    try {
      if (selectedDoc != null && userController.userId != null) {
        // Update plan in Firestore with payment details
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userController.userId)
            .update({
          'plan': selectedDoc!['name'],
          'limit': int.parse(selectedDoc!['limit'].toString()),
          'lastPaymentId': paymentId,
          'planUpdatedAt': FieldValue.serverTimestamp(),
        });

        // Update local controller
        await userController.updatePlan(
          selectedDoc!['name'],
          int.parse(selectedDoc!['limit'].toString()),
        );

        Navigator.of(context).pop(); // Close loading dialog
        _showPlanUpdateSuccess();

        // Reset selection
        setState(() {
          selIndex = -1;
          selectedDoc = null;
          selectedAmount = 0;
        });
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showError('Failed to update plan: $e');
    }
  }

  void _showPlanUpdateSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Plan Upgraded Successfully!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${selectedDoc?['name'] ?? 'new'} plan is now active.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentFailedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Retry payment
                      if (selectedAmount > 0) {
                        startPayment(selectedAmount * 100);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Membership',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (widget.showButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'SKIP',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const SizedBox.shrink()
        ],
        centerTitle: true,
        elevation: 0,
      ),
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCurrentPlanCard(),
            _buildMembershipPlans(),
            if (selIndex != -1 && _canUpgrade()) _buildUpgradeButton(),
          ],
        ),
      ),
    ));
  }

  Widget _buildCurrentPlanCard() {
    if (userController.userData == null) {
      return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userController.userData!['plan'] == 'free'
                ? 'Free'
                : userController.userData!['plan'] ?? 'Free',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${userController.currentEntries}/${userController.currentLimit}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withOpacity(0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: userController.percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'INVENTORY UPLOADED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Note: Only ${userController.currentLimit} uploads allowed in ${userController.userData!['plan'] ?? 'free'} plan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipPlans() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.53,
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
                childAspectRatio: 0.9,
              ),
              itemCount: documents.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                DocumentSnapshot document = documents[index];
                bool isCurrentPlan = userController.userData != null &&
                    userController.userData!['plan'] == document['name'];

                return InkWell(
                  onTap: isCurrentPlan || isProcessingPayment ? null : () {
                    setState(() {
                      selIndex = index;
                      selectedAmount = int.parse(document['price'].toString());
                      selectedDoc = document;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: isCurrentPlan ? 3 : (selIndex == index ? 2 : 1),
                        color: isCurrentPlan
                            ? Colors.green
                            : (selIndex == index ? Colors.blue : const Color(0xffCBC0C0)),
                      ),
                      color: isCurrentPlan
                          ? Colors.green.withOpacity(0.1)
                          : Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  document['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: isCurrentPlan ? Colors.green : Colors.black,
                                  ),
                                ),
                                if (isCurrentPlan)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'CURRENT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: isCurrentPlan ? Colors.green : Colors.black,
                                  ),
                                ),
                                Text(
                                  '${document['price']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 32,
                                    color: isCurrentPlan ? Colors.green : Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '/ Year',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: isCurrentPlan ? Colors.green : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              document['name'] == 'COLLECTOR'
                                  ? '• Unlimited uploads allowed'
                                  : '• Up to ${document['limit']} uploads allowed',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: isCurrentPlan ? Colors.green : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        if (isCurrentPlan)
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 15, right: 15, bottom: 30),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isProcessingPayment
                ? [Colors.grey, Colors.grey.shade400]
                : [Colors.blue, Colors.blueAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isProcessingPayment ? Colors.grey : Colors.blue).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isProcessingPayment ? null : () {
            int amount = selectedAmount * 100;
            startPayment(amount);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isProcessingPayment
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Processing...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          )
              : const Text(
            'UPGRADE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  bool _canUpgrade() {
    if (userController.userData == null || selectedDoc == null || isProcessingPayment) return false;
    return userController.userData!['plan'] != selectedDoc!['name'];
  }
}
*/

// class MembershipScreen extends StatefulWidget {
//   final bool showButton;
//   const MembershipScreen({super.key, required this.showButton});
//
//   @override
//   MembershipScreenState createState() => MembershipScreenState();
// }
//
// class MembershipScreenState extends State<MembershipScreen> {
//
//
//   bool active = false;
//   late RazorpayManager _razorpayManager;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpayManager = RazorpayManager(
//       context,
//       onPaymentSuccessCallback: updatePlan, // Pass the callback
//     );
//     _razorpayManager = RazorpayManager(context);
//     _razorpayManager.initialize();
//     stream = FirebaseFirestore.instance.collection('Membership').snapshots();
//     fetchDetails();
//
//   }
//
//   @override
//   void dispose() {
//     _razorpayManager.dispose();
//     super.dispose();
//   }
//
//   void startPayment(int amount) {
//     _razorpayManager.openCheckout(
//       apiKey: 'rzp_live_zVxJxUNbIpRrBA',
//       amount: amount,
//       name: 'Think Diecast',
//       description: 'Payment for Think DieCast Subscription',
//       contact: '',
//       email: '',
//     );
//   }
//
//   String? userId;
//
//   fetchDetails() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     setState(() {
//       userId = preferences.getString('userId');
//     });
//
//     getUsers();
//   }
//
//   List<Map<String, dynamic>> users = [];
//   Map<String, dynamic>? userData;
//
//   void getUsers() async {
//     final snapshot = await FirebaseFirestore.instance.collection('Users').get();
//     for (var document in snapshot.docs) {
//       setState(() {
//         users.add(document.data());
//       });
//       if (document['uid'] == userId) {
//         userData = document.data();
//         percentage = (double.parse(userData!['entries'].toString()) /
//             double.parse(userData!['limit'].toString()));
//       }
//     }
//
//     print('Data:  $userData $percentage');
//   }
//
//   void updatePlan() async {
//
//     await FirebaseFirestore.instance.collection('Users').doc(userId).update({
//           'plan' : selectedDoc!['name'],
//           'limit': selectedDoc!['limit'],
//         });
//     getUsers();
//   }
//
//   final PageController pageController = PageController(initialPage: 0);
//
//   DocumentSnapshot? selectedDoc;
//   double percentage = 0;
//
//   Stream<QuerySnapshot>? stream;
//
//   int selIndex = -1;
//   int selectedAmount = 0 ;
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder(
//         init: HomeController(),
//         builder: (controller) {
//           return Scaffold(
//             appBar: AppBar(
//               leading: IconButton(
//                 onPressed: (){
//                   Navigator.pop(context);
//                 },
//                 icon: const Icon(Icons.arrow_back_outlined, color: AppColors.dark,),
//               ),
//               backgroundColor: AppColors.white,
//               title: const Text('Membership',
//               style: TextStyle(
//                 color: AppColors.dark,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700
//               ),),
//               actions: [
//                 widget.showButton ?
//                 TextButton(
//                     onPressed: (){
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(builder: (context) => const DashboardScreen()),
//                   );
//                 }, child: const Text('SKIP', style: TextStyle(
//                     color: AppColors.dark,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700
//                 ),))
//                     : const SizedBox.shrink()
//               ],
//               centerTitle: true,
//             ),
//             extendBody: true,
//             body: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     margin: const EdgeInsets.all(15),
//                     width: MediaQuery.of(context).size.width,
//                     // height: MediaQuery.of(context).size.height * 0.26,
//                     decoration: BoxDecoration(
//                         color: AppColors.bright,
//                         borderRadius: BorderRadius.circular(20)),
//                     child: userData == null
//                         ? const Center(
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Padding(
//                                 padding: EdgeInsets.only(left: 8.0),
//                                 child: Text(
//                                   'Current Plan',
//                                   style: TextStyle(
//                                       color: AppColors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 8.0),
//                                 child: Text(
//                                   userData!['plan'] == 'free'
//                                       ? 'Free'
//                                       : userData!['plan'],
//                                   style: const TextStyle(
//                                       color: AppColors.white,
//                                       fontSize: 36,
//                                       fontWeight: FontWeight.w700),
//                                 ),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                         bottom: 5.0, right: 10),
//                                     child: Text(
//                                       textAlign: TextAlign.right,
//                                       '${userData!['entries']}/${userData!['limit']}',
//                                       style: const TextStyle(
//                                           color: AppColors.white,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               LinearPercentIndicator(
//                                 width: MediaQuery.of(context).size.width - 50,
//                                 lineHeight: 8.0,
//                                 barRadius: Radius.circular(4),
//                                 percent: percentage,
//                                 backgroundColor: Colors.white,
//                                 progressColor: AppColors.dark,
//                               ),
//                               const Padding(
//                                 padding: EdgeInsets.only(
//                                     top: 5.0, bottom: 12, left: 8),
//                                 child: Text(
//                                   'INVENTORY UPLOADED',
//                                   style: TextStyle(
//                                       color: AppColors.white,
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 5.0),
//                                 child: Text(
//                                   userData!['name'] == 'Free' ?
//                                   'Note: \nonly ${userData!['limit']} uploads allowed in free plan'
//                                   : 'Note: \nonly ${userData!['limit']} uploads allowed in ${userData!['plan']} plan',
//                                   style: const TextStyle(
//                                       color: AppColors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.height * 0.53,
//                     child: StreamBuilder<QuerySnapshot>(
//                         stream: stream,
//                         builder: (BuildContext context,
//                             AsyncSnapshot<QuerySnapshot> snapshot) {
//                           if (snapshot.hasError) {
//                             return const Text('Something went wrong');
//                           }
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) return Text("Loading");
//                           List<DocumentSnapshot> documents =
//                               snapshot.data!.docs;
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 15, vertical: 5),
//                             child: GridView.builder(
//                               gridDelegate:
//                                   const SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 2,
//                                       mainAxisSpacing: 15.0,
//                                       crossAxisSpacing: 15.0,
//                                       childAspectRatio: 0.9),
//                               itemCount: documents.length,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 DocumentSnapshot document = documents[index];
//                                 return InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         selIndex = index;
//                                         selectedAmount = int.parse(document['price'].toString());
//                                         selectedDoc = document;
//                                       });
//                                      },
//                                     child: Container(
//                                       padding: const EdgeInsets.all(10),
//                                       height:
//                                           MediaQuery.of(context).size.width /
//                                                   2 -
//                                               30,
//                                       width: MediaQuery.of(context).size.width /
//                                               2 -
//                                           30,
//                                       decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(20),
//                                           border: Border.all(
//                                               width: selIndex == index ? 2 : 1,
//                                               color: selIndex == index
//                                                   ? AppColors.bright
//                                                   : Color(0xffCBC0C0))),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             document['name'],
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.w400,
//                                                 fontSize: 18),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                                 top: 20.0, bottom: 25),
//                                             child: Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.start,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     const Padding(
//                                                       padding: EdgeInsets.only(
//                                                           top: 5.0),
//                                                       child: Text(
//                                                         'Rs.',
//                                                         style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.w400,
//                                                             fontSize: 18),
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       '${document['price']}',
//                                                       style: const TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.w700,
//                                                           fontSize: 36),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 const Align(
//                                                   alignment:
//                                                       Alignment.bottomRight,
//                                                   child: Text(
//                                                     '/ Year',
//                                                     textAlign: TextAlign.end,
//                                                     style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.w400,
//                                                         fontSize: 15),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Text(
//                                             document['name'] == 'COLLECTOR'
//                                                 ? '• Unlimited upload allowed'
//                                                 : '• Upto ${document['limit']} upload \n allowed',
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.w400,
//                                                 fontSize: 13),
//                                           ),
//                                         ],
//                                       ),
//                                     ));
//                               },
//                             ),
//                           );
//                         }),
//                   ),
//                   selIndex != -1
//                       ? Padding(
//                           padding: const EdgeInsets.only(
//                               top: 10.0, left: 15, right: 15, bottom: 30),
//                           child: ShrinkButton(
//                               child: 'UPGRADE', onPressed: (){
//                                 int amount = selectedAmount * 100 ;
//
//                                 startPayment(amount);
//                           }
//                           ),
//                         )
//                       : const SizedBox.shrink(),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
// }
