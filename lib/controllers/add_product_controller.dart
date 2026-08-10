
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';
import 'package:thinkdiecast/controllers/refresh_controller.dart';
import 'package:thinkdiecast/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Product body (matches your swagger exactly):
/// {
///   "id": "string",            // only sent on update
///   "name": "string",
///   "description": "string",
///   "brandId": 0,
///   "categoryId": 0,
///   "type": "string",
///   "scale": "string",
///   "year": 0,
///   "color": "string",
///   "price": 0,
///   "image": "string",
///   "createdBy": "string",
///   "userId": "string"
/// }
///
/// NOTE: Category/Brand/Scale list endpoints weren't visible in the swagger
/// screenshot you sent (it only showed /Users/register + /Users/login), so
/// this assumes the same convention as /Products/*:
///   GET /Brand/getAll, GET /Category/getAll, GET /Scale/getAll
/// Update these three paths if your real routes differ — that's the only
/// place they're referenced (fetchDropdownData below).


class AddProductController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late ApiService _apiService;
  late UserController _userController;

  // Text controllers
  final titleNameController = TextEditingController(); // name
  final descriptionController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();
  final priceController = TextEditingController();

  // Static TYPE options — fixed by design, not API driven.
  static const List<String> typeOptions = ['Bikes', 'Cars', 'Trucks', 'Planes'];

  // Dynamic dropdown source lists: each item is {"id": ..., "name": ...}
  final RxList<Map<String, dynamic>> brands = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> scales = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingDropdowns = false.obs;

  // Selected values
  // Brand & category dropdowns display and select by NAME, but the backend
  // still requires the ID field on create/update, so we track the id too.
  final RxString selectedBrandId = ''.obs;
  final RxString selectedBrand = ''.obs; // name, for display + sending
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedCategory = ''.obs; // name, for display + sending
  final RxString selectedType = ''.obs;
  final RxString selectedScale = ''.obs; // scale is stored as a name/string on the product

  final RxBool isLoading = false.obs;

  // Image handling
  Rx<XFile?> image = Rx<XFile?>(null);
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final RxString existingImageUrl = ''.obs;
  // Set as soon as a picked image finishes uploading to /Upload/image.
  // addProduct/updateProduct send this directly instead of uploading at
  // submit time.
  final RxString uploadedImageUrl = ''.obs;
  final RxBool isUploadingImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = ApiService();
    try {
      _userController = Get.find<UserController>();
    } catch (e) {
      _userController = Get.put(UserController());
    }
    fetchDropdownData();
  }

  @override
  void onClose() {
    titleNameController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    colorController.dispose();
    priceController.dispose();
    super.onClose();
  }

  String _idOf(Map<String, dynamic> item) => (item['_id'] ?? item['id'] ?? '').toString();

  /// Call these from the dropdown's onChanged with the selected id.
  /// They set both the id (sent as brandId/categoryId, required by the API)
  /// and the name (sent as brand/category, for display) in one go.
  Map<String, dynamic>? _findById(List<Map<String, dynamic>> list, String? id) {
    for (final item in list) {
      if (_idOf(item) == id) return item;
    }
    return null;
  }

  void selectBrandById(String? id) {

    selectedBrandId.value = id ?? '';
    final match = _findById(brands, id);
    selectedBrand.value = (match?['name'] ?? '').toString();
    print('this is my selected brand ${selectedBrand.value}');
    update();
  }

  void selectCategoryById(String? id) {
    selectedCategoryId.value = id ?? '';
    final match = _findById(categories, id);
    selectedCategory.value = (match?['name'] ?? '').toString();
    update();
  }

  Future<void> fetchDropdownData() async {
    try {
      print('calling APIs');
      isLoadingDropdowns.value = true;
      final results = await Future.wait([
        _apiService.get('/Brands/findAll'),
        _apiService.get('/Categories/findAll'),
        _apiService.get('/Scales/findAll'),
      ]);

      List<Map<String, dynamic>> _asList(dynamic res) {
        final list = (res is List) ? res : (res?['data'] as List? ?? []);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      print('this is my categories result ${results[1]}');
      brands.value = _asList(results[0]);
      categories.value = _asList(results[1]);
      scales.value = _asList(results[2]);
    } catch (e) {
      debugPrint('[v0] Error fetching dropdown data: $e');
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  // ---------------- Image picking (unchanged behaviour) ----------------

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
            const Text('UPLOAD PHOTO',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(context, 'Camera', Icons.camera_alt, Colors.blue,
                        () => _pickImage(ImageSource.camera, context)),
                _buildImageOption(context, 'Gallery', Icons.photo_library, Colors.green,
                        () => _pickImage(ImageSource.gallery, context)),
              ],
            ),
            if (selectedImage.value != null || image.value != null) ...[
              const SizedBox(height: 20),
              _buildImageOption(context, 'Remove', Icons.delete, Colors.red,
                      () => _removeImage(context)),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(
      BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      bool hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        _showSnackBar(context,
            'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission',
            Colors.orange);
        return;
      }
      final XFile? pickedImage =
      await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          _showSnackBar(context, 'Image size should be less than 5MB', Colors.red);
          return;
        }
        image.value = pickedImage;
        selectedImage.value = pickedImage;
        await _uploadPickedImage(pickedImage, context);

      }
      update();
    } catch (e) {
      _showSnackBar(context, 'Failed to pick image: $e', Colors.red);
    }
  }

  /// Uploads the picked image to /Upload/image right away and stores the
  /// returned url in [uploadedImageUrl]. addProduct/updateProduct then send
  /// this url directly, with no upload happening at submit time.
  Future<void> _uploadPickedImage(XFile file, BuildContext context) async {
    try {
      isUploadingImage.value = true;
      uploadedImageUrl.value = '';
      final response = await _apiService.uploadImage('/Upload/image', file);
      final url = response?['url']?.toString();
      if (url == null || url.isEmpty) {
        throw Exception('Upload response did not contain a url');
      }
      uploadedImageUrl.value = url;
      _showSnackBar(context, 'Image uploaded successfully!', Colors.green);
    } catch (e) {
      // Uploading failed — clear the picked image so the UI doesn't show a
      // photo that was never actually saved to the server.
      image.value = null;
      selectedImage.value = null;
      print('Failed to upload image: ${e.toString()}');
      _showSnackBar(context, 'Failed to upload image: ${e.toString()}', Colors.red);
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      return (await Permission.camera.request()).isGranted;
    }
    // Gallery picker does not require storage/photo permissions on modern iOS/Android versions when using image_picker.
    return true;
  }

  void _removeImage(BuildContext context) {
    image.value = null;
    selectedImage.value = null;
    existingImageUrl.value = '';
    uploadedImageUrl.value = '';
    _showSnackBar(context, 'Image removed successfully!', Colors.green);
  }

  Future<void> requestPermission(BuildContext context) async => showImagePickerOptions(context);

  // ---------------- Create / Update ----------------

  /// brand & category are now sent as plain NAME strings (like scale),
  /// brandName/categoryName carry the display name; brandId/categoryId
  /// carry the id — both are sent together.
  Map<String, dynamic> _buildBody({required String imageUrl}) {
    return {
      'name': titleNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'brandId': selectedBrandId.value,
      'brandName': selectedBrand.value,
      'categoryId': selectedCategoryId.value,
      'categoryName': selectedCategory.value,
      'type': selectedType.value,
      'scale': selectedScale.value,
      'year': int.tryParse(yearController.text.trim()) ?? 0,
      'color': colorController.text.trim(),
      'price': num.tryParse(priceController.text.trim()) ?? 0,
      'image': imageUrl,
      'createdBy': _userController.currentUser?.name ?? '',
      'userId': _userController.currentUser?.id ?? '',
    };
  }

  Future<void> addProduct(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
      return;
    }
    if (selectedBrandId.value.isEmpty) {
      _showSnackBar(context, 'Please select a brand!', Colors.orange);
      return;
    }
    if (selectedCategoryId.value.isEmpty) {
      _showSnackBar(context, 'Please select a category!', Colors.orange);
      return;
    }
    if (selectedType.value.isEmpty) {
      _showSnackBar(context, 'Please select a type!', Colors.orange);
      return;
    }
    if (isUploadingImage.value) {
      _showSnackBar(context, 'Please wait, image is still uploading...', Colors.orange);
      return;
    }
    // if (uploadedImageUrl.value.isEmpty) {
    //   _showSnackBar(context, 'Please select a product image!', Colors.orange);
    //   return;
    // }

    try {
      isLoading.value = true;

      if (_userController.currentUser == null) {
        await _userController.fetchUserProfile();
      }
      if (!_userController.canAddEntry()) {
        _showLimitReachedDialog(context, _userController.getEntryStatusMessage());
        return;
      }

      final body = _buildBody(imageUrl: uploadedImageUrl.value);
      final response = await _apiService.post('/Products/create', body: body);

      if (response != null && (response['_id'] != null || response['id'] != null)) {
        await _userController.updateUserEntries(1);
        AppRefreshController.to.refreshProducts();
        AppRefreshController.to.changeTab(0);
        final remaining = _userController.getRemainingEntries();
        String successMessage = 'Product added successfully!';
        if (remaining <= 2 && remaining > 0) {
          successMessage += ' ($remaining entries remaining)';
        } else if (remaining == 0) {
          successMessage += ' (Plan limit reached)';
        }
        clearFields();
        _showSnackBar(context, successMessage, Colors.green);
        if (context.mounted && Navigator.canPop(context)) Navigator.pop(context, true);
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      print('Failed to add product: ${e.toString()}');
      _showSnackBar(context, 'Failed to add product: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
      return;
    }
    if (isUploadingImage.value) {
      _showSnackBar(context, 'Please wait, image is still uploading...', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;
      final imageUrl = uploadedImageUrl.value.isNotEmpty ? uploadedImageUrl.value : existingImageUrl.value;

      final body = _buildBody(imageUrl: imageUrl);
      body['id'] = productId;

      await _apiService.post('/Products/update', body: body);

      AppRefreshController.to.refreshProducts();

      _showSnackBar(context, 'Product updated successfully!', Colors.green);
      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar(context, 'Failed to update product: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> deleteProduct(String productId, BuildContext context) async {
    try {
      UserController userController;
      try {
        userController = Get.find<UserController>();
      } catch (e) {
        userController = Get.put(UserController());
        await userController.fetchUserProfile();
      }

      final apiService = ApiService();
      await apiService.delete('/Products/deleteById?id=$productId');

      if (userController.currentEntries > 0) {
        await userController.updateUserEntries(-1);
      }
      AppRefreshController.to.refreshProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<bool> canUserAddProduct() async {
    try {
      UserController userController;
      try {
        userController = Get.find<UserController>();
      } catch (e) {
        userController = Get.put(UserController());
        await userController.fetchUserProfile();
      }
      return userController.canAddEntry();
    } catch (e) {
      return false;
    }
  }

  // ---------------- Edit-mode population ----------------

  /// Populates the form for edit mode. Assumes the product payload returned
  /// by your API includes 'brandId'/'categoryId' (used to set the dropdown
  /// selection and satisfy backend validation) and 'brand'/'category' name
  /// strings (used for display). If your edit payload only has the ids and
  /// not the names, that's fine too — the dropdown will still show the
  /// correct selection once `brands`/`categories` finish loading, since the
  /// GradientBorderDropdown looks up the display label by matching id.
  void populateFieldsForEdit(Map<String, dynamic> data) {
    titleNameController.text = data['name'] ?? '';
    descriptionController.text = data['description'] ?? '';
    yearController.text = (data['year'] ?? '').toString();
    colorController.text = data['color'] ?? '';
    priceController.text = (data['price'] ?? '').toString();
    selectedBrandId.value = (data['brandId'] ?? '').toString();
    selectedBrand.value = data['brandName'] ?? '';
    selectedCategoryId.value = (data['categoryId'] ?? '').toString();
    selectedCategory.value = data['categoryName'] ?? '';
    selectedType.value = data['type'] ?? '';
    selectedScale.value = data['scale'] ?? '';
    existingImageUrl.value = data['image'] ?? '';
  }

  void clearFields() {
    titleNameController.clear();
    descriptionController.clear();
    yearController.clear();
    colorController.clear();
    priceController.clear();
    selectedBrandId.value = '';
    selectedBrand.value = '';
    selectedCategoryId.value = '';
    selectedCategory.value = '';
    selectedType.value = '';
    selectedScale.value = '';
    image.value = null;
    selectedImage.value = null;
    existingImageUrl.value = '';
    uploadedImageUrl.value = '';
    isUploadingImage.value = false;
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    showCustomToast(message, isSuccess: color != Colors.red);
  }

  void _showLimitReachedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Plan Limit Reached',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}





// class AddProductController extends GetxController {
//   final formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();
//   late ApiService _apiService;
//   late UserController _userController;
//
//   // Text controllers
//   final titleNameController = TextEditingController(); // name
//   final descriptionController = TextEditingController();
//   final yearController = TextEditingController();
//   final colorController = TextEditingController();
//   final priceController = TextEditingController();
//
//   // Static TYPE options — fixed by design, not API driven.
//   static const List<String> typeOptions = ['Bikes', 'Cars', 'Trucks', 'Planes'];
//
//   // Dynamic dropdown source lists: each item is {"id": ..., "name": ...}
//   final RxList<Map<String, dynamic>> brands = <Map<String, dynamic>>[].obs;
//   final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
//   final RxList<Map<String, dynamic>> scales = <Map<String, dynamic>>[].obs;
//   final RxBool isLoadingDropdowns = false.obs;
//
//   // Selected values
//   final RxString selectedBrandId = ''.obs;
//   final RxString selectedCategoryId = ''.obs;
//   final RxString selectedType = ''.obs;
//   final RxString selectedScale = ''.obs; // scale is stored as a name/string on the product
//
//   final RxBool isLoading = false.obs;
//
//   // Image handling
//   Rx<XFile?> image = Rx<XFile?>(null);
//   Rx<XFile?> selectedImage = Rx<XFile?>(null);
//   final RxString existingImageUrl = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _apiService = ApiService();
//     try {
//       _userController = Get.find<UserController>();
//     } catch (e) {
//       _userController = Get.put(UserController());
//     }
//     fetchDropdownData();
//   }
//
//   @override
//   void onClose() {
//     titleNameController.dispose();
//     descriptionController.dispose();
//     yearController.dispose();
//     colorController.dispose();
//     priceController.dispose();
//     super.onClose();
//   }
//
//   String _idOf(Map<String, dynamic> item) => (item['_id'] ?? item['id'] ?? '').toString();
//
//   Future<void> fetchDropdownData() async {
//     try {
//       print('calling APIs');
//       isLoadingDropdowns.value = true;
//       final results = await Future.wait([
//         _apiService.get('/Brands/findAll'),
//         _apiService.get('/Categories/findAll'),
//         _apiService.get('/Scales/findAll'),
//       ]);
//
//       List<Map<String, dynamic>> _asList(dynamic res) {
//         final list = (res is List) ? res : (res?['data'] as List? ?? []);
//         return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
//       }
//
//       print('this is my categories result ${results[1]}');
//       brands.value = _asList(results[0]);
//       categories.value = _asList(results[1]);
//       scales.value = _asList(results[2]);
//     } catch (e) {
//       debugPrint('[v0] Error fetching dropdown data: $e');
//     } finally {
//       isLoadingDropdowns.value = false;
//     }
//   }
//
//   // ---------------- Image picking (unchanged behaviour) ----------------
//
//   Future<void> showImagePickerOptions(BuildContext context) async {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('UPLOAD PHOTO',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildImageOption(context, 'Camera', Icons.camera_alt, Colors.blue,
//                         () => _pickImage(ImageSource.camera, context)),
//                 _buildImageOption(context, 'Gallery', Icons.photo_library, Colors.green,
//                         () => _pickImage(ImageSource.gallery, context)),
//               ],
//             ),
//             if (selectedImage.value != null || image.value != null) ...[
//               const SizedBox(height: 20),
//               _buildImageOption(context, 'Remove', Icons.delete, Colors.red,
//                       () => _removeImage(context)),
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageOption(
//       BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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
//             Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
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
//         _showSnackBar(context,
//             'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission',
//             Colors.orange);
//         return;
//       }
//       final XFile? pickedImage =
//       await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
//       if (pickedImage != null) {
//         final file = File(pickedImage.path);
//         final fileSize = await file.length();
//         if (fileSize > 5 * 1024 * 1024) {
//           _showSnackBar(context, 'Image size should be less than 5MB', Colors.red);
//           return;
//         }
//         image.value = pickedImage;
//         selectedImage.value = pickedImage;
//         _showSnackBar(context, 'Image selected successfully!', Colors.green);
//       }
//     } catch (e) {
//       _showSnackBar(context, 'Failed to pick image: $e', Colors.red);
//     }
//   }
//
//   Future<bool> _requestPermission(ImageSource source) async {
//     if (source == ImageSource.camera) {
//       return (await Permission.camera.request()).isGranted;
//     }
//     if (Platform.isAndroid) {
//       final storageStatus = await Permission.storage.request();
//       final photosStatus = await Permission.photos.request();
//       return storageStatus.isGranted || photosStatus.isGranted;
//     }
//     return (await Permission.photos.request()).isGranted;
//   }
//
//   void _removeImage(BuildContext context) {
//     image.value = null;
//     selectedImage.value = null;
//     existingImageUrl.value = '';
//     _showSnackBar(context, 'Image removed successfully!', Colors.green);
//   }
//
//   Future<void> requestPermission(BuildContext context) async => showImagePickerOptions(context);
//
//   /// NOTE: your swagger `image` field is a plain string (a URL). There's no
//   /// image-upload endpoint in what you've shared, so this still just returns
//   /// the local file path as a placeholder — same as your original code. Swap
//   /// this for a real upload call (e.g. POST /Upload) once that route exists,
//   /// and return the hosted URL instead.
//   Future<String?> _uploadImage() async {
//     XFile? imageToUpload = image.value ?? selectedImage.value;
//     if (imageToUpload == null) {
//       return existingImageUrl.value.isEmpty ? null : existingImageUrl.value;
//     }
//     return imageToUpload.path;
//   }
//
//   // ---------------- Create / Update ----------------
//
//   Map<String, dynamic> _buildBody({required String imageUrl}) {
//     return {
//       'name': titleNameController.text.trim(),
//       'description': descriptionController.text.trim(),
//       'brandId': _toNum(selectedBrandId.value) ?? selectedBrandId.value,
//       'categoryId': _toNum(selectedCategoryId.value) ?? selectedCategoryId.value,
//       'category': selectedCategoryId ,
//       'type': selectedType.value,
//       'scale': selectedScale.value,
//       'year': int.tryParse(yearController.text.trim()) ?? 0,
//       'color': colorController.text.trim(),
//       'price': num.tryParse(priceController.text.trim()) ?? 0,
//       'image': imageUrl,
//       'createdBy': _userController.currentUser?.name ?? '',
//       'userId': _userController.currentUser?.id ?? '',
//     };
//   }
//
//   num? _toNum(String value) => num.tryParse(value);
//
//   Future<void> addProduct(BuildContext context) async {
//     if (!formKey.currentState!.validate()) {
//       _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
//       return;
//     }
//     if (selectedBrandId.value.isEmpty) {
//       _showSnackBar(context, 'Please select a brand!', Colors.orange);
//       return;
//     }
//     if (selectedCategoryId.value.isEmpty) {
//       _showSnackBar(context, 'Please select a category!', Colors.orange);
//       return;
//     }
//     if (selectedType.value.isEmpty) {
//       _showSnackBar(context, 'Please select a type!', Colors.orange);
//       return;
//     }
//     if (image.value == null && selectedImage.value == null) {
//       _showSnackBar(context, 'Please select a product image!', Colors.orange);
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//
//       if (_userController.currentUser == null) {
//         await _userController.fetchUserProfile();
//       }
//       if (!_userController.canAddEntry()) {
//         _showLimitReachedDialog(context, _userController.getEntryStatusMessage());
//         return;
//       }
//
//       final imageUrl = await _uploadImage();
//       if (imageUrl == null) throw Exception('Failed to process image');
//
//       final body = _buildBody(imageUrl: imageUrl);
//       final response = await _apiService.post('/Products/create', body: body);
//
//       if (response != null && (response['_id'] != null || response['id'] != null)) {
//         await _userController.updateUserEntries(1);
//         final remaining = _userController.getRemainingEntries();
//         String successMessage = 'Product added successfully!';
//         if (remaining <= 2 && remaining > 0) {
//           successMessage += ' ($remaining entries remaining)';
//         } else if (remaining == 0) {
//           successMessage += ' (Plan limit reached)';
//         }
//         clearFields();
//         _showSnackBar(context, successMessage, Colors.green);
//         if (context.mounted && Navigator.canPop(context)) Navigator.pop(context, true);
//       } else {
//         throw Exception('Failed to create product');
//       }
//     } catch (e) {
//       _showSnackBar(context, 'Failed to add product: ${e.toString()}', Colors.red);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> updateProduct(String productId, BuildContext context) async {
//     if (!formKey.currentState!.validate()) {
//       _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//       final imageUrl = await _uploadImage() ?? existingImageUrl.value;
//
//       final body = _buildBody(imageUrl: imageUrl);
//       body['id'] = productId;
//
//       await _apiService.put('/Products/update', body: body);
//
//       _showSnackBar(context, 'Product updated successfully!', Colors.green);
//       if (context.mounted && Navigator.canPop(context)) Navigator.pop(context, true);
//     } catch (e) {
//       _showSnackBar(context, 'Failed to update product: ${e.toString()}', Colors.red);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   static Future<void> deleteProduct(String productId, BuildContext context) async {
//     try {
//       UserController userController;
//       try {
//         userController = Get.find<UserController>();
//       } catch (e) {
//         userController = Get.put(UserController());
//         await userController.fetchUserProfile();
//       }
//
//       final apiService = ApiService();
//       await apiService.delete('/Products/deleteById', );
//
//       if (userController.currentEntries > 0) {
//         await userController.updateUserEntries(-1);
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product deleted successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete product: $e'), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   static Future<bool> canUserAddProduct() async {
//     try {
//       UserController userController;
//       try {
//         userController = Get.find<UserController>();
//       } catch (e) {
//         userController = Get.put(UserController());
//         await userController.fetchUserProfile();
//       }
//       return userController.canAddEntry();
//     } catch (e) {
//       return false;
//     }
//   }
//
//   // ---------------- Edit-mode population ----------------
//
//   void populateFieldsForEdit(Map<String, dynamic> data) {
//     titleNameController.text = data['name'] ?? '';
//     descriptionController.text = data['description'] ?? '';
//     yearController.text = (data['year'] ?? '').toString();
//     colorController.text = data['color'] ?? '';
//     priceController.text = (data['price'] ?? '').toString();
//     selectedBrandId.value = (data['brandId'] ?? '').toString();
//     selectedCategoryId.value = (data['categoryId'] ?? '').toString();
//     selectedType.value = data['type'] ?? '';
//     selectedScale.value = data['scale'] ?? '';
//     existingImageUrl.value = data['image'] ?? '';
//   }
//
//   void clearFields() {
//     titleNameController.clear();
//     descriptionController.clear();
//     yearController.clear();
//     colorController.clear();
//     priceController.clear();
//     selectedBrandId.value = '';
//     selectedCategoryId.value = '';
//     selectedType.value = '';
//     selectedScale.value = '';
//     image.value = null;
//     selectedImage.value = null;
//     existingImageUrl.value = '';
//   }
//
//   void _showSnackBar(BuildContext context, String message, Color color) {
//     Fluttertoast.showToast(msg: message, backgroundColor: color);
//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 3)),
//     // );
//   }
//
//   void _showLimitReachedDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Row(
//             children: [
//               Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
//               SizedBox(width: 12),
//               Text('Plan Limit Reached',
//                   style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20)),
//             ],
//           ),
//           content: Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87)),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

///Latest Changed
/*
class AddProductController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late ApiService _apiService;
  late UserController _userController;

  // Form controllers
  final titleNameController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();

  // Reactive variables
  final RxString selectedBrand = ''.obs;
  final RxString selectedType = ''.obs;
  final RxString selectedScale = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;

  // Image handling
  Rx<XFile?> image = Rx<XFile?>(null);
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final RxString existingImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = ApiService();
    try {
      _userController = Get.find<UserController>();
    } catch (e) {
      print('[v0] UserController not found, initializing...');
      _userController = Get.put(UserController());
    }
  }

  @override
  void onClose() {
    titleNameController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    colorController.dispose();
    priceController.dispose();
    brandController.dispose();
    categoryController.dispose();
    super.onClose();
  }

  Future<void> showImagePickerOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
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
            if (selectedImage.value != null || image.value != null) ...[
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
        _showSnackBar(
          context,
          'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission',
          Colors.orange,
        );
        return;
      }

      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final fileSize = await file.length();

        if (fileSize > 5 * 1024 * 1024) {
          _showSnackBar(context, 'Image size should be less than 5MB', Colors.red);
          return;
        }

        image.value = pickedImage;
        selectedImage.value = pickedImage;
        _showSnackBar(context, 'Image selected successfully!', Colors.green);
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
    } else {
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        final photosStatus = await Permission.photos.request();
        return storageStatus.isGranted || photosStatus.isGranted;
      } else {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
    }
  }

  void _removeImage(BuildContext context) {
    image.value = null;
    selectedImage.value = null;
    existingImageUrl.value = '';
    _showSnackBar(context, 'Image removed successfully!', Colors.green);
  }

  Future<void> requestPermission(BuildContext context) async {
    await showImagePickerOptions(context);
  }

  Future<void> pickImage(ImageSource source) async {
    await _pickImage(source, Get.context!);
  }

  Future<String?> _uploadImage() async {
    XFile? imageToUpload = image.value ?? selectedImage.value;
    if (imageToUpload == null) {
      return existingImageUrl.value.isEmpty ? null : existingImageUrl.value;
    }

    try {
      // For now, we'll return the local path
      // In production, you would upload to a cloud storage service
      print('[v0] Image path: ${imageToUpload.path}');
      return imageToUpload.path;
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  Future<void> addProduct(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
      return;
    }

    if (image.value == null && selectedImage.value == null) {
      _showSnackBar(context, 'Please select a product image!', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      // Ensure user controller is initialized
      if (_userController.currentUser == null) {
        await _userController.fetchUserProfile();
      }

      if (!_userController.canAddEntry()) {
        final statusMessage = _userController.getEntryStatusMessage();
        _showLimitReachedDialog(context, statusMessage);
        isLoading.value = false;
        return;
      }

      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        throw Exception('Failed to process image');
      }

      String productName = titleNameController.text.trim().isNotEmpty
          ? titleNameController.text.trim()
          : nameController.text.trim();

      if (productName.isEmpty) {
        _showSnackBar(context, 'Product name is required!', Colors.orange);
        isLoading.value = false;
        return;
      }

      String productType = selectedType.value.isNotEmpty
          ? selectedType.value
          : categoryController.text.trim();

      final productData = {
        'name': productName,
        'description': descriptionController.text.trim(),
        'brand': selectedBrand.value.isNotEmpty ? selectedBrand.value : brandController.text.trim(),
        'type': productType,
        'scale': selectedScale.value,
        'year': yearController.text.trim(),
        'category': selectedCategory.value.isNotEmpty ? selectedCategory.value : categoryController.text.trim(),
        'color': colorController.text.trim(),
        'price': priceController.text.trim(),
        'image': imageUrl,
      };

      // Call API to create product
      final response = await _apiService.post('/Products/create', body: productData);

      if (response != null && response['_id'] != null) {
        // Update user entries
        await _userController.updateUserEntries(1);

        final remaining = _userController.getRemainingEntries();
        String successMessage = 'Product added successfully!';
        if (remaining <= 2 && remaining > 0) {
          successMessage += ' ($remaining entries remaining)';
        } else if (remaining == 0) {
          successMessage += ' (Plan limit reached)';
        }

        _clearForm();
        _showSnackBar(context, successMessage, Colors.green);
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      print('[v0] Error adding product: $e');
      _showSnackBar(context, 'Failed to add product: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      final imageUrl = await _uploadImage();

      String productName = titleNameController.text.trim().isNotEmpty
          ? titleNameController.text.trim()
          : nameController.text.trim();

      if (productName.isEmpty) {
        _showSnackBar(context, 'Product name is required!', Colors.orange);
        isLoading.value = false;
        return;
      }

      String newType = selectedType.value.isNotEmpty
          ? selectedType.value
          : categoryController.text.trim();

      final productData = {
        'name': productName,
        'description': descriptionController.text.trim(),
        'brand': selectedBrand.value.isNotEmpty ? selectedBrand.value : brandController.text.trim(),
        'type': newType,
        'scale': selectedScale.value,
        'year': yearController.text.trim(),
        'category': selectedCategory.value.isNotEmpty ? selectedCategory.value : categoryController.text.trim(),
        'color': colorController.text.trim(),
        'price': priceController.text.trim(),
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        productData['image'] = imageUrl;
      }

      // Call API to update product
      await _apiService.put('/Products/update', body: productData);

      _showSnackBar(context, 'Product updated successfully!', Colors.green);
      Navigator.pop(context, true);
    } catch (e) {
      print('[v0] Error updating product: $e');
      _showSnackBar(context, 'Failed to update product: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> deleteProduct(String productId, BuildContext context) async {
    try {
      UserController userController;
      try {
        userController = Get.find<UserController>();
      } catch (e) {
        userController = Get.put(UserController());
        await userController.fetchUserProfile();
      }

      ApiService apiService = ApiService();
      await apiService.delete('/Products/deleteById');

      // Update user entries
      if (userController.currentEntries > 0) {
        await userController.updateUserEntries(-1);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      print('[v0] Product deleted successfully');
    } catch (e) {
      print('[v0] Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<bool> canUserAddProduct() async {
    try {
      UserController userController;
      try {
        userController = Get.find<UserController>();
      } catch (e) {
        userController = Get.put(UserController());
        await userController.fetchUserProfile();
      }
      return userController.canAddEntry();
    } catch (e) {
      print('[v0] Error checking if user can add product: $e');
      return false;
    }
  }

  void populateFieldsForEdit(Map<String, dynamic> data) {
    titleNameController.text = data['name'] ?? '';
    descriptionController.text = data['description'] ?? '';
    yearController.text = data['year'] ?? '';
    colorController.text = data['color'] ?? '';
    priceController.text = data['price'] ?? '';
    selectedBrand.value = data['brand'] ?? '';
    selectedType.value = data['type'] ?? '';
    selectedScale.value = data['scale'] ?? '';
    selectedCategory.value = data['category'] ?? '';
    existingImageUrl.value = data['image'] ?? '';
  }

  void clearFields() {
    titleNameController.clear();
    nameController.clear();
    descriptionController.clear();
    yearController.clear();
    colorController.clear();
    priceController.clear();
    brandController.clear();
    categoryController.clear();
    selectedBrand.value = '';
    selectedType.value = '';
    selectedScale.value = '';
    selectedCategory.value = '';
    image.value = null;
    selectedImage.value = null;
    existingImageUrl.value = '';
  }

  void _clearForm() {
    clearFields();
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLimitReachedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'Plan Limit Reached',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
*/
///Latest Changed
///

///
/*class AddProductController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final titleNameController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();

  // Reactive variables
  final RxString selectedBrand = ''.obs;
  final RxString selectedType = ''.obs;
  final RxString selectedScale = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;

  // Image handling
  Rx<XFile?> image = Rx<XFile?>(null);
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final RxString existingImageUrl = ''.obs;

  // User controller reference
  late UserController _userController;

  @override
  void onInit() {
    super.onInit();
    try {
      _userController = Get.find<UserController>();
    } catch (e) {
      print('UserProfileController not found, initializing...');
      _userController = Get.put(UserController());
    }
  }

  @override
  void onClose() {
    titleNameController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    colorController.dispose();
    priceController.dispose();
    brandController.dispose();
    categoryController.dispose();
    super.onClose();
  }

  Future<void> showImagePickerOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundClr,
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
                color: AppColors.black,
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
                  'assets/camera.png',
                  AppColors.cardBgClr,
                      () => _pickImage(ImageSource.camera, context),
                ),
                _buildImageOption(
                  context,
                  'Gallery',
                  'assets/gallery.png',
                  AppColors.cardBgClr,
                      () => _pickImage(ImageSource.gallery, context),
                ),
              ],
            ),
            if (selectedImage.value != null || image.value != null) ...[
              const SizedBox(height: 20),
              _buildImageOption(
                context,
                'Remove',
                'assets/icons/delete.svg',
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
      String icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(16),
          color: Colors.black,
          strokeWidth: 1,
          child: Container(
            width: 130,
            height: 117,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.cardBgClr,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                width: 2,
                color: color.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Image.asset(
                  icon,
                  width: 45,
                  height: 45,
                  color: AppColors.black,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      bool hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        _showSnackBar(
          context,
          'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission to continue',
          Colors.orange,
        );
        return;
      }

      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final fileSize = await file.length();

        if (fileSize > 5 * 1024 * 1024) {
          _showSnackBar(context, 'Image size should be less than 5MB', Colors.red);
          return;
        }

        image.value = pickedImage;
        selectedImage.value = pickedImage;
        _showSnackBar(context, 'Image selected successfully!', Colors.green);
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar(context, 'Failed to pick image: $e', Colors.red);
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        final photosStatus = await Permission.photos.request();
        return storageStatus.isGranted || photosStatus.isGranted;
      } else {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
    }
  }

  void _removeImage(BuildContext context) {
    image.value = null;
    selectedImage.value = null;
    existingImageUrl.value = '';
    _showSnackBar(context, 'Image removed successfully!', Colors.green);
  }

  Future<void> requestPermission(BuildContext context) async {
    await showImagePickerOptions(context);
  }

  Future<void> pickImage(ImageSource source) async {
    await _pickImage(source, Get.context!);
  }

  Future<String?> _uploadImage() async {
    XFile? imageToUpload = image.value ?? selectedImage.value;
    if (imageToUpload == null) {
      return existingImageUrl.value.isEmpty ? null : existingImageUrl.value;
    }

    try {
      final String fileName =
          'products/${DateTime.now().millisecondsSinceEpoch}_${imageToUpload.name}';
      final Reference storageRef = _storage.ref().child(fileName);

      final UploadTask uploadTask = storageRef.putFile(File(imageToUpload.path));
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // New method to update type count
  Future<void> _updateTypeCount(String type, int change) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      // Normalize type name to match the keys in typeCounts map
      String typeKey = type.toUpperCase();

      DocumentReference userRef = _firestore.collection('Users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> typeCounts = Map<String, dynamic>.from(userData['typeCounts'] ?? {});

        // Update the count
        int currentCount = typeCounts[typeKey] ?? 0;
        int newCount = currentCount + change;

        // Ensure count doesn't go below 0
        if (newCount < 0) newCount = 0;

        typeCounts[typeKey] = newCount;

        await userRef.update({'typeCounts': typeCounts});
        print('Updated $typeKey count: $currentCount -> $newCount');
      }
    } catch (e) {
      print('Error updating type count: $e');
    }
  }

  Future<void> addProduct(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
      return;
    }

    if (image.value == null && selectedImage.value == null) {
      _showSnackBar(context, 'Please select a product image!', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      try {
        _userController = Get.find<UserController>();
      } catch (e) {
        _userController = Get.put(UserController());
        await _userController.fetchUserProfile();
      }

      if (!_userController.canAddEntry()) {
        final statusMessage = _userController.getEntryStatusMessage();
        _showLimitReachedDialog(context, statusMessage);
        isLoading.value = false;
        return;
      }

      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      String productName = titleNameController.text.trim().isNotEmpty
          ? titleNameController.text.trim()
          : nameController.text.trim();

      if (productName.isEmpty) {
        _showSnackBar(context, 'Product name is required!', Colors.orange);
        isLoading.value = false;
        return;
      }

      // Get the type for counting
      String productType = selectedType.value.isNotEmpty
          ? selectedType.value
          : categoryController.text.trim();

      final productData = {
        'name': productName,
        'description': descriptionController.text.trim(),
        'brand': selectedBrand.value.isNotEmpty
            ? selectedBrand.value
            : brandController.text.trim(),
        'type': productType,
        'scale': selectedScale.value,
        'year': yearController.text.trim(),
        'category': selectedCategory.value.isNotEmpty
            ? selectedCategory.value
            : categoryController.text.trim(),
        'color': colorController.text.trim(),
        'price': priceController.text.trim(),
        'image': imageUrl,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      WriteBatch batch = _firestore.batch();

      DocumentReference productRef = _firestore.collection('Products').doc();
      batch.set(productRef, productData);

      DocumentReference userRef = _firestore.collection('Users').doc(userId);
      batch.update(userRef, {
        'entries': _userController.currentEntries + 1,
      });

      await batch.commit();

      // Update type count after successful product addition
      if (productType.isNotEmpty) {
        await _updateTypeCount(productType, 1);
      }

      print('Product added and entries updated successfully');

      final remaining = _userController.getRemainingEntries() - 1;
      String successMessage = 'Product added successfully!';
      if (remaining <= 2 && remaining > 0) {
        successMessage += ' ($remaining entries remaining)';
      } else if (remaining == 0) {
        successMessage += ' (Plan limit reached)';
      }

      _clearForm();
      _showSnackBar(context, successMessage, Colors.green);
    } catch (e) {
      print('Error adding product: $e');
      _showSnackBar(context, 'Failed to add product: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      // Get old product data to check if type changed
      DocumentSnapshot oldProductDoc = await _firestore.collection('Products').doc(productId).get();
      String? oldType;
      if (oldProductDoc.exists) {
        Map<String, dynamic> oldData = oldProductDoc.data() as Map<String, dynamic>;
        oldType = oldData['type'];
      }

      final imageUrl = await _uploadImage();

      String productName = titleNameController.text.trim().isNotEmpty
          ? titleNameController.text.trim()
          : nameController.text.trim();

      if (productName.isEmpty) {
        _showSnackBar(context, 'Product name is required!', Colors.orange);
        isLoading.value = false;
        return;
      }

      String newType = selectedType.value.isNotEmpty
          ? selectedType.value
          : categoryController.text.trim();

      final productData = {
        'name': productName,
        'description': descriptionController.text.trim(),
        'brand': selectedBrand.value.isNotEmpty
            ? selectedBrand.value
            : brandController.text.trim(),
        'type': newType,
        'scale': selectedScale.value,
        'year': yearController.text.trim(),
        'category': selectedCategory.value.isNotEmpty
            ? selectedCategory.value
            : categoryController.text.trim(),
        'color': colorController.text.trim(),
        'price': priceController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        productData['image'] = imageUrl;
      }

      await _firestore.collection('Products').doc(productId).update(productData);

      // Update type counts if type changed
      if (oldType != null && newType.isNotEmpty && oldType != newType) {
        await _updateTypeCount(oldType, -1); // Decrease old type
        await _updateTypeCount(newType, 1);  // Increase new type
      }

      _showSnackBar(context, 'Product updated successfully!', Colors.green);
    } catch (e) {
      print('Error updating product: $e');
      _showSnackBar(context, 'Failed to update product: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> deleteProduct(String productId, BuildContext context) async {
    try {
      UserController userController;
      try {
        userController = Get.find<UserController>();
      } catch (e) {
        userController = Get.put(UserController());
        await userController.fetchUserProfile();
      }

      // Get product data to determine type before deletion
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('Products')
          .doc(productId)
          .get();

      String? productType;
      if (productDoc.exists) {
        Map<String, dynamic> productData = productDoc.data() as Map<String, dynamic>;
        productType = productData['type'];
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.delete(FirebaseFirestore.instance.collection('Products').doc(productId));

      final userId = userController.userId;
      if (userId != null) {
        DocumentReference userRef =
        FirebaseFirestore.instance.collection('Users').doc(userId);
        final newEntries =
        userController.currentEntries > 0 ? userController.currentEntries - 1 : 0;
        batch.update(userRef, {'entries': newEntries});
      }

      await batch.commit();

      // Update type count after successful deletion
      if (productType != null && productType.isNotEmpty && userId != null) {
        await _updateTypeCountStatic(userId, productType, -1);
      }

      print('Product deleted and entries updated successfully');

      Fluttertoast.showToast(
        msg: 'Product deleted successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16,
      );
    } catch (e) {
      print('Error deleting product: $e');
      Fluttertoast.showToast(
        msg: 'Failed to delete product: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  // Static method for updating type count (used in deleteProduct)
  static Future<void> _updateTypeCountStatic(String userId, String type, int change) async {
    try {
      String typeKey = type.toUpperCase();

      DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> typeCounts = Map<String, dynamic>.from(userData['typeCounts'] ?? {});

        int currentCount = typeCounts[typeKey] ?? 0;
        int newCount = currentCount + change;

        if (newCount < 0) newCount = 0;

        typeCounts[typeKey] = newCount;

        await userRef.update({'typeCounts': typeCounts});
        print('Updated $typeKey count: $currentCount -> $newCount');
      }
    } catch (e) {
      print('Error updating type count: $e');
    }
  }

  static Future<bool> canUserAddProduct() async {
    try {
      UserController userController;
      try {
        userController = Get.find<UserController>();
      } catch (e) {
        userController = Get.put(UserController());
        await userController.fetchUserProfile();
      }
      return userController.canAddEntry();
    } catch (e) {
      print('Error checking if user can add product: $e');
      return false;
    }
  }

  void _clearForm() {
    titleNameController.clear();
    nameController.clear();
    descriptionController.clear();
    yearController.clear();
    colorController.clear();
    priceController.clear();
    brandController.clear();
    categoryController.clear();
    selectedBrand.value = '';
    selectedType.value = '';
    selectedScale.value = '';
    selectedCategory.value = '';
    image.value = null;
    selectedImage.value = null;
    existingImageUrl.value = '';
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showLimitReachedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131B32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FF7), Color(0xFF00D4FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Entry Limit Reached',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upgrade your plan to add more products and unlock additional features.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2FF7), Color(0xFF00D4FF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upgrade Plan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void populateFieldsForEdit(Map<String, dynamic> data) {
    titleNameController.text = data['name'] ?? '';
    nameController.text = data['name'] ?? '';
    descriptionController.text = data['description'] ?? '';
    selectedBrand.value = data['brand'] ?? '';
    brandController.text = data['brand'] ?? '';
    selectedType.value = data['type'] ?? '';
    selectedScale.value = data['scale'] ?? '';
    yearController.text = data['year'] ?? '';
    selectedCategory.value = data['category'] ?? '';
    categoryController.text = data['category'] ?? '';
    colorController.text = data['color'] ?? '';
    priceController.text = data['price'] ?? '';
    existingImageUrl.value = data['image'] ?? '';
  }

  void clearFields() {
    titleNameController.clear();

    nameController.clear();
    descriptionController.clear();
    selectedBrand.value =  '';
    brandController.clear();
    selectedType.value =  '';
    selectedScale.value =  '';
    yearController.clear();
    selectedCategory.value =  '';
    categoryController.clear();
    colorController.clear();
    priceController.clear();
    existingImageUrl.value = '';
  }
}*/
///
/*class AddProductController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final titleNameController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();

  // Reactive variables
  final RxString selectedBrand = ''.obs;
  final RxString selectedType = ''.obs;
  final RxString selectedScale = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;

  // Image handling
  Rx<XFile?> image = Rx<XFile?>(null);
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final RxString existingImageUrl = ''.obs;

  // User controller reference
  late UserProfileController _userController;

  @override
  void onInit() {
    super.onInit();
    try {
      _userController = Get.find<UserProfileController>();
    } catch (e) {
      print('UserProfileController not found, initializing...');
      _userController = Get.put(UserProfileController());
    }
  }

  @override
  void onClose() {
    titleNameController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    colorController.dispose();
    priceController.dispose();
    brandController.dispose();
    categoryController.dispose();
    super.onClose();
  }

  Future<void> showImagePickerOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundClr,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Color(0xFF131B32),
          //     Color(0xFF0A0E14),
          //   ],
          // ),
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
                color: AppColors.black,
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
                  'assets/camera.png',
                  AppColors.cardBgClr,
                      () => _pickImage(ImageSource.camera, context),
                ),
                _buildImageOption(
                  context,
                  'Gallery',
                  'assets/gallery.png',
                  AppColors.cardBgClr,
                      () => _pickImage(ImageSource.gallery, context),
                ),
              ],
            ),
            if (selectedImage.value != null || image.value != null) ...[
              const SizedBox(height: 20),
              _buildImageOption(
                context,
                'Remove',
                'assets/icons/delete.svg',
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
      String icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
     child: DottedBorder(
       borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        color: Colors.black,
        // gap: 3,
        strokeWidth: 1,

      child: Container(
        width: 130,
        height: 117,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          // color: AppColors.backgroundClr,
          color: AppColors.cardBgClr,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: 2,
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Image.asset(
              icon,
              width: 45,
              height: 45,
              color: AppColors.black,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
     )
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      // Request permissions
      bool hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        _showSnackBar(
          context,
          'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission to continue',
          Colors.orange,
        );
        return;
      }

      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final fileSize = await file.length();

        if (fileSize > 5 * 1024 * 1024) {
          _showSnackBar(context, 'Image size should be less than 5MB', Colors.red);
          return;
        }

        image.value = pickedImage;
        selectedImage.value = pickedImage;
        _showSnackBar(context, 'Image selected successfully!', Colors.green);
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar(context, 'Failed to pick image: $e', Colors.red);
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        final photosStatus = await Permission.photos.request();
        return storageStatus.isGranted || photosStatus.isGranted;
      } else {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
    }
  }

  void _removeImage(BuildContext context) {
    image.value = null;
    selectedImage.value = null;
    existingImageUrl.value = '';
    _showSnackBar(context, 'Image removed successfully!', Colors.green);
  }

  Future<void> requestPermission(BuildContext context) async {
    await showImagePickerOptions(context);
  }

  Future<void> pickImage(ImageSource source) async {
    await _pickImage(source, Get.context!);
  }

  Future<String?> _uploadImage() async {
    XFile? imageToUpload = image.value ?? selectedImage.value;
    if (imageToUpload == null) {
      return existingImageUrl.value.isEmpty ? null : existingImageUrl.value;
    }

    try {
      final String fileName =
          'products/${DateTime.now().millisecondsSinceEpoch}_${imageToUpload.name}';
      final Reference storageRef = _storage.ref().child(fileName);

      final UploadTask uploadTask = storageRef.putFile(File(imageToUpload.path));
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> addProduct(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
      return;
    }

    // Validate image
    if (image.value == null && selectedImage.value == null) {
      _showSnackBar(context, 'Please select a product image!', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      // Ensure user controller is initialized
      try {
        _userController = Get.find<UserProfileController>();
      } catch (e) {
        _userController = Get.put(UserProfileController());
        await _userController.fetchUserData();
      }

      // Check if user can add entry
      if (!_userController.canAddEntry()) {
        final statusMessage = _userController.getEntryStatusMessage();
        _showLimitReachedDialog(context, statusMessage);
        isLoading.value = false;
        return;
      }

      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Use titleNameController as primary, fallback to nameController
      String productName = titleNameController.text.trim().isNotEmpty
          ? titleNameController.text.trim()
          : nameController.text.trim();

      if (productName.isEmpty) {
        _showSnackBar(context, 'Product name is required!', Colors.orange);
        isLoading.value = false;
        return;
      }

      final productData = {
        'name': productName,
        'description': descriptionController.text.trim(),
        'brand': selectedBrand.value.isNotEmpty
            ? selectedBrand.value
            : brandController.text.trim(),
        'type': selectedType.value.isNotEmpty
            ? selectedType.value
            : selectedType.trim(),
        'scale': selectedScale.value,
        'year': yearController.text.trim(),
        'category': selectedCategory.value.isNotEmpty
            ? selectedCategory.value
            : categoryController.text.trim(),
        'color': colorController.text.trim(),
        'price': priceController.text.trim(),
        'image': imageUrl,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Use batch operation for atomic updates
      WriteBatch batch = _firestore.batch();

      // Add product
      DocumentReference productRef = _firestore.collection('Products').doc();
      batch.set(productRef, productData);

      // Update user entries
      DocumentReference userRef = _firestore.collection('Users').doc(userId);
      batch.update(userRef, {
        'entries': _userController.currentEntries + 1,
      });

      await batch.commit();
      print('Product added and entries updated successfully');

      final remaining = _userController.getRemainingEntries() - 1;
      String successMessage = 'Product added successfully!';
      if (remaining <= 2 && remaining > 0) {
        successMessage += ' ($remaining entries remaining)';
      } else if (remaining == 0) {
        successMessage += ' (Plan limit reached)';
      }

      _clearForm();
      _showSnackBar(context, successMessage, Colors.green);
    } catch (e) {
      print('Error adding product: $e');
      _showSnackBar(context, 'Failed to add product: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final imageUrl = await _uploadImage();

      String productName = titleNameController.text.trim().isNotEmpty
          ? titleNameController.text.trim()
          : nameController.text.trim();

      if (productName.isEmpty) {
        _showSnackBar(context, 'Product name is required!', Colors.orange);
        isLoading.value = false;
        return;
      }

      final productData = {
        'name': productName,
        'description': descriptionController.text.trim(),
        'brand': selectedBrand.value.isNotEmpty
            ? selectedBrand.value
            : brandController.text.trim(),
        'type': selectedType.value.isNotEmpty
            ? selectedType.value
            : selectedType.trim(),
        'scale': selectedScale.value,
        'year': yearController.text.trim(),
        'category': selectedCategory.value.isNotEmpty
            ? selectedCategory.value
            : categoryController.text.trim(),
        'color': colorController.text.trim(),
        'price': priceController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        productData['image'] = imageUrl;
      }

      await _firestore.collection('Products').doc(productId).update(productData);

      _showSnackBar(context, 'Product updated successfully!', Colors.green);
    } catch (e) {
      print('Error updating product: $e');
      _showSnackBar(context, 'Failed to update product: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> deleteProduct(String productId, BuildContext context) async {
    try {
      UserProfileController userController;
      try {
        userController = Get.find<UserProfileController>();
      } catch (e) {
        userController = Get.put(UserProfileController());
        await userController.fetchUserData();
      }

      // Use batch operation for atomic updates
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete product
      batch.delete(FirebaseFirestore.instance.collection('Products').doc(productId));

      // Update user entries
      final userId = userController.userId;
      if (userId != null) {
        DocumentReference userRef =
        FirebaseFirestore.instance.collection('Users').doc(userId);
        final newEntries =
        userController.currentEntries > 0 ? userController.currentEntries - 1 : 0;
        batch.update(userRef, {'entries': newEntries});
      }

      await batch.commit();
      print('Product deleted and entries updated successfully');

      Fluttertoast.showToast(
        msg: 'Product deleted successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16,
      );
    } catch (e) {
      print('Error deleting product: $e');
      Fluttertoast.showToast(
        msg: 'Failed to delete product: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  static Future<bool> canUserAddProduct() async {
    try {
      UserProfileController userController;
      try {
        userController = Get.find<UserProfileController>();
      } catch (e) {
        userController = Get.put(UserProfileController());
        await userController.fetchUserData();
      }
      return userController.canAddEntry();
    } catch (e) {
      print('Error checking if user can add product: $e');
      return false;
    }
  }

  void _clearForm() {
    titleNameController.clear();
    nameController.clear();
    descriptionController.clear();
    yearController.clear();
    colorController.clear();
    priceController.clear();
    brandController.clear();
    categoryController.clear();
    selectedBrand.value = '';
    selectedScale.value = '';
    selectedCategory.value = '';
    image.value = null;
    selectedImage.value = null;
    existingImageUrl.value = '';
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showLimitReachedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131B32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FF7), Color(0xFF00D4FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Entry Limit Reached',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upgrade your plan to add more products and unlock additional features.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2FF7), Color(0xFF00D4FF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to membership screen
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => MembershipScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upgrade Plan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to populate fields for edit mode
  void populateFieldsForEdit(Map<String, dynamic> data) {
    titleNameController.text = data['name'] ?? '';
    nameController.text = data['name'] ?? '';
    descriptionController.text = data['description'] ?? '';
    selectedBrand.value = data['brand'] ?? '';
    brandController.text = data['brand'] ?? '';
    selectedScale.value = data['scale'] ?? '';
    yearController.text = data['year'] ?? '';
    selectedCategory.value = data['category'] ?? '';
    categoryController.text = data['category'] ?? '';
    colorController.text = data['color'] ?? '';
    priceController.text = data['price'] ?? '';
    existingImageUrl.value = data['image'] ?? '';
  }
}*/

// class AddProductController extends GetxController {
//   final formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();
//
//   // Form controllers
//   final titleNameController = TextEditingController();
//   final nameController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final yearController = TextEditingController();
//   final colorController = TextEditingController();
//   final priceController = TextEditingController();
//   final brandController = TextEditingController();
//   final categoryController = TextEditingController();
//
//   // Reactive variables
//   final RxString selectedBrand = ''.obs;
//   final RxString selectedScale = ''.obs;
//   final RxString selectedCategory = ''.obs;
//   final RxBool isLoading = false.obs;
//
//   // Image handling
//   Rx<XFile?> image = Rx<XFile?>(null);
//   Rx<XFile?> selectedImage = Rx<XFile?>(null);
//   final RxString existingImageUrl = ''.obs;
//
//   // User controller reference
//   late UserProfileController _userController;
//
//
//
//   @override
//   void onInit() {
//     super.onInit();
//     try {
//       _userController = Get.find<UserProfileController>();
//     } catch (e) {
//       print('UserProfileController not found, will be initialized later');
//     }
//   }
//
//   @override
//   void onClose() {
//     titleNameController.dispose();
//     nameController.dispose();
//     descriptionController.dispose();
//     yearController.dispose();
//     colorController.dispose();
//     priceController.dispose();
//     brandController.dispose();
//     categoryController.dispose();
//     super.onClose();
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
//               'UPLOAD PHOTO',
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
//                  'assets/icons/camera.svg',
//                   Color(0xffD4DBFF),
//                   // Colors.blue,
//                       () => _pickImage(ImageSource.camera, context),
//                 ),
//                 _buildImageOption(
//                   context,
//                   'Gallery',
//                   'assets/icons/gallery.svg',
//                   Color(0xffD4DBFF),
//                   // Colors.green,
//                       () => _pickImage(ImageSource.gallery, context),
//                 ),
//               ],
//             ),
//             if (selectedImage.value != null || image.value != null) ...[
//               const SizedBox(height: 20),
//               _buildImageOption(
//                 context,
//                 'Remove',
//                 'assets/icons/delete.svg',
//                 Color(0xffD4DBFF),
//                 // Colors.red,
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
//             SvgPicture.asset(icon),
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
//       // Request permissions
//       bool hasPermission = await _requestPermission(source);
//       if (!hasPermission) {
//         _showSnackBar(context, 'Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission to continue', Colors.orange);
//         return;
//       }
//
//       final XFile? pickedImage = await _picker.pickImage(
//         source: source,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 80,
//       );
//
//       if (pickedImage != null) {
//         final file = File(pickedImage.path);
//         final fileSize = await file.length();
//
//         if (fileSize > 5 * 1024 * 1024) {
//           _showSnackBar(context, 'Image size should be less than 5MB', Colors.red);
//           return;
//         }
//
//         image.value = pickedImage;
//         selectedImage.value = pickedImage;
//         _showSnackBar(context, 'Image selected successfully!', Colors.green);
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
//         final status2 = await Permission.photos.request();
//         return status.isGranted && status2.isGranted;
//       } else {
//         final status = await Permission.photos.request();
//         return status.isGranted;
//       }
//     }
//   }
//
//   void _removeImage(BuildContext context) {
//     image.value = null;
//     selectedImage.value = null;
//     existingImageUrl.value = '';
//     _showSnackBar(context, 'Image removed successfully!', Colors.green);
//   }
//
//   Future<void> requestPermission(BuildContext context) async {
//     await showImagePickerOptions(context);
//   }
//
//   Future<void> pickImage(ImageSource source) async {
//     await _pickImage(source, Get.context!);
//   }
//
//   Future<String?> _uploadImage() async {
//     XFile? imageToUpload = image.value ?? selectedImage.value;
//     if (imageToUpload == null) return existingImageUrl.value.isEmpty ? null : existingImageUrl.value;
//
//     try {
//       final String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_${imageToUpload.name}';
//       final Reference storageRef = _storage.ref().child(fileName);
//
//       final UploadTask uploadTask = storageRef.putFile(File(imageToUpload.path));
//       final TaskSnapshot snapshot = await uploadTask;
//
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       throw Exception('Failed to upload image: $e');
//     }
//   }
//
//   Future<String?> _getCurrentUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userId');
//   }
//
//   Future<void> addProduct(BuildContext context) async {
//     if (!formKey.currentState!.validate()) {
//       _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//
//       final userId = await _getCurrentUserId();
//       if (userId == null) throw Exception('User not logged in');
//
//       // Get user controller
//       try {
//         _userController = Get.find<UserProfileController>();
//       } catch (e) {
//         throw Exception('User controller not found');
//       }
//
//       // Check if user can add entry
//       if (!_userController.canAddEntry()) {
//         final statusMessage = _userController.getEntryStatusMessage();
//         _showLimitReachedDialog(context, statusMessage);
//         _showSnackBar(context, 'You have reached the limit of entries! Upgrade your plan!', Colors.redAccent);
//         return;
//       }
//
//       final imageUrl = await _uploadImage();
//       if (imageUrl == null && (image.value != null || selectedImage.value != null)) {
//         throw Exception('Failed to upload image');
//       }
//
//       // Use the correct controller based on what's available
//       String productName = nameController.text.trim().isNotEmpty
//           ? nameController.text.trim()
//           : titleNameController.text.trim();
//
//       final productData = {
//         'name': productName,
//         'description': descriptionController.text.trim(),
//         'brand': selectedBrand.value.isNotEmpty ? selectedBrand.value : brandController.text.trim(),
//         'scale': selectedScale.value,
//         'year': yearController.text.trim(),
//         'category': selectedCategory.value.isNotEmpty ? selectedCategory.value : categoryController.text.trim(),
//         'color': colorController.text.trim(),
//         'price': priceController.text.trim(),
//         'image': imageUrl ?? '',
//         'createdBy': userId,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       };
//
//       // Use batch operation for consistency
//       WriteBatch batch = _firestore.batch();
//
//       // Add product
//       DocumentReference productRef = _firestore.collection('Products').doc();
//       batch.set(productRef, productData);
//
//       // Update user entries
//       DocumentReference userRef = _firestore.collection('Users').doc(userId);
//       batch.update(userRef, {
//         'entries': _userController.currentEntries + 1,
//       });
//
//       await batch.commit();
//       print('Product added and entries updated successfully');
//
//       final remaining = _userController.getRemainingEntries() - 1; // Account for the entry we just added
//       String successMessage = 'Product added successfully!';
//       if (remaining <= 2 && remaining > 0) {
//         successMessage += ' ($remaining entries remaining)';
//       } else if (remaining == 0) {
//         successMessage += ' (Plan limit reached)';
//       }
//
//       _clearForm();
//       _showSnackBar(context, successMessage, Colors.green);
//
//     } catch (e) {
//       print('Error adding product: $e');
//       _showSnackBar(context, 'Failed to add product: $e', Colors.red);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> updateProduct(String productId, BuildContext context) async {
//     if (!formKey.currentState!.validate()) {
//       _showSnackBar(context, 'Please fill all required fields correctly!', Colors.orange);
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//
//       final userId = await _getCurrentUserId();
//       if (userId == null) throw Exception('User not logged in');
//
//       final imageUrl = await _uploadImage();
//
//       String productName = nameController.text.trim().isNotEmpty
//           ? nameController.text.trim()
//           : titleNameController.text.trim();
//
//       final productData = {
//         'name': productName,
//         'description': descriptionController.text.trim(),
//         'brand': selectedBrand.value.isNotEmpty ? selectedBrand.value : brandController.text.trim(),
//         'scale': selectedScale.value,
//         'year': yearController.text.trim(),
//         'category': selectedCategory.value.isNotEmpty ? selectedCategory.value : categoryController.text.trim(),
//         'color': colorController.text.trim(),
//         'price': priceController.text.trim(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       };
//
//       if (imageUrl != null) {
//         productData['image'] = imageUrl;
//       }
//
//       await _firestore
//           .collection('Products')
//           .doc(productId)
//           .update(productData);
//
//       _showSnackBar(context, 'Product updated successfully!', Colors.green);
//     } catch (e) {
//       print('Error updating product: $e');
//       _showSnackBar(context, 'Failed to update product: $e', Colors.red);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   static Future<void> deleteProduct(String productId, BuildContext context) async {
//     try {
//       UserProfileController userController;
//       try {
//         userController = Get.find<UserProfileController>();
//       } catch (e) {
//         userController = Get.put(UserProfileController());
//         await userController.fetchUserData();
//       }
//
//       // Use batch operation for consistency
//       WriteBatch batch = FirebaseFirestore.instance.batch();
//
//       // Delete product
//       batch.delete(FirebaseFirestore.instance.collection('Products').doc(productId));
//
//       // Update user entries
//       final userId = userController.userId;
//       if (userId != null) {
//         DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
//         final newEntries = userController.currentEntries > 0 ? userController.currentEntries - 1 : 0;
//         batch.update(userRef, {'entries': newEntries});
//       }
//
//       await batch.commit();
//       print('Product deleted and entries updated successfully');
//
//       Fluttertoast.showToast(
//         msg: 'Product deleted successfully!',
//         backgroundColor:  Colors.green,
//
//       );
//
//
//     } catch (e) {
//       print('Error deleting product: $e');
//       Fluttertoast.showToast(
//         msg: 'Failed to delete product: $e',
//         backgroundColor:  Colors.green,
//
//       );
//
//     }
//   }
//
//   static Future<bool> canUserAddProduct() async {
//     try {
//       UserProfileController userController;
//       try {
//         userController = Get.find<UserProfileController>();
//       } catch (e) {
//         userController = Get.put(UserProfileController());
//         await userController.fetchUserData();
//       }
//       return userController.canAddEntry();
//     } catch (e) {
//       print('Error checking if user can add product: $e');
//       return false;
//     }
//   }
//
//   void _clearForm() {
//     titleNameController.clear();
//     nameController.clear();
//     descriptionController.clear();
//     yearController.clear();
//     colorController.clear();
//     priceController.clear();
//     brandController.clear();
//     categoryController.clear();
//     selectedBrand.value = '';
//     selectedScale.value = '';
//     selectedCategory.value = '';
//     image.value = null;
//     selectedImage.value = null;
//     existingImageUrl.value = '';
//   }
//
//   void _showSnackBar(BuildContext context, String message, Color color) {
//     Fluttertoast.showToast(
//       msg: message,
//       backgroundColor: color,
//
//     );
//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   SnackBar(
//     //     content: Text(message),
//     //     backgroundColor: color,
//     //     duration: const Duration(seconds: 3),
//     //   ),
//     // );
//   }
//
//   void _showLimitReachedDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Row(
//             children: [
//               Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
//               SizedBox(width: 12),
//               Text(
//                 'Entry Limit Reached',
//                 style: TextStyle(
//                   color: Colors.orange,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 message,
//                 style: const TextStyle(fontSize: 16, color: Colors.black87),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Upgrade your plan to add more products and unlock additional features.',
//                 style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Navigate to membership screen
//                 // Get.toNamed('/membership'); // Uncomment if using named routes
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text('Upgrade Plan', style: TextStyle(fontWeight: FontWeight.w600)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Helper method to populate fields for edit mode
//   void populateFieldsForEdit(Map<String, dynamic> data) {
//     titleNameController.text = data['name'] ?? '';
//     nameController.text = data['name'] ?? '';
//     descriptionController.text = data['description'] ?? '';
//     selectedBrand.value = data['brand'] ?? '';
//     brandController.text = data['brand'] ?? '';
//     selectedScale.value = data['scale'] ?? '';
//     yearController.text = data['year'] ?? '';
//     selectedCategory.value = data['category'] ?? '';
//     categoryController.text = data['category'] ?? '';
//     colorController.text = data['color'] ?? '';
//     priceController.text = data['price'] ?? '';
//     existingImageUrl.value = data['image'] ?? '';
//   }
// }


/*
class AddProductController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleNameController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();
  final priceController = TextEditingController();

  String? selectedBrand;
  String? selectedScale;
  String? selectedCategory;

  XFile? image;
  String? existingImageUrl;

  final ImagePicker _picker = ImagePicker();

  void requestPermission(BuildContext context, Function setState) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final fileSize = await file.length();

        if (fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size should be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          image = pickedImage;
        });
        update();
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

  Future<String?> _uploadImage() async {
    if (image == null) return existingImageUrl;

    try {
      final String fileName =
          'products/${DateTime.now().millisecondsSinceEpoch}_${image!.name}';
      final Reference storageRef =
      FirebaseStorage.instance.ref().child(fileName);

      final UploadTask uploadTask = storageRef.putFile(File(image!.path));
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // 🔹 Add product
  Future<void> addProduct(BuildContext context) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final UserProfileController userController =
      Get.find<UserProfileController>();

      await userController.fetchUserData();

      if (!userController.canAddEntry()) {
        final statusMessage = userController.getEntryStatusMessage();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Upgrade',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to membership/upgrade screen
                // Get.toNamed('/membership'); // Uncomment if using named routes
              },
            ),
          ),
        );
        return;
      }

      final imageUrl = await _uploadImage();
      if (imageUrl == null) throw Exception('Please select an image');

      final productData = {
        'name': titleNameController.text.trim(),
        'brand': selectedBrand,
        'scale': selectedScale,
        'year': yearController.text.trim(),
        'category': selectedCategory,
        'color': colorController.text.trim(),
        'price': priceController.text.trim(),
        'image': imageUrl,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Add product
      DocumentReference productRef = FirebaseFirestore.instance.collection('Products').doc();
      batch.set(productRef, productData);

      // Update user entries
      final userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('uid', isEqualTo: userId)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        final currentEntries = userDoc.data()['entries'] is int
            ? userDoc.data()['entries'] as int
            : int.tryParse(userDoc.data()['entries']?.toString() ?? '0') ?? 0;

        batch.update(userDoc.reference, {
          'entries': currentEntries + 1,
        });
      }

      await batch.commit();
      print('Product added and entries updated successfully');

      // Update local user data
      await userController.fetchUserData();

      final remaining = userController.getRemainingEntries();
      String successMessage = 'Product added successfully!';
      if (remaining <= 2 && remaining > 0) {
        successMessage += ' ($remaining entries remaining)';
      } else if (remaining == 0) {
        successMessage += ' (Plan limit reached)';
      }

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 Update product
  Future<void> updateProduct(String productId, BuildContext context) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final imageUrl = await _uploadImage();

      final productData = {
        'name': titleNameController.text.trim(),
        'brand': selectedBrand,
        'scale': selectedScale,
        'year': yearController.text.trim(),
        'category': selectedCategory,
        'color': colorController.text.trim(),
        'price': priceController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        productData['image'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('Products')
          .doc(productId)
          .update(productData);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // 🔹 Delete product
  static Future<void> deleteProduct(
      String productId, BuildContext context) async {
    try {
      UserProfileController userController;
      try {
        userController = Get.find<UserProfileController>();
      } catch (e) {
        userController = Get.put(UserProfileController());
        await userController.fetchUserData();
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete product
      batch.delete(FirebaseFirestore.instance.collection('Products').doc(productId));

      // Update user entries
      final userId = userController.userId;
      if (userId != null) {
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('uid', isEqualTo: userId)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          final currentEntries = userDoc.data()['entries'] is int
              ? userDoc.data()['entries'] as int
              : int.tryParse(userDoc.data()['entries']?.toString() ?? '0') ?? 0;

          final newEntries = currentEntries > 0 ? currentEntries - 1 : 0;

          batch.update(userDoc.reference, {
            'entries': newEntries,
          });
        }
      }

      await batch.commit();
      print('Product deleted and entries updated successfully');

      // Refresh user data
      await userController.fetchUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<bool> canUserAddProduct() async {
    try {
      UserProfileController userController;
      try {
        userController = Get.find<UserProfileController>();
      } catch (e) {
        userController = Get.put(UserProfileController());
        await userController.fetchUserData();
      }
      return userController.canAddEntry();
    } catch (e) {
      print('Error checking if user can add product: $e');
      return false;
    }
  }

  void _clearForm() {
    titleNameController.clear();
    yearController.clear();
    colorController.clear();
    priceController.clear();
    selectedBrand = null;
    selectedScale = null;
    selectedCategory = null;
    image = null;
    existingImageUrl = null;
    update();
  }

  @override
  void onClose() {
    titleNameController.dispose();
    yearController.dispose();
    colorController.dispose();
    priceController.dispose();
    super.onClose();
  }
}

*/


// class AddProductController extends AppBaseController {
//   TextEditingController titleNameController = TextEditingController();
//   TextEditingController yearController = TextEditingController();
//   TextEditingController colorController = TextEditingController();
//   TextEditingController priceController = TextEditingController();
//   String pin = '';
//   String? selectedBrand, selectedCategory, selectedScale;
//
//   final formKey = GlobalKey<FormState>();
//   int value1 = 0;
//   bool isVisible = true;
//
//   bool shoPass = true;
//
//   final ImagePicker picker = ImagePicker();
// // Pick an image.
//   XFile? image;
//
//   String? userId;
//   fetchDetails() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     userId = preferences.getString('userId');
//     update();
//     getEntries();
//   }
//
//   List<Map<String, dynamic>> users = [];
//   Map<String, dynamic>? userData;
//   String? entries;
//
//   void getEntries() async {
//     final snapshot = await FirebaseFirestore.instance.collection('Users').get();
//     for (var document in snapshot.docs) {
//       users.add(document.data());
//
//       if (document['uid'] == userId) {
//         userData = document.data();
//         entries = userData!['entries'];
//       }
//     }
//     update();
//   }
//
//   void requestPermission(
//       BuildContext context, Function(Function()) setStat) async {
//     return await showDialog<void>(
//       context: context,
//       // barrierDismissible: barrierDismissible, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(6))),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               InkWell(
//                 onTap: () async {
//                   pickImage(true, setStat);
//                 },
//                 child: Container(
//                   child: const ListTile(
//                       title: Text("Gallery"),
//                       leading: Icon(
//                         Icons.image,
//                         color: AppColors.primary,
//                       )),
//                 ),
//               ),
//               Container(
//                 width: 200,
//                 height: 1,
//                 color: Colors.black12,
//               ),
//               InkWell(
//                 onTap: () async {
//                   pickImage(false, setStat);
//                 },
//                 child: Container(
//                   child: const ListTile(
//                       title: Text("Camera"),
//                       leading: Icon(
//                         Icons.camera,
//                         color: AppColors.primary,
//                       )),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//
//     ///
//   }
//
//   pickImage(bool isGallery, Function(Function()) setStat) async {
//     if (isGallery) {
//       image = await picker.pickImage(source: ImageSource.gallery);
//       setStat(() {});
//     } else {
//       image = await picker.pickImage(source: ImageSource.camera);
//       setStat(() {});
//     }
//
//     Get.back();
//   }
//
//   static FirebaseStorage storage = FirebaseStorage.instance;
//   static FirebaseFirestore firestore = FirebaseFirestore.instance;
//   String? docID;
//
//   Future<void> uploadProductImage(File file, String userId) async {
//     Reference db = FirebaseStorage.instance
//         .ref()
//         .child('Products/$userId/${DateTime.now().toString()}');
//     await db.putFile(File(file.path));
//
//     print('this is image is sending $db');
//
//     final imageUrl = await db.getDownloadURL();
//
//     DocumentReference docRef = await firestore.collection('Products').add({
//       'image': imageUrl,
//     });
//     docID = docRef.id;
//     update();
//   }
//
//   addProduct() async {
//     if (selectedBrand == null ||
//         selectedCategory == null ||
//         selectedScale == null) {
//       showSnackBar('Please fill all details first!');
//     } else {
//       await uploadProductImage(File(image!.path), userId.toString() ?? '');
//       if (docID == '' || docID == null) {
//         showSnackBar('Image not uploaded properly! Try to Re-upload');
//       } else {
//         await firestore.collection('Products').doc(docID).update({
//           'brand': selectedBrand ?? '',
//           'category': selectedCategory ?? '',
//           'color': colorController.text.toString() ?? '',
//           'name': titleNameController.text.toString(),
//           'price': priceController.text.toString(),
//           'scale': selectedScale ?? '',
//           'year': yearController.text.toString(),
//           'createdAt': FieldValue.serverTimestamp(),
//           'createdBy': userId
//         });
//         entries = (int.parse(entries.toString()) + 1).toString();
//         update();
//         await firestore
//             .collection('Users')
//             .doc(userId)
//             .update({'entries': entries});
//         clear();
//         Get.offAllNamed(dashbord);
//       }
//     }
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDetails();
//   }
//
//   clear() {
//     titleNameController.clear();
//     colorController.clear();
//     priceController.clear();
//     yearController.clear();
//     selectedScale = null;
//     selectedCategory = null;
//     selectedBrand = null;
//     image = null;
//     docID = null;
//     update();
//   }
//
//   Future<void> updateProduct(String productId, BuildContext context) async {
//     if (selectedBrand == null ||
//         selectedCategory == null ||
//         selectedScale == null) {
//       showSnackBar('Please fill all details first!');
//       return;
//     }
//
//     try {
//       String? imageUrl;
//
//       // Upload new image if selected
//       if (image != null) {
//         final storageRef = FirebaseStorage.instance
//             .ref()
//             .child('Products/${DateTime.now().millisecondsSinceEpoch}.jpg');
//         await storageRef.putFile(File(image!.path));
//         imageUrl = await storageRef.getDownloadURL();
//       }
//
//       // Prepare update data
//       Map<String, dynamic> updateData = {
//         'name': titleNameController.text.trim(),
//         'brand': selectedBrand ?? '',
//         'scale': selectedScale ?? '',
//         'year': yearController.text.trim(),
//         'category': selectedCategory ?? '',
//         'color': colorController.text.trim(),
//         'price': priceController.text.trim(),
//         'updatedAt': FieldValue.serverTimestamp(),
//         'createdBy': userId,
//       };
//
//       if (imageUrl != null) {
//         updateData['image'] = imageUrl;
//       }
//
//       await FirebaseFirestore.instance
//           .collection('Products')
//           .doc(productId)
//           .update(updateData);
//
//       Fluttertoast.showToast(
//           msg: 'Product updated successfully!',
//           backgroundColor: Colors.green,
//           textColor: Colors.white
//       );
//
//       clear();
//
//       // Safe GetX navigation
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (Get.isRegistered<HomeController>()) {
//           Get.find<HomeController>().update(); // Refresh the controller
//         }
//
//         // Use Get.until to go back to DashboardScreen safely
//         Get.until((route) => route.settings.name == '/dashboard' || route.isFirst);
//       });
//
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: 'Failed to update product: $e',
//           backgroundColor: Colors.red,
//           textColor: Colors.white
//       );
//       rethrow;
//     }
//   }
//
//   // Future<void> updateProduct(String productId, BuildContext context) async {
//   //   if (selectedBrand == null ||
//   //       selectedCategory == null ||
//   //       selectedScale == null) {
//   //     showSnackBar('Please fill all details first!');
//   //     return;
//   //   }
//   //
//   //   try {
//   //     String? imageUrl;
//   //
//   //     // Upload new image if selected
//   //     if (image != null) {
//   //       final storageRef = FirebaseStorage.instance
//   //           .ref()
//   //           .child('Products/${DateTime.now().millisecondsSinceEpoch}.jpg');
//   //       await storageRef.putFile(File(image!.path));
//   //       imageUrl = await storageRef.getDownloadURL();
//   //     }
//   //
//   //     // Prepare update data
//   //     Map<String, dynamic> updateData = {
//   //       'name': titleNameController.text.trim(),
//   //       'brand': selectedBrand ?? '',
//   //       'scale': selectedScale ?? '',
//   //       'year': yearController.text.trim(),
//   //       'category': selectedCategory ?? '',
//   //       'color': colorController.text.trim(),
//   //       'price': priceController.text.trim(),
//   //       'updatedAt': FieldValue.serverTimestamp(),
//   //       'createdBy': userId, // match addProduct() if you want to track
//   //     };
//   //
//   //     if (imageUrl != null) {
//   //       updateData['image'] = imageUrl;
//   //     }
//   //
//   //     await FirebaseFirestore.instance
//   //         .collection('Products') // ✅ uppercase P to match addProduct()
//   //         .doc(productId)
//   //         .update(updateData);
//   //     // await firestore
//   //     //     .collection('Users')
//   //     //     .doc(userId)
//   //     //     .update({'entries': entries});
//   //     clear();
//   //     Get.offAllNamed(dashbord);
//   //
//   //     Fluttertoast.showToast(msg: 'Product updated successfully!', backgroundColor: Colors.green, textColor: Colors.white);
//   //     // showSnackBar('Product updated successfully!');
//   //
//   //     // Get.snackbar(
//   //     //   'Success',
//   //     //   'Product updated successfully!',
//   //     //   backgroundColor: Colors.green,
//   //     //   colorText: Colors.white,
//   //     //   snackPosition: SnackPosition.BOTTOM,
//   //     // );
//   //
//   //     // clear();
//   //     // // Navigator.pop(context);
//   //     // Get.offAll( const DashboardScreen());
//   //     // Get.back();
//   //   } catch (e) {
//   //     Fluttertoast.showToast(msg: 'Failed to update product: $e', backgroundColor: Colors.red, textColor: Colors.white);
//   //     // showSnackBar('Failed to update product: $e');
//   //     // Get.snackbar(
//   //     //   'Error',
//   //     //   'Failed to update product: $e',
//   //     //   backgroundColor: Colors.red,
//   //     //   colorText: Colors.white,
//   //     //   snackPosition: SnackPosition.BOTTOM,
//   //     // );
//   //     throw e;
//   //   }
//   // }
//
//
//   // Delete Product Method
//   static Future<void> deleteProduct(String productId) async {
//     try {
//       // Get product data first to delete image from storage
//       final productDoc = await FirebaseFirestore.instance
//           .collection('Products')
//           .doc(productId)
//           .get();
//
//       if (productDoc.exists) {
//         final productData = productDoc.data() as Map<String, dynamic>;
//         final imageUrl = productData['image'] as String?;
//
//         // Delete image from storage if exists
//         if (imageUrl != null && imageUrl.isNotEmpty) {
//           try {
//             await FirebaseStorage.instance.refFromURL(imageUrl).delete();
//           } catch (e) {
//             print('Error deleting image: $e');
//           }
//         }
//
//         // Delete product document
//         await FirebaseFirestore.instance
//             .collection('products')
//             .doc(productId)
//             .delete();
//
//         Get.snackbar(
//           'Success',
//           'Product deleted successfully!',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//           'Error',
//           'Failed to delete');
//     }
//   }
//
//   //
//   // List<Data> loginData = [];
// }
