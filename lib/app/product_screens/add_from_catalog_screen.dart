// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';
// // import 'package:provider/provider.dart';
// //
// // import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// // import 'package:jippymart_restaurant/controller/add_from_catalog_controller.dart';
// // import 'package:jippymart_restaurant/models/master_product_model.dart';
// // import 'package:jippymart_restaurant/models/selected_product_model.dart';
// // import 'package:jippymart_restaurant/themes/app_them_data.dart';
// // import 'package:jippymart_restaurant/themes/round_button_fill.dart';
// // import 'package:jippymart_restaurant/themes/text_field_widget.dart';
// // import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
// // import 'package:jippymart_restaurant/utils/network_image_widget.dart';
// // import 'package:jippymart_restaurant/models/vendor_category_model.dart';
// // import 'package:dropdown_search/dropdown_search.dart';
// // import 'package:jippymart_restaurant/constant/constant.dart';
// // import 'package:jippymart_restaurant/utils/const/color_const.dart';
// //
// // /// Reusable catalog flow body: category → master products → select → save.
// // /// Used by both AddFromCatalogScreen and AddProductScreen.
// // class AddFromCatalogBody extends StatelessWidget {
// //   const AddFromCatalogBody({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final themeChange = Provider.of<DarkThemeProvider>(context);
// //     return GetX<AddFromCatalogController>(
// //       init: AddFromCatalogController(),
// //       builder: (c) {
// //         if (c.isLoading.value) return Constant.loader();
// //         return Column(
// //           children: [
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// //                 children: [
// //                   Text('Category'.tr, style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
// //                   const SizedBox(height: 6),
// //                   DropdownSearch<VendorCategoryModel>(
// //                     items: c.categoryList,
// //                     itemAsString: (VendorCategoryModel item) => item.title ?? '',
// //                     selectedItem: c.selectedCategory.value,
// //                     dropdownDecoratorProps: DropDownDecoratorProps(
// //                       dropdownSearchDecoration: InputDecoration(
// //                         hintText: 'Select category'.tr,
// //                         filled: true,
// //                         fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
// //                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// //                       ),
// //                     ),
// //                     onChanged: (v) => c.selectCategory(v),
// //                     popupProps: PopupProps.menu(showSearchBox: true),
// //                   ),
// //                   if (c.selectedCategory.value != null) ...[
// //                     const SizedBox(height: 8),
// //                     TextFieldWidget(
// //                       title: 'Search products'.tr,
// //                       hintText: 'Product name...'.tr,
// //                       onchange: (v) => c.setSearch(v),
// //                     ),
// //                     Row(
// //                       children: [
// //                         Expanded(child: RoundedButtonFill(title: 'Search'.tr, color: ColorConst.orange, width: 40, height: 5, textColor: AppThemeData.grey50, onPress: () => c.searchProducts())),
// //                         const SizedBox(width: 8),
// //                         Expanded(child: RoundedButtonFill(title: 'Load'.tr, color: AppThemeData.secondary300, width: 40, height: 5, textColor: AppThemeData.grey50, onPress: () => c.loadMasterProducts())),
// //                       ],
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //             if (c.selectedCategory.value == null)
// //               Expanded(child: Center(child: Text('Select a category to load products.'.tr, style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600))))
// //             else
// //               Expanded(
// //                 child: c.isLoadingProducts.value
// //                     ? Constant.loader()
// //                     : c.masterProducts.isEmpty
// //                         ? Center(child: Text('No products in this category.'.tr, style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600)))
// //                         : ListView.builder(
// //                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                             itemCount: c.masterProducts.length,
// //                             itemBuilder: (context, index) => _ProductCard(themeChange: themeChange, product: c.masterProducts[index], controller: c),
// //                           ),
// //               ),
// //             AddFromCatalogBody._buildPagination(c, themeChange),
// //             AddFromCatalogBody._buildBottomBar(context, c, themeChange),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   static Widget _buildPagination(AddFromCatalogController c, DarkThemeProvider themeChange) {
// //     if (c.lastPage.value <= 1) return const SizedBox.shrink();
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           IconButton(
// //             icon: const Icon(Icons.chevron_left),
// //             onPressed: c.currentPage.value > 1 ? () => c.goToPage(c.currentPage.value - 1) : null,
// //           ),
// //           Text('${c.currentPage.value} / ${c.lastPage.value}', style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
// //           IconButton(
// //             icon: const Icon(Icons.chevron_right),
// //             onPressed: c.currentPage.value < c.lastPage.value ? () => c.goToPage(c.currentPage.value + 1) : null,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   static Widget _buildBottomBar(BuildContext context, AddFromCatalogController c, DarkThemeProvider themeChange) {
// //     final count = c.selectedProducts.length;
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50),
// //       child: SafeArea(
// //         child: Row(
// //           children: [
// //             Text('$count selected'.tr, style: TextStyle(fontFamily: AppThemeData.semiBold, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
// //             const SizedBox(width: 16),
// //             Expanded(
// //               child: RoundedButtonFill(
// //                 title: 'Save'.tr,
// //                 color: ColorConst.orange,
// //                 width: 60,
// //                 height: 5.5,
// //                 textColor: AppThemeData.grey50,
// //                 onPress: () async {
// //                         if (count == 0) return;
// //                         final err = c.validateForSave();
// //                         if (err != null) {
// //                           ShowToastDialog.showToast(err);
// //                           return;
// //                         }
// //                         ShowToastDialog.showLoader('Saving...'.tr);
// //                         final ok = await c.saveAndCaptureResponse();
// //                         ShowToastDialog.closeLoader();
// //                         if (ok) {
// //                           ShowToastDialog.showToast(c.lastStoreResponse?.message ?? 'Successfully imported.'.tr);
// //                           Get.back(result: true);
// //                         } else {
// //                           final msg = c.lastStoreResponse?.message ?? 'Save failed.'.tr;
// //                           final errors = c.lastStoreResponse?.errors;
// //                           String show = msg;
// //                           if (errors != null && errors.isNotEmpty) {
// //                             final first = errors.entries.first;
// //                             show = '${first.value is List ? (first.value as List).join(' ') : first.value}';
// //                           }
// //                           ShowToastDialog.showToast(show);
// //                         }
// //                       },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class AddFromCatalogScreen extends StatelessWidget {
// //   const AddFromCatalogScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: ColorConst.orange,
// //         title: Text('Add from catalog'.tr, style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium)),
// //         iconTheme: const IconThemeData(color: AppThemeData.grey50),
// //       ),
// //       body: const AddFromCatalogBody(),
// //     );
// //   }
// // }
// //
// // class _ProductCard extends StatelessWidget {
// //   final DarkThemeProvider themeChange;
// //   final MasterProductModel product;
// //   final AddFromCatalogController controller;
// //
// //   const _ProductCard({required this.themeChange, required this.product, required this.controller});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final id = product.id ?? '';
// //     final isSelected = controller.isSelected(id);
// //     final sel = controller.selectedProducts[id];
// //
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.circular(8),
// //                   child: NetworkImageWidget(
// //                     imageUrl: product.photo ?? '',
// //                     width: 72,
// //                     height: 72,
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       if (product.isExisting == true)
// //                         Padding(
// //                           padding: const EdgeInsets.only(bottom: 4),
// //                           child: Chip(label: Text('Already added'.tr, style: const TextStyle(fontSize: 11)), backgroundColor: AppThemeData.success400.withValues(alpha: 0.3)),
// //                         ),
// //                       Text(product.name ?? '', style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 16, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900)),
// //                       if (product.description != null && product.description!.isNotEmpty)
// //                         Text(product.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600)),
// //                     ],
// //                   ),
// //                 ),
// //                 Checkbox(
// //                   value: isSelected,
// //                   onChanged: (_) => controller.toggleSelection(product),
// //                   activeColor: ColorConst.orange,
// //                 ),
// //               ],
// //             ),
// //             if (isSelected && sel != null) ...[
// //               const Divider(height: 24),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: _PriceField(
// //                       label: 'Your price'.tr,
// //                       value: sel.merchantPrice,
// //                       onChanged: (v) => controller.updateMerchantPrice(id, v),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   // Expanded(
// //                   //   child: _PriceField(
// //                   //     label: 'Online price'.tr,
// //                   //     value: sel.onlinePrice,
// //                   //     onChanged: (v) => controller.updateOnlinePrice(id, v),
// //                   //   ),
// //                   // ),
// //                   const SizedBox(width: 8),
// //                   // Expanded(
// //                   //   child: _PriceField(
// //                   //     label: 'Discount'.tr,
// //                   //     value: sel.discountPrice,
// //                   //     onChanged: (v) => controller.updateDiscountPrice(id, v),
// //                   //   ),
// //                   // ),
// //                 ],
// //               ),
// //               const SizedBox(height: 8),
// //               Row(
// //                 children: [
// //                   Text('Publish'.tr, style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600)),
// //                   CupertinoSwitch(value: sel.publish, onChanged: (v) => controller.setPublish(id, v), activeColor: ColorConst.orange),
// //                   const SizedBox(width: 16),
// //                   Text('Available'.tr, style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600)),
// //                   CupertinoSwitch(value: sel.isAvailable, onChanged: (v) => controller.setAvailable(id, v), activeColor: ColorConst.orange),
// //                 ],
// //               ),
// //               const SizedBox(height: 8),
// //               Row(
// //                 children: [
// //                   TextButton.icon(
// //                     onPressed: () => _showOptionsSheet(context, controller, id, sel, themeChange),
// //                     icon: const Icon(Icons.tune, size: 18),
// //                     label: Text('Options'.tr),
// //                   ),
// //                   TextButton.icon(
// //                     onPressed: () => _showAvailabilitySheet(context, controller, id, sel, themeChange),
// //                     icon: const Icon(Icons.schedule, size: 18),
// //                     label: Text('Availability'.tr),
// //                   ),
// //                 ],
// //               ),
// //               if (sel.addons.isNotEmpty)
// //                 Padding(
// //                   padding: const EdgeInsets.only(top: 4),
// //                   child: Text('Add-ons: ${sel.addons.length}'.tr, style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500)),
// //                 ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _PriceField extends StatelessWidget {
// //   final String label;
// //   final double value;
// //   final ValueChanged<double> onChanged;
// //
// //   const _PriceField({required this.label, required this.value, required this.onChanged});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Text(label, style: const TextStyle(fontSize: 11)),
// //         TextFormField(
// //           key: ValueKey('$label-$value'),
// //           initialValue: value.toStringAsFixed(2),
// //           keyboardType: const TextInputType.numberWithOptions(decimal: true),
// //           inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
// //           decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
// //           onChanged: (t) {
// //             final v = double.tryParse(t);
// //             if (v != null) onChanged(v);
// //           },
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // void _showOptionsSheet(BuildContext context, AddFromCatalogController c, String masterId, SelectedProductModel sel, DarkThemeProvider themeChange) {
// //   final options = List<OptionItem>.from(sel.options);
// //   showModalBottomSheet(
// //     context: context,
// //     isScrollControlled: true,
// //     builder: (ctx) => StatefulBuilder(
// //       builder: (ctx, setState) {
// //         return DraggableScrollableSheet(
// //           initialChildSize: 0.5,
// //           maxChildSize: 0.9,
// //           expand: false,
// //           builder: (_, scroll) => Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               children: [
// //                 Text('Product options'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                 const SizedBox(height: 16),
// //                 Expanded(
// //                   child: ListView.builder(
// //                     itemCount: options.length,
// //                     itemBuilder: (_, index) {
// //                       final o = options[index];
// //                       return ListTile(
// //                         title: Text(o.title),
// //                         trailing: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             SizedBox(
// //                               width: 80,
// //                               child: TextFormField(
// //                                 initialValue: o.price,
// //                                 keyboardType: TextInputType.number,
// //                                 onChanged: (v) => options[index] = OptionItem(id: o.id, title: o.title, price: v, originalPrice: o.originalPrice, isAvailable: o.isAvailable),
// //                               ),
// //                             ),
// //                             Checkbox(
// //                               value: o.isAvailable,
// //                               onChanged: (v) {
// //                                 options[index] = OptionItem(id: o.id, title: o.title, price: o.price, originalPrice: o.originalPrice, isAvailable: v ?? true);
// //                                 setState(() {});
// //                               },
// //                             ),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //                 RoundedButtonFill(
// //                   title: 'Done'.tr,
// //                   color: ColorConst.orange,
// //                   width: 50,
// //                   height: 5,
// //                   textColor: AppThemeData.grey50,
// //                   onPress: () {
// //                     c.setOptions(masterId, options);
// //                     Navigator.of(ctx).pop();
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     ),
// //   );
// // }
// //
// // void _showAvailabilitySheet(BuildContext context, AddFromCatalogController c, String masterId, SelectedProductModel sel, DarkThemeProvider themeChange) {
// //   const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
// //   var selectedDays = List<String>.from(sel.availableDays);
// //   var timings = <String, List<TimeRangeItem>>{};
// //   for (final e in sel.availableTimings.entries) {
// //     timings[e.key] = List.from(e.value);
// //   }
// //
// //   showModalBottomSheet(
// //     context: context,
// //     isScrollControlled: true,
// //     builder: (ctx) => StatefulBuilder(
// //       builder: (ctx, setState) {
// //         return DraggableScrollableSheet(
// //           initialChildSize: 0.5,
// //           maxChildSize: 0.9,
// //           expand: false,
// //           builder: (_, scroll) => Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.stretch,
// //               children: [
// //                 Text('Available days & times'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                 const SizedBox(height: 12),
// //                 Wrap(
// //                   spacing: 8,
// //                   children: days.map((d) {
// //                     final checked = selectedDays.contains(d);
// //                     return FilterChip(
// //                       label: Text(d),
// //                       selected: checked,
// //                       onSelected: (v) {
// //                         if (v) {
// //                           selectedDays.add(d);
// //                           if (!timings.containsKey(d)) timings[d] = [TimeRangeItem(from: '09:00', to: '22:00')];
// //                         } else {
// //                           selectedDays.remove(d);
// //                           timings.remove(d);
// //                         }
// //                         setState(() {});
// //                       },
// //                     );
// //                   }).toList(),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Expanded(
// //                   child: ListView(
// //                     children: selectedDays.map((d) {
// //                       final slots = timings[d] ?? [TimeRangeItem(from: '09:00', to: '22:00')];
// //                       return Padding(
// //                         padding: const EdgeInsets.only(bottom: 12),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
// //                             ...slots.asMap().entries.map((e) => Row(
// //                               children: [
// //                                 SizedBox(width: 70, child: TextFormField(initialValue: e.value.from, decoration: const InputDecoration(labelText: 'From'), onChanged: (v) => slots[e.key] = TimeRangeItem(from: v, to: slots[e.key].to))),
// //                                 const SizedBox(width: 8),
// //                                 SizedBox(width: 70, child: TextFormField(initialValue: e.value.to, decoration: const InputDecoration(labelText: 'To'), onChanged: (v) => slots[e.key] = TimeRangeItem(from: slots[e.key].from, to: v))),
// //                               ],
// //                             )),
// //                           ],
// //                         ),
// //                       );
// //                     }).toList(),
// //                   ),
// //                 ),
// //                 RoundedButtonFill(
// //                   title: 'Done'.tr,
// //                   color: ColorConst.orange,
// //                   width: 50,
// //                   height: 5,
// //                   textColor: AppThemeData.grey50,
// //                   onPress: () {
// //                     c.setAvailableDays(masterId, selectedDays);
// //                     c.setAvailableTimings(masterId, timings);
// //                     Navigator.of(ctx).pop();
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     ),
// //   );
// // }
//
//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
//
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// import 'package:jippymart_restaurant/controller/add_from_catalog_controller.dart';
// import 'package:jippymart_restaurant/models/master_product_model.dart';
// import 'package:jippymart_restaurant/models/selected_product_model.dart';
// import 'package:jippymart_restaurant/models/vendor_category_model.dart';
// import 'package:jippymart_restaurant/themes/app_them_data.dart';
// import 'package:jippymart_restaurant/themes/round_button_fill.dart';
// import 'package:jippymart_restaurant/themes/text_field_widget.dart';
// import 'package:jippymart_restaurant/utils/const/color_const.dart';
// import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
// import 'package:jippymart_restaurant/utils/network_image_widget.dart';
// import 'package:dropdown_search/dropdown_search.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Screen
// // ─────────────────────────────────────────────────────────────────────────────
// class AddFromCatalogScreen extends StatelessWidget {
//   const AddFromCatalogScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//       Theme.of(context).brightness == Brightness.dark
//           ? AppThemeData.grey900
//           : const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: ColorConst.orange,
//         elevation: 0,
//         title: Text(
//           'Add from Catalog'.tr,
//           style: const TextStyle(
//             color: AppThemeData.grey50,
//             fontSize: 18,
//             fontFamily: AppThemeData.semiBold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: AppThemeData.grey50),
//       ),
//       body: const AddFromCatalogBody(),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Body
// // ─────────────────────────────────────────────────────────────────────────────
// class AddFromCatalogBody extends StatelessWidget {
//   const AddFromCatalogBody({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<DarkThemeProvider>(context);
//
//     return GetX<AddFromCatalogController>(
//       init: AddFromCatalogController(),
//       builder: (c) {
//         if (c.isLoading.value) return Constant.loader();
//
//         return Column(
//           children: [
//             _FilterPanel(ctrl: c, theme: theme),
//             Expanded(child: _ProductSection(ctrl: c, theme: theme)),
//             if (c.selectedCategory.value != null &&
//                 !c.isLoadingProducts.value &&
//                 c.lastPage.value > 1)
//               _Pagination(ctrl: c, theme: theme),
//             _BottomBar(ctrl: c, theme: theme),
//           ],
//         );
//       },
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Filter panel
// // ─────────────────────────────────────────────────────────────────────────────
// class _FilterPanel extends StatelessWidget {
//   const _FilterPanel({required this.ctrl, required this.theme});
//   final AddFromCatalogController ctrl;
//   final DarkThemeProvider theme;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = theme.getThem();
//
//     return Container(
//       margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: isDark ? AppThemeData.grey800 : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: isDark
//             ? []
//             : [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             'Category'.tr,
//             style: TextStyle(
//               fontFamily: AppThemeData.semiBold,
//               fontSize: 13,
//               color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
//             ),
//           ),
//           const SizedBox(height: 6),
//           DropdownSearch<VendorCategoryModel>(
//             items: ctrl.categoryList,
//             itemAsString: (item) => item.title ?? '',
//             selectedItem: ctrl.selectedCategory.value,
//             dropdownDecoratorProps: DropDownDecoratorProps(
//               dropdownSearchDecoration: InputDecoration(
//                 hintText: 'Select a category'.tr,
//                 hintStyle: TextStyle(
//                   color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
//                   fontSize: 13,
//                 ),
//                 filled: true,
//                 fillColor: isDark ? AppThemeData.grey700 : AppThemeData.grey50,
//                 contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(
//                     color: isDark ? AppThemeData.grey600 : AppThemeData.grey200,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(
//                     color: isDark ? AppThemeData.grey600 : AppThemeData.grey200,
//                   ),
//                 ),
//               ),
//             ),
//             onChanged: ctrl.selectCategory,
//             popupProps: PopupProps.menu(showSearchBox: true),
//           ),
//           if (ctrl.selectedCategory.value != null) ...[
//             const SizedBox(height: 10),
//             TextFieldWidget(
//               title: 'Search'.tr,
//               hintText: 'Product name...'.tr,
//               onchange: ctrl.setSearch,
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: _ActionButton(
//                     label: 'Search'.tr,
//                     icon: Icons.search_rounded,
//                     color: ColorConst.orange,
//                     onTap: ctrl.searchProducts,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: _ActionButton(
//                     label: 'Load All'.tr,
//                     icon: Icons.refresh_rounded,
//                     color: AppThemeData.secondary300,
//                     onTap: ctrl.loadMasterProducts,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class _ActionButton extends StatelessWidget {
//   const _ActionButton({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: color,
//       borderRadius: BorderRadius.circular(10),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(10),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.white, size: 16),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontFamily: AppThemeData.semiBold,
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Product section
// // ─────────────────────────────────────────────────────────────────────────────
// class _ProductSection extends StatelessWidget {
//   const _ProductSection({required this.ctrl, required this.theme});
//   final AddFromCatalogController ctrl;
//   final DarkThemeProvider theme;
//
//   @override
//   Widget build(BuildContext context) {
//     if (ctrl.selectedCategory.value == null) {
//       return _EmptyHint(
//         icon: Icons.category_outlined,
//         message: 'Select a category to browse products'.tr,
//         theme: theme,
//       );
//     }
//
//     if (ctrl.isLoadingProducts.value) return Constant.loader();
//
//     if (ctrl.masterProducts.isEmpty) {
//       return _EmptyHint(
//         icon: Icons.inventory_2_outlined,
//         message: 'No products in this category'.tr,
//         theme: theme,
//       );
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
//       itemCount: ctrl.masterProducts.length,
//       itemBuilder: (_, i) => _ProductCard(
//         product: ctrl.masterProducts[i],
//         ctrl: ctrl,
//         theme: theme,
//       ),
//     );
//   }
// }
//
// class _EmptyHint extends StatelessWidget {
//   const _EmptyHint(
//       {required this.icon, required this.message, required this.theme});
//   final IconData icon;
//   final String message;
//   final DarkThemeProvider theme;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = theme.getThem();
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon,
//               size: 48,
//               color: isDark ? AppThemeData.grey500 : AppThemeData.grey400),
//           const SizedBox(height: 12),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
//               fontFamily: AppThemeData.regular,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Product card
// // ─────────────────────────────────────────────────────────────────────────────
// class _ProductCard extends StatelessWidget {
//   const _ProductCard({
//     required this.product,
//     required this.ctrl,
//     required this.theme,
//   });
//
//   final MasterProductModel product;
//   final AddFromCatalogController ctrl;
//   final DarkThemeProvider theme;
//
//   @override
//   Widget build(BuildContext context) {
//     final id = product.id ?? '';
//     final isSelected = ctrl.isSelected(id);
//     final sel = ctrl.selectedProducts[id];
//     final isDark = theme.getThem();
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: isDark ? AppThemeData.grey800 : Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: isSelected
//             ? Border.all(color: ColorConst.orange.withOpacity(0.5), width: 1.5)
//             : Border.all(
//             color: isDark ? AppThemeData.grey700 : Colors.grey.shade200,
//             width: 1),
//         boxShadow: isDark
//             ? []
//             : [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Main row ──────────────────────────────────────────────────
//           InkWell(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
//             onTap: () => ctrl.toggleSelection(product),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _CatalogImage(url: product.photo, isDark: isDark),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (product.isExisting == true)
//                           Container(
//                             margin: const EdgeInsets.only(bottom: 4),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF0A9E6E).withOpacity(0.12),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               'Already added'.tr,
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 color: Color(0xFF0A9E6E),
//                                 fontFamily: AppThemeData.semiBold,
//                               ),
//                             ),
//                           ),
//                         Text(
//                           product.name ?? '',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontFamily: AppThemeData.semiBold,
//                             color: isDark
//                                 ? AppThemeData.grey100
//                                 : AppThemeData.grey900,
//                           ),
//                         ),
//                         if (product.description?.isNotEmpty == true) ...[
//                           const SizedBox(height: 2),
//                           Text(
//                             product.description!,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: isDark
//                                   ? AppThemeData.grey400
//                                   : AppThemeData.grey500,
//                               fontFamily: AppThemeData.regular,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   // Checkbox
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 180),
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color:
//                       isSelected ? ColorConst.orange : Colors.transparent,
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(
//                         color: isSelected
//                             ? ColorConst.orange
//                             : (isDark
//                             ? AppThemeData.grey500
//                             : AppThemeData.grey300),
//                         width: 2,
//                       ),
//                     ),
//                     child: isSelected
//                         ? const Icon(Icons.check, color: Colors.white, size: 16)
//                         : null,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // ── Expanded form (only when selected) ───────────────────────
//           if (isSelected && sel != null)
//             _SelectedProductForm(
//               id: id,
//               sel: sel,
//               ctrl: ctrl,
//               theme: theme,
//               product: product,
//               context: context,
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Catalog image
// // ─────────────────────────────────────────────────────────────────────────────
// class _CatalogImage extends StatelessWidget {
//   const _CatalogImage({required this.url, required this.isDark});
//   final String? url;
//   final bool isDark;
//
//   bool get _hasImage {
//     final u = url?.trim() ?? '';
//     return u.isNotEmpty && u != 'null';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: _hasImage
//           ? NetworkImageWidget(
//         imageUrl: url!,
//         width: 72,
//         height: 72,
//         fit: BoxFit.cover,
//       )
//           : Container(
//         width: 72,
//         height: 72,
//         color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.fastfood_rounded,
//                 size: 26,
//                 color: isDark
//                     ? AppThemeData.grey500
//                     : AppThemeData.grey400),
//             const SizedBox(height: 2),
//             Text(
//               'No Image',
//               style: TextStyle(
//                 fontSize: 9,
//                 color: isDark
//                     ? AppThemeData.grey500
//                     : AppThemeData.grey400,
//                 fontFamily: AppThemeData.regular,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Selected product form
// // ─────────────────────────────────────────────────────────────────────────────
// class _SelectedProductForm extends StatelessWidget {
//   const _SelectedProductForm({
//     required this.id,
//     required this.sel,
//     required this.ctrl,
//     required this.theme,
//     required this.product,
//     required this.context,
//   });
//
//   final String id;
//   final SelectedProductModel sel;
//   final AddFromCatalogController ctrl;
//   final DarkThemeProvider theme;
//   final MasterProductModel product;
//   final BuildContext context;
//
//   @override
//   Widget build(BuildContext _) {
//     final isDark = theme.getThem();
//
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark
//             ? AppThemeData.grey700.withOpacity(0.5)
//             : AppThemeData.grey50,
//         borderRadius:
//         const BorderRadius.vertical(bottom: Radius.circular(14)),
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Divider(
//               height: 1,
//               color: isDark ? AppThemeData.grey600 : Colors.grey.shade200),
//           const SizedBox(height: 12),
//
//           // ── Price field ──────────────────────────────────────────────
//           _PriceField(
//             label: 'Your price'.tr,
//             value: sel.merchantPrice,
//             isDark: isDark,
//             onChanged: (v) => ctrl.updateMerchantPrice(id, v),
//           ),
//
//           const SizedBox(height: 12),
//
//           // ── Publish / Available toggles ──────────────────────────────
//           Row(
//             children: [
//               _ToggleChip(
//                 label: 'Publish'.tr,
//                 value: sel.publish,
//                 activeColor: const Color(0xFF0A9E6E),
//                 isDark: isDark,
//                 onChanged: (v) => ctrl.setPublish(id, v),
//               ),
//               const SizedBox(width: 10),
//               _ToggleChip(
//                 label: 'Available'.tr,
//                 value: sel.isAvailable,
//                 activeColor: ColorConst.orange,
//                 isDark: isDark,
//                 onChanged: (v) => ctrl.setAvailable(id, v),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 10),
//
//           // ── Options / Availability buttons ───────────────────────────
//           Row(
//             children: [
//               _SheetButton(
//                 icon: Icons.tune_rounded,
//                 label: 'Options'.tr,
//                 onTap: () =>
//                     _showOptionsSheet(context, ctrl, id, sel, theme),
//               ),
//               const SizedBox(width: 8),
//               _SheetButton(
//                 icon: Icons.schedule_rounded,
//                 label: 'Availability'.tr,
//                 onTap: () =>
//                     _showAvailabilitySheet(context, ctrl, id, sel, theme),
//               ),
//             ],
//           ),
//
//           // ── Add-on count badge ───────────────────────────────────────
//           if (sel.addons.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Container(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: isDark ? AppThemeData.grey600 : AppThemeData.grey200,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 '${sel.addons.length} add-on(s)'.tr,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: isDark
//                       ? AppThemeData.grey300
//                       : AppThemeData.grey600,
//                   fontFamily: AppThemeData.regular,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Toggle chip
// // ─────────────────────────────────────────────────────────────────────────────
// class _ToggleChip extends StatelessWidget {
//   const _ToggleChip({
//     required this.label,
//     required this.value,
//     required this.activeColor,
//     required this.isDark,
//     required this.onChanged,
//   });
//   final String label;
//   final bool value;
//   final Color activeColor;
//   final bool isDark;
//   final ValueChanged<bool> onChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => onChanged(!value),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: value
//               ? activeColor.withOpacity(0.12)
//               : (isDark ? AppThemeData.grey700 : Colors.grey.shade100),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: value ? activeColor.withOpacity(0.4) : Colors.transparent,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 7,
//               height: 7,
//               decoration: BoxDecoration(
//                 color: value
//                     ? activeColor
//                     : (isDark ? AppThemeData.grey500 : Colors.grey.shade400),
//                 shape: BoxShape.circle,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontFamily: AppThemeData.semiBold,
//                 color: value
//                     ? activeColor
//                     : (isDark ? AppThemeData.grey400 : AppThemeData.grey600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SheetButton extends StatelessWidget {
//   const _SheetButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 15, color: AppThemeData.grey600),
//             const SizedBox(width: 5),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontFamily: AppThemeData.medium,
//                 color: AppThemeData.grey600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Price field
// // ─────────────────────────────────────────────────────────────────────────────
// class _PriceField extends StatelessWidget {
//   const _PriceField({
//     required this.label,
//     required this.value,
//     required this.isDark,
//     required this.onChanged,
//   });
//   final String label;
//   final double value;
//   final bool isDark;
//   final ValueChanged<double> onChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             fontFamily: AppThemeData.semiBold,
//             color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
//           ),
//         ),
//         const SizedBox(height: 4),
//         TextFormField(
//           key: ValueKey('$label-$value'),
//           initialValue: value.toStringAsFixed(2),
//           keyboardType:
//           const TextInputType.numberWithOptions(decimal: true),
//           inputFormatters: [
//             FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
//           ],
//           style: TextStyle(
//             fontSize: 14,
//             fontFamily: AppThemeData.semiBold,
//             color: isDark ? AppThemeData.grey100 : AppThemeData.grey900,
//           ),
//           decoration: InputDecoration(
//             isDense: true,
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             filled: true,
//             fillColor: isDark ? AppThemeData.grey700 : Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(
//                   color: isDark
//                       ? AppThemeData.grey600
//                       : Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(
//                   color: isDark
//                       ? AppThemeData.grey600
//                       : Colors.grey.shade300),
//             ),
//           ),
//           onChanged: (t) {
//             final v = double.tryParse(t);
//             if (v != null) onChanged(v);
//           },
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Pagination
// // ─────────────────────────────────────────────────────────────────────────────
// class _Pagination extends StatelessWidget {
//   const _Pagination({required this.ctrl, required this.theme});
//   final AddFromCatalogController ctrl;
//   final DarkThemeProvider theme;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = theme.getThem();
//     final cur = ctrl.currentPage.value;
//     final last = ctrl.lastPage.value;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       color: isDark ? AppThemeData.grey900 : const Color(0xFFF5F6FA),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _PageArrow(
//             icon: Icons.chevron_left,
//             enabled: cur > 1,
//             isDark: isDark,
//             onTap: () => ctrl.goToPage(cur - 1),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             '$cur / $last',
//             style: TextStyle(
//               fontFamily: AppThemeData.semiBold,
//               fontSize: 13,
//               color: isDark ? AppThemeData.grey200 : AppThemeData.grey800,
//             ),
//           ),
//           const SizedBox(width: 12),
//           _PageArrow(
//             icon: Icons.chevron_right,
//             enabled: cur < last,
//             isDark: isDark,
//             onTap: () => ctrl.goToPage(cur + 1),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _PageArrow extends StatelessWidget {
//   const _PageArrow({
//     required this.icon,
//     required this.enabled,
//     required this.isDark,
//     required this.onTap,
//   });
//   final IconData icon;
//   final bool enabled;
//   final bool isDark;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: enabled
//               ? ColorConst.orange.withOpacity(0.1)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(
//           icon,
//           size: 22,
//           color: enabled
//               ? ColorConst.orange
//               : (isDark ? AppThemeData.grey600 : AppThemeData.grey300),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Bottom save bar
// // ─────────────────────────────────────────────────────────────────────────────
// class _BottomBar extends StatelessWidget {
//   const _BottomBar({required this.ctrl, required this.theme});
//   final AddFromCatalogController ctrl;
//   final DarkThemeProvider theme;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = theme.getThem();
//     final count = ctrl.selectedProducts.length;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? AppThemeData.grey900 : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDark ? 0.2 : 0.07),
//             blurRadius: 16,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//       child: SafeArea(
//         child: Row(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding:
//               const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: count > 0
//                     ? ColorConst.orange.withOpacity(0.12)
//                     : (isDark
//                     ? AppThemeData.grey700
//                     : AppThemeData.grey100),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 count > 0 ? '$count selected'.tr : 'None selected'.tr,
//                 style: TextStyle(
//                   fontFamily: AppThemeData.semiBold,
//                   fontSize: 13,
//                   color: count > 0
//                       ? ColorConst.orange
//                       : (isDark
//                       ? AppThemeData.grey400
//                       : AppThemeData.grey500),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: RoundedButtonFill(
//                 title: 'Save'.tr,
//                 color: count > 0 ? ColorConst.orange : Colors.grey.shade400,
//                 width: 60,
//                 height: 5.5,
//                 textColor: AppThemeData.grey50,
//                 onPress: () async {
//                   if (count == 0) return;
//                   final err = ctrl.validateForSave();
//                   if (err != null) {
//                     ShowToastDialog.showToast(err);
//                     return;
//                   }
//                   ShowToastDialog.showLoader('Saving...'.tr);
//                   final ok = await ctrl.saveAndCaptureResponse();
//                   ShowToastDialog.closeLoader();
//                   if (ok) {
//                     ShowToastDialog.showToast(ctrl.lastStoreResponse?.message ??
//                         'Successfully imported.'.tr);
//                     Get.back(result: true);
//                   } else {
//                     final msg =
//                         ctrl.lastStoreResponse?.message ?? 'Save failed.'.tr;
//                     final errors = ctrl.lastStoreResponse?.errors;
//                     String display = msg;
//                     if (errors != null && errors.isNotEmpty) {
//                       final first = errors.entries.first;
//                       display = first.value is List
//                           ? (first.value as List).join(' ')
//                           : first.value.toString();
//                     }
//                     ShowToastDialog.showToast(display);
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Options bottom sheet — FIX: shows empty state if no options; only
// // interactive after product is selected (called from _SelectedProductForm)
// // ─────────────────────────────────────────────────────────────────────────────
// void _showOptionsSheet(
//     BuildContext context,
//     AddFromCatalogController c,
//     String masterId,
//     SelectedProductModel sel,
//     DarkThemeProvider theme,
//     ) {
//   // Deep-copy so edits don't mutate until "Done"
//   final options = List<OptionItem>.from(sel.options);
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (ctx) => _OptionsSheetContent(
//       options: options,
//       theme: theme,
//       onDone: (edited) {
//         c.setOptions(masterId, edited);
//         Navigator.of(ctx).pop();
//       },
//     ),
//   );
// }
//
// class _OptionsSheetContent extends StatefulWidget {
//   const _OptionsSheetContent({
//     required this.options,
//     required this.theme,
//     required this.onDone,
//   });
//   final List<OptionItem> options;
//   final DarkThemeProvider theme;
//   final ValueChanged<List<OptionItem>> onDone;
//
//   @override
//   State<_OptionsSheetContent> createState() => _OptionsSheetContentState();
// }
//
// class _OptionsSheetContentState extends State<_OptionsSheetContent> {
//   late List<OptionItem> _options;
//
//   @override
//   void initState() {
//     super.initState();
//     _options = List.from(widget.options);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = widget.theme.getThem();
//     final bg = isDark ? AppThemeData.grey800 : Colors.white;
//
//     return DraggableScrollableSheet(
//       initialChildSize: _options.isEmpty ? 0.35 : 0.55,
//       minChildSize: 0.3,
//       maxChildSize: 0.9,
//       expand: false,
//       builder: (_, scrollController) => Container(
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius:
//           const BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             // ── Handle ────────────────────────────────────────────────
//             _SheetHandle(),
//
//             // ── Header ────────────────────────────────────────────────
//             Padding(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: ColorConst.orange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(Icons.tune_rounded,
//                         size: 18, color: ColorConst.orange),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     'Product Options'.tr,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontFamily: AppThemeData.bold,
//                       color: isDark
//                           ? AppThemeData.grey100
//                           : AppThemeData.grey900,
//                     ),
//                   ),
//                   const Spacer(),
//                   // Option count badge
//                   if (_options.isNotEmpty)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: ColorConst.orange.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${_options.length}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontFamily: AppThemeData.semiBold,
//                           color: ColorConst.orange,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//
//             Divider(
//                 height: 1,
//                 color:
//                 isDark ? AppThemeData.grey700 : Colors.grey.shade200),
//
//             // ── Content ───────────────────────────────────────────────
//             Expanded(
//               child: _options.isEmpty
//                   ? _OptionsEmptyState(isDark: isDark)
//                   : ListView.separated(
//                 controller: scrollController,
//                 padding: const EdgeInsets.all(16),
//                 itemCount: _options.length,
//                 separatorBuilder: (_, __) =>
//                 const SizedBox(height: 8),
//                 itemBuilder: (_, i) {
//                   final o = _options[i];
//                   return _OptionRow(
//                     option: o,
//                     isDark: isDark,
//                     onPriceChanged: (v) {
//                       _options[i] = OptionItem(
//                         id: o.id,
//                         title: o.title,
//                         price: v,
//                         originalPrice: o.originalPrice,
//                         isAvailable: o.isAvailable,
//                       );
//                     },
//                     onAvailableChanged: (v) {
//                       setState(() {
//                         _options[i] = OptionItem(
//                           id: o.id,
//                           title: o.title,
//                           price: o.price,
//                           originalPrice: o.originalPrice,
//                           isAvailable: v ?? true,
//                         );
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),
//
//             // ── Done button ───────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//               child: SafeArea(
//                 child: RoundedButtonFill(
//                   title: 'Done'.tr,
//                   color: ColorConst.orange,
//                   width: 50,
//                   height: 5,
//                   textColor: AppThemeData.grey50,
//                   onPress: () => widget.onDone(_options),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Shown inside the options sheet when the product has no options defined
// class _OptionsEmptyState extends StatelessWidget {
//   const _OptionsEmptyState({required this.isDark});
//   final bool isDark;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 64,
//               height: 64,
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? AppThemeData.grey700
//                     : AppThemeData.grey100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.tune_rounded,
//                 size: 28,
//                 color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
//               ),
//             ),
//             const SizedBox(height: 14),
//             Text(
//               'No Options Available'.tr,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontFamily: AppThemeData.semiBold,
//                 color: isDark ? AppThemeData.grey300 : AppThemeData.grey700,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               'This product has no configurable options.'.tr,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: isDark ? AppThemeData.grey500 : AppThemeData.grey500,
//                 fontFamily: AppThemeData.regular,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _OptionRow extends StatelessWidget {
//   const _OptionRow({
//     required this.option,
//     required this.isDark,
//     required this.onPriceChanged,
//     required this.onAvailableChanged,
//   });
//   final OptionItem option;
//   final bool isDark;
//   final ValueChanged<String> onPriceChanged;
//   final ValueChanged<bool?> onAvailableChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: isDark ? AppThemeData.grey700 : AppThemeData.grey50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: isDark ? AppThemeData.grey600 : Colors.grey.shade200,
//         ),
//       ),
//       child: Row(
//         children: [
//           // Option name
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   option.title,
//                   style: TextStyle(
//                     fontFamily: AppThemeData.medium,
//                     fontSize: 13,
//                     color:
//                     isDark ? AppThemeData.grey100 : AppThemeData.grey800,
//                   ),
//                 ),
//                 if (option.originalPrice!.isNotEmpty) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     'Original: ${option.originalPrice}',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: isDark
//                           ? AppThemeData.grey500
//                           : AppThemeData.grey400,
//                       fontFamily: AppThemeData.regular,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           // Price field
//           SizedBox(
//             width: 80,
//             child: TextFormField(
//               initialValue: option.price,
//               keyboardType: TextInputType.number,
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
//               ],
//               style: TextStyle(
//                 fontSize: 13,
//                 fontFamily: AppThemeData.medium,
//                 color: isDark ? AppThemeData.grey100 : AppThemeData.grey900,
//               ),
//               decoration: InputDecoration(
//                 isDense: true,
//                 hintText: '0.00',
//                 contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                 filled: true,
//                 fillColor: isDark ? AppThemeData.grey800 : Colors.white,
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(
//                         color: isDark
//                             ? AppThemeData.grey600
//                             : Colors.grey.shade300)),
//                 enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(
//                         color: isDark
//                             ? AppThemeData.grey600
//                             : Colors.grey.shade300)),
//               ),
//               onChanged: onPriceChanged,
//             ),
//           ),
//           const SizedBox(width: 4),
//           // Available checkbox with label
//           Column(
//             children: [
//               Checkbox(
//                 value: option.isAvailable,
//                 onChanged: onAvailableChanged,
//                 activeColor: ColorConst.orange,
//                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 visualDensity: VisualDensity.compact,
//               ),
//               Text(
//                 'Avail'.tr,
//                 style: TextStyle(
//                   fontSize: 9,
//                   color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
//                   fontFamily: AppThemeData.regular,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Availability bottom sheet — FIX: keyboard pushes content up properly
// // using padding from MediaQuery (viewInsets) inside a scrollable.
// // ─────────────────────────────────────────────────────────────────────────────
// void _showAvailabilitySheet(
//     BuildContext context,
//     AddFromCatalogController c,
//     String masterId,
//     SelectedProductModel sel,
//     DarkThemeProvider theme,
//     ) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     // KEY: let Flutter resize the sheet when keyboard appears
//     backgroundColor: Colors.transparent,
//     builder: (ctx) => _AvailabilitySheetContent(
//       sel: sel,
//       theme: theme,
//       onDone: (days, timings) {
//         c.setAvailableDays(masterId, days);
//         c.setAvailableTimings(masterId, timings);
//         Navigator.of(ctx).pop();
//       },
//     ),
//   );
// }
//
// class _AvailabilitySheetContent extends StatefulWidget {
//   const _AvailabilitySheetContent({
//     required this.sel,
//     required this.theme,
//     required this.onDone,
//   });
//   final SelectedProductModel sel;
//   final DarkThemeProvider theme;
//   final void Function(
//       List<String> days, Map<String, List<TimeRangeItem>> timings) onDone;
//
//   @override
//   State<_AvailabilitySheetContent> createState() =>
//       _AvailabilitySheetContentState();
// }
//
// class _AvailabilitySheetContentState
//     extends State<_AvailabilitySheetContent> {
//   static const _days = [
//     'Monday', 'Tuesday', 'Wednesday', 'Thursday',
//     'Friday', 'Saturday', 'Sunday'
//   ];
//
//   late List<String> _selectedDays;
//   late Map<String, List<TimeRangeItem>> _timings;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedDays = List<String>.from(widget.sel.availableDays);
//     _timings = {
//       for (final e in widget.sel.availableTimings.entries)
//         e.key: List.from(e.value),
//     };
//   }
//
//   void _toggleDay(String day, bool selected) {
//     setState(() {
//       if (selected) {
//         _selectedDays.add(day);
//         if (!_timings.containsKey(day)) {
//           _timings[day] = [TimeRangeItem(from: '09:00', to: '22:00')];
//         }
//       } else {
//         _selectedDays.remove(day);
//         _timings.remove(day);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = widget.theme.getThem();
//     final bg = isDark ? AppThemeData.grey800 : Colors.white;
//     // KEY FIX: read keyboard height and add as bottom padding
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius:
//         const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       // Animate height change when keyboard appears/disappears
//       padding: EdgeInsets.only(bottom: keyboardHeight),
//       child: DraggableScrollableSheet(
//         initialChildSize: 0.6,
//         minChildSize: 0.4,
//         maxChildSize: 0.92,
//         expand: false,
//         builder: (_, scrollController) => Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ── Handle ──────────────────────────────────────────────
//             _SheetHandle(),
//
//             // ── Header ──────────────────────────────────────────────
//             Padding(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: ColorConst.orange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(Icons.schedule_rounded,
//                         size: 18, color: ColorConst.orange),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     'Available Days & Times'.tr,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontFamily: AppThemeData.bold,
//                       color: isDark
//                           ? AppThemeData.grey100
//                           : AppThemeData.grey900,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             Divider(
//                 height: 1,
//                 color:
//                 isDark ? AppThemeData.grey700 : Colors.grey.shade200),
//
//             // ── Day chips ────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Select Days'.tr,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontFamily: AppThemeData.semiBold,
//                       color: isDark
//                           ? AppThemeData.grey400
//                           : AppThemeData.grey600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 6,
//                     runSpacing: 6,
//                     children: _days.map((d) {
//                       final on = _selectedDays.contains(d);
//                       return _DayChip(
//                         day: d,
//                         selected: on,
//                         isDark: isDark,
//                         onToggle: (v) => _toggleDay(d, v),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//
//             Divider(
//                 height: 1,
//                 indent: 16,
//                 endIndent: 16,
//                 color:
//                 isDark ? AppThemeData.grey700 : Colors.grey.shade200),
//
//             // ── Time slots per day — scrollable ──────────────────────
//             Expanded(
//               child: _selectedDays.isEmpty
//                   ? Center(
//                 child: Text(
//                   'Select days above to set hours'.tr,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: isDark
//                         ? AppThemeData.grey500
//                         : AppThemeData.grey400,
//                     fontFamily: AppThemeData.regular,
//                   ),
//                 ),
//               )
//                   : ListView.separated(
//                 // FIX: use the controller so DraggableScrollableSheet
//                 // and keyboard don't fight each other
//                 controller: scrollController,
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                 itemCount: _selectedDays.length,
//                 separatorBuilder: (_, __) =>
//                 const SizedBox(height: 12),
//                 itemBuilder: (_, i) {
//                   final day = _selectedDays[i];
//                   final slots = _timings[day] ??
//                       [TimeRangeItem(from: '09:00', to: '22:00')];
//                   return _DayTimeSection(
//                     day: day,
//                     slots: slots,
//                     isDark: isDark,
//                     onSlotsChanged: (updated) {
//                       setState(() => _timings[day] = updated);
//                     },
//                   );
//                 },
//               ),
//             ),
//
//             // ── Done button ──────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//               child: SafeArea(
//                 // bottom: false so we don't double-add safe area since
//                 // we already handle keyboard insets above
//                 bottom: false,
//                 child: RoundedButtonFill(
//                   title: 'Done'.tr,
//                   color: ColorConst.orange,
//                   width: 50,
//                   height: 5,
//                   textColor: AppThemeData.grey50,
//                   onPress: () => widget.onDone(_selectedDays, _timings),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Single styled day chip replacing FilterChip for better dark-mode control
// class _DayChip extends StatelessWidget {
//   const _DayChip({
//     required this.day,
//     required this.selected,
//     required this.isDark,
//     required this.onToggle,
//   });
//   final String day;
//   final bool selected;
//   final bool isDark;
//   final ValueChanged<bool> onToggle;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => onToggle(!selected),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 160),
//         padding:
//         const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//         decoration: BoxDecoration(
//           color: selected
//               ? ColorConst.orange
//               : (isDark ? AppThemeData.grey700 : AppThemeData.grey100),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: selected
//                 ? ColorConst.orange
//                 : (isDark
//                 ? AppThemeData.grey600
//                 : Colors.grey.shade300),
//           ),
//         ),
//         child: Text(
//           day.substring(0, 3),
//           style: TextStyle(
//             fontSize: 12,
//             fontFamily: AppThemeData.semiBold,
//             color: selected
//                 ? Colors.white
//                 : (isDark ? AppThemeData.grey300 : AppThemeData.grey600),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Time section for one day: shows all time slots
// class _DayTimeSection extends StatelessWidget {
//   const _DayTimeSection({
//     required this.day,
//     required this.slots,
//     required this.isDark,
//     required this.onSlotsChanged,
//   });
//   final String day;
//   final List<TimeRangeItem> slots;
//   final bool isDark;
//   final ValueChanged<List<TimeRangeItem>> onSlotsChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isDark ? AppThemeData.grey700 : AppThemeData.grey50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark ? AppThemeData.grey600 : Colors.grey.shade200,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Day label + add slot button
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: ColorConst.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   day,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontFamily: AppThemeData.semiBold,
//                     color: ColorConst.orange,
//                   ),
//                 ),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () {
//                   final updated = List<TimeRangeItem>.from(slots)
//                     ..add(TimeRangeItem(from: '09:00', to: '22:00'));
//                   onSlotsChanged(updated);
//                 },
//                 child: Row(
//                   children: [
//                     Icon(Icons.add_circle_outline,
//                         size: 16, color: ColorConst.orange),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Add slot'.tr,
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: ColorConst.orange,
//                         fontFamily: AppThemeData.medium,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           // Slots
//           ...slots.asMap().entries.map((e) {
//             final idx = e.key;
//             final slot = e.value;
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Row(
//                 children: [
//                   // From
//                   Expanded(
//                     child: _TimeField(
//                       label: 'From'.tr,
//                       initial: slot.from,
//                       isDark: isDark,
//                       onChanged: (v) {
//                         final updated = List<TimeRangeItem>.from(slots);
//                         updated[idx] =
//                             TimeRangeItem(from: v, to: slot.to);
//                         onSlotsChanged(updated);
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 6),
//                     child: Icon(Icons.arrow_forward,
//                         size: 14,
//                         color: isDark
//                             ? AppThemeData.grey500
//                             : AppThemeData.grey400),
//                   ),
//                   // To
//                   Expanded(
//                     child: _TimeField(
//                       label: 'To'.tr,
//                       initial: slot.to,
//                       isDark: isDark,
//                       onChanged: (v) {
//                         final updated = List<TimeRangeItem>.from(slots);
//                         updated[idx] =
//                             TimeRangeItem(from: slot.from, to: v);
//                         onSlotsChanged(updated);
//                       },
//                     ),
//                   ),
//                   // Remove slot (only if more than one)
//                   if (slots.length > 1) ...[
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: () {
//                         final updated = List<TimeRangeItem>.from(slots)
//                           ..removeAt(idx);
//                         onSlotsChanged(updated);
//                       },
//                       child: Icon(Icons.remove_circle_outline,
//                           size: 18,
//                           color: isDark
//                               ? AppThemeData.grey500
//                               : Colors.grey.shade400),
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// class _TimeField extends StatelessWidget {
//   const _TimeField({
//     required this.label,
//     required this.initial,
//     required this.isDark,
//     required this.onChanged,
//   });
//   final String label;
//   final String initial;
//   final bool isDark;
//   final ValueChanged<String> onChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       initialValue: initial,
//       keyboardType: TextInputType.datetime,
//       style: TextStyle(
//         fontSize: 13,
//         fontFamily: AppThemeData.medium,
//         color: isDark ? AppThemeData.grey100 : AppThemeData.grey900,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(
//           fontSize: 11,
//           color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
//         ),
//         isDense: true,
//         contentPadding:
//         const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         filled: true,
//         fillColor: isDark ? AppThemeData.grey800 : Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(
//               color:
//               isDark ? AppThemeData.grey600 : Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(
//               color:
//               isDark ? AppThemeData.grey600 : Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide:
//           BorderSide(color: ColorConst.orange, width: 1.5),
//         ),
//       ),
//       onChanged: onChanged,
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Shared sheet handle
// // ─────────────────────────────────────────────────────────────────────────────
// class _SheetHandle extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         width: 36,
//         height: 4,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(2),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:provider/provider.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/add_from_catalog_controller.dart';
import 'package:jippymart_restaurant/models/master_product_model.dart';
import 'package:jippymart_restaurant/models/selected_product_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import 'package:dropdown_search/dropdown_search.dart';
//import 'package:jippymart_restaurant/lib/app/product_screens/add_masterproduct_screen.dart';
//import 'package:jippymart_restaurent_java/app/product_screens/add_masterproduct_screen.dart';
import 'add_masterproduct_screen.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class AddFromCatalogScreen extends StatelessWidget {
  const AddFromCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey900 : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: ColorConst.orange,
        elevation: 0,
        title: Text(
          'Add from Catalog'.tr,
          style: const TextStyle(
            color: AppThemeData.grey50,
            fontSize: 18,
            fontFamily: AppThemeData.semiBold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                _showCreateCategoryDialog(context);
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Category'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: AppThemeData.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: AppThemeData.grey50),
      ),
      body: const _CategorySelectionStep(),

    );
  }
}
void _showCreateCategoryDialog(BuildContext context) {
  final TextEditingController categoryController =
  TextEditingController();
  final TextEditingController imageController =
  TextEditingController();

  final controller =
  Get.find<AddFromCatalogController>();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: ColorConst.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child:  Icon(
                Icons.category_outlined,
                color: ColorConst.orange,
                size: 32,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Create Category",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Add a new category for your products",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                hintText: "e.g. Biryani Specials",
                prefixIcon:  Icon(
                  Icons.local_offer_outlined,
                  color: ColorConst.orange,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide:  BorderSide(
                    color: ColorConst.orange,
                    width: 2,
                  ),
                ),
              ),
            ),
            TextField(
              controller: imageController,
              decoration: InputDecoration(
                hintText: "Category Image URL",
                prefixIcon: Icon(
                  Icons.image_outlined,
                  color: ColorConst.orange,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize:
                      const Size.fromHeight(48),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final categoryName = categoryController.text.trim();

                      final categoryImageUrl = imageController.text.trim();
                     final Outletid= Preferences.getInt("outletId");

                      if (categoryName.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please enter category name",
                        );
                        return;
                      }

                      final success = await FireStoreUtils.createCategory(
                        categoryName: categoryName,
                        categoryType: "ALL",
                        categoryImageUrl: categoryImageUrl,
                        createdBy:Outletid // Replace with the logged-in user's ID if available
                      );

                      if (success) {

                        FireStoreUtils
                            .clearVendorCategoriesCache();

                        await controller
                            .loadCategories();

                        Get.back();

                        Get.snackbar(
                          "Success",
                          "Category created successfully",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      ColorConst.orange,
                      minimumSize:
                      const Size.fromHeight(48),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Create",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Step 1 – pick a category on a clean, simple screen.
class _CategorySelectionStep extends StatelessWidget {
  const _CategorySelectionStep();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.getThem();

    return GetX<AddFromCatalogController>(
      init: AddFromCatalogController(),
      builder: (c) {
        if (c.isLoading.value) return Constant.loader();

        if (c.categoryList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No categories found.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppThemeData.grey300
                      : AppThemeData.grey600,
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a category'.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 16,
                  color:
                      isDark ? AppThemeData.grey100 : AppThemeData.grey900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We’ll show products from the category you pick.'
                    .tr,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? AppThemeData.grey400 : AppThemeData.grey600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: c.categoryList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final cat = c.categoryList[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Remember the chosen category, then open the
                        // products screen. When products screen finishes
                        // with result == true, bubble that up so the
                        // product list screen can refresh.
                        c.selectCategory(cat);
                        Get.to(() => const AddFromCatalogProductScreen())
                            ?.then((v) {
                          if (v == true) {
                            Get.back(result: true);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppThemeData.grey800
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorConst.orange
                                    .withOpacity(0.12),
                              ),
                              child:  Icon(
                                Icons.category_rounded,
                                size: 18,
                                color: ColorConst.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.title ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily:
                                          AppThemeData.semiBold,
                                      fontSize: 14,
                                      color: isDark
                                          ? AppThemeData.grey100
                                          : AppThemeData.grey900,
                                    ),
                                  ),
                                  if ((cat.description ?? '')
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      cat.description!,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppThemeData.grey400,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────
class AddFromCatalogBody extends StatelessWidget {
  const AddFromCatalogBody({
    super.key,
    this.initialCategory,
    this.themeOverride,
  });

  /// If provided, products for this category are loaded directly (step 2).
  /// If null, controller will behave like the old flow and can be used
  /// from existing screens that just call `const AddFromCatalogBody()`.
  final VendorCategoryModel? initialCategory;

  /// Optional theme override for cases where a parent already has it.
  final DarkThemeProvider? themeOverride;

  @override
  Widget build(BuildContext context) {
    final theme =
        themeOverride ?? Provider.of<DarkThemeProvider>(context);

    final bool hasExistingController =
        Get.isRegistered<AddFromCatalogController>();

    return GetX<AddFromCatalogController>(
      // When we come from the category step we already have a controller,
      // so don't create a new one or we lose selectedProducts.
      init: initialCategory != null
          ? AddFromCatalogController(initialCategory: initialCategory)
          : (hasExistingController ? null : AddFromCatalogController()),
      builder: (c) {
        if ((c.isLoading.value || c.isLoadingProducts.value) &&
            c.masterProducts.isEmpty) {
          return Constant.loader();
        }

        return Column(
          children: [
            _FilterPanel(ctrl: c, theme: theme),
            Expanded(child: _ProductSection(ctrl: c, theme: theme)),
            if (!c.isLoadingProducts.value && c.lastPage.value > 1)
              _Pagination(ctrl: c, theme: theme),
            _BottomBar(ctrl: c, theme: theme),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter panel
// Selecting a category auto-loads products. "Load All" removed.
// Only a search field + icon button remains after category is chosen.
// ─────────────────────────────────────────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.ctrl, required this.theme});
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.getThem();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ctrl.selectedCategory.value?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 14,
                    color: isDark
                        ? AppThemeData.grey100
                        : AppThemeData.grey900,
                  ),
                ),
              ),
              Text(
                '${ctrl.totalProducts.value} items'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppThemeData.grey400
                      : AppThemeData.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFieldWidget(
                  title: 'Search'.tr,
                  hintText: 'Product name...'.tr,
                  onchange: ctrl.setSearch,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: ctrl.searchProducts,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: ColorConst.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product section
// ─────────────────────────────────────────────────────────────────────────────
class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.ctrl, required this.theme});
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    if (ctrl.selectedCategory.value == null) {
      return _EmptyHint(
        icon: Icons.category_outlined,
        message: 'Select a category to browse products'.tr,
        theme: theme,
      );
    }
    if (ctrl.isLoadingProducts.value) return Constant.loader();
    if (ctrl.masterProducts.isEmpty) {
      return _EmptyHint(
        icon: Icons.inventory_2_outlined,
        message: 'No products in this category'.tr,
        theme: theme,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      itemCount: ctrl.masterProducts.length,
      itemBuilder: (_, i) => _ProductCard(
        product: ctrl.masterProducts[i],
        ctrl: ctrl,
        theme: theme,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(
      {required this.icon, required this.message, required this.theme});
  final IconData icon;
  final String message;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.getThem();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 48,
              color: isDark ? AppThemeData.grey500 : AppThemeData.grey400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
              fontFamily: AppThemeData.regular,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product card
// ─────────────────────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.ctrl,
    required this.theme,
  });

  final MasterProductModel product;
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final id = product.id ?? '';
      final isSelected = ctrl.isSelected(id);
      final sel = ctrl.selectedProducts[id];
      final isDark = theme.getThem();

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: ColorConst.orange.withOpacity(0.5),
                  width: 1.5,
                )
              : Border.all(
                  color: isDark
                      ? AppThemeData.grey700
                      : Colors.grey.shade200,
                  width: 1,
                ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tappable header row ───────────────────────────────────────
            InkWell(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(14),
                bottom: isSelected ? Radius.zero : const Radius.circular(14),
              ),
              onTap: () => ctrl.toggleSelection(product),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CatalogImage(url: product.photo, isDark: isDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.isExisting == true)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A9E6E)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Already added'.tr,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF0A9E6E),
                                  fontFamily: AppThemeData.semiBold,
                                ),
                              ),
                            ),
                          Text(
                            product.name ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: AppThemeData.semiBold,
                              color: isDark
                                  ? AppThemeData.grey100
                                  : AppThemeData.grey900,
                            ),
                          ),
                          if (product.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              product.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppThemeData.grey400
                                    : AppThemeData.grey500,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Animated checkbox indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorConst.orange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? ColorConst.orange
                              : (isDark
                                  ? AppThemeData.grey500
                                  : AppThemeData.grey300),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            // ── Detail form shown when selected ───────────────────────────
            if (isSelected && sel != null)
              _SelectedProductForm(
                id: id,
                sel: sel,
                ctrl: ctrl,
                theme: theme,
                context: context,
              ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Catalog image
// ─────────────────────────────────────────────────────────────────────────────
class _CatalogImage extends StatelessWidget {
  const _CatalogImage({required this.url, required this.isDark});
  final String? url;
  final bool isDark;

  bool get _hasImage {
    final u = url?.trim() ?? '';
    return u.isNotEmpty && u != 'null';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: _hasImage
          ? NetworkImageWidget(
        imageUrl: url!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      )
          : Container(
        width: 72,
        height: 72,
        color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood_rounded,
                size: 26,
                color: isDark
                    ? AppThemeData.grey500
                    : AppThemeData.grey400),
            const SizedBox(height: 2),
            Text(
              'No Image',
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? AppThemeData.grey500
                    : AppThemeData.grey400,
                fontFamily: AppThemeData.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selected product form
// • Price field
// • Publish / Available as CupertinoSwitch rows
// • Options shown inline (no bottom sheet button)
// • Availability button (opens sheet unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class _SelectedProductForm extends StatelessWidget {
  const _SelectedProductForm({
    required this.id,
    required this.sel,
    required this.ctrl,
    required this.theme,
    required this.context,
  });

  final String id;
  final SelectedProductModel sel;
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final isDark = theme.getThem();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.grey700.withOpacity(0.45)
            : const Color(0xFFF9FAFB),
        borderRadius:
        const BorderRadius.vertical(bottom: Radius.circular(14)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppThemeData.grey600 : Colors.grey.shade200,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Price ──────────────────────────────────────────────────
          _PriceField(
            label: 'Your price'.tr,
            value: sel.merchantPrice,
            isDark: isDark,
            onChanged: (v) => ctrl.updateMerchantPrice(id, v),
          ),

          const SizedBox(height: 14),

          // ── Publish toggle ─────────────────────────────────────────
          _SwitchRow(
            label: 'Publish'.tr,
            subtitle: 'Show this product to customers'.tr,
            value: sel.publish,
            activeColor: const Color(0xFF0A9E6E),
            isDark: isDark,
            onChanged: (v) => ctrl.setPublish(id, v),
          ),
          const SizedBox(height: 10),

          // ── Available toggle ───────────────────────────────────────
          _SwitchRow(
            label: 'Available'.tr,
            subtitle: 'Mark as available for ordering'.tr,
            value: sel.isAvailable,
            activeColor: ColorConst.orange,
            isDark: isDark,
            onChanged: (v) => ctrl.setAvailable(id, v),
          ),

          // ── Inline options (no button — always visible when exist) ─
          if (sel.options.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InlineOptionsSection(
              id: id,
              options: sel.options,
              isDark: isDark,
              ctrl: ctrl,
            ),
          ],

          // ── Availability button (opens sheet) ──────────────────────
          const SizedBox(height: 12),
          _AvailabilityButton(
            availableDays: sel.availableDays,
            isDark: isDark,
            onTap: () =>
                _showAvailabilitySheet(context, ctrl, id, sel, theme),
          ),

          // ── Add-on count badge ─────────────────────────────────────
          if (sel.addons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey600 : AppThemeData.grey200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${sel.addons.length} add-on(s)'.tr,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppThemeData.grey300
                      : AppThemeData.grey600,
                  fontFamily: AppThemeData.regular,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Switch row — replaces ToggleChip; cleaner for publish/available
// ─────────────────────────────────────────────────────────────────────────────
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.isDark,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: AppThemeData.semiBold,
                  color: isDark ? AppThemeData.grey200 : AppThemeData.grey800,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: AppThemeData.regular,
                  color: isDark ? AppThemeData.grey500 : AppThemeData.grey500,
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline options section
// Saves in format:
//   [{"id":"opt_xxx","title":"...","subtitle":"...","price":"329",
//     "original_price":"329","is_available":true,"is_featured":false}]
// ─────────────────────────────────────────────────────────────────────────────
class _InlineOptionsSection extends StatelessWidget {
  const _InlineOptionsSection({
    required this.id,
    required this.options,
    required this.isDark,
    required this.ctrl,
  });
  final String id;
  final List<OptionItem> options;
  final bool isDark;
  final AddFromCatalogController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            Icon(Icons.tune_rounded,
                size: 14,
                color: isDark ? AppThemeData.grey400 : AppThemeData.grey600),
            const SizedBox(width: 5),
            Text(
              'Options'.tr,
              style: TextStyle(
                fontSize: 12,
                fontFamily: AppThemeData.semiBold,
                color: isDark ? AppThemeData.grey400 : AppThemeData.grey600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ColorConst.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${options.length}',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: AppThemeData.semiBold,
                  color: ColorConst.orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // One row per option
        ...options.asMap().entries.map((e) {
          final i = e.key;
          final o = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _InlineOptionRow(
              option: o,
              isDark: isDark,
              onPriceChanged: (v) {
                final updated = List<OptionItem>.from(options);
                updated[i] = OptionItem(
                  id: o.id,
                  title: o.title,
                  subtitle: o.subtitle,
                  // User-entered value is treated as the original/MRP price
                  price: v,
                  originalPrice: v,
                  isAvailable: o.isAvailable,
                  isFeatured: o.isFeatured,
                );
                ctrl.setOptions(id, updated);
              },
              onAvailableChanged: (v) {
                final updated = List<OptionItem>.from(options);
                updated[i] = OptionItem(
                  id: o.id,
                  title: o.title,
                  subtitle: o.subtitle,
                  price: o.price,
                  originalPrice: o.originalPrice,
                  isAvailable: v ?? true,
                  isFeatured: o.isFeatured,
                );
                ctrl.setOptions(id, updated);
              },
            ),
          );
        }),
      ],
    );
  }
}

class _InlineOptionRow extends StatelessWidget {
  const _InlineOptionRow({
    required this.option,
    required this.isDark,
    required this.onPriceChanged,
    required this.onAvailableChanged,
  });
  final OptionItem option;
  final bool isDark;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<bool?> onAvailableChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey700 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppThemeData.grey600 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Name + subtitle + original price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: TextStyle(
                    fontFamily: AppThemeData.medium,
                    fontSize: 13,
                    color: isDark
                        ? AppThemeData.grey100
                        : AppThemeData.grey800,
                  ),
                ),
                if ((option.subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    option.subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppThemeData.grey400
                          : AppThemeData.grey500,
                      fontFamily: AppThemeData.regular,
                    ),
                  ),
                ],
                if ((option.originalPrice ?? '').isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    'MRP: ₹${option.originalPrice}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppThemeData.grey500
                          : AppThemeData.grey400,
                      fontFamily: AppThemeData.regular,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Editable price field
          SizedBox(
            width: 78,
            child: TextFormField(
              key: ValueKey('opt-${option.id}'),
              initialValue: option.price,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppThemeData.semiBold,
                color: isDark ? AppThemeData.grey100 : AppThemeData.grey900,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: '0',
                prefixText: '₹',
                prefixStyle: TextStyle(
                  fontSize: 12,
                  fontFamily: AppThemeData.semiBold,
                  color:
                  isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                filled: true,
                fillColor:
                isDark ? AppThemeData.grey800 : AppThemeData.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppThemeData.grey600
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppThemeData.grey600
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  BorderSide(color: ColorConst.orange, width: 1.5),
                ),
              ),
              onChanged: onPriceChanged,
            ),
          ),
          const SizedBox(width: 4),

          // Available toggle (compact)
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: option.isAvailable,
              onChanged: onAvailableChanged,
              activeColor: ColorConst.orange,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Availability button — shows day count or prompt, opens sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AvailabilityButton extends StatelessWidget {
  const _AvailabilityButton({
    required this.availableDays,
    required this.isDark,
    required this.onTap,
  });
  final List<String> availableDays;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasData = availableDays.isNotEmpty;
    final label = hasData
        ? '${availableDays.length} day(s) set'.tr
        : 'Set Availability'.tr;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: hasData
              ? ColorConst.orange.withOpacity(0.08)
              : (isDark ? AppThemeData.grey700 : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasData
                ? ColorConst.orange.withOpacity(0.4)
                : (isDark ? AppThemeData.grey600 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded,
                size: 15,
                color: hasData
                    ? ColorConst.orange
                    : (isDark ? AppThemeData.grey400 : AppThemeData.grey600)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: AppThemeData.medium,
                color: hasData
                    ? ColorConst.orange
                    : (isDark ? AppThemeData.grey400 : AppThemeData.grey600),
              ),
            ),
            if (hasData) ...[
              const SizedBox(width: 6),
              Icon(Icons.edit_outlined,
                  size: 12, color: ColorConst.orange.withOpacity(0.7)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price field
// ─────────────────────────────────────────────────────────────────────────────
class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });
  final String label;
  final double value;
  final bool isDark;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontFamily: AppThemeData.semiBold,
            color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          // Stable key per field so focus is preserved while typing
          key: ValueKey(label),
          initialValue: value.toStringAsFixed(2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
          ],
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppThemeData.semiBold,
            color: isDark ? AppThemeData.grey100 : AppThemeData.grey900,
          ),
          decoration: InputDecoration(
            isDense: true,
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              fontSize: 13,
              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: isDark ? AppThemeData.grey700 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color:
                  isDark ? AppThemeData.grey600 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color:
                  isDark ? AppThemeData.grey600 : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorConst.orange, width: 1.5),
            ),
          ),
          // Update the controller live as the user types; thanks to
          // the stable key, focus is not lost on rebuild.
          onChanged: (t) {
            final v = double.tryParse(t);
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pagination
// ─────────────────────────────────────────────────────────────────────────────
class _Pagination extends StatelessWidget {
  const _Pagination({required this.ctrl, required this.theme});
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.getThem();
    final cur = ctrl.currentPage.value;
    final last = ctrl.lastPage.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? AppThemeData.grey900 : const Color(0xFFF5F6FA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageArrow(
            icon: Icons.chevron_left,
            enabled: cur > 1,
            isDark: isDark,
            onTap: () => ctrl.goToPage(cur - 1),
          ),
          const SizedBox(width: 12),
          Text(
            '$cur / $last',
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: 13,
              color: isDark ? AppThemeData.grey200 : AppThemeData.grey800,
            ),
          ),
          const SizedBox(width: 12),
          _PageArrow(
            icon: Icons.chevron_right,
            enabled: cur < last,
            isDark: isDark,
            onTap: () => ctrl.goToPage(cur + 1),
          ),
        ],
      ),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled
              ? ColorConst.orange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled
              ? ColorConst.orange
              : (isDark ? AppThemeData.grey600 : AppThemeData.grey300),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom save bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.ctrl, required this.theme});
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.getThem();

    return Obx(() {
      final count = ctrl.selectedProducts.length;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: SafeArea(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: count > 0
                      ? ColorConst.orange.withOpacity(0.12)
                      : (isDark
                          ? AppThemeData.grey700
                          : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 0 ? '$count selected'.tr : 'None selected'.tr,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 13,
                    color: count > 0
                        ? ColorConst.orange
                        : (isDark
                            ? AppThemeData.grey400
                            : AppThemeData.grey500),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RoundedButtonFill(
                  title: 'Save'.tr,
                  color:
                      count > 0 ? ColorConst.orange : Colors.grey.shade400,
                  width: 60,
                  height: 5.5,
                  textColor: AppThemeData.grey50,
                  onPress: () async {
                    if (count == 0) return;
                    final err = ctrl.validateForSave();
                    if (err != null) {
                      ShowToastDialog.showToast(err);
                      return;
                    }
                    ShowToastDialog.showLoader('Saving...'.tr);
                    final ok = await ctrl.saveAndCaptureResponse();
                    ShowToastDialog.closeLoader();
                    if (ok) {
                      ShowToastDialog.showToast(
                          ctrl.lastStoreResponse?.message ??
                              'Successfully imported.'.tr);
                      Get.back(result: true);
                    } else {
                      final msg = ctrl.lastStoreResponse?.message ??
                          'Save failed.'.tr;
                      final errors = ctrl.lastStoreResponse?.errors;
                      String display = msg;
                      if (errors != null && errors.isNotEmpty) {
                        final first = errors.entries.first;
                        display = first.value is List
                            ? (first.value as List).join(' ')
                            : first.value.toString();
                      }
                      ShowToastDialog.showToast(display);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Availability bottom sheet (keyboard-safe, unchanged logic)
// Saved format: [{"day":"Monday","timeslot":[{"from":"11:00","to":"22:00"}]}]
// ─────────────────────────────────────────────────────────────────────────────
void _showAvailabilitySheet(
    BuildContext context,
    AddFromCatalogController c,
    String masterId,
    SelectedProductModel sel,
    DarkThemeProvider theme,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AvailabilitySheetContent(
      sel: sel,
      theme: theme,
      onDone: (days, timings) {
        c.setAvailableDays(masterId, days);
        c.setAvailableTimings(masterId, timings);
        Navigator.of(ctx).pop();
      },
    ),
  );
}

class _AvailabilitySheetContent extends StatefulWidget {
  const _AvailabilitySheetContent({
    required this.sel,
    required this.theme,
    required this.onDone,
  });
  final SelectedProductModel sel;
  final DarkThemeProvider theme;
  final void Function(
      List<String> days,
      Map<String, List<TimeRangeItem>> timings) onDone;

  @override
  State<_AvailabilitySheetContent> createState() =>
      _AvailabilitySheetContentState();
}

class _AvailabilitySheetContentState
    extends State<_AvailabilitySheetContent> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late List<String> _selectedDays;
  late Map<String, List<TimeRangeItem>> _timings;

  @override
  void initState() {
    super.initState();
    _selectedDays = List<String>.from(widget.sel.availableDays);
    _timings = {
      for (final e in widget.sel.availableTimings.entries)
        e.key: List.from(e.value),
    };
  }

  void _toggleDay(String day, bool selected) {
    setState(() {
      if (selected) {
        _selectedDays.add(day);
        if (!_timings.containsKey(day)) {
          _timings[day] = [TimeRangeItem(from: '09:00', to: '22:00')];
        }
      } else {
        _selectedDays.remove(day);
        _timings.remove(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.getThem();
    final bg = isDark ? AppThemeData.grey800 : Colors.white;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConst.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.schedule_rounded,
                        size: 18, color: ColorConst.orange),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Available Days & Times'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppThemeData.bold,
                      color: isDark
                          ? AppThemeData.grey100
                          : AppThemeData.grey900,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: isDark
                    ? AppThemeData.grey700
                    : Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Days'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppThemeData.semiBold,
                      color: isDark
                          ? AppThemeData.grey400
                          : AppThemeData.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _days.map((d) {
                      final on = _selectedDays.contains(d);
                      return _DayChip(
                        day: d,
                        selected: on,
                        isDark: isDark,
                        onToggle: (v) => _toggleDay(d, v),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: isDark
                    ? AppThemeData.grey700
                    : Colors.grey.shade200),
            Expanded(
              child: _selectedDays.isEmpty
                  ? Center(
                child: Text(
                  'Select days above to set hours'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppThemeData.grey500
                        : AppThemeData.grey400,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
              )
                  : ListView.separated(
                controller: scrollController,
                padding:
                const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: _selectedDays.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final day = _selectedDays[i];
                  final slots = _timings[day] ??
                      [
                        TimeRangeItem(from: '09:00', to: '22:00')
                      ];
                  return _DayTimeSection(
                    day: day,
                    slots: slots,
                    isDark: isDark,
                    onSlotsChanged: (updated) {
                      setState(() => _timings[day] = updated);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SafeArea(
                bottom: false,
                child: RoundedButtonFill(
                  title: 'Done'.tr,
                  color: ColorConst.orange,
                  width: 50,
                  height: 5,
                  textColor: AppThemeData.grey50,
                  onPress: () =>
                      widget.onDone(_selectedDays, _timings),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.isDark,
    required this.onToggle,
  });
  final String day;
  final bool selected;
  final bool isDark;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? ColorConst.orange
              : (isDark ? AppThemeData.grey700 : AppThemeData.grey100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? ColorConst.orange
                : (isDark ? AppThemeData.grey600 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          day.substring(0, 3),
          style: TextStyle(
            fontSize: 12,
            fontFamily: AppThemeData.semiBold,
            color: selected
                ? Colors.white
                : (isDark ? AppThemeData.grey300 : AppThemeData.grey600),
          ),
        ),
      ),
    );
  }
}

class _DayTimeSection extends StatelessWidget {
  const _DayTimeSection({
    required this.day,
    required this.slots,
    required this.isDark,
    required this.onSlotsChanged,
  });
  final String day;
  final List<TimeRangeItem> slots;
  final bool isDark;
  final ValueChanged<List<TimeRangeItem>> onSlotsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey700 : AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey600 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConst.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppThemeData.semiBold,
                    color: ColorConst.orange,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final updated = List<TimeRangeItem>.from(slots)
                    ..add(TimeRangeItem(from: '09:00', to: '22:00'));
                  onSlotsChanged(updated);
                },
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 16, color: ColorConst.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Add slot'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorConst.orange,
                        fontFamily: AppThemeData.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...slots.asMap().entries.map((e) {
            final idx = e.key;
            final slot = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'From'.tr,
                      initial: slot.from,
                      isDark: isDark,
                      onChanged: (v) {
                        final updated =
                        List<TimeRangeItem>.from(slots);
                        updated[idx] =
                            TimeRangeItem(from: v, to: slot.to);
                        onSlotsChanged(updated);
                      },
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward,
                        size: 14,
                        color: isDark
                            ? AppThemeData.grey500
                            : AppThemeData.grey400),
                  ),
                  Expanded(
                    child: _TimeField(
                      label: 'To'.tr,
                      initial: slot.to,
                      isDark: isDark,
                      onChanged: (v) {
                        final updated =
                        List<TimeRangeItem>.from(slots);
                        updated[idx] =
                            TimeRangeItem(from: slot.from, to: v);
                        onSlotsChanged(updated);
                      },
                    ),
                  ),
                  if (slots.length > 1) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        final updated =
                        List<TimeRangeItem>.from(slots)
                          ..removeAt(idx);
                        onSlotsChanged(updated);
                      },
                      child: Icon(Icons.remove_circle_outline,
                          size: 18,
                          color: isDark
                              ? AppThemeData.grey500
                              : Colors.grey.shade400),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.initial,
    required this.isDark,
    required this.onChanged,
  });
  final String label;
  final String initial;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      keyboardType: TextInputType.datetime,
      style: TextStyle(
        fontSize: 13,
        fontFamily: AppThemeData.medium,
        color: isDark ? AppThemeData.grey100 : AppThemeData.grey900,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 11,
          color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
        ),
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: isDark ? AppThemeData.grey800 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color:
              isDark ? AppThemeData.grey600 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color:
              isDark ? AppThemeData.grey600 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
          BorderSide(color: ColorConst.orange, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sheet handle
// ─────────────────────────────────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}