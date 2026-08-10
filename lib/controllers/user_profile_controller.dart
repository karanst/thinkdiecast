import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';
// import 'package:thinkdiecast/ApiHandler/ApiServices/auth_services.dart';
// import 'package:thinkdiecast/ApiHandler/ApiServices/user_services.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/custom_toast.dart';
import '../models/user_model.dart';

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user_model.dart';


// class UserProfileController extends GetxController {
//   // Reactive variables for real-time updates
//   final RxMap<String, dynamic> _userData = <String, dynamic>{}.obs;
//   final RxString _userId = ''.obs;
//   final RxDouble _percentage = 0.0.obs;
//   final RxBool _isLoading = false.obs;
//   final RxInt _currentEntries = 0.obs;
//   final RxInt _currentLimit = 5.obs;
//
//   final ApiService _apiService = ApiService();
//
//   // Type counts
//   final RxMap<String, int> _typeCounts = <String, int>{}.obs;
//
//   // Profile image
//   Rx<XFile?> profileImage = Rx<XFile?>(null);
//   final ImagePicker _picker = ImagePicker();
//
//   // Stream subscriptions for real-time data
//   StreamSubscription<DocumentSnapshot>? _userDataSubscription;
//   StreamSubscription<QuerySnapshot>? _productsSubscription;
//
//   // Getters
//   Map<String, dynamic>? get userData => _userData.value.isEmpty ? null : _userData.value;
//   String? get userId => _userId.value.isEmpty ? null : _userId.value;
//   double get percentage => _percentage.value;
//   bool get isLoading => _isLoading.value;
//   int get currentEntries => _currentEntries.value;
//   int get currentLimit => _currentLimit.value;
//   String get displayName => _userData['name'] ?? 'User';
//   String get email => _userData['email'] ?? 'No email';
//   String get profilePictureUrl => _userData['profilePicture'] ?? '';
//   String get entries => _currentEntries.value.toString();
//   String get limit => _currentLimit.value.toString();
//
//   // Type count getters
//   int getTypeCount(String type) => _typeCounts[type.toUpperCase()] ?? 0;
//   String getCarsCount() => getTypeCount('CARS').toString();
//   String getBikesCount() => getTypeCount('BIKES').toString();
//   String getTrucksCount() => getTypeCount('TRUCKS').toString();
//   String getPlanesCount() => getTypeCount('PLANES').toString();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeUser();
//   }
//
//   @override
//   void onClose() {
//     _userDataSubscription?.cancel();
//     _productsSubscription?.cancel();
//     super.onClose();
//   }
//
//   Future<void> _initializeUser() async {
//     try {
//       _isLoading.value = true;
//       await _getCurrentUserId();
//       print('User ID: $_userId');
//       if (_userId.value.isNotEmpty) {
//         await _setupRealTimeListeners();
//       }
//     } catch (e) {
//       print('Error initializing user: $e');
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> _getCurrentUserId() async {
//     try {
//      final userId = await _apiService.getUserId();
//      print('User ID: $userId');
//       if (userId != null) {
//         _userId.value = userId;
//       }
//     } catch (e) {
//       print('Error getting user ID: $e');
//     }
//   }
//
//   Future<void> _setupRealTimeListeners() async {
//     if (_userId.value.isEmpty) return;
//
//     try {
//       // Listen to user document changes
//       _userDataSubscription = FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .snapshots()
//           .listen((DocumentSnapshot snapshot) {
//         if (snapshot.exists) {
//           updateUserDataFromSnapshot(snapshot.data() as Map<String, dynamic>);
//         }
//       }, onError: (error) {
//         print('Error listening to user data: $error');
//       });
//
//       // Listen to user's products for real-time entry counting
//       _productsSubscription = FirebaseFirestore.instance
//           .collection('Products')
//           .where('createdBy', isEqualTo: _userId.value)
//           .snapshots()
//           .listen((QuerySnapshot snapshot) {
//         _syncEntriesWithProducts(snapshot.docs.length);
//       }, onError: (error) {
//         print('Error listening to products: $error');
//       });
//
//     } catch (e) {
//       print('Error setting up listeners: $e');
//     }
//   }
//
//   void updateUserDataFromSnapshot(Map<String, dynamic> data) {
//     try {
//       _userData.value = data;
//
//       // Parse entries and limit safely
//       _currentEntries.value = _parseIntValue(data['entries'], 0);
//       _currentLimit.value = _parseIntValue(data['limit'], 5);
//
//       // Update type counts
//       if (data['typeCounts'] != null) {
//         Map<String, dynamic> typeCountsData = data['typeCounts'];
//         _typeCounts.clear();
//         typeCountsData.forEach((key, value) {
//           _typeCounts[key] = _parseIntValue(value, 0);
//         });
//       } else {
//         // Initialize default counts if not present
//         _typeCounts.value = {
//           'CARS': 0,
//           'BIKES': 0,
//           'TRUCKS': 0,
//           'PLANES': 0,
//         };
//       }
//
//       // Calculate percentage
//       if (_currentLimit.value > 0) {
//         _percentage.value = _currentEntries.value / _currentLimit.value;
//       } else {
//         _percentage.value = 0.0;
//       }
//
//       print('User data updated - Entries: ${_currentEntries.value}, Limit: ${_currentLimit.value}, Percentage: ${_percentage.value}');
//       print('Type counts: $_typeCounts');
//     } catch (e) {
//       print('Error updating user data: $e');
//     }
//   }
//
//   int _parseIntValue(dynamic value, int defaultValue) {
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? defaultValue;
//     return defaultValue;
//   }
//
//   Future<void> _syncEntriesWithProducts(int actualProductCount) async {
//     try {
//       if (_currentEntries.value != actualProductCount) {
//         print('Syncing entries: Current=${_currentEntries.value}, Actual=$actualProductCount');
//
//         await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(_userId.value)
//             .update({'entries': actualProductCount});
//       }
//     } catch (e) {
//       print('Error syncing entries: $e');
//     }
//   }
//
//   Future<void> fetchUserData() async {
//     if (_userId.value.isEmpty) {
//       await _getCurrentUserId();
//     }
//
//     if (_userId.value.isEmpty) {
//       throw Exception('User not logged in');
//     }
//
//     try {
//       _isLoading.value = true;
//
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .get();
//
//       if (userDoc.exists) {
//         updateUserDataFromSnapshot(userDoc.data() as Map<String, dynamic>);
//       } else {
//         throw Exception('User document not found');
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//       rethrow;
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> showImagePickerOptions(BuildContext context) async {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundClr,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'UPLOAD PHOTO',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.black,
//                 letterSpacing: 2,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildImageOption(
//                   context,
//                   'Camera',
//                   'assets/camera.png',
//                   AppColors.cardBgClr,
//                       () => _pickImage(ImageSource.camera, context),
//                 ),
//                 _buildImageOption(
//                   context,
//                   'Gallery',
//                   'assets/gallery.png',
//                   AppColors.cardBgClr,
//                       () => _pickImage(ImageSource.gallery, context),
//                 ),
//               ],
//             ),
//             if (profileImage.value != null || profilePictureUrl.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               _buildImageOption(
//                 context,
//                 'Remove',
//                 'assets/icons/delete.svg',
//                 Colors.red,
//                     () => _removeImage(context),
//               ),
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageOption(
//       BuildContext context,
//       String title,
//       String icon,
//       Color color,
//       VoidCallback onTap,
//       ) {
//     return GestureDetector(
//         onTap: () {
//           Navigator.pop(context);
//           onTap();
//         },
//         child: DottedBorder(
//           borderType: BorderType.RRect,
//           radius: const Radius.circular(16),
//           color: Colors.black,
//           strokeWidth: 1,
//           child: Container(
//             width: 130,
//             height: 117,
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//             decoration: BoxDecoration(
//               color: AppColors.cardBgClr,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(
//                 width: 2,
//                 color: color.withOpacity(0.3),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Image.asset(
//                   icon,
//                   width: 45,
//                   height: 45,
//                   color: AppColors.black,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.black,
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         )
//     );
//   }
//
//   // Future<void> showImagePickerOptions(BuildContext context) async {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (context) => Container(
//   //       decoration: const BoxDecoration(
//   //         color: Colors.white,
//   //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //       ),
//   //       padding: const EdgeInsets.all(20),
//   //       child: Column(
//   //         mainAxisSize: MainAxisSize.min,
//   //         children: [
//   //           Container(
//   //             width: 40,
//   //             height: 4,
//   //             decoration: BoxDecoration(
//   //               color: Colors.grey[300],
//   //               borderRadius: BorderRadius.circular(2),
//   //             ),
//   //           ),
//   //           const SizedBox(height: 20),
//   //           const Text(
//   //             'Select Profile Picture',
//   //             style: TextStyle(
//   //               fontSize: 18,
//   //               fontWeight: FontWeight.bold,
//   //               color: Colors.black87,
//   //             ),
//   //           ),
//   //           const SizedBox(height: 20),
//   //           Row(
//   //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //             children: [
//   //               _buildImageOption(
//   //                 context,
//   //                 'Camera',
//   //                 Icons.camera_alt,
//   //                 Colors.blue,
//   //                     () => _pickImage(ImageSource.camera, context),
//   //               ),
//   //               _buildImageOption(
//   //                 context,
//   //                 'Gallery',
//   //                 Icons.photo_library,
//   //                 Colors.green,
//   //                     () => _pickImage(ImageSource.gallery, context),
//   //               ),
//   //             ],
//   //           ),
//   //           if (profileImage.value != null || profilePictureUrl.isNotEmpty) ...[
//   //             const SizedBox(height: 20),
//   //             _buildImageOption(
//   //               context,
//   //               'Remove',
//   //               Icons.delete,
//   //               Colors.red,
//   //                   () => _removeImage(context),
//   //             ),
//   //           ],
//   //           const SizedBox(height: 20),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//   //
//   // Widget _buildImageOption(
//   //     BuildContext context,
//   //     String title,
//   //     IconData icon,
//   //     Color color,
//   //     VoidCallback onTap,
//   //     ) {
//   //   return GestureDetector(
//   //     onTap: () {
//   //       Navigator.pop(context);
//   //       onTap();
//   //     },
//   //     child: Container(
//   //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//   //       decoration: BoxDecoration(
//   //         color: color.withOpacity(0.1),
//   //         borderRadius: BorderRadius.circular(12),
//   //         border: Border.all(color: color.withOpacity(0.3)),
//   //       ),
//   //       child: Column(
//   //         children: [
//   //           Icon(icon, size: 32, color: color),
//   //           const SizedBox(height: 8),
//   //           Text(
//   //             title,
//   //             style: TextStyle(
//   //               fontSize: 14,
//   //               fontWeight: FontWeight.w600,
//   //               color: color,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Future<void> _pickImage(ImageSource source, BuildContext context) async {
//     try {
//       bool hasPermission = await _requestPermission(source);
//       if (!hasPermission) {
//         _showSnackBar(context, 'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission to continue', Colors.orange);
//         return;
//       }
//
//       final XFile? image = await _picker.pickImage(
//         source: source,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 80,
//       );
//
//       if (image != null) {
//         profileImage.value = image;
//         await uploadProfileImage(context);
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//       _showSnackBar(context, 'Failed to pick image: $e', Colors.red);
//     }
//   }
//
//   Future<bool> _requestPermission(ImageSource source) async {
//     if (source == ImageSource.camera) {
//       final status = await Permission.camera.request();
//       return status.isGranted;
//     } else {
//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         return status.isGranted;
//       } else {
//         final status = await Permission.photos.request();
//         return status.isGranted;
//       }
//     }
//   }
//
//   Future<void> _removeImage(BuildContext context) async {
//     try {
//       _isLoading.value = true;
//
//       if (_userId.value.isEmpty) return;
//
//       if (profilePictureUrl.isNotEmpty) {
//         try {
//           final ref = FirebaseStorage.instance.refFromURL(profilePictureUrl);
//           await ref.delete();
//         } catch (e) {
//           print('Error deleting old image: $e');
//         }
//       }
//
//       await FirebaseFirestore.instance.collection('Users').doc(_userId.value).update({
//         'profilePicture': '',
//       });
//
//       profileImage.value = null;
//       _showSnackBar(context, 'Profile picture removed successfully!', Colors.green);
//     } catch (e) {
//       print('Error removing profile image: $e');
//       _showSnackBar(context, 'Failed to remove profile picture: $e', Colors.red);
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> pickProfileImage(BuildContext context) async {
//     await showImagePickerOptions(context);
//   }
//
//   Future<void> uploadProfileImage(BuildContext context) async {
//     if (profileImage.value == null || _userId.value.isEmpty) return;
//
//     try {
//       _isLoading.value = true;
//
//       final String fileName = 'profile_pictures/${_userId.value}/${DateTime.now().millisecondsSinceEpoch}_${profileImage.value!.name}';
//       final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
//
//       final UploadTask uploadTask = storageRef.putFile(File(profileImage.value!.path));
//       final TaskSnapshot snapshot = await uploadTask;
//       final String downloadUrl = await snapshot.ref.getDownloadURL();
//
//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .update({'profilePicture': downloadUrl});
//
//       _showSnackBar(context, 'Profile picture updated successfully!', Colors.green);
//     } catch (e) {
//       _showSnackBar(context, 'Failed to upload profile picture: $e', Colors.red);
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> updateUserEntries(int change) async {
//     try {
//       if (_userId.value.isEmpty) {
//         print('Cannot update entries: User not logged in');
//         return;
//       }
//
//       int newEntries = _currentEntries.value + change;
//
//       if (newEntries < 0) {
//         newEntries = 0;
//       }
//
//       if (change > 0 && newEntries > _currentLimit.value) {
//         print('Cannot exceed entry limit. Current: ${_currentEntries.value}, Limit: ${_currentLimit.value}');
//         return;
//       }
//
//       print('Updating entries from ${_currentEntries.value} to $newEntries for user: ${_userId.value}');
//
//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .update({'entries': newEntries});
//
//       print('Successfully updated entries to: $newEntries');
//     } catch (e) {
//       print('Failed to update user entries: $e');
//       rethrow;
//     }
//   }
//
//   bool canAddEntry() {
//     if (_userData.value.isEmpty) {
//       print('Cannot check entry limit: userData is null');
//       return false;
//     }
//
//     bool canAdd = _currentEntries.value < _currentLimit.value;
//     print('Entry check - Current: ${_currentEntries.value}, Limit: ${_currentLimit.value}, Can add: $canAdd');
//     return canAdd;
//   }
//
//   int getRemainingEntries() {
//     int remaining = _currentLimit.value - _currentEntries.value;
//     return remaining > 0 ? remaining : 0;
//   }
//
//   String getEntryStatusMessage() {
//     if (_userData.value.isEmpty) return 'Unable to load entry information';
//
//     int remaining = getRemainingEntries();
//
//     if (remaining == 0) {
//       return 'You\'ve reached your plan limit of ${_currentLimit.value} entries. Upgrade to add more!';
//     } else if (remaining <= 2) {
//       return 'Only $remaining entries remaining in your current plan';
//     } else {
//       return '$remaining of ${_currentLimit.value} entries available';
//     }
//   }
//
//   Future<void> updatePlan(String planName, int newLimit) async {
//     try {
//       if (_userId.value.isEmpty) return;
//
//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .update({
//         'plan': planName,
//         'limit': newLimit,
//       });
//
//       print('Plan updated successfully: $planName with limit: $newLimit');
//     } catch (e) {
//       print('Error updating plan: $e');
//       rethrow;
//     }
//   }
//
//   // Add this method to your existing UserProfileController class
//
//   Future<void> updateUserProfile({
//     String? name,
//     String? phone,
//     String? city,
//     String? bio,
//   }) async {
//     if (_userId.value.isEmpty) {
//       throw Exception('User not logged in');
//     }
//
//     try {
//       _isLoading.value = true;
//
//       Map<String, dynamic> updateData = {};
//
//       if (name != null && name.isNotEmpty) {
//         updateData['name'] = name;
//       }
//       if (phone != null && phone.isNotEmpty) {
//         updateData['phone'] = phone;
//       }
//       if (city != null && city.isNotEmpty) {
//         updateData['city'] = city;
//       }
//       if (bio != null && bio.isNotEmpty) {
//         updateData['bio'] = bio;
//       }
//
//       if (updateData.isNotEmpty) {
//         await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(_userId.value)
//             .update(updateData);
//
//         print('Profile updated successfully');
//       }
//     } catch (e) {
//       print('Error updating profile: $e');
//       rethrow;
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> logout(BuildContext context) async {
//     try {
//       _userDataSubscription?.cancel();
//       _productsSubscription?.cancel();
//
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       await preferences.clear();
//
//       _userData.clear();
//       _userId.value = '';
//       _percentage.value = 0.0;
//       _currentEntries.value = 0;
//       _currentLimit.value = 5;
//       _typeCounts.clear();
//       profileImage.value = null;
//
//       _showSnackBar(context, 'Logged out successfully', Colors.green);
//     } catch (error) {
//       _showSnackBar(context, 'Logout failed: $error', Colors.red);
//     }
//   }
//
//   void _showSnackBar(BuildContext context, String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//       ),
//     );
//   }
//
//   Future<void> refreshUserData() async {
//     await fetchUserData();
//   }
// }




class UserController extends GetxController {
  // Reactive variables for real-time updates
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxString _userId = ''.obs;
  final RxDouble _percentage = 0.0.obs;
  final RxBool _isLoading = false.obs;
  final RxInt _currentEntries = 0.obs;
  final RxInt _currentLimit = 5.obs;

  // Type counts
  final RxMap<String, int> _typeCounts = <String, int>{}.obs;

  // Profile image
  final RxString profileImagePath = ''.obs;
  final ImagePicker _picker = ImagePicker();

  // API Service
  late ApiService _apiService;

  // Getters
  User? get currentUser => _currentUser.value;
  String? get userId => _userId.value.isEmpty ? null : _userId.value;
  double get percentage => _percentage.value;
  RxBool get isLoading => _isLoading;
  int get currentEntries => _currentEntries.value;
  int get currentLimit => _currentLimit.value;
  String get displayName => _currentUser.value?.name ?? 'User';
  String get email => _currentUser.value?.email1 ?? 'No email';
  String get entries => _currentEntries.value.toString();
  String get limit => _currentLimit.value.toString();

  // Type count getters
  int getTypeCount(String type) => _typeCounts[type.toUpperCase()] ?? 0;
  String getCarsCount() => getTypeCount('CARS').toString();
  String getBikesCount() => getTypeCount('BIKES').toString();
  String getTrucksCount() => getTypeCount('TRUCKS').toString();
  String getPlanesCount() => getTypeCount('PLANES').toString();

  @override
  void onInit() {
    super.onInit();
    _apiService = ApiService();
    _initializeUser();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> _initializeUser() async {
    try {
      _isLoading.value = true;
      await _getCurrentUserId();
      if (_userId.value.isNotEmpty) {
        await fetchUserProfile();
      }
    } catch (e) {
      print('[v0] Error initializing user: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _getCurrentUserId() async {
    try {
      final userId = await _apiService.getUserId();
      print('user ID: $userId');
      if (userId != null) {
        _userId.value = userId;
      }
    } catch (e) {
      print('Error getting user ID: $e');
    }
  }

  Future<void> fetchUserProfile() async {
    if (_userId.value.isEmpty) {
      await _getCurrentUserId();
    }

    if (_userId.value.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      _isLoading.value = true;

      // Fetch from API
      final response = await _apiService.get('/Users/findById?id=$_userId');

      if (response != null && response.isNotEmpty) {
        updateUserDataFromResponse(response);
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      print('[v0] Error fetching user profile: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  void updateUserDataFromResponse(Map<String, dynamic> data) {
    try {
      // Create UserModel from API response
      _currentUser.value = User.fromJson(data);

      // Parse entries and limit safely
      _currentEntries.value = _parseIntValue(data['entries'] ?? data['Entries'], 0);
      _currentLimit.value = _parseIntValue(data['limit'] ?? data['Limit'], 5);

      // Update type counts if available
      if (data['typeCounts'] != null) {
        Map<String, dynamic> typeCountsData = data['typeCounts'];
        _typeCounts.clear();
        typeCountsData.forEach((key, value) {
          _typeCounts[key] = _parseIntValue(value, 0);
        });
      } else {
        // Initialize default counts if not present
        _typeCounts.value = {
          'CARS': 0,
          'BIKES': 0,
          'TRUCKS': 0,
          'PLANES': 0,
        };
      }

      // Update profile image path if available
      if (data['profilePicture'] != null && data['profilePicture'].toString().isNotEmpty) {
        profileImagePath.value = data['profilePicture'].toString();
      }

      // Calculate percentage
      if (_currentLimit.value > 0) {
        _percentage.value = _currentEntries.value / _currentLimit.value;
      } else {
        _percentage.value = 0.0;
      }

      print('[v0] User data updated - Entries: ${_currentEntries.value}, Limit: ${_currentLimit.value}, Percentage: ${_percentage.value}');
      print('[v0] Type counts: $_typeCounts');
    } catch (e) {
      print('[v0] Error updating user data: $e');
    }
  }

  int _parseIntValue(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Future<void> showImagePickerOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'UPLOAD PHOTO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  context,
                  'Camera',
                  Icons.camera_alt,
                  Colors.blue,
                      () => _pickImage(ImageSource.camera, context),
                ),
                _buildImageOption(
                  context,
                  'Gallery',
                  Icons.photo_library,
                  Colors.green,
                      () => _pickImage(ImageSource.gallery, context),
                ),
              ],
            ),
            if (profileImagePath.value.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildImageOption(
                context,
                'Remove',
                Icons.delete,
                Colors.red,
                    () => _removeImage(context),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      bool hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        _showSnackBar(context, 'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission to continue', Colors.orange);
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        await uploadProfileImage(context, image);
      }
    } catch (e) {
      print('[v0] Error picking image: $e');
      _showSnackBar(context, 'Failed to pick image: $e', Colors.red);
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    // Gallery picker does not require storage/photo permissions on modern iOS/Android versions when using image_picker.
    return true;
  }

  Future<void> _removeImage(BuildContext context) async {
    try {
      _isLoading.value = true;

      if (_userId.value.isEmpty) return;

      // Call API to remove profile picture
      await _apiService.post('/Users/update',body:  {
        'id': userId,
        'profile_picture': '',
      });

      profileImagePath.value = '';
      _showSnackBar(context, 'Profile picture removed successfully!', Colors.green);
    } catch (e) {
      print('[v0] Error removing profile image: $e');
      _showSnackBar(context, 'Failed to remove profile picture: $e', Colors.red);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> pickProfileImage(BuildContext context) async {
    await showImagePickerOptions(context);
  }

  Future<void> uploadProfileImage(BuildContext context, XFile image) async {
    if (_userId.value.isEmpty) return;

    try {
      _isLoading.value = true;

      // Upload image to server
      final response = await _apiService.uploadImage('/Upload/image', image);

      if (response != null && response['url'] != null) {
        String uploadedUrl = response['url'].toString();

        // Call API to update the profilePicture field in backend
        await _apiService.post('/Users/update', body: {
          'id': userId,
          'profile_picture': uploadedUrl,
        });

        // Update local state
        profileImagePath.value = uploadedUrl;
        if (_currentUser.value != null) {
          _currentUser.refresh();
        }

        _showSnackBar(context, 'Profile picture updated successfully!', Colors.green);
      } else {
        throw Exception('Server failed to return image URL');
      }
    } catch (e) {
      _showSnackBar(context, 'Failed to upload profile picture: $e', Colors.red);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserEntries(int change) async {
    try {
      if (_userId.value.isEmpty) {
        print('[v0] Cannot update entries: User not logged in');
        return;
      }

      int newEntries = _currentEntries.value + change;

      if (newEntries < 0) {
        newEntries = 0;
      }

      if (change > 0 && newEntries > _currentLimit.value) {
        print('[v0] Cannot exceed entry limit. Current: ${_currentEntries.value}, Limit: ${_currentLimit.value}');
        return;
      }

      print('[v0] Updating entries from $userId ${_currentEntries.value} to $newEntries');

      // Update via API
      await _apiService.post('/Users/update',body:  {
        'entries': newEntries,
        'id': userId
      });

      _currentEntries.value = newEntries;
      if (_currentLimit.value > 0) {
        _percentage.value = _currentEntries.value / _currentLimit.value;
      } else {
        _percentage.value = 0.0;
      }
      print('[v0] Successfully updated entries to: $newEntries, percentage: ${_percentage.value}');
    } catch (e) {
      print('[v0] Failed to update user entries: $e');
      rethrow;
    }
  }

  bool canAddEntry() {
    if (_currentUser.value == null) {
      print('[v0] Cannot check entry limit: userData is null');
      return false;
    }

    bool canAdd = _currentEntries.value < _currentLimit.value;
    print('[v0] Entry check - Current: ${_currentEntries.value}, Limit: ${_currentLimit.value}, Can add: $canAdd');
    return canAdd;
  }

  int getRemainingEntries() {
    int remaining = _currentLimit.value - _currentEntries.value;
    return remaining > 0 ? remaining : 0;
  }

  String getEntryStatusMessage() {
    if (_currentUser.value == null) return 'Unable to load entry information';

    int remaining = getRemainingEntries();

    if (remaining == 0) {
      return 'You\'ve reached your plan limit of ${_currentLimit.value} entries. Upgrade to add more!';
    } else if (remaining <= 2) {
      return 'Only $remaining entries remaining in your current plan';
    } else {
      return '$remaining of ${_currentLimit.value} entries available';
    }
  }

  Future<void> updatePlan(String planName, int newLimit) async {
    try {
      if (_userId.value.isEmpty) return;

      await _apiService.post('/Users/update', body: {
        'id': userId,
        'plan': planName,
        'limit': newLimit,
      });

      _currentLimit.value = newLimit;
      if (_currentUser.value != null) {
        _currentUser.value!.plan = planName;
      }

      print('[v0] Plan updated successfully: $planName with limit: $newLimit');
    } catch (e) {
      print('[v0] Error updating plan: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phone,
    required String city,
    String? plan,
  }) async {
    if (_userId.value.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      _isLoading.value = true;

      Map<String, dynamic> updateData = {
        'id': userId,
        'name': name,
        'email': email,
        'email1': email,
        'phone': phone,
        'city': city,
      };

      if (plan != null && plan.isNotEmpty) {
        updateData['plan'] = plan;
      }

      // Call API to update profile
      await _apiService.post('/Users/update',body:  updateData);

      // Update local state
      if (_currentUser.value != null) {
        _currentUser.value = _currentUser.value!.copyWith(
          name: name,
          email1: email,
          phone: phone,
          city: city,
          plan: plan ?? _currentUser.value!.plan,
        );
      }

      print('[v0] Profile updated successfully');
    } catch (e) {
      print('[v0] Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      _currentUser.value = null;
      _userId.value = '';
      _percentage.value = 0.0;
      _currentEntries.value = 0;
      _currentLimit.value = 5;
      _typeCounts.clear();
      profileImagePath.value = '';

      _showSnackBar(context, 'Logged out successfully', Colors.green);
    } catch (error) {
      _showSnackBar(context, 'Logout failed: $error', Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    showCustomToast(message, isSuccess: color != Colors.red);
  }

  Future<void> refreshUserData() async {
    await fetchUserProfile();
  }
}




// class UserProfileController extends GetxController {
//   // Reactive variables for real-time updates
//   final RxMap<String, dynamic> _userData = <String, dynamic>{}.obs;
//   final RxString _userId = ''.obs;
//   final RxDouble _percentage = 0.0.obs;
//   final RxBool _isLoading = false.obs;
//   final RxInt _currentEntries = 0.obs;
//   final RxInt _currentLimit = 5.obs;
//
//   // Type counts
//   final RxInt _carsCount = 0.obs;
//   final RxInt _bikesCount = 0.obs;
//   final RxInt _trucksCount = 0.obs;
//   final RxInt _planesCount = 0.obs;
//
//   // Profile image
//   Rx<XFile?> profileImage = Rx<XFile?>(null);
//   final ImagePicker _picker = ImagePicker();
//
//   // Stream subscriptions for real-time data
//   StreamSubscription<DocumentSnapshot>? _userDataSubscription;
//   StreamSubscription<QuerySnapshot>? _productsSubscription;
//
//   // Getters
//   Map<String, dynamic>? get userData => _userData.value.isEmpty ? null : _userData.value;
//   String? get userId => _userId.value.isEmpty ? null : _userId.value;
//   double get percentage => _percentage.value;
//   bool get isLoading => _isLoading.value;
//   int get currentEntries => _currentEntries.value;
//   int get currentLimit => _currentLimit.value;
//   String get displayName => _userData['name'] ?? 'User';
//   String get email => _userData['email'] ?? 'No email';
//   String get profilePictureUrl => _userData['profilePicture'] ?? '';
//   String get entries => _currentEntries.value.toString();
//   String get limit => _currentLimit.value.toString();
//
//   // Type count getters
//   int get carsCount => _carsCount.value;
//   int get bikesCount => _bikesCount.value;
//   int get trucksCount => _trucksCount.value;
//   int get planesCount => _planesCount.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeUser();
//   }
//
//   @override
//   void onClose() {
//     _userDataSubscription?.cancel();
//     _productsSubscription?.cancel();
//     super.onClose();
//   }
//
//   Future<void> _initializeUser() async {
//     try {
//       _isLoading.value = true;
//       await _getCurrentUserId();
//       if (_userId.value.isNotEmpty) {
//         await _setupRealTimeListeners();
//       }
//     } catch (e) {
//       print('Error initializing user: $e');
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> _getCurrentUserId() async {
//     try {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       String? id = preferences.getString('userId');
//       if (id != null) {
//         _userId.value = id;
//       }
//     } catch (e) {
//       print('Error getting user ID: $e');
//     }
//   }
//
//   Future<void> _setupRealTimeListeners() async {
//     if (_userId.value.isEmpty) return;
//
//     try {
//       // Listen to user document changes
//       _userDataSubscription = FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .snapshots()
//           .listen((DocumentSnapshot snapshot) {
//         if (snapshot.exists) {
//           updateUserDataFromSnapshot(snapshot.data() as Map<String, dynamic>);
//         }
//       }, onError: (error) {
//         print('Error listening to user data: $error');
//       });
//
//       // Listen to user's products for real-time entry counting and type counts
//       _productsSubscription = FirebaseFirestore.instance
//           .collection('Products')
//           .where('createdBy', isEqualTo: _userId.value)
//           .snapshots()
//           .listen((QuerySnapshot snapshot) {
//         _syncEntriesWithProducts(snapshot.docs.length);
//         _updateTypeCounts(snapshot.docs);
//       }, onError: (error) {
//         print('Error listening to products: $error');
//       });
//
//     } catch (e) {
//       print('Error setting up listeners: $e');
//     }
//   }
//
//   void _updateTypeCounts(List<QueryDocumentSnapshot> products) {
//     try {
//       int cars = 0;
//       int bikes = 0;
//       int trucks = 0;
//       int planes = 0;
//
//       for (var doc in products) {
//         final data = doc.data() as Map<String, dynamic>;
//         final type = (data['type'] ?? '').toString().toLowerCase().trim();
//
//         switch (type) {
//           case 'cars':
//           case 'car':
//             cars++;
//             break;
//           case 'bikes':
//           case 'bike':
//             bikes++;
//             break;
//           case 'trucks':
//           case 'truck':
//             trucks++;
//             break;
//           case 'planes':
//           case 'plane':
//             planes++;
//             break;
//         }
//       }
//
//       _carsCount.value = cars;
//       _bikesCount.value = bikes;
//       _trucksCount.value = trucks;
//       _planesCount.value = planes;
//
//       print('Type counts updated - Cars: $cars, Bikes: $bikes, Trucks: $trucks, Planes: $planes');
//
//       // Optionally sync with Firestore
//       _syncTypeCountsToFirestore(cars, bikes, trucks, planes);
//     } catch (e) {
//       print('Error updating type counts: $e');
//     }
//   }
//
//   Future<void> _syncTypeCountsToFirestore(int cars, int bikes, int trucks, int planes) async {
//     try {
//       if (_userId.value.isEmpty) return;
//
//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .update({
//         'carsCount': cars,
//         'bikesCount': bikes,
//         'trucksCount': trucks,
//         'planesCount': planes,
//       });
//     } catch (e) {
//       print('Error syncing type counts to Firestore: $e');
//     }
//   }
//
//   void updateUserDataFromSnapshot(Map<String, dynamic> data) {
//     try {
//       _userData.value = data;
//
//       // Parse entries and limit safely
//       _currentEntries.value = _parseIntValue(data['entries'], 0);
//       _currentLimit.value = _parseIntValue(data['limit'], 5);
//
//       // Parse type counts from user data
//       _carsCount.value = _parseIntValue(data['carsCount'], 0);
//       _bikesCount.value = _parseIntValue(data['bikesCount'], 0);
//       _trucksCount.value = _parseIntValue(data['trucksCount'], 0);
//       _planesCount.value = _parseIntValue(data['planesCount'], 0);
//
//       // Calculate percentage
//       if (_currentLimit.value > 0) {
//         _percentage.value = _currentEntries.value / _currentLimit.value;
//       } else {
//         _percentage.value = 0.0;
//       }
//
//       print('User data updated - Entries: ${_currentEntries.value}, Limit: ${_currentLimit.value}, Percentage: ${_percentage.value}');
//     } catch (e) {
//       print('Error updating user data: $e');
//     }
//   }
//
//   int _parseIntValue(dynamic value, int defaultValue) {
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? defaultValue;
//     return defaultValue;
//   }
//
//   Future<void> _syncEntriesWithProducts(int actualProductCount) async {
//     try {
//       if (_currentEntries.value != actualProductCount) {
//         print('Syncing entries: Current=${_currentEntries.value}, Actual=$actualProductCount');
//
//         await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(_userId.value)
//             .update({'entries': actualProductCount});
//       }
//     } catch (e) {
//       print('Error syncing entries: $e');
//     }
//   }
//
//   Future<void> fetchUserData() async {
//     if (_userId.value.isEmpty) {
//       await _getCurrentUserId();
//     }
//
//     if (_userId.value.isEmpty) {
//       throw Exception('User not logged in');
//     }
//
//     try {
//       _isLoading.value = true;
//
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .get();
//
//       if (userDoc.exists) {
//         updateUserDataFromSnapshot(userDoc.data() as Map<String, dynamic>);
//       } else {
//         throw Exception('User document not found');
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//       rethrow;
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> showImagePickerOptions(BuildContext context) async {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Select Profile Picture',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildImageOption(
//                   context,
//                   'Camera',
//                   Icons.camera_alt,
//                   Colors.blue,
//                       () => _pickImage(ImageSource.camera, context),
//                 ),
//                 _buildImageOption(
//                   context,
//                   'Gallery',
//                   Icons.photo_library,
//                   Colors.green,
//                       () => _pickImage(ImageSource.gallery, context),
//                 ),
//               ],
//             ),
//             if (profileImage.value != null || profilePictureUrl.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               _buildImageOption(
//                 context,
//                 'Remove',
//                 Icons.delete,
//                 Colors.red,
//                     () => _removeImage(context),
//               ),
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageOption(
//       BuildContext context,
//       String title,
//       IconData icon,
//       Color color,
//       VoidCallback onTap,
//       ) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pop(context);
//         onTap();
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 32, color: color),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickImage(ImageSource source, BuildContext context) async {
//     try {
//       bool hasPermission = await _requestPermission(source);
//       if (!hasPermission) {
//         _showSnackBar(context, 'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission to continue', Colors.orange);
//         return;
//       }
//
//       final XFile? image = await _picker.pickImage(
//         source: source,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 80,
//       );
//
//       if (image != null) {
//         profileImage.value = image;
//         await uploadProfileImage(context);
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//       _showSnackBar(context, 'Failed to pick image: $e', Colors.red);
//     }
//   }
//
//   Future<bool> _requestPermission(ImageSource source) async {
//     if (source == ImageSource.camera) {
//       final status = await Permission.camera.request();
//       return status.isGranted;
//     } else {
//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         return status.isGranted;
//       } else {
//         final status = await Permission.photos.request();
//         return status.isGranted;
//       }
//     }
//   }
//
//   Future<void> _removeImage(BuildContext context) async {
//     try {
//       _isLoading.value = true;
//
//       if (_userId.value.isEmpty) return;
//
//       if (profilePictureUrl.isNotEmpty) {
//         try {
//           final ref = FirebaseStorage.instance.refFromURL(profilePictureUrl);
//           await ref.delete();
//         } catch (e) {
//           print('Error deleting old image: $e');
//         }
//       }
//
//       await FirebaseFirestore.instance.collection('Users').doc(_userId.value).update({
//         'profilePicture': '',
//       });
//
//       profileImage.value = null;
//       _showSnackBar(context, 'Profile picture removed successfully!', Colors.green);
//     } catch (e) {
//       print('Error removing profile image: $e');
//       _showSnackBar(context, 'Failed to remove profile picture: $e', Colors.red);
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> pickProfileImage(BuildContext context) async {
//     await showImagePickerOptions(context);
//   }
//
//   Future<void> uploadProfileImage(BuildContext context) async {
//     if (profileImage.value == null || _userId.value.isEmpty) return;
//
//     try {
//       _isLoading.value = true;
//
//       final String fileName = 'profile_pictures/${_userId.value}/${DateTime.now().millisecondsSinceEpoch}_${profileImage.value!.name}';
//       final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
//
//       final UploadTask uploadTask = storageRef.putFile(File(profileImage.value!.path));
//       final TaskSnapshot snapshot = await uploadTask;
//       final String downloadUrl = await snapshot.ref.getDownloadURL();
//
//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .update({'profilePicture': downloadUrl});
//
//       _showSnackBar(context, 'Profile picture updated successfully!', Colors.green);
//     } catch (e) {
//       _showSnackBar(context, 'Failed to upload profile picture: $e', Colors.red);
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> updateUserEntries(int change) async {
//     try {
//       if (_userId.value.isEmpty) {
//         print('Cannot update entries: User not logged in');
//         return;
//       }
//
//       int newEntries = _currentEntries.value + change;
//
//       if (newEntries < 0) {
//         newEntries = 0;
//       }
//
//       if (change > 0 && newEntries > _currentLimit.value) {
//         print('Cannot exceed entry limit. Current: ${_currentEntries.value}, Limit: ${_currentLimit.value}');
//         return;
//       }
//
//       print('Updating entries from ${_currentEntries.value} to $newEntries for user: ${_userId.value}');
//
//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .update({'entries': newEntries});
//
//       print('Successfully updated entries to: $newEntries');
//     } catch (e) {
//       print('Failed to update user entries: $e');
//       rethrow;
//     }
//   }
//
//   bool canAddEntry() {
//     if (_userData.value.isEmpty) {
//       print('Cannot check entry limit: userData is null');
//       return false;
//     }
//
//     bool canAdd = _currentEntries.value < _currentLimit.value;
//     print('Entry check - Current: ${_currentEntries.value}, Limit: ${_currentLimit.value}, Can add: $canAdd');
//     return canAdd;
//   }
//
//   int getRemainingEntries() {
//     int remaining = _currentLimit.value - _currentEntries.value;
//     return remaining > 0 ? remaining : 0;
//   }
//
//   String getEntryStatusMessage() {
//     if (_userData.value.isEmpty) return 'Unable to load entry information';
//
//     int remaining = getRemainingEntries();
//
//     if (remaining == 0) {
//       return 'You\'ve reached your plan limit of ${_currentLimit.value} entries. Upgrade to add more!';
//     } else if (remaining <= 2) {
//       return 'Only $remaining entries remaining in your current plan';
//     } else {
//       return '$remaining of ${_currentLimit.value} entries available';
//     }
//   }
//
//   Future<void> updatePlan(String planName, int newLimit) async {
//     try {
//       if (_userId.value.isEmpty) return;
//
//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_userId.value)
//           .update({
//         'plan': planName,
//         'limit': newLimit,
//       });
//
//       print('Plan updated successfully: $planName with limit: $newLimit');
//     } catch (e) {
//       print('Error updating plan: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> logout(BuildContext context) async {
//     try {
//       _userDataSubscription?.cancel();
//       _productsSubscription?.cancel();
//
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       await preferences.clear();
//
//       _userData.clear();
//       _userId.value = '';
//       _percentage.value = 0.0;
//       _currentEntries.value = 0;
//       _currentLimit.value = 5;
//       _carsCount.value = 0;
//       _bikesCount.value = 0;
//       _trucksCount.value = 0;
//       _planesCount.value = 0;
//       profileImage.value = null;
//
//       _showSnackBar(context, 'Logged out successfully', Colors.green);
//     } catch (error) {
//       _showSnackBar(context, 'Logout failed: $error', Colors.red);
//     }
//   }
//
//   void _showSnackBar(BuildContext context, String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//       ),
//     );
//   }
//
//   Future<void> refreshUserData() async {
//     await fetchUserData();
//   }
// }


/*class UserProfileController extends GetxController {
  // User data
  Map<String, dynamic>? userData;
  String? userId;
  double percentage = 0.0;
  bool isLoading = false;

  // Profile image
  XFile? profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  // Fetch current user ID from SharedPreferences
  Future<void> _getCurrentUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('userId');
    update();
  }

  void updateUserDataFromSnapshot(Map<String, dynamic> data) {
    print('this is user data $data');
    userData = data;
    entries = data['entries'].toString() ?? '0';
    limit = data['limit'].toString() ?? '0';
    displayName = data['name'] ?? 'User';
    email = data['email'] ?? '';
    profilePictureUrl = data['profilePicture'] ?? '';

    final entriesInt = (data['entries'] is int)
        ? data['entries'] as int
        : int.tryParse(data['entries']?.toString() ?? '0') ?? 0;

    final limitInt = (data['limit'] is int)
        ? data['limit'] as int
        : int.tryParse(data['limit']?.toString() ?? '1') ?? 1;

    percentage = entriesInt / limitInt;

    update(); // Notify listeners
  }

  void updateUserData(Map<String, dynamic> data) {
    updateUserDataFromSnapshot(data);
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      isLoading = true;
      update();

      await _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final snapshot = await FirebaseFirestore.instance.collection('Users').get();

      for (var document in snapshot.docs) {
        if (document['uid'] == userId) {
          userData = document.data();
          percentage = (double.parse(userData!['entries'].toString()) /
              double.parse(userData!['limit'].toString()));
          break;
        }
      }

      isLoading = false;
      update();

      print('User Data: $userData, Percentage: $percentage');
    } catch (error) {
      isLoading = false;
      update();
      throw Exception('Failed to fetch user data: $error');
    }
  }

  // Request permission and pick profile image
  Future<void> pickProfileImage(BuildContext context) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        // Check file size (2MB limit for profile pictures)
        final file = File(pickedImage.path);
        final fileSize = await file.length();

        if (fileSize > 2 * 1024 * 1024) { // 2MB in bytes
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image size should be less than 2MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        profileImage = pickedImage;
        update();

        // Auto-upload the image
        await uploadProfileImage(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Upload profile image to Firebase Storage
  Future<void> uploadProfileImage(BuildContext context) async {
    if (profileImage == null || userId == null) return;

    try {
      isLoading = true;
      update();

      // Upload to different path for profile pictures
      final String fileName = 'profile_pictures/$userId/${DateTime.now().millisecondsSinceEpoch}_${profileImage!.name}';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      final UploadTask uploadTask = storageRef.putFile(File(profileImage!.path));
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user document with new profile picture URL
      await FirebaseFirestore.instance
          .collection('Users')
          .where('uid', isEqualTo: userId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'profilePicture': downloadUrl});
        }
      });

      // Update local userData
      if (userData != null) {
        userData!['profilePicture'] = downloadUrl;
      }

      isLoading = false;
      update();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      isLoading = false;
      update();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Logout function
  Future<void> logout(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route)=> false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateUserEntries(int change) async {
    try {
      if (userId == null || userData == null) {
        print('Cannot update entries: User not logged in or userData is null');
        return;
      }

      int currentEntries;
      if (userData!['entries'] is int) {
        currentEntries = userData!['entries'] as int;
      } else {
        currentEntries = int.tryParse(userData!['entries']?.toString() ?? '0') ?? 0;
      }

      int limit;
      if (userData!['limit'] is int) {
        limit = userData!['limit'] as int;
      } else {
        limit = int.tryParse(userData!['limit']?.toString() ?? '0') ?? 0;
      }

      int newEntries = currentEntries + change;

      // Ensure entries don't go below 0
      if (newEntries < 0) {
        print('Cannot decrease entries below 0. Current: $currentEntries');
        newEntries = 0;
      }

      // Ensure entries don't exceed limit when adding
      if (change > 0 && newEntries > limit) {
        print('Cannot exceed entry limit. Current: $currentEntries, Limit: $limit');
        return;
      }

      print('Updating entries from $currentEntries to $newEntries for user: $userId');

      WriteBatch batch = FirebaseFirestore.instance.batch();

      final userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('uid', isEqualTo: userId)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        batch.update(userDoc.reference, {
          'entries': newEntries, // Store as integer, not string
        });

        await batch.commit();
        print('Firestore update committed successfully');
      } else {
        throw Exception('User document not found');
      }

      // Update local userData
      userData!['entries'] = newEntries;
      percentage = newEntries / limit;

      update();
      print('Successfully updated entries to: $newEntries');
    } catch (e) {
      print('Failed to update user entries: $e');
      rethrow; // Re-throw to handle in calling method
    }
  }

  bool canAddEntry() {
    if (userData == null) {
      print('Cannot check entry limit: userData is null');
      return false;
    }

    try {
      int currentEntries = int.parse(userData!['entries'].toString());
      int limit = int.parse(userData!['limit'].toString());

      bool canAdd = currentEntries < limit;
      print('Entry check - Current: $currentEntries, Limit: $limit, Can add: $canAdd');
      return canAdd;
    } catch (e) {
      print('Error checking entry limit: $e');
      return false;
    }
  }

  int getRemainingEntries() {
    if (userData == null) return 0;

    try {
      int currentEntries = int.parse(userData!['entries'].toString());
      int limit = int.parse(userData!['limit'].toString());

      int remaining = limit - currentEntries;
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      print('Error calculating remaining entries: $e');
      return 0;
    }
  }

  String getEntryStatusMessage() {
    if (userData == null) return 'Unable to load entry information';

    try {
      int currentEntries = int.parse(userData!['entries'].toString());
      int limit = int.parse(userData!['limit'].toString());
      int remaining = getRemainingEntries();

      if (remaining == 0) {
        return 'You\'ve reached your plan limit of $limit entries. Upgrade to add more!';
      } else if (remaining <= 2) {
        return 'Only $remaining entries remaining in your current plan';
      } else {
        return '$remaining of $limit entries available';
      }
    } catch (e) {
      return 'Error loading entry information';
    }
  }

  // Get user display name
  String get displayName => userData?['name'] ?? 'User';

  // Get user email
  String get email => userData?['email'] ?? 'No email';

  // Get profile picture URL
  String get profilePictureUrl => userData?['profilePicture'] ?? '';

  // Get user entries
  String get entries => userData?['entries'] ?? '0';

  // Get user limit
  String get limit => userData?['limit']?.toString() ?? '0';

  // Set user entries
  set entries(String value) {
    if (userData == null) userData = {};
    userData!['entries'] = value;
    update();
  }

  // Set user limit
  set limit(String value) {
    if (userData == null) userData = {};
    userData!['limit'] = value;
    update();
  }

  // Set display name
  set displayName(String value) {
    if (userData == null) userData = {};
    userData!['name'] = value;
    update();
  }

  // Set email
  set email(String value) {
    if (userData == null) userData = {};
    userData!['email'] = value;
    update();
  }

  // Set profile picture URL
  set profilePictureUrl(String value) {
    if (userData == null) userData = {};
    userData!['profilePicture'] = value;
    update();
  }
}*/


