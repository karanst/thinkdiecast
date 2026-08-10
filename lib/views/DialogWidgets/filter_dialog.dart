import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';
import 'package:thinkdiecast/controllers/home_controller.dart';

class FilterDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  const FilterDialog({super.key, required this.onApply});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  // Selected filters
  String? selectedType;
  String? selectedCategory;
  String? selectedBrand;
  String? selectedSubCategory;
  String? selectedScale;
  String? selectedColor;
  RangeValues yearRange = const RangeValues(2003, 2021);

  List<Map<String, dynamic>> scalesList = [];
  bool isLoadingScales = true;

  @override
  void initState() {
    super.initState();
    _fetchScales();
  }

  Future<void> _fetchScales() async {
    try {
      final response = await ApiService().get('/Scales/findAll');
      if (response is List) {
        setState(() {
          scalesList = response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          isLoadingScales = false;
        });
      } else if (response?['data'] is List) {
        setState(() {
          scalesList = (response['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          isLoadingScales = false;
        });
      } else {
        setState(() {
          isLoadingScales = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingScales = false;
      });
    }
  }

  // Category icons mapping
  final Map<String, String> categoryIcons = {
    'CARS': 'assets/icons/cars.svg',
    'BIKES': 'assets/icons/bikes.svg',
    'TRUCKS': 'assets/icons/trucks.svg',
    'PLANES': 'assets/icons/planes.svg',
  };

  void _clearFilters() {
    setState(() {
      selectedType = null;
      selectedCategory = null;
      selectedBrand = null;
      selectedSubCategory = null;
      selectedScale = null;
      selectedColor = null;
      yearRange = const RangeValues(2003, 2021);
    });
  }

  void _applyFilters() {
    Map<String, dynamic> filters = {};

    if (selectedType != null) {
      filters['type'] = selectedType;
    }
    if (selectedCategory != null) {
      filters['category'] = selectedCategory;
    }
    if (selectedBrand != null) {
      filters['brand'] = selectedBrand;
    }
    if (selectedSubCategory != null) {
      filters['subCategory'] = selectedSubCategory;
    }
    if (selectedScale != null) {
      filters['scale'] = selectedScale;
    }
    if (selectedColor != null) {
      filters['color'] = selectedColor;
    }
    filters['yearRange'] = [yearRange.start.round(), yearRange.end.round()];

    widget.onApply(filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: AppColors.backgroundClr,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSection(),
                    const SizedBox(height: 24),
                    _buildBrandSection(),
                    const SizedBox(height: 24),
                    _buildSubCategorySection(),
                    const SizedBox(height: 24),
                    _buildScaleSection(),
                    const SizedBox(height: 24),
                    _buildYearSection(),
                    const SizedBox(height: 24),
                    _buildColorSection(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8F5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'FILTERS AND SORTS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D5F),
            ),
          ),
          GestureDetector(
            onTap: _clearFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.grad1Clr, AppColors.grad2Clr]),
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeCard('CARS', 'assets/icons/cars.svg'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeCard('TRUCKS', 'assets/icons/trucks.svg'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeCard('BIKES', 'assets/icons/bikes.svg'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeCard('PLANES', 'assets/icons/planes.svg'),
        ),
      ],
    );
  }

  Widget _buildTypeCard(String type, String iconPath) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = isSelected ? null : type;
        });
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC5CAE9)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5C6BC0)
                : const Color(0xFFC5CAE9),
            width: 1.5,
          ),
        ),
        child: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: isSelected
                  ? [const Color(0xFF5C6BC0), const Color(0xFF3F51B5)]
                  : [AppColors.grad1Clr, AppColors.grad2Clr],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: SvgPicture.asset(
              iconPath,
              width: 26,
              height: 26,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategorySection() {
    final homeController = Get.find<HomeController>();
    final categoriesList = homeController.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUB CATEGORY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D5F),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categoriesList.map((cat) {
            final categoryName = (cat['name'] ?? '').toString().toUpperCase();
            final isSelected = selectedCategory == categoryName;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = isSelected ? null : categoryName;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.bright.withOpacity(0.4)
                      : AppColors.bright.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bright,
                    width: 2,
                  ),
                ),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2D2D5F),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrandSection() {
    final homeController = Get.find<HomeController>();
    final brands = homeController.brands;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BRAND',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D5F),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: brands.map((brand) {
            final brandName = brand['name']?.toString() ?? '';
            final brandImage = brand['imageUrl']?.toString() ?? brand['image']?.toString() ?? '';
            final isSelected = selectedBrand == brandName;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedBrand = isSelected ? null : brandName;
                });
              },
              child: Container(
                width: 90,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.bright.withOpacity(0.4)
                      : AppColors.bright.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bright,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: brandImage.isNotEmpty
                      ? Image.network(
                          brandImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    brandName,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF2D2D5F),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              brandName,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF2D2D5F),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScaleSection() {
    if (isLoadingScales) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SCALE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D5F),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: scalesList.map((scale) {
            final scaleName = scale['name']?.toString() ?? '';
            final isSelected = selectedScale == scaleName;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedScale = isSelected ? null : scaleName;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.bright.withOpacity(0.4)
                      : AppColors.bright.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bright,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  scaleName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF2D2D5F),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildYearSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YEAR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D5F),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${yearRange.start.round()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D5F),
              ),
            ),
            Text(
              '${yearRange.end.round()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D5F),
              ),
            ),
          ],
        ),
        RangeSlider(
          values: yearRange,
          min: 2003,
          max: 2026,
          // divisions: 18,
          activeColor: AppColors.bright,
          inactiveColor: const Color(0xFFD1D1E0),
          onChanged: (RangeValues values) {
            setState(() {
              yearRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    final colors = [
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Black', 'color': Colors.black},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Yellow', 'color': Colors.yellow},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COLOR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D5F),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((colorData) {
            final colorName = colorData['name'] as String;
            final color = colorData['color'] as Color;
            final isSelected = selectedColor == colorName;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = isSelected ? null : colorName;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.bright.withOpacity(0.4)
                      : AppColors.bright.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bright,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      colorName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF2D2D5F),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF4C6EF5), Color(0xFF7C3AED)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text(
            'Apply',
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
}
// Usage function
