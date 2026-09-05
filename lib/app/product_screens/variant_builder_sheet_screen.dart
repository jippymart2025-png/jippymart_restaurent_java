import 'package:flutter/material.dart';

import 'package:jippymart_restaurant/models/variant_group_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

import '../../models/outlet_product_model.dart';

class VariantBuilderSheetScreen extends StatefulWidget {
  const VariantBuilderSheetScreen({super.key, required this.productId,required this.originalProduct,});

  final int productId;
  final OutletSingleProductModel originalProduct;
  @override
  State<VariantBuilderSheetScreen> createState() =>
      _VariantBuilderSheetScreenState();
}

class _VariantBuilderSheetScreenState
    extends State<VariantBuilderSheetScreen> {
  List<VariantGroupModel> _allGroups = [];
  final Map<int, List<VariantGroupValueModel>> _valuesByGroup = {};

  /// What actually exists on the server right now — used as the diff
  /// baseline when Save is pressed.
  List<StagedVariantGroup> _original = [];

  /// What the merchant is currently editing.
  List<StagedVariantGroup> _groups = [];

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final groups = await FireStoreUtils.getProductVariantGroups();
    if (groups == null) {
      setState(() {
        _error = 'Could not load variant groups. Pull down to retry.';
        _loading = false;
      });
      return;
    }

    final existing = await FireStoreUtils.getProductVariantOptions(
      widget.productId,
      knownGroups: groups,
    );
    if (existing == null) {
      setState(() {
        _error = 'Could not load this product\'s variants. Pull down to retry.';
        _loading = false;
      });
      return;
    }

    for (final g in existing) {
      if (g.groupId != 0) await _ensureValues(g.groupId);
    }

    setState(() {
      _allGroups = groups;
      _original = existing;
      _groups = existing.isEmpty
          ? [_emptyGroup()]
          : existing
          .map((g) => g.copyWith(options: List.of(g.options)))
          .toList();
      _loading = false;
    });
  }

  Future<void> _ensureValues(int groupId) async {
    if (_valuesByGroup.containsKey(groupId)) return;
    final values = await FireStoreUtils.getVariantGroupValues(groupId);
    if (values != null && mounted) {
      setState(() => _valuesByGroup[groupId] = values);
    }
  }

  StagedVariantGroup _emptyGroup() =>
      StagedVariantGroup(groupId: 0, groupName: '', options: [_emptyOption()]);

  StagedVariantOption _emptyOption() => StagedVariantOption(
    productVariantOptionsId: 0,
    productVariantGroupValuesId: 0,
    variantName: '',
    priceType: 'MAIN',
    variantPrice: 0,
  );

  void _addGroup() => setState(() => _groups.add(_emptyGroup()));

  void _removeGroup(int i) => setState(() => _groups.removeAt(i));

  void _addOption(int gi) => setState(() {
    final updated = List<StagedVariantOption>.from(_groups[gi].options)
      ..add(_emptyOption());
    _groups[gi] = _groups[gi].copyWith(options: updated);
  });

  void _removeOption(int gi, int oi) => setState(() {
    final updated = List<StagedVariantOption>.from(_groups[gi].options)
      ..removeAt(oi);
    _groups[gi] = _groups[gi].copyWith(options: updated);
  });

  Future<void> _onGroupPicked(int gi, VariantGroupModel g) async {
    setState(() {
      _groups[gi] = _groups[gi].copyWith(groupId: g.id, groupName: g.groupName);
    });
    await _ensureValues(g.id);
  }

  void _onOptionValuePicked(int gi, int oi, VariantGroupValueModel v) {
    setState(() {
      final updated = List<StagedVariantOption>.from(_groups[gi].options);
      updated[oi] = updated[oi].copyWith(
        productVariantGroupValuesId: v.id,
        variantName: v.variantName,
      );
      _groups[gi] = _groups[gi].copyWith(options: updated);
    });
  }

  void _onOptionPriceTypeChanged(int gi, int oi, String t) {
    setState(() {
      final updated = List<StagedVariantOption>.from(_groups[gi].options);
      updated[oi] = updated[oi].copyWith(priceType: t);
      _groups[gi] = _groups[gi].copyWith(options: updated);
    });
  }

  void _onOptionPriceChanged(int gi, int oi, double p) {
    setState(() {
      final updated = List<StagedVariantOption>.from(_groups[gi].options);
      updated[oi] = updated[oi].copyWith(variantPrice: p);
      _groups[gi] = _groups[gi].copyWith(options: updated);
    });
  }

  Future<void> _createValue(int gi, int oi, String name) async {
    final groupId = _groups[gi].groupId;
    if (groupId == 0 || name.trim().isEmpty) return;
    final created = await FireStoreUtils.createVariantGroupValue(
      groupId: groupId,
      variantName: name.trim(),
    );
    if (created == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not add "$name"')));
      }
      return;
    }
    setState(() {
      _valuesByGroup[groupId] = [...?_valuesByGroup[groupId], created];
    });
    _onOptionValuePicked(gi, oi, created);
  }

  bool get _canSave {
    for (final g in _groups) {
      final isUntouchedPlaceholder = g.groupId == 0 &&
          g.options.every((o) => o.productVariantGroupValuesId == 0);
      if (isUntouchedPlaceholder) continue;

      if (g.groupId == 0) return false;
      if (g.options.any((o) => o.productVariantGroupValuesId == 0)) {
        return false;
      }
    }
    return true;
  }
  Future<void> _save() async {
    debugPrint('[VariantSave] _save called, canSave=$_canSave saving=$_saving');
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final originalIds = _original
        .expand((g) => g.options)
        .map((o) => o.productVariantOptionsId)
        .where((id) => id != 0)
        .toSet();
    final currentIds = _groups
        .expand((g) => g.options)
        .map((o) => o.productVariantOptionsId)
        .where((id) => id != 0)
        .toSet();

    debugPrint('[VariantSave] originalIds=$originalIds');
    debugPrint('[VariantSave] currentIds=$currentIds');
    debugPrint('[VariantSave] toDelete=${originalIds.difference(currentIds)}');

    var ok = true;

    for (final id in originalIds.difference(currentIds)) {
      debugPrint('[VariantSave] calling deleteProductVariantOption id=$id');
      final success = await FireStoreUtils.deleteProductVariantOption(
        productId: widget.productId,
        optionId: id,
      );
      debugPrint('[VariantSave] delete result for id=$id -> $success');
      ok = ok && success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Variants')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Variant groups',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addGroup,
                  icon: const Icon(Icons.add),
                  label: const Text('Add group'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _groups.isEmpty
                ? const Center(child: Text('No variants added'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groups.length,
              itemBuilder: (context, gi) => _GroupBlock(
                key: ValueKey('$gi-${_groups[gi].groupId}'),
                allGroups: _allGroups,
                staged: _groups[gi],
                values: _groups[gi].groupId == 0
                    ? const []
                    : _valuesByGroup[_groups[gi].groupId] ?? const [],
                onGroupPicked: (g) => _onGroupPicked(gi, g),
                onAddOption: () => _addOption(gi),
                onRemoveOption: (oi) => _removeOption(gi, oi),
                onValuePicked: (oi, v) =>
                    _onOptionValuePicked(gi, oi, v),
                onCreateValue: (oi, name) =>
                    _createValue(gi, oi, name),
                onPriceTypeChanged: (oi, t) =>
                    _onOptionPriceTypeChanged(gi, oi, t),
                onPriceChanged: (oi, p) =>
                    _onOptionPriceChanged(gi, oi, p),
                onRemoveGroup: () => _removeGroup(gi),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canSave && !_saving ? _save : null,
                    child: _saving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Save variants'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  List<ProductVariantGroupModel> _buildVariantGroupsPayload() {
    return _groups
        .where((g) => g.groupId != 0 && g.options.isNotEmpty)
        .map((g) => ProductVariantGroupModel(
      productVariantGroupsId: g.groupId,
      options: g.options
          .where((o) => o.productVariantGroupValuesId != 0)
          .map((o) => ProductVariantOptionModel(
        productVariantOptionsId:
        o.productVariantOptionsId == 0 ? null : o.productVariantOptionsId,
        productVariantGroupValuesId: o.productVariantGroupValuesId,
        priceType: o.priceType,
        variantPrice: o.variantPrice,
      ))
          .toList(),
    ))
        .toList();
  }

}

class _GroupBlock extends StatelessWidget {
  const _GroupBlock({
    super.key,
    required this.allGroups,
    required this.staged,
    required this.values,
    required this.onGroupPicked,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.onValuePicked,
    required this.onCreateValue,
    required this.onPriceTypeChanged,
    required this.onPriceChanged,
    required this.onRemoveGroup,
  });

  final List<VariantGroupModel> allGroups;
  final StagedVariantGroup staged;
  final List<VariantGroupValueModel> values;
  final ValueChanged<VariantGroupModel> onGroupPicked;
  final VoidCallback onAddOption;
  final ValueChanged<int> onRemoveOption;
  final void Function(int optionIndex, VariantGroupValueModel value) onValuePicked;
  final void Function(int optionIndex, String name) onCreateValue;
  final void Function(int optionIndex, String priceType) onPriceTypeChanged;
  final void Function(int optionIndex, double price) onPriceChanged;
  final VoidCallback onRemoveGroup;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Variant group'),
                    value: staged.groupId == 0 ? null : staged.groupId,
                    items: allGroups
                        .map((g) => DropdownMenuItem(value: g.id, child: Text(g.groupName)))
                        .toList(),
                    onChanged: (id) {
                      final g = allGroups.firstWhere((g) => g.id == id);
                      onGroupPicked(g);
                    },
                  ),
                ),
                // IconButton(
                //   icon: const Icon(Icons.delete_outline, color: Colors.red),
                //   onPressed: onRemoveGroup,
                // ),
              ],
            ),
            if (staged.groupId != 0) ...[
              const SizedBox(height: 8),
              for (int i = 0; i < staged.options.length; i++)
                _OptionRow(
                  option: staged.options[i],
                  values: values,
                  onValuePicked: (v) => onValuePicked(i, v),
                  onCreateValue: (name) => onCreateValue(i, name),
                  onPriceTypeChanged: (t) => onPriceTypeChanged(i, t),
                  onPriceChanged: (p) => onPriceChanged(i, p),
                  onRemove: () => onRemoveOption(i),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onAddOption,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add option'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.values,
    required this.onValuePicked,
    required this.onCreateValue,
    required this.onPriceTypeChanged,
    required this.onPriceChanged,
    required this.onRemove,
  });

  final StagedVariantOption option;
  final List<VariantGroupValueModel> values;
  final ValueChanged<VariantGroupValueModel> onValuePicked;
  final ValueChanged<String> onCreateValue;
  final ValueChanged<String> onPriceTypeChanged;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 500;

          if (isCompact) {
            // Stack fields vertically on small screens.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Autocomplete<VariantGroupValueModel>(
                        displayStringForOption: (v) => v.variantName,
                        initialValue:
                        TextEditingValue(text: option.variantName),
                        optionsBuilder: (text) {
                          if (text.text.isEmpty) {
                            return values;
                          }

                          return values.where(
                                (v) => v.variantName
                                .toLowerCase()
                                .contains(text.text.toLowerCase()),
                          );
                        },
                        onSelected: onValuePicked,
                        fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onSubmit,
                            ) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Value',
                            ),
                            onSubmitted: (text) {
                              final match = values.where(
                                    (v) =>
                                v.variantName.toLowerCase() ==
                                    text.trim().toLowerCase(),
                              );

                              if (match.isEmpty &&
                                  text.trim().isNotEmpty) {
                                onCreateValue(text);
                              }
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 4),

                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                      ),
                      onPressed: onRemove,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Price type',
                        ),
                        value: option.priceType,
                        items: const [
                          DropdownMenuItem(
                            value: 'MAIN',
                            child: Text('MAIN'),
                          ),
                          DropdownMenuItem(
                            value: 'ADD',
                            child: Text('ADD'),
                          ),
                        ],
                        onChanged: (v) {
                          onPriceTypeChanged(v ?? 'MAIN');
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Price',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        initialValue: option.variantPrice == 0
                            ? ''
                            : option.variantPrice.toString(),
                        onChanged: (v) {
                          onPriceChanged(
                            double.tryParse(v) ?? 0,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          // Desktop / tablet layout.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Autocomplete<VariantGroupValueModel>(
                  displayStringForOption: (v) => v.variantName,
                  initialValue:
                  TextEditingValue(text: option.variantName),
                  optionsBuilder: (text) {
                    if (text.text.isEmpty) {
                      return values;
                    }

                    return values.where(
                          (v) => v.variantName
                          .toLowerCase()
                          .contains(text.text.toLowerCase()),
                    );
                  },
                  onSelected: onValuePicked,
                  fieldViewBuilder: (
                      context,
                      controller,
                      focusNode,
                      onSubmit,
                      ) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Value',
                      ),
                      onSubmitted: (text) {
                        final match = values.where(
                              (v) =>
                          v.variantName.toLowerCase() ==
                              text.trim().toLowerCase(),
                        );

                        if (match.isEmpty &&
                            text.trim().isNotEmpty) {
                          onCreateValue(text);
                        }
                      },
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  // IMPORTANT
                  isExpanded: true,

                  decoration: const InputDecoration(
                    labelText: 'Price type',
                  ),

                  value: option.priceType,

                  items: const [
                    DropdownMenuItem(
                      value: 'MAIN',
                      child: Text(
                        'MAIN',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ADD',
                      child: Text(
                        'ADD',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  onChanged: (v) {
                    onPriceTypeChanged(v ?? 'MAIN');
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  initialValue: option.variantPrice == 0
                      ? ''
                      : option.variantPrice.toString(),
                  onChanged: (v) {
                    onPriceChanged(
                      double.tryParse(v) ?? 0,
                    );
                  },
                ),
              ),

              const SizedBox(width: 2),

              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 36,
                ),
                icon: const Icon(
                  Icons.close,
                  size: 18,
                ),
                onPressed: onRemove,
              ),
            ],
          );
        },
      ),
    );
  }

}