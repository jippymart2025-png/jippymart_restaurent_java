// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// import 'package:jippymart_restaurant/models/outlet_details_model.dart';
// import 'package:jippymart_restaurant/models/product_model.dart';
// import 'package:jippymart_restaurant/themes/app_them_data.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/utils/network_image_widget.dart';
// import 'package:jippymart_restaurant/utils/preferences.dart';
//
// class EditProductScreen extends StatefulWidget {
//   final ProductModel? product;
//
//   const EditProductScreen({super.key, this.product});
//
//   @override
//   State<EditProductScreen> createState() => _EditProductScreenState();
// }
//
// class _EditProductScreenState extends State<EditProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   late final TextEditingController _nameCtrl;
//   late final TextEditingController _descCtrl;
//   late final TextEditingController _shortDescCtrl;
//   late final TextEditingController _categoryNameCtrl;
//   late final TextEditingController _subCategoryNameCtrl;
//   late final TextEditingController _cuisineTypeCtrl;
//   late final TextEditingController _merchantPriceCtrl;
//   late final TextEditingController _priceCtrl;
//   late final TextEditingController _caloriesCtrl;
//   late final TextEditingController _proteinCtrl;
//   late final TextEditingController _fatsCtrl;
//   late final TextEditingController _carbsCtrl;
//   late final TextEditingController _gramsCtrl;
//
//   String _foodType = 'Veg';
//   bool _publish = true;
//   bool _hasOptions = false;
//
//   List<_OptionItem> _options = [];
//   List<dynamic> _images = [];
//
//   bool _isSaving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     final p = widget.product;
//
//     _nameCtrl = TextEditingController(text: p?.name ?? '');
//     _descCtrl = TextEditingController(text: p?.description ?? '');
//     _shortDescCtrl = TextEditingController();
//     _categoryNameCtrl = TextEditingController();
//     _subCategoryNameCtrl = TextEditingController();
//     _cuisineTypeCtrl = TextEditingController();
//     _merchantPriceCtrl =
//         TextEditingController(text: p?.merchant_price ?? p?.price ?? '0');
//     _priceCtrl = TextEditingController(text: p?.price ?? p?.merchant_price ?? '0');
//     _caloriesCtrl = TextEditingController(text: '${p?.calories ?? 0}');
//     _proteinCtrl = TextEditingController(text: '${p?.proteins ?? 0}');
//     _fatsCtrl = TextEditingController(text: '${p?.fats ?? 0}');
//     _carbsCtrl = TextEditingController(text: '0');
//     _gramsCtrl = TextEditingController(text: '${p?.grams ?? 0}');
//
//     _foodType = (p?.nonveg == true) ? 'Non Veg' : 'Veg';
//     _publish = p?.isAvailable ?? p?.publish ?? true;
//
//     if (p?.photos != null && p!.photos!.isNotEmpty) {
//       _images = List.from(p.photos!);
//     } else if (p?.photo != null && p!.photo!.isNotEmpty) {
//       _images = [p.photo!];
//     }
//
//     if (p?.itemAttribute?.variants != null &&
//         p!.itemAttribute!.variants!.isNotEmpty) {
//       _hasOptions = true;
//       _options = p.itemAttribute!.variants!
//           .map((v) => _OptionItem(
//                 variantId: int.tryParse(v.variantId ?? ''),
//                 nameCtrl: TextEditingController(text: v.variantSku ?? ''),
//                 merchantPriceCtrl: TextEditingController(
//                   text: v.variantMerchantPrice ?? v.variantPrice ?? '0',
//                 ),
//                 priceCtrl: TextEditingController(text: v.variantPrice ?? '0'),
//               ))
//           .toList();
//     }
//
//     if (p?.categoryID != null) {
//       _categoryNameCtrl.text = p!.categoryID!;
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _descCtrl.dispose();
//     _shortDescCtrl.dispose();
//     _categoryNameCtrl.dispose();
//     _subCategoryNameCtrl.dispose();
//     _cuisineTypeCtrl.dispose();
//     _merchantPriceCtrl.dispose();
//     _priceCtrl.dispose();
//     _caloriesCtrl.dispose();
//     _proteinCtrl.dispose();
//     _fatsCtrl.dispose();
//     _carbsCtrl.dispose();
//     _gramsCtrl.dispose();
//     for (final o in _options) {
//       o.nameCtrl.dispose();
//       o.merchantPriceCtrl.dispose();
//       o.priceCtrl.dispose();
//     }
//     super.dispose();
//   }
//
//   bool get _isOutletEdit {
//     final loginType = Preferences.getString('loginType').trim().toUpperCase();
//     if (loginType != 'MERCHANT' && loginType != 'OUTLET') return false;
//     return FireStoreUtils.resolveActiveOutletId() > 0;
//   }
//
//   Future<void> _saveProduct() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final productId = int.tryParse(widget.product?.id ?? '0') ?? 0;
//     if (productId <= 0) {
//       ShowToastDialog.showToast('Invalid product ID');
//       return;
//     }
//
//     setState(() => _isSaving = true);
//     ShowToastDialog.showLoader('Saving...');
//
//     final success =
//         _isOutletEdit ? await _saveOutletProduct(productId) : await _saveMasterProduct(productId);
//
//     ShowToastDialog.closeLoader();
//     setState(() => _isSaving = false);
//
//     if (success) {
//       ShowToastDialog.showToast('Product updated successfully');
//       Get.back(result: true);
//     } else {
//       ShowToastDialog.showToast('Failed to update product');
//     }
//   }
//
//   // Future<bool> _saveOutletProduct(int productId) async {
//   //   final existingDetails = await FireStoreUtils.fetchOutletDetailsModel();
//   //   final existingProduct = existingDetails?.findProductById(productId);
//   //
//   //   final variants = _hasOptions && _options.isNotEmpty
//   //       ? _options
//   //           .map(
//   //             (o) => OutletProductVariantModel(
//   //               variantId: o.variantId,
//   //               variantName: o.nameCtrl.text.trim(),
//   //               merchantPrice:
//   //                   num.tryParse(o.merchantPriceCtrl.text.trim()) ?? 0,
//   //               price: num.tryParse(o.priceCtrl.text.trim()) ?? 0,
//   //             ),
//   //           )
//   //           .toList()
//   //       : existingProduct?.variants ?? const <OutletProductVariantModel>[];
//   //
//   //   final updatedProduct = (existingProduct ??
//   //           OutletProductModel(productId: productId))
//   //       .copyWith(
//   //     productName: _nameCtrl.text.trim(),
//   //     description: _descCtrl.text.trim(),
//   //     merchantPrice: num.tryParse(_merchantPriceCtrl.text.trim()) ?? 0,
//   //     price: num.tryParse(_priceCtrl.text.trim()) ?? 0,
//   //     isVeg: _foodType == 'Veg',
//   //     hasProductVariants: _hasOptions,
//   //     isAvailable: _publish,
//   //     variants: variants,
//   //     productTimings: existingProduct?.productTimings ?? const [],
//   //   );
//   //
//   //   return FireStoreUtils.updateOutletProductItem(
//   //     productId: productId,
//   //     updatedProduct: updatedProduct,
//   //   );
//   // }
//
//   // Future<bool> _saveOutletProduct(int productId) async {
//   //   final result = await FireStoreUtils.getOutletProducts(
//   //     forceRefresh: true,
//   //   );
//   //
//   //   // Find the product and ensure it's cast to the correct model type if necessary
//   //   final existingProduct = result?.products.firstWhereOrNull(
//   //         (p) => p.id?.toString() == productId.toString(),
//   //   );
//   //
//   //   // Note: Adjust 'variants' and 'timings' based on what fields ProductModel actually has
//   //   final variants = _hasOptions && _options.isNotEmpty
//   //       ? _options
//   //       .map(
//   //         (o) => OutletProductVariantModel(
//   //       variantId: o.variantId,
//   //       variantName: o.nameCtrl.text.trim(),
//   //       merchantPrice:
//   //       num.tryParse(o.merchantPriceCtrl.text.trim()) ?? 0,
//   //       price:
//   //       num.tryParse(o.priceCtrl.text.trim()) ?? 0,
//   //     ),
//   //   )
//   //       .toList()
//   //       : const <OutletProductVariantModel>[];
//   //
//   //   // Build the updated product model using fields available in your ProductModel
//   //   final updatedProduct = OutletProductModel(
//   //     productId: productId,
//   //     productName: _nameCtrl.text.trim(),
//   //     description: _descCtrl.text.trim(),
//   //     merchantPrice: num.tryParse(_merchantPriceCtrl.text.trim()) ?? 0,
//   //     price: num.tryParse(_priceCtrl.text.trim()) ?? 0,
//   //     isVeg: _foodType == 'Veg',
//   //     hasProductVariants: _hasOptions,
//   //     isAvailable: _publish,
//   //     variants: variants,
//   //     productTimings: const [], // Use matching property name from your OutletProductModel
//   //   );
//   //
//   //   return FireStoreUtils.updateSingleOutletProductDetails(
//   //     productId: productId,
//   //     updatedProduct: updatedProduct,
//   //   );
//   // }
//   Future<bool> _saveOutletProduct(int productId) async {
//     final result = await FireStoreUtils.getOutletProducts(
//       forceRefresh: true,
//     );
//
//     final existingProduct = result?.products.firstWhereOrNull(
//           (p) => p.id?.toString() == productId.toString(),
//     );
//
//     final variants = _hasOptions && _options.isNotEmpty
//         ? _options
//         .map(
//           (o) => OutletProductVariantModel(
//         variantId: o.variantId,
//         variantName: o.nameCtrl.text.trim(),
//         merchantPrice:
//         num.tryParse(o.merchantPriceCtrl.text.trim()) ?? 0,
//         price: num.tryParse(o.priceCtrl.text.trim()) ?? 0,
//       ),
//     )
//         .toList()
//         : const <OutletProductVariantModel>[];
//
//     final updatedProduct = OutletProductModel(
//       productId: productId,
//       productName: _nameCtrl.text.trim(),
//       description: _descCtrl.text.trim(),
//       merchantPrice: num.tryParse(_merchantPriceCtrl.text.trim()) ?? 0,
//       price: num.tryParse(_priceCtrl.text.trim()) ?? 0,
//       isVeg: _foodType == 'Veg',
//       hasProductVariants: _hasOptions,
//       isAvailable: _publish,
//       variants: variants,
//       productTimings: const [],
//     );
//
//     return FireStoreUtils.updateSingleOutletProductDetails(
//       productId: productId,
//       updatedProduct: updatedProduct,
//       categoryId: /* your category id source, e.g. */ 0,
//       imageLink: /* your image URL source, e.g. */ '',
//       outletId: null,
//     );
//   }
//
//   Future<bool> _saveMasterProduct(int productId) async {
//     final optionsJson = _hasOptions && _options.isNotEmpty
//         ? jsonEncode(_options
//             .map((o) => {
//                   'name': o.nameCtrl.text.trim(),
//                   'price': double.tryParse(o.priceCtrl.text.trim()) ?? 0,
//                 })
//             .toList())
//         : null;
//
//     final payload = <String, dynamic>{
//       'masterProductName': _nameCtrl.text.trim(),
//       'description': _descCtrl.text.trim(),
//       'shortDescription': _shortDescCtrl.text.trim(),
//       'photo': _images.isNotEmpty ? _images.first.toString() : '',
//       'photos': _images.where((e) => e is String).join(','),
//       'thumbnail': _images.isNotEmpty ? _images.first.toString() : '',
//       'categoryId': int.tryParse(_categoryNameCtrl.text.trim()) ?? 0,
//       'categoryName': _categoryNameCtrl.text.trim(),
//       'subCategoryId': int.tryParse(_subCategoryNameCtrl.text.trim()) ?? 0,
//       'subCategoryName': _subCategoryNameCtrl.text.trim(),
//       'veg': _foodType == 'Veg' ? 1 : 0,
//       'nonVeg': _foodType == 'Non Veg' ? 1 : 0,
//       'foodType': _foodType,
//       'cuisineType': _cuisineTypeCtrl.text.trim(),
//       'hasOptions': _hasOptions ? 1 : 0,
//       'optionsEnabled': _hasOptions ? 1 : 0,
//       'options': optionsJson,
//       'calories': int.tryParse(_caloriesCtrl.text.trim()) ?? 0,
//       'protein': int.tryParse(_proteinCtrl.text.trim()) ?? 0,
//       'fats': int.tryParse(_fatsCtrl.text.trim()) ?? 0,
//       'carbs': int.tryParse(_carbsCtrl.text.trim()) ?? 0,
//       'grams': int.tryParse(_gramsCtrl.text.trim()) ?? 0,
//       'publish': _publish ? 1 : 0,
//       'updatedBy': 1,
//     };
//
//     final success =
//         await FireStoreUtils.updateMasterProduct(productId, payload);
//
//     return success;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: AppThemeData.secondary300,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Edit Product',
//           style: TextStyle(
//             fontFamily: AppThemeData.semiBold,
//             fontSize: 18,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 12),
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Center(
//               child: Text(
//                 'Editing',
//                 style: TextStyle(
//                   fontFamily: AppThemeData.medium,
//                   fontSize: 12,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//           child: SizedBox(
//             height: 50,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppThemeData.secondary300,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 0,
//               ),
//               onPressed: _isSaving ? null : _saveProduct,
//               child: const Text(
//                 'Save Details',
//                 style: TextStyle(
//                   fontFamily: AppThemeData.semiBold,
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             children: [
//               _buildSection(
//                 icon: Icons.image_outlined,
//                 title: 'Product Images',
//                 child: _buildImageSection(),
//               ),
//               const SizedBox(height: 14),
//               _buildSection(
//                 icon: Icons.info_outline_rounded,
//                 title: 'Basic Information',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildLabel('Product Title'),
//                     _buildTextField(_nameCtrl, 'Enter product name',
//                         validator: _required),
//                     const SizedBox(height: 14),
//                     _buildLabel('Category'),
//                     _buildTextField(_categoryNameCtrl, 'Category ID or name'),
//                     const SizedBox(height: 14),
//                     _buildLabel('Product Description'),
//                     _buildTextField(_descCtrl, 'Enter description',
//                         maxLines: 3),
//                     const SizedBox(height: 14),
//                     _buildLabel('Short Description'),
//                     _buildTextField(_shortDescCtrl, 'Brief one-line summary'),
//                     const SizedBox(height: 14),
//                     _buildLabel('Cuisine Type'),
//                     _buildTextField(_cuisineTypeCtrl, 'e.g. Hyderabadi'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 14),
//               _buildSection(
//                 icon: Icons.attach_money_rounded,
//                 title: 'Pricing & Stock',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildLabel('Food Type'),
//                     _buildDropdown(
//                       value: _foodType,
//                       items: const ['Veg', 'Non Veg'],
//                       onChanged: (v) => setState(() => _foodType = v!),
//                     ),
//                     const SizedBox(height: 14),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildLabeledPriceField(
//                             label: 'Merchant Price',
//                             controller: _merchantPriceCtrl,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _buildLabeledPriceField(
//                             label: 'Price',
//                             controller: _priceCtrl,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 14),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildLabel('Available'),
//                               Switch(
//                                 value: _publish,
//                                 activeColor: AppThemeData.secondary300,
//                                 onChanged: (v) =>
//                                     setState(() => _publish = v),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildLabel('Has Options'),
//                               Switch(
//                                 value: _hasOptions,
//                                 activeColor: AppThemeData.secondary300,
//                                 onChanged: (v) =>
//                                     setState(() => _hasOptions = v),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (_hasOptions) ...[
//                 const SizedBox(height: 14),
//                 _buildSection(
//                   icon: Icons.list_alt_rounded,
//                   title: 'Options / Variants',
//                   child: _buildOptionsSection(),
//                 ),
//               ],
//               const SizedBox(height: 14),
//               _buildSection(
//                 icon: Icons.fitness_center_rounded,
//                 title: 'Nutritional Info',
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildLabeledField(
//                               'Calories', _caloriesCtrl, 'kcal'),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _buildLabeledField(
//                               'Protein', _proteinCtrl, 'g'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child:
//                               _buildLabeledField('Fats', _fatsCtrl, 'g'),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child:
//                               _buildLabeledField('Carbs', _carbsCtrl, 'g'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     _buildLabeledField('Grams (serving)', _gramsCtrl, 'g'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 80),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSection({
//     required IconData icon,
//     required String title,
//     required Widget child,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: AppThemeData.secondary300),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontFamily: AppThemeData.semiBold,
//                   fontSize: 15,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           child,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImageSection() {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: Container(
//         height: 120,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: const Color(0xFFFAFAFA),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: const Color(0xFFE8ECF5),
//             style: BorderStyle.solid,
//           ),
//         ),
//         child: _images.isNotEmpty
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: _images.first is String
//                     ? NetworkImageWidget(
//                         imageUrl: _images.first,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: 120,
//                       )
//                     : const Icon(Icons.image, size: 40),
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.cloud_upload_outlined,
//                       size: 36, color: AppThemeData.new_primary),
//                   const SizedBox(height: 6),
//                   const Text(
//                     'Tap to upload images',
//                     style: TextStyle(
//                       fontFamily: AppThemeData.medium,
//                       fontSize: 13,
//                       color: Color(0xFF64748B),
//                     ),
//                   ),
//                   const Text(
//                     'JPEG, PNG supported',
//                     style: TextStyle(
//                       fontFamily: AppThemeData.regular,
//                       fontSize: 11,
//                       color: Color(0xFF94A3B8),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
//
//   Widget _buildOptionsSection() {
//     return Column(
//       children: [
//         for (int i = 0; i < _options.length; i++)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: _buildTextField(
//                         _options[i].nameCtrl,
//                         'Variant name',
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.remove_circle_outline,
//                           color: Colors.red, size: 20),
//                       onPressed: () {
//                         setState(() {
//                           _options[i].nameCtrl.dispose();
//                           _options[i].merchantPriceCtrl.dispose();
//                           _options[i].priceCtrl.dispose();
//                           _options.removeAt(i);
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildLabeledPriceField(
//                         label: 'Merchant Price',
//                         controller: _options[i].merchantPriceCtrl,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: _buildLabeledPriceField(
//                         label: 'Price',
//                         controller: _options[i].priceCtrl,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: TextButton.icon(
//             onPressed: () {
//               setState(() {
//                 _options.add(_OptionItem(
//                   nameCtrl: TextEditingController(),
//                   merchantPriceCtrl: TextEditingController(),
//                   priceCtrl: TextEditingController(),
//                 ));
//               });
//             },
//             icon: const Icon(Icons.add, size: 18),
//             label: const Text('Add Option'),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontFamily: AppThemeData.medium,
//           fontSize: 13,
//           color: Color(0xFF334155),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//     TextEditingController controller,
//     String hint, {
//     int maxLines = 1,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: const TextStyle(
//         fontFamily: AppThemeData.regular,
//         fontSize: 14,
//       ),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(
//           fontFamily: AppThemeData.regular,
//           fontSize: 14,
//           color: Color(0xFF94A3B8),
//         ),
//         filled: true,
//         fillColor: const Color(0xFFF8FAFC),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFE8ECF5)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFE8ECF5)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: AppThemeData.secondary300),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDropdown({
//     required String value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       items: items
//           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//           .toList(),
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: const Color(0xFFF8FAFC),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFE8ECF5)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFE8ECF5)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLabeledPriceField({
//     required String label,
//     required TextEditingController controller,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildLabel(label),
//         TextFormField(
//           controller: controller,
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           inputFormatters: [
//             FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
//           ],
//           style: const TextStyle(
//             fontFamily: AppThemeData.regular,
//             fontSize: 14,
//           ),
//           decoration: InputDecoration(
//             prefixText: '₹ ',
//             filled: true,
//             fillColor: const Color(0xFFF8FAFC),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFFE8ECF5)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFFE8ECF5)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: AppThemeData.secondary300),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLabeledField(
//       String label, TextEditingController ctrl, String suffix) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildLabel(label),
//         TextFormField(
//           controller: ctrl,
//           keyboardType: TextInputType.number,
//           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           style: const TextStyle(
//             fontFamily: AppThemeData.regular,
//             fontSize: 14,
//           ),
//           decoration: InputDecoration(
//             suffixText: suffix,
//             filled: true,
//             fillColor: const Color(0xFFF8FAFC),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFFE8ECF5)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFFE8ECF5)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: AppThemeData.secondary300),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   String? _required(String? v) {
//     if (v == null || v.trim().isEmpty) return 'Required';
//     return null;
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _images = [picked];
//       });
//     }
//   }
// }
//
// class _OptionItem {
//   final int? variantId;
//   final TextEditingController nameCtrl;
//   final TextEditingController merchantPriceCtrl;
//   final TextEditingController priceCtrl;
//
//   _OptionItem({
//     this.variantId,
//     required this.nameCtrl,
//     required this.merchantPriceCtrl,
//     required this.priceCtrl,
//   });
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import '../../controller/dash_board_controller.dart';
import '../../models/outlet_product_model.dart';
import '../../models/promotion_models.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _merchantPriceCtrl = TextEditingController();
  final _imageLinkCtrl = TextEditingController();

  String _foodType = 'Veg';
  bool _hasOptions = false;
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isLoadingCategories = false;

  OutletSingleProductModel? _originalProduct;
  List<PromotionOutletProductModel> _outletProductsFlat = [];
  List<_CategoryOption> _availableCategories = [];

  /// Same resolution order used by PromotionPlansController.outletId —
  /// this screen has no controller of its own, so it's duplicated here.
  int get _resolvedOutletId {
    if (Get.isRegistered<DashBoardController>()) {
      final dash = Get.find<DashBoardController>();
      if (dash.activeOutletId.value > 0) {
        return dash.activeOutletId.value;
      }
    }

    final directOutletId = Preferences.getInt('outletId');
    if (directOutletId > 0) return directOutletId;

    final selectedOutletId = Preferences.getInt('selectedOutletId');
    if (selectedOutletId > 0) return selectedOutletId;

    return 0;
  }

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _merchantPriceCtrl.dispose();
    _imageLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    setState(() => _isLoading = true);

    final data = await FireStoreUtils.getOutletSingleProductDetails(widget.productId);

    if (data != null) {
      _originalProduct = data;
      setState(() {
        _nameCtrl.text = data.productName ?? '';
        _descCtrl.text = data.description ?? '';
        _merchantPriceCtrl.text = data.merchantPrice?.toString() ?? '';
        _imageLinkCtrl.text = data.imageLink ?? '';
        _foodType = (data.isVeg == true) ? 'Veg' : 'Non-Veg';
        _hasOptions = data.hasProductVariants ?? false;
        _selectedCategoryId = data.outletCategoryId;
      });
    }

    setState(() => _isLoading = false);

    // Load the category list separately — no dedicated "list categories"
    // endpoint exists, so this reuses the same flat product list the
    // promotion picker uses and derives unique categories from it.
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    final outletId = _resolvedOutletId;
    if (outletId <= 0) return;

    setState(() => _isLoadingCategories = true);
    try {
      final result = await FireStoreUtils.getOutletProductsDetailsOnlyForPromotions(outletId: outletId);
      if (result != null) {
        _outletProductsFlat = result;

        final Map<int, String> seen = {};
        for (final p in result) {
          if (p.outletCategoryId > 0) {
            seen[p.outletCategoryId] = p.categoryName;
          }
        }

        // Make sure the product's current category always shows up in the
        // dropdown, even if that category currently has no other products
        // listed in the flat fetch (edge case, but avoids an orphaned selection).
        if (_selectedCategoryId != null && _selectedCategoryId! > 0 && !seen.containsKey(_selectedCategoryId)) {
          seen[_selectedCategoryId!] = 'Current Category';
        }

        setState(() {
          _availableCategories = seen.entries
              .map((e) => _CategoryOption(id: e.key, name: e.value))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _saveProduct() async {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Product name cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_originalProduct == null) {
      Get.snackbar('Error', 'Product details not loaded yet', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isLoading = true);

    final success = await FireStoreUtils.updateSingleOutletProductDetails(
      productId: widget.productId,
      originalProduct: _originalProduct!,
      categoryId: _selectedCategoryId ?? 0,
      productName: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isVeg: _foodType == 'Veg',
      hasProductVariants: _hasOptions,
      merchantPrice: num.tryParse(_merchantPriceCtrl.text.trim()) ?? 0,
      imageLink: _imageLinkCtrl.text.trim(),
      outletId: null,
    );

    setState(() => _isLoading = false);

    if (success) {
      Get.back(result: true);
      Get.snackbar('Success', 'Product updated successfully', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'Failed to update product details', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Product Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Product Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _merchantPriceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Merchant Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageLinkCtrl,
              decoration: const InputDecoration(
                labelText: 'Image Link (URL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Category:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingCategories
                ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
                : DropdownButtonFormField<int>(
              value: _availableCategories.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _availableCategories.map((c) {
                return DropdownMenuItem<int>(
                  value: c.id,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Food Type:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _foodType,
                  items: ['Veg', 'Non-Veg'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _foodType = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saveProduct,
              child: const Text(
                'Save Details',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryOption {
  final int id;
  final String name;

  _CategoryOption({required this.id, required this.name});
}