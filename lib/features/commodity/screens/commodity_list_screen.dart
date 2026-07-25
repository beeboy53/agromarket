import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../providers/commodity_provider.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../widgets/commodity_card.dart';
import '../widgets/filter_sheet.dart';

/// Shows a searchable, filterable list of commodities.
///
/// Reused in two places:
/// 1. Pushed as a normal route (AppRoutes.commodityList) when the
///    user taps a category on Home — [initialCategory] pre-applies
///    that category filter.
/// 2. Embedded directly as the "Search" bottom-nav tab with no
///    initial category, letting the user browse/search everything.
class CommodityListScreen extends StatefulWidget {
  final String? initialCategory;

  const CommodityListScreen({super.key, this.initialCategory});

  @override
  State<CommodityListScreen> createState() => _CommodityListScreenState();
}

class _CommodityListScreenState extends State<CommodityListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Apply the category filter passed in (if any) right after the
    // first frame, so we don't call notifyListeners() during build.
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<CommodityProvider>().setCategoryFilter(widget.initialCategory);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommodityProvider>();
    final results = provider.filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialCategory ?? AppStrings.searchHint),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: provider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _FilterButton(hasActiveFilters: provider.hasActiveFilters),
                ],
              ),
            ),
            if (provider.hasActiveFilters) _ActiveFiltersRow(provider: provider),
            Expanded(
              child: provider.isLoading
                  ? const LoadingWidget(message: 'Loading commodities...')
                  : results.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.search_off,
                          message: AppStrings.noResultsFound,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final commodity = results[index];
                            return CommodityCard(
                              commodity: commodity,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.commodityDetails,
                                arguments: commodity,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool hasActiveFilters;
  const _FilterButton({required this.hasActiveFilters});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => FilterSheet.show(context),
          ),
        ),
        if (hasActiveFilters)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _ActiveFiltersRow extends StatelessWidget {
  final CommodityProvider provider;
  const _ActiveFiltersRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (provider.categoryFilter != null) {
      chips.add(_chip(provider.categoryFilter!, () => provider.setCategoryFilter(null)));
    }
    if (provider.stateFilter != null) {
      chips.add(_chip(provider.stateFilter!, () => provider.setStateFilter(null)));
    }
    if (provider.marketFilter != null) {
      chips.add(_chip(provider.marketFilter!, () => provider.setMarketFilter(null)));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  Widget _chip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onDeleted: onDeleted,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      deleteIconColor: AppColors.primary,
      side: BorderSide.none,
    );
  }
}