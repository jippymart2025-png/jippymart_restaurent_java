import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import '../../../../controller/promotion_plans_controller.dart';
import 'promotion_plans_screen.dart';
import 'create_promotion_plan_screen.dart';

class PromotionPlanTypesScreen extends StatelessWidget {
  const PromotionPlanTypesScreen({super.key});

  // Strict matching by ID to guarantee the correct color, widget, and subtitle
  Map<String, dynamic> _getPlanStyle(int id) {
    switch (id) {
      case 1:
        return {
          'color': const Color(0xFFF97316), // Orange
          'widget': const Icon(Icons.percent, color: Colors.white, size: 26),
          'subtitle': 'Percentage based discount',
        };
      case 2:
        return {
          'color': const Color(0xFFF59E0B), // Yellow/Amber
          'widget': const Icon(Icons.local_offer, color: Colors.white, size: 24),
          'subtitle': 'Flat amount discount',
        };
      case 3:
        return {
          'color': const Color(0xFFFB7185), // Red/Pink
          // Using Text widget for 1+1 instead of an icon, matching your screenshot
          'widget': const Text(
            '1+1',
            style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: AppThemeData.bold, fontWeight: FontWeight.w900),
          ),
          'subtitle': 'Buy one get one offer',
        };
      case 4:
        return {
          'color': const Color(0xFF8B5CF6), // Purple
          'widget': const Icon(Icons.event_note, color: Colors.white, size: 24),
          'subtitle': 'Book slots & get offers',
        };
      case 15:
      default:
        return {
          'color': const Color(0xFF4ADE80), // Green
          'widget': const Icon(Icons.card_giftcard, color: Colors.white, size: 24),
          'subtitle': 'Special festival offers',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<PromotionPlansController>()
        ? Get.find<PromotionPlansController>()
        : Get.put(PromotionPlansController());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryOrange = Color(0xFFF95B12);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0.5,
        title: Text(
          'Promotion Plan Types',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: AppThemeData.semiBold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Get.to(() => const PromotionPlansScreen(showBackButton: true)),
            icon: const Icon(Icons.list_alt, color: primaryOrange, size: 20),
            label: const Text(
              'My Plans',
              style: TextStyle(color: primaryOrange, fontFamily: AppThemeData.semiBold),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.planTypes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.planTypes.isEmpty) {
          return const Center(child: Text('No plan types available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.planTypes.length,
          itemBuilder: (context, index) {
            final type = controller.planTypes[index];

            // Get style explicitly by ID
            final style = _getPlanStyle(type.promotionPlanTypesId);
            final Color cardColor = style['color'];
            final Widget displayWidget = style['widget'];
            final String subtitleText = style['subtitle'];

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: displayWidget, // Dynamically loads Icon or Text
                ),
                title: Text(
                  type.planName,
                  style: TextStyle(
                    fontFamily: AppThemeData.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitleText,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          // The ID badge is always pale orange matching the screenshot
                          color: const Color(0xFFFFF0E6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: ${type.promotionPlanTypesId}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: AppThemeData.bold,
                            color: primaryOrange, // Always orange text
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  Get.to(() => CreatePromotionPlanScreen(
                    preselectedTypeId: type.promotionPlanTypesId,
                  ));
                },
              ),
            );
          },
        );
      }),
    );
  }
}