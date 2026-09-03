import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import '../../../../controller/promotion_plans_controller.dart';
import '../../../../models/promotion_models.dart';
import '../../../../constant/show_toast_dialog.dart';
import '../../../../utils/fire_store_utils.dart';
import '../../../models/outlet_details_model.dart';

enum PromotionScope { allCategories, selectedCategories, selectedProducts }

class CreatePromotionPlanScreen extends StatefulWidget {
  const CreatePromotionPlanScreen({super.key, this.preselectedTypeId, this.existingPlan});
  final int? preselectedTypeId;
  final PromotionPlanModel? existingPlan;

  @override
  State<CreatePromotionPlanScreen> createState() => _CreatePromotionPlanScreenState();
}

class _CreatePromotionPlanScreenState extends State<CreatePromotionPlanScreen> {
  final controller = Get.find<PromotionPlansController>();

  final _offerNameCtrl = TextEditingController();
  final _offerAmountCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _maxSelectionCtrl = TextEditingController(text: '-1');

  int? _selectedTypeId;
  String _offerType = 'FLAT';
  PromotionScope _selectedScope = PromotionScope.allCategories;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  List<OutletCategoryModel> _outletCategories = [];
  List<PromotionOutletProductModel> _outletProducts = [];
  bool _isLoadingMenu = false;

  final List<int> _selectedCategoryIds = [];
  final List<int> _selectedProductIds = [];

  bool get _isEditMode => widget.existingPlan != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPlan;

    if (existing != null) {
      // Pre-fill everything from the plan being edited.
      _selectedTypeId = existing.promotionPlanTypeId;
      _offerType = existing.offerType;
      _offerNameCtrl.text = existing.offerName;
      _offerAmountCtrl.text = existing.offerAmount.toString();
      _minOrderCtrl.text = existing.minimumOrderValue.toString();
      _maxSelectionCtrl.text = existing.maxSelection.toString();
      _startDate = DateTime.tryParse(existing.planStartDate) ?? DateTime.now();
      _endDate = DateTime.tryParse(existing.planEndDate) ?? DateTime.now().add(const Duration(days: 7));
      _startTime = _parseTimeOfDay(existing.planStartTime) ?? const TimeOfDay(hour: 10, minute: 0);
      _endTime = _parseTimeOfDay(existing.planEndTime) ?? const TimeOfDay(hour: 22, minute: 0);

      if (existing.productIds.isNotEmpty) {
        _selectedScope = PromotionScope.selectedProducts;
        _selectedProductIds.addAll(existing.productIds);
      } else if (existing.outletCategoryIds.isNotEmpty) {
        _selectedScope = PromotionScope.selectedCategories;
        _selectedCategoryIds.addAll(existing.outletCategoryIds);
      } else {
        _selectedScope = PromotionScope.allCategories;
      }
    } else {
      _selectedTypeId = widget.preselectedTypeId ??
          (controller.planTypes.isNotEmpty
              ? controller.planTypes.first.promotionPlanTypesId
              : 1);
    }

