import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thinkdiecast/controllers/user_profile_controller.dart';

class EntryLimitWidget extends StatelessWidget {
  final bool showUpgradeButton;
  final VoidCallback? onUpgradePressed;

  const EntryLimitWidget({
    super.key,
    this.showUpgradeButton = true,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.put(UserController());

    return Obx(() => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _getStatusColor(controller.percentage).withOpacity(0.1),
        border: Border.all(
          color: _getStatusColor(controller.percentage).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(controller.percentage),
                color: _getStatusColor(controller.percentage),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entry Limit Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(controller.percentage),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.getEntryStatusMessage(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[300],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: controller.percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _getStatusColor(controller.percentage),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.currentEntries}/${controller.currentLimit} entries used',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${(controller.percentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(controller.percentage),
                ),
              ),
            ],
          ),

          // Upgrade button
          if (showUpgradeButton && controller.percentage >= 0.8)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onUpgradePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getStatusColor(controller.percentage),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Upgrade Plan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 0.9) return Colors.red;
    if (percentage >= 0.7) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(double percentage) {
    if (percentage >= 0.9) return Icons.warning;
    if (percentage >= 0.7) return Icons.info;
    return Icons.check_circle;
  }
}
