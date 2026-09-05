import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';


class ProductPromotionScreen extends StatefulWidget {
  const ProductPromotionScreen({super.key});

  @override
  State<ProductPromotionScreen> createState() => _ProductPromotionScreenState();
}

class _ProductPromotionScreenState extends State<ProductPromotionScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _restaurantTitle;
  List<Map<String, dynamic>> _promotions = [];
  VendorModel? _vendor;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await FireStoreUtils.getProduct();
      String? vendorId = Constant.userModel?.vendorID?.toString();
      VendorModel? vendor;
      if (vendorId != null && vendorId.isNotEmpty) {
        vendor = await FireStoreUtils.getVendorById(vendorId);
        _promotions = await FireStoreUtils.getProductPromotions(vendorId);
      }
      setState(() {
        _products = products ?? [];
        _restaurantTitle = vendor?.title;
        _vendor = vendor;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
      ShowToastDialog.showToast('Failed to load products');
    }
  }

  bool _isExpired(String endDate) {
    try {
      return DateTime.parse(endDate).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  void _openForm({Map<String, dynamic>? promo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromotionFormSheet(
        products: _products,
        restaurantTitle: _restaurantTitle,
        vendor: _vendor,
        editingPromotion: promo,
        onSaved: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Product Promotions',
          style: TextStyle(
            fontFamily: AppThemeData.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppThemeData.secondary300,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Promotion',
          style: TextStyle(
            fontFamily: AppThemeData.semiBold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
      body: _isLoading
          ? Constant.loader()
          : _promotions.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _promotions.length,
        itemBuilder: (context, index) {
          return _buildPromoCard(_promotions[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppThemeData.secondary300.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_offer_outlined,
                size: 36, color: AppThemeData.secondary300),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Promotions Yet',
            style: TextStyle(
              fontFamily: AppThemeData.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create\nyour first promotion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo) {
    final productTitle =
        (promo['product_name'] ?? promo['product_title'])?.toString().trim() ??
            'Unknown';
    final rawPromoPrice = promo['promo_price']?.toString() ?? '';
    final rawOriginalPrice = promo['price']?.toString() ?? '';
    final endDate = promo['end_date']?.toString() ?? '';
    final photoUrl = promo['photo']?.toString() ?? '';
    final expired = _isExpired(endDate);

    String formattedDate = '';
    if (endDate.isNotEmpty) {
      try {
        formattedDate =
            DateTime.parse(endDate).toLocal().toString().split(' ').first;
      } catch (_) {
        formattedDate = endDate;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product image / placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      color: AppThemeData.secondary300.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.fastfood_rounded,
                        color: AppThemeData.secondary300,
                        size: 26,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productTitle,
                    style: const TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (rawOriginalPrice.isNotEmpty)
                        Text(
                          Constant.amountShow(amount: rawOriginalPrice),
                          style: TextStyle(
                            fontFamily: AppThemeData.regular,
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (rawOriginalPrice.isNotEmpty) const SizedBox(width: 6),
                      if (rawPromoPrice.isNotEmpty)
                        Text(
                          Constant.amountShow(amount: rawPromoPrice),
                          style: TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: 14,
                            color: AppThemeData.secondary300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (formattedDate.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: expired
                              ? Colors.red.shade400
                              : Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontFamily: AppThemeData.medium,
                            fontSize: 12,
                            color: expired
                                ? Colors.red.shade400
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Status + edit/delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: expired ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    expired ? 'Expired' : 'Active',
                    style: TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      fontSize: 11,
                      color: expired ? Colors.red.shade600 : Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit
                    GestureDetector(
                      onTap: () => _openForm(promo: promo),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Delete
                    GestureDetector(
                      onTap: () => _confirmDeletePromotion(promo),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.red.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeletePromotion(Map<String, dynamic> promo) async {
    final id = promo['id']?.toString() ?? '';
    if (id.isEmpty) {
      ShowToastDialog.showToast('Unable to delete: missing promotion id');
      return;
    }

    final productTitle =
        (promo['product_name'] ?? promo['product_title'])?.toString().trim() ??
            'this promotion';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete promotion?',
            style: TextStyle(fontFamily: AppThemeData.semiBold),
          ),
          content: Text(
            'Are you sure you want to delete the promotion for "$productTitle"?',
            style: const TextStyle(fontFamily: AppThemeData.regular),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    ShowToastDialog.showLoader('Deleting...');
    final ok = await FireStoreUtils.deleteProductPromotion(id);
    ShowToastDialog.closeLoader();

    if (ok) {
      ShowToastDialog.showToast('Promotion deleted');
      await _loadData(); // refresh list
    } else {
      ShowToastDialog.showToast('Failed to delete promotion');
    }
  }

  Widget _infoChip(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppThemeData.medium,
              fontSize: 12,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}




class PromotionFormSheet extends StatefulWidget {
  final List<ProductModel> products;
  final String? restaurantTitle;
  final VendorModel? vendor;
  final Map<String, dynamic>? editingPromotion;
  final VoidCallback onSaved;

  const PromotionFormSheet({
    super.key,
    required this.products,
    required this.onSaved,
    this.restaurantTitle,
    this.vendor,
    this.editingPromotion,
  });

  @override
  State<PromotionFormSheet> createState() => _PromotionFormSheetState();
}

class _PromotionFormSheetState extends State<PromotionFormSheet> {
  final TextEditingController _promoPriceController = TextEditingController();
  int? _itemLimit;
  DateTime? _startDate;
  DateTime? _endDate;
  ProductModel? _selectedProduct;

  bool get isEditing => widget.editingPromotion != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final promo = widget.editingPromotion!;
      final product = widget.products.firstWhere(
            (p) => p.id?.toString() == promo['product_id']?.toString(),
        orElse: () => ProductModel(),
      );
      _selectedProduct = product.id == null ? null : product;
      _promoPriceController.text = promo['promo_price']?.toString() ?? '';
      final limit = promo['item_limit'];
      if (limit != null) {
        _itemLimit = int.tryParse(limit.toString());
      }
      final startDateStr = promo['start_date']?.toString() ?? '';
      if (startDateStr.isNotEmpty) {
        try {
          _startDate = DateTime.parse(startDateStr);
        } catch (_) {}
      }
      final endDate = promo['end_date']?.toString() ?? '';
      if (endDate.isNotEmpty) {
        try {
          _endDate = DateTime.parse(endDate);
        } catch (_) {}
      }
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final initial = (_startDate != null && _startDate!.isAfter(now))
        ? _startDate!
        : now;
    final lastDate = _endDate ?? DateTime(now.year + 5);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(lastDate) ? initial : lastDate,
      firstDate: now,
      lastDate: lastDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppThemeData.secondary300,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial = (_endDate != null && _endDate!.isAfter(now))
        ? _endDate!
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppThemeData.secondary300,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _submit() async {
    if (_selectedProduct == null) {
      ShowToastDialog.showToast('Please select a product');
      return;
    }
    if (_promoPriceController.text.trim().isEmpty) {
      ShowToastDialog.showToast('Please enter promotion price');
      return;
    }
    if (_endDate == null) {
      ShowToastDialog.showToast('Please select end date');
      return;
    }
    if (_startDate == null) {
      ShowToastDialog.showToast('Please select start date');
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ShowToastDialog.showToast('Start date must be on or before end date');
      return;
    }
    if (_itemLimit == null) {
      ShowToastDialog.showToast('Please select item limit');
      return;
    }

    final vendor = widget.vendor;
    String formatDate(DateTime d, {bool isPM = false}) {
      final dateTime = DateTime(
        d.year,
        d.month,
        d.day,
        isPM ? 22 : 10, // 10 AM start, 10 PM end
      );

      return dateTime.toIso8601String();
    }

    final formattedStartDate = formatDate(_startDate!);
    final formattedEndDate = formatDate(_endDate!, isPM: true);
    final data = {
      'restaurant_id': vendor?.id?.toString(),
      'restaurant_title': vendor?.title ?? widget.restaurantTitle ?? '',
      'zone_id': vendor?.zoneId?.toString(),
      'product_id': _selectedProduct!.id?.toString(),
      'product_title': _selectedProduct!.name ?? '',
      'promo_price': _promoPriceController.text.trim(),
      'start_date': formattedStartDate,
      'end_date': formattedEndDate,
      'item_limit': _itemLimit.toString(),
    };

    ShowToastDialog.showLoader('Please wait');
    bool ok;
    if (isEditing && widget.editingPromotion!['id'] != null) {
      ok = await FireStoreUtils.updateProductPromotion(
        widget.editingPromotion!['id'].toString(),
        data,
      );
    } else {
      ok = await FireStoreUtils.createProductPromotion(data);
    }
    ShowToastDialog.closeLoader();

    if (ok) {
      ShowToastDialog.showToast(
          isEditing ? 'Promotion updated!' : 'Promotion created!');
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } else {
      ShowToastDialog.showToast('Failed to save promotion');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomPad),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Title row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppThemeData.secondary300
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.local_offer_rounded,
                          color: AppThemeData.secondary300, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Promotion' : 'New Promotion',
                      style: const TextStyle(
                        fontFamily: AppThemeData.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Product dropdown
                _label('Select Product'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ProductModel>(
                      value: _selectedProduct,
                      isExpanded: true,
                      hint: Text(
                        'Choose a product',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontFamily: AppThemeData.regular,
                          fontSize: 14,
                        ),
                      ),
                      items: widget.products
                          .map((p) => DropdownMenuItem<ProductModel>(
                                value: p,
                                child: Text(
                                  p.name ?? 'Unnamed',
                                  style: const TextStyle(
                                    fontFamily: AppThemeData.medium,
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (p) => setState(() => _selectedProduct = p),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Price
                _label('Promotion Price'),
                const SizedBox(height: 8),
                TextField(
                  controller: _promoPriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      fontFamily: AppThemeData.medium, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'e.g. 199',
                    prefixIcon:
                        const Icon(Icons.currency_rupee_rounded, size: 18),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: AppThemeData.secondary300, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Item limit dropdown
                _label('Item limit'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _itemLimit,
                      isExpanded: true,
                      hint: Text(
                        'Select max items per order',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontFamily: AppThemeData.regular,
                          fontSize: 14,
                        ),
                      ),
                      items: List.generate(
                        5,
                        (index) => index + 1,
                      )
                          .map(
                            (v) => DropdownMenuItem<int>(
                              value: v,
                              child: Text(
                                v.toString(),
                                style: const TextStyle(
                                  fontFamily: AppThemeData.medium,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _itemLimit = v),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _label('Start Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppThemeData.secondary300),
                        const SizedBox(width: 12),
                        Text(
                          _startDate == null
                              ? 'Select start date'
                              : _startDate!
                              .toLocal()
                              .toString()
                              .split(' ')
                              .first,
                          style: TextStyle(
                            fontFamily: AppThemeData.medium,
                            fontSize: 14,
                            color: _startDate == null
                                ? Colors.grey.shade400
                                : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),

                // End date
                _label('End Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppThemeData.secondary300),
                        const SizedBox(width: 12),
                        Text(
                          _endDate == null
                              ? 'Select end date'
                              : _endDate!
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                          style: TextStyle(
                            fontFamily: AppThemeData.medium,
                            fontSize: 14,
                            color: _endDate == null
                                ? Colors.grey.shade400
                                : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Start date (below end date)

                const SizedBox(height: 28),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeData.secondary300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'Update Promotion' : 'Create Promotion',
                      style: const TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppThemeData.semiBold,
        fontSize: 13,
        color: Colors.black54,
      ),
    );
  }
}