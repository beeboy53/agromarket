import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/commodity_provider.dart';
import '../../../shared/widgets/custom_button.dart';

/// Bottom sheet that lets the user filter the commodity list by
/// Category, State, and Market. Reads/writes filter state directly
/// on [CommodityProvider] so every list screen updates instantly.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _category;
  String? _state;
  String? _market;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CommodityProvider>();
    _category = provider.categoryFilter;
    _state = provider.stateFilter;
    _market = provider.marketFilter;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommodityProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.filter, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          _buildDropdown(
            label: AppStrings.category,
            value: _category,
            items: AppCategories.all.map((c) => c.name).toList(),
            onChanged: (val) => setState(() => _category = val),
          ),
          const SizedBox(height: 14),
          _buildDropdown(
            label: AppStrings.state,
            value: _state,
            items: provider.allStates,
            onChanged: (val) => setState(() => _state = val),
          ),
          const SizedBox(height: 14),
          _buildDropdown(
            label: AppStrings.market,
            value: _market,
            items: provider.allMarkets,
            onChanged: (val) => setState(() => _market = val),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: AppStrings.clearFilter,
                  isOutlined: true,
                  onPressed: () {
                    setState(() {
                      _category = null;
                      _state = null;
                      _market = null;
                    });
                    provider.clearFilters();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: AppStrings.applyFilter,
                  onPressed: () {
                    provider.setCategoryFilter(_category);
                    provider.setStateFilter(_state);
                    provider.setMarketFilter(_market);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('All')),
        ...items.map(
          (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}