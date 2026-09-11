import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../controllers/add_from_catalog_controller.dart';
import '../../../models/master_product_model.dart';
import '../../../models/selected_product_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/const/color_const.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/network_image_widget.dart';
import 'AvailabilitySheetContent.dart';


class ProductCard extends StatelessWidget {
  const ProductCard({
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
    builder: (ctx) => AvailabilitySheetContent(
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
          // const SizedBox(height: 14),
          // _VariantsButton(
          //   id: id,
          //   variantGroups: sel.variantGroups,
          //   isDark: isDark,
          //   onSaved: (groups) => ctrl.setVariantGroups(id, groups),
          // ),
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
