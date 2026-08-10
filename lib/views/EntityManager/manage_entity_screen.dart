import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thinkdiecast/controllers/manage_entity_controller.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/utils/custom_textfield.dart';
import 'package:thinkdiecast/utils/widgets.dart';

/// Generic list + add/edit/delete screen for Category, Brand and Scale.
/// Visual language intentionally mirrors AddProductScreen: same bg image,
/// same header style, same gradient bottom sheet with GradientBorderTextField
/// and a pill-shaped gradient submit button.
class ManageEntityScreen extends StatefulWidget {
  final String endpoint;    // e.g. '/Category'
  final String entityLabel; // e.g. 'CATEGORY'
  final String tag;         // unique Get tag, e.g. 'category'
  final bool hasImage;      // whether to allow image upload

  const ManageEntityScreen({
    super.key,
    required this.endpoint,
    required this.entityLabel,
    required this.tag,
    this.hasImage = false,
  });

  @override
  State<ManageEntityScreen> createState() => _ManageEntityScreenState();
}

class _ManageEntityScreenState extends State<ManageEntityScreen> {
  late ManageEntityController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ManageEntityController(endpoint: widget.endpoint, entityLabel: widget.entityLabel),
      tag: widget.tag,
    );
  }
  // ---------------- Image upload (unchanged) ----------------



  @override
  void dispose() {
    Get.delete<ManageEntityController>(tag: widget.tag);
    super.dispose();
  }

  void _openFormSheet({String? id, String? currentName, String? currentImageUrl}) {
    final isEdit = id != null;
    final nameController = TextEditingController(text: currentName ?? '');
    XFile? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.primary],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(color: AppColors.grad1Clr.withOpacity(0.3), width: 2),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isEdit ? 'EDIT ${widget.entityLabel}' : 'ADD ${widget.entityLabel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    widget.hasImage ?
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              pickedImage = image;
                            });
                          }
                        },
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.grad1Clr.withOpacity(0.5)),
                          ),
                          child: pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    File(pickedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (currentImageUrl != null && currentImageUrl.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        currentImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white54, size: 40),
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate, color: Colors.white70, size: 40),
                                        SizedBox(height: 8),
                                        Text('Upload Image', style: TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                        ),
                      )
                    : const SizedBox  (),
                      const SizedBox(height: 24),
                    GradientBorderTextField(
                      label: 'NAME',
                      controller: nameController,
                      validator: (val) => val?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                colors: [AppColors.grad1Clr, AppColors.grad2Clr],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () async {
                                      final name = nameController.text.trim();
                                      if (name.isEmpty) return;
                                      
                                      String? imageUrl = currentImageUrl;
                                      if (pickedImage != null) {
                                        imageUrl = await controller.uploadEntityImage(pickedImage);
                                        if (imageUrl == null) return; // Upload failed
                                      }
                                      
                                      bool ok;
                                      if (isEdit) {
                                        ok = await controller.updateItem(id, name, imageUrl: imageUrl);
                                      } else {
                                        ok = await controller.addItem(name, imageUrl: imageUrl);
                                      }
                                      if (ok && mounted) Navigator.pop(ctx);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.bright,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: controller.isSaving.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      isEdit ? 'Update' : 'Save',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openActionsSheet(Map<String, dynamic> item) {
    final id = (item['_id'] ?? item['id']).toString();
    final name = item['name']?.toString() ?? '';
    final imageUrl = item['imageUrl']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name.toUpperCase(),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionOption(ctx, 'Edit', Icons.edit, Colors.blue, () {
                  Navigator.pop(ctx);
                  _openFormSheet(id: id, currentName: name, currentImageUrl: imageUrl);
                }),
                _actionOption(ctx, 'Delete', Icons.delete, Colors.red, () {
                  Navigator.pop(ctx);
                  _confirmDelete(id, name);
                }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _actionOption(BuildContext ctx, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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

  void _confirmDelete(String id, String name) {
    showCustomConfirmDialog(
      context: context,
      message: 'Are you sure want to\ndelete "$name"',
      actionText: 'Yes, Delete',
    ).then((confirmed) async {
      if (confirmed == true) {
        await controller.deleteItem(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/auth_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MANAGE',
                                  style: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.entityLabel,
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
                        GestureDetector(
                          onTap: () => _openFormSheet(),
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.bright, AppColors.bright2],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.bright.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primary, AppColors.primary],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        border: Border(
                          top: BorderSide(color: AppColors.grad1Clr.withOpacity(0.3), width: 2),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : controller.items.isEmpty
                              ? Center(
                                  child: Text(
                                    'No ${widget.entityLabel.toLowerCase()}s yet.\nTap + to add one.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: controller.fetchAll,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                                    itemCount: controller.items.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = controller.items[index];
                                      return GestureDetector(
                                        onTap: () => _openActionsSheet(item),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 18),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.06),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                                color: AppColors.grad1Clr.withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  if (widget.hasImage && item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty) ...[
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.network(
                                                        item['imageUrl'].toString(),
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white54, size: 40),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                  ],
                                                  Text(
                                                    (item['name'] ?? '').toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Icon(Icons.chevron_right, color: Colors.white54),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