    _loadMenuData();
  }

  TimeOfDay? _parseTimeOfDay(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _loadMenuData() async {
    setState(() => _isLoadingMenu = true);
    try {
      final result = await FireStoreUtils.getOutletProductsDetailsOnlyForPromotions(outletId: controller.outletId);
      if (result != null) {
        // Derive categories by deduplicating outletCategoryId across the flat product list.
        final Map<int, String> seenCategories = {};
        for (final p in result) {
          if (p.outletCategoryId > 0) {
            seenCategories[p.outletCategoryId] = p.categoryName;
          }
        }

        setState(() {
          _outletCategories = seenCategories.entries.map((e) {
            return OutletCategoryModel(
              categoryId: e.key,
              outletCategoryId: e.key,
              categoryName: e.value,
              isAvailable: true,
            );
          }).toList();

          _outletProducts = result;
        });
      }
    } catch (e) {
      debugPrint("Error loading menu: $e");
    } finally {
      setState(() => _isLoadingMenu = false);
    }
  }

  @override
  void dispose() {
    _offerNameCtrl.dispose();
    _offerAmountCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxSelectionCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  /// Replaces raw "product <id>" / "category <id>" mentions in a backend
  /// message with the actual product/category name, when we have it loaded.
  String _resolveNamesInMessage(String message) {
    String result = message;

    final productRegex = RegExp(r'product\s+(\d+)', caseSensitive: false);
    result = result.replaceAllMapped(productRegex, (match) {
      final id = int.tryParse(match.group(1) ?? '');
      if (id == null) return match.group(0)!;
      final prod = _outletProducts.firstWhereOrNull((p) => p.productId == id);
      if (prod != null && prod.productName.isNotEmpty) {
        return '"${prod.productName}"';
      }
      return match.group(0)!;
    });

    final categoryRegex = RegExp(r'categor\w*\s+(\d+)', caseSensitive: false);
    result = result.replaceAllMapped(categoryRegex, (match) {
      final id = int.tryParse(match.group(1) ?? '');
      if (id == null) return match.group(0)!;
      final cat = _outletCategories.firstWhereOrNull(
            (c) => (c.outletCategoryId ?? c.categoryId) == id,
      );
      if (cat != null && (cat.categoryName?.isNotEmpty ?? false)) {
        return '"${cat.categoryName}"';
      }
      return match.group(0)!;
    });

    return result;
  }

  Future<void> _submit() async {
    final resolvedOutletId = controller.outletId;
    if (resolvedOutletId <= 0) {
      Get.snackbar('Error', 'No active outlet found');
      return;
    }

    if (_selectedTypeId == null) {
      Get.snackbar('Error', 'Please select a plan type');
      return;
    }

    if (_offerNameCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter an offer name');
      return;
    }

    final offerAmountText = _offerAmountCtrl.text.trim();
    if (offerAmountText.isEmpty) {
      Get.snackbar(
        'Error',
        _offerType == '% OFF' ? 'Please enter the discount percentage' : 'Please enter the offer amount',
      );
      return;
    }
    final parsedOfferAmount = double.tryParse(offerAmountText);
    if (parsedOfferAmount == null || parsedOfferAmount <= 0) {
      Get.snackbar('Error', 'Please enter a valid offer amount');
      return;
    }

    final minOrderText = _minOrderCtrl.text.trim();
    if (minOrderText.isEmpty) {
      Get.snackbar('Error', 'Please enter the minimum order amount');
      return;
    }
    final parsedMinOrder = double.tryParse(minOrderText);
    if (parsedMinOrder == null || parsedMinOrder < 0) {
      Get.snackbar('Error', 'Please enter a valid minimum order amount');
      return;
    }

    List<int> finalCategoryIds = [];
    List<int> finalProductIds = [];

    if (_selectedScope == PromotionScope.allCategories) {
      finalCategoryIds = _outletCategories
          .map((c) => c.outletCategoryId ?? c.categoryId ?? 0)
          .where((id) => id > 0)
          .toList();
    } else if (_selectedScope == PromotionScope.selectedCategories) {
      if (_selectedCategoryIds.isEmpty) {
        Get.snackbar('Error', 'Please select at least one category');
        return;
      }
      finalCategoryIds = List.from(_selectedCategoryIds);
    } else if (_selectedScope == PromotionScope.selectedProducts) {
      if (_selectedProductIds.isEmpty) {
        Get.snackbar('Error', 'Please select at least one product');
        return;
      }
      finalProductIds = List.from(_selectedProductIds);
    }

    final planData = PromotionPlanModel(
      outletId: resolvedOutletId,
      promotionPlanTypeId: _selectedTypeId,
      planStartDate: _formatDate(_startDate),
      planEndDate: _formatDate(_endDate),
      planStartTime: _formatTime(_startTime),
      planEndTime: _formatTime(_endTime),
      offerName: _offerNameCtrl.text.trim(),
      minimumOrderValue: parsedMinOrder,
      offerAmount: parsedOfferAmount,
      offerType: _offerType,
      productIds: finalProductIds,
      outletCategoryIds: finalCategoryIds,
      maxSelection: int.tryParse(_maxSelectionCtrl.text.trim()) ?? -1,
      status: widget.existingPlan?.status ?? 'ACTIVE',
    );

    final result = (_isEditMode && widget.existingPlan!.promotionPlanId != null)
        ? await controller.updatePromotionPlan(widget.existingPlan!.promotionPlanId!, planData)
        : await controller.createPromotionPlan(planData);

    ShowToastDialog.showToast(_resolveNamesInMessage(result.message));

    if (result.success) Get.back();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryOrange = Color(0xFFF95B12);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditMode ? 'Edit Promotion Plan' : 'Create Promotion Plan',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: AppThemeData.semiBold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: _selectedTypeId,
              decoration: _inputDecoration('Plan Type *', isDark),
              items: controller.planTypes.map((type) {
                return DropdownMenuItem<int>(
                  value: type.promotionPlanTypesId,
                  child: Text(type.planName),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedTypeId = v),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _offerNameCtrl,
              decoration: _inputDecoration('Offer Name *', isDark, hint: 'e.g., Special Weekend Offer'),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Flat Amount')),
                    selected: _offerType == 'FLAT',
                    selectedColor: primaryOrange.withOpacity(0.15),
                    onSelected: (val) => setState(() => _offerType = 'FLAT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('% OFF')),
                    selected: _offerType == '% OFF',
                    selectedColor: primaryOrange.withOpacity(0.15),
                    onSelected: (val) => setState(() => _offerType = '% OFF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _offerAmountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      _offerType == '% OFF' ? 'Discount (%) *' : 'Amount (₹) *',
                      isDark,
                      hint: _offerType == '% OFF' ? 'e.g., 20' : 'e.g., 100',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minOrderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Min Order (₹) *', isDark, hint: 'e.g., 300'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildSectionHeader('Applies On'),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2437) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E374D) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  RadioListTile<PromotionScope>(
                    title: const Text('All Categories', style: TextStyle(fontSize: 14, fontFamily: AppThemeData.medium)),
                    subtitle: Text(
                      'Applies automatically to all categories (${_outletCategories.length} categories)',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    value: PromotionScope.allCategories,
                    groupValue: _selectedScope,
                    activeColor: primaryOrange,
                    dense: true,
                    onChanged: (v) => setState(() => _selectedScope = v!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<PromotionScope>(
                    title: const Text('Selected Categories', style: TextStyle(fontSize: 14, fontFamily: AppThemeData.medium)),
                    subtitle: const Text('Select specific categories to include', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    value: PromotionScope.selectedCategories,
                    groupValue: _selectedScope,
                    activeColor: primaryOrange,
                    dense: true,
                    onChanged: (v) => setState(() => _selectedScope = v!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<PromotionScope>(
                    title: const Text('Selected Products', style: TextStyle(fontSize: 14, fontFamily: AppThemeData.medium)),
                    subtitle: const Text('Select specific products to include', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    value: PromotionScope.selectedProducts,
                    groupValue: _selectedScope,
                    activeColor: primaryOrange,
                    dense: true,
                    onChanged: (v) => setState(() => _selectedScope = v!),
                  ),
                ],
              ),
            ),

            if (_selectedScope == PromotionScope.selectedCategories) ...[
              const SizedBox(height: 14),
              _buildCategorySelector(isDark),
            ],

            if (_selectedScope == PromotionScope.selectedProducts) ...[
              const SizedBox(height: 14),
              _buildProductSelector(isDark),
            ],

            const SizedBox(height: 20),

            _buildSectionHeader('Plan Schedule'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _DatePickerTile(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerTile(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _TimePickerTile(
                    label: 'Start Time',
                    time: _startTime,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (picked != null) setState(() => _startTime = picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimePickerTile(
                    label: 'End Time',
                    time: _endTime,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (picked != null) setState(() => _endTime = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildSectionHeader('Maximum Selection'),
            const SizedBox(height: 12),
            TextField(
              controller: _maxSelectionCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Max items allowed (-1 for unlimited)', isDark),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _isEditMode ? 'Update Plan' : 'Create Plan',
                      style: const TextStyle(color: Colors.white, fontFamily: AppThemeData.semiBold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2437) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF2E374D) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Categories (${_selectedCategoryIds.length})',
                style: const TextStyle(fontSize: 13, fontFamily: AppThemeData.semiBold),
              ),
              TextButton.icon(
                onPressed: _openCategoryPickerDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Select'),
              ),
            ],
          ),
          if (_isLoadingMenu)
            const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_selectedCategoryIds.isEmpty)
            const Text('No categories selected. Tap "Select" to add.', style: TextStyle(fontSize: 12, color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _selectedCategoryIds.map((targetId) {
                final cat = _outletCategories.firstWhereOrNull(
                      (c) => ((c.outletCategoryId ?? 0) == targetId || (c.categoryId ?? 0) == targetId),
                );
                final title = cat?.categoryName ?? 'Category #$targetId';
                return Chip(
                  label: Text(title, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _selectedCategoryIds.remove(targetId)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProductSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2437) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF2E374D) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Products (${_selectedProductIds.length})',
                style: const TextStyle(fontSize: 13, fontFamily: AppThemeData.semiBold),
              ),
              TextButton.icon(
                onPressed: _openProductPickerDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Select'),
              ),
            ],
          ),
          if (_isLoadingMenu)
            const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_selectedProductIds.isEmpty)
            const Text('No products selected. Tap "Select" to add.', style: TextStyle(fontSize: 12, color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _selectedProductIds.map((id) {
                final prod = _outletProducts.firstWhereOrNull((p) => p.productId == id);
                final name = prod?.productName ?? 'Product #$id';
                return Chip(
                  label: Text(name, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _selectedProductIds.remove(id)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _openCategoryPickerDialog() {
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setSheetState) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Categories', style: TextStyle(fontSize: 16, fontFamily: AppThemeData.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _outletCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _outletCategories[index];
                    final resolvedCatId = cat.outletCategoryId ?? cat.categoryId ?? 0;
                    final isChecked = _selectedCategoryIds.contains(resolvedCatId);

                    return CheckboxListTile(
                      title: Text(cat.categoryName ?? 'Category $resolvedCatId'),
                      value: isChecked,
                      activeColor: const Color(0xFFF95B12),
                      onChanged: (val) {
                        setSheetState(() {
                          if (val == true) {
                            _selectedCategoryIds.add(resolvedCatId);
                          } else {
                            _selectedCategoryIds.remove(resolvedCatId);
                          }
                        });
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF95B12)),
                onPressed: () => Get.back(),
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }),
    );
  }
  void _openProductPickerDialog() {
    String search = '';
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setSheetState) {
        final filtered = _outletProducts
            .where((p) => p.productName.toLowerCase().contains(search.toLowerCase()))
            .toList();

        return Container(
          height: 450,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Products', style: TextStyle(fontSize: 16, fontFamily: AppThemeData.bold)),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => setSheetState(() => search = v),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final prod = filtered[index];
                    final prodId = prod.productId;
                    final isChecked = _selectedProductIds.contains(prodId);
                    return CheckboxListTile(
                      title: Text(prod.productName.isNotEmpty ? prod.productName : 'Product $prodId'),
                      subtitle: Text(prod.categoryName),
                      value: isChecked,
                      activeColor: const Color(0xFFF95B12),
                      onChanged: (val) {
                        setSheetState(() {
                          if (val == true) {
                            _selectedProductIds.add(prodId);
                          } else {
                            _selectedProductIds.remove(prodId);
                          }
                        });
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF95B12)),
                onPressed: () => Get.back(),
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 3, height: 16, color: const Color(0xFFF95B12)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14)),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.black26,
        fontSize: 13,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E2437) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({required this.label, required this.date, required this.onTap});
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${date.day}/${date.month}/${date.year}'),
                const Icon(Icons.calendar_today_outlined, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({required this.label, required this.time, required this.onTap});
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context)),
                const Icon(Icons.access_time_rounded, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}