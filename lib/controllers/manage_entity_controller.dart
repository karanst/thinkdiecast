import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/utils/custom_toast.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';
import 'package:thinkdiecast/controllers/refresh_controller.dart';
 // adjust path to your existing ApiService

/// Generic controller used for Category, Brand and Scale management.
/// Backend contract assumed (same convention as your /Products/* routes,
/// since Category/Brand/Scale endpoints were not visible in the swagger
/// screenshot you sent — only /Users/register and /Users/login were shown).
///
/// GET    {endpoint}/getAll        -> List<{ _id/id, name }>
/// POST   {endpoint}/create        -> body: { "name": "string" }
/// PUT    {endpoint}/update        -> body: { "id": "string", "name": "string" }
/// DELETE {endpoint}/deleteById    -> body: { "id": "string" }
///
/// If your real routes differ, only the four call sites below
/// (fetchAll / addItem / updateItem / deleteItem) need to change.
class ManageEntityController extends GetxController {
  final String endpoint;   // e.g. '/Category', '/Brand', '/Scale'
  final String entityLabel; // e.g. 'CATEGORY', 'BRAND', 'SCALE'

  ManageEntityController({required this.endpoint, required this.entityLabel});

  final ApiService _apiService = ApiService();

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  String _idOf(Map<String, dynamic> item) =>
      (item['_id'] ?? item['id'] ?? '').toString();

  Future<void> fetchAll() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get('$endpoint/findAll');
      final List list = (response is List)
          ? response
          : (response?['data'] as List? ?? []);
      items.value = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      debugPrint('[$entityLabel] fetchAll error: $e');
      showCustomToast('Failed to load $entityLabel list', isSuccess: false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addItem(String name, {String? imageUrl}) async {
    if (name.trim().isEmpty) return false;
    try {
      isSaving.value = true;
      final body = {'name': name.trim()};
      if (imageUrl != null) {
        body['imageUrl'] = imageUrl;
      }
      final response =
          await _apiService.post('$endpoint/create', body: body);
      if (response != null) {
        await fetchAll();
        _triggerRefresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[$entityLabel] addItem error: $e');
      showCustomToast('Failed to add $entityLabel', isSuccess: false);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateItem(String id, String name, {String? imageUrl}) async {
    if (name.trim().isEmpty) return false;
    try {
      isSaving.value = true;
      final body = {'id': id, 'name': name.trim()};
      if (imageUrl != null) {
        body['imageUrl'] = imageUrl;
      }
      await _apiService.post('$endpoint/update',
          body: body);
      await fetchAll();
      _triggerRefresh();
      return true;
    } catch (e) {
      debugPrint('[$entityLabel] updateItem error: $e');
      showCustomToast('Failed to update $entityLabel', isSuccess: false);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      isSaving.value = true;
      await _apiService.delete('$endpoint/deleteById?id=$id');
      items.removeWhere((e) => _idOf(e) == id);
      _triggerRefresh();
      return true;
    } catch (e) {
      debugPrint('[$entityLabel] deleteItem error: $e');
      showCustomToast('Failed to delete $entityLabel', isSuccess: false);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<String?> uploadEntityImage(var file) async {
    try {
      isSaving.value = true;
      final response = await _apiService.uploadImage('/Upload/image', file);
      if (response != null && response['url'] != null) {
        return response['url'].toString();
      }
      return null;
    } catch (e) {
      debugPrint('[$entityLabel] uploadEntityImage error: $e');
      showCustomToast('Failed to upload image', isSuccess: false);
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  void _triggerRefresh() {
    if (Get.isRegistered<AppRefreshController>()) {
      if (entityLabel.toUpperCase() == 'BRAND') {
        AppRefreshController.to.refreshBrands();
      } else if (entityLabel.toUpperCase() == 'CATEGORY') {
        AppRefreshController.to.refreshCategories();
      }
    }
  }
}
