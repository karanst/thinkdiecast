import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';
import 'package:thinkdiecast/utils/colors.dart';

class AdminMembershipScreen extends StatefulWidget {
  const AdminMembershipScreen({super.key});

  @override
  State<AdminMembershipScreen> createState() => _AdminMembershipScreenState();
}

class _AdminMembershipScreenState extends State<AdminMembershipScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> membershipPlans = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMembershipPlans();
  }

  Future<void> _loadMembershipPlans() async {
    try {
      setState(() => isLoading = true);
      final response = await _apiService.get('/Membership/findAll');
      if (response != null && response is List) {
        setState(() {
          membershipPlans = List<Map<String, dynamic>>.from(
            response.map((item) => item as Map<String, dynamic>)
          );
        });
      }
    } catch (e) {
      print('[Admin] Error loading plans: $e');
      _showToast('Failed to load plans: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showToast(String msg, Color color) {
    Fluttertoast.showToast(msg: msg, backgroundColor: color);
  }

  Future<void> _addOrUpdatePlan({Map<String, dynamic>? existingPlan}) async {
    final isEdit = existingPlan != null;
    final nameController = TextEditingController(text: existingPlan?['name'] ?? '');
    final priceController = TextEditingController(text: existingPlan?['price']?.toString() ?? '');
    final limitController = TextEditingController(text: existingPlan?['limit']?.toString() ?? '');
    final descController = TextEditingController(text: existingPlan?['description'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Membership Plan' : 'Add Membership Plan',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Plan Name (e.g. PRO)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Price (Rs.)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Upload Limit',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description (e.g. Upto 250 uploads allowed)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.bright),
            onPressed: () async {
              final name = nameController.text.trim();
              final price = int.tryParse(priceController.text.trim());
              final limit = int.tryParse(limitController.text.trim());
              final description = descController.text.trim();

              if (name.isEmpty || price == null || limit == null) {
                _showToast('Please fill all required fields correctly', Colors.orange);
                return;
              }

              Navigator.pop(context);
              setState(() => isLoading = true);

              try {
                if (isEdit) {
                  await _apiService.post('/Membership/update', body: {
                    'id': existingPlan['id'],
                    'name': name,
                    'price': price,
                    'limit': limit,
                    'description': description,
                  });
                  _showToast('Plan updated successfully!', Colors.green);
                } else {
                  await _apiService.post('/Membership/create', body: {
                    'name': name,
                    'price': price,
                    'limit': limit,
                    'description': description,
                  });
                  _showToast('Plan created successfully!', Colors.green);
                }
                _loadMembershipPlans();
              } catch (e) {
                _showToast('Operation failed: $e', Colors.red);
                setState(() => isLoading = false);
              }
            },
            child: Text(isEdit ? 'Update' : 'Create', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this plan?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        await _apiService.delete('/Membership/deleteById?id=$id');
        _showToast('Plan deleted successfully!', Colors.green);
        _loadMembershipPlans();
      } catch (e) {
        _showToast('Delete failed: $e', Colors.red);
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/auth_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'MANAGE MEMBERSHIP PLANS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: membershipPlans.isEmpty
                          ? const Center(
                              child: Text(
                                'No membership plans found',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: membershipPlans.length,
                              itemBuilder: (context, index) {
                                final plan = membershipPlans[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.bright.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              plan['name'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              plan['description'] ?? 'Upto ${plan['limit']} uploads allowed',
                                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Price: Rs. ${plan['price']} /yr  |  Limit: ${plan['limit']}',
                                              style: TextStyle(
                                                color: AppColors.borderColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _addOrUpdatePlan(existingPlan: plan),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deletePlan(plan['id']),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bright,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () => _addOrUpdatePlan(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add New Membership Plan',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}
