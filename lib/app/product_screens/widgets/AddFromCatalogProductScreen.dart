import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';
import '../../../constant/show_toast_dialog.dart';
import '../controllers/add_from_catalog_controller.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/const/color_const.dart';
import '../../../utils/dark_theme_provider.dart';
import '../add_from_catalog_screen.dart';
import '../add_masterproduct_screen.dart';

class AddFromCatalogProductScreen extends StatelessWidget {
  const AddFromCatalogProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final ctrl = Get.find<AddFromCatalogController>();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppThemeData.grey900
          : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: ColorConst.orange,
        elevation: 0,
        title: Text(
          ctrl.selectedCategory.value?.title ?? 'Products'.tr,
          style: const TextStyle(
            color: AppThemeData.grey50,
            fontSize: 18,
            fontFamily: AppThemeData.semiBold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppThemeData.grey50),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          backgroundColor: ColorConst.orange,
          onPressed: () async {
            final category = ctrl.selectedCategory.value;
            final categoryId =
                int.tryParse(category?.id ?? '') ?? 0;
            if (categoryId <= 0) {
              ShowToastDialog.showToast('Invalid category'.tr);
              return;
            }

            final result = await Get.to(
                  () => AddMasterProductScreen(
                categoryId: categoryId,
                categoryName: category?.title,
              ),
            );

            if (result == true) {
              await ctrl.loadMasterProducts();
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: AddFromCatalogBody(themeOverride: theme),
    );
  }
}
