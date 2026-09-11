import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/product_screens/variant_builder_sheet_screen.dart';
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
  String? _merchantPriceError;

  double get currentPrice {
    return _originalProduct?.merchantPrice?.toDouble() ?? 0.0;
  }

  String _foodType = 'Veg';
  bool _hasOptions = false;
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isLoadingCategories = false;

  OutletSingleProductModel? _originalProduct;
  List<ProductVariantGroupModel>? _variantGroupsOverride;
  List<PromotionOutletProductModel> _outletProductsFlat = [];
  List<_CategoryOption> _availableCategories = [];
  static final Map<int, List<_CategoryOption>> _categoryCache = {};
  static final Map<int, Future<void>> _categoryLoading = {};

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
        // Only take the server's variant flag when the user hasn't edited the
        // variants in this session. If they have, keep the local (pending) value.
        if (_variantGroupsOverride == null) {
          _hasOptions = data.hasProductVariants ?? false;
        }
        _selectedCategoryId = data.outletCategoryId;
      });
    }

    setState(() => _isLoading = false);
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    final outletId = _resolvedOutletId;

    if (outletId <= 0) return;

    // Already loaded for this outlet → use cache.
    if (_categoryCache.containsKey(outletId)) {
      if (mounted) {
        setState(() {
          _availableCategories = _categoryCache[outletId]!;
          _isLoadingCategories = false;
        });
      }
      return;
    }

    // Another screen is already loading the same outlet's categories.
    if (_categoryLoading.containsKey(outletId)) {
      if (mounted) {
        setState(() => _isLoadingCategories = true);
      }

      await _categoryLoading[outletId];

      if (mounted) {
        setState(() {
          _availableCategories = _categoryCache[outletId] ?? [];
          _isLoadingCategories = false;
        });
      }

      return;
    }

    if (mounted) {
      setState(() => _isLoadingCategories = true);
    }

    final future = _fetchAndCacheCategories(outletId);
    _categoryLoading[outletId] = future;

    try {
      await future;

      if (mounted) {
        setState(() {
          _availableCategories = _categoryCache[outletId] ?? [];
        });
      }
    } finally {
      _categoryLoading.remove(outletId);

      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _fetchAndCacheCategories(int outletId) async {
    try {
      final result =
      await FireStoreUtils.getOutletProductsDetailsOnlyForPromotions(
        outletId: outletId,
      );

      if (result == null) return;

      _outletProductsFlat = result;

      final Map<int, String> seen = {};

      for (final p in result) {
        if (p.outletCategoryId > 0) {
          seen[p.outletCategoryId] = p.categoryName;
        }
      }

      final categories = seen.entries
          .map(
            (e) => _CategoryOption(
          id: e.key,
          name: e.value,
        ),
      )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      _categoryCache[outletId] = categories;
    } catch (e) {
      debugPrint('Error loading categories: $e');
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
      variantGroupsOverride: _variantGroupsOverride,
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Merchant Price',
                border: const OutlineInputBorder(),
                errorText: _merchantPriceError,
              ),
              onChanged: (value) {
                final enteredPrice = double.tryParse(value);

                setState(() {
                  if (enteredPrice != null && enteredPrice > currentPrice) {
                    _merchantPriceError =
                    'Merchant price cannot be greater than ₹$currentPrice';
                  } else {
                    _merchantPriceError = null;
                  }
                });
              },
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
            OutlinedButton.icon(
              icon: const Icon(Icons.tune_rounded),
              label: Text(_hasOptions ? 'Manage Variants' : 'Add Variants'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () async {
                if (_originalProduct == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product information is not available yet.'),
                    ),
                  );
                  return;
                }

                final variantGroups =
                await Navigator.of(context).push<List<ProductVariantGroupModel>>(
                  MaterialPageRoute(
                    builder: (_) => VariantBuilderSheetScreen(
                      productId: widget.productId,
                      originalProduct: _originalProduct!,
                    ),
                  ),
                );

                if (variantGroups != null) {
                  setState(() {
                    _variantGroupsOverride = variantGroups;
                    _hasOptions = variantGroups.isNotEmpty;
                  });
                }
              },            ),
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