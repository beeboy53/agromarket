import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/commodity.dart';
import '../../../models/price_comparison.dart';
import '../../../providers/commodity_provider.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/section_title.dart';

/// Compares one commodity's price across every state that has a
/// recorded price for it, so the user can see where the best price is
/// and how much they would save by buying there.
///
/// Opened from the Home quick-action card or from the "Compare Across
/// States" card on the Commodity Details screen (which passes the
/// commodity being viewed as [initialCommodity]).
class PriceComparisonScreen extends StatefulWidget {
  final Commodity? initialCommodity;

  const PriceComparisonScreen({super.key, this.initialCommodity});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  String? _selectedName;

  /// Sell by default: the app is built for farmers selling produce.
  PricePerspective _perspective = PricePerspective.sell;

  @override
  void initState() {
    super.initState();
    _selectedName = widget.initialCommodity?.name;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommodityProvider>();
    final names = provider.allCommodityNames;

    if (provider.isLoading && names.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.comparePrices)),
        body: const LoadingWidget(message: 'Loading market prices...'),
      );
    }

    if (names.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.comparePrices)),
        body: const EmptyStateWidget(
          icon: Icons.compare_arrows,
          message: 'No market prices available to compare yet.',
        ),
      );
    }

    // Fall back to the first commodity if nothing was passed in, or if
    // the previously selected one is no longer in the dataset.
    final selectedName = _selectedName != null && names.contains(_selectedName)
        ? _selectedName!
        : names.first;
    final comparison = provider.comparePricesFor(
      selectedName,
      perspective: _perspective,
    );
    final best = comparison.bestOption;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.comparePrices)),
      body: SafeArea(
        child: Column(
          children: [
            _PerspectiveToggle(
              perspective: _perspective,
              onChanged: (perspective) =>
                  setState(() => _perspective = perspective),
            ),
            _CommoditySelector(
              names: names,
              selectedName: selectedName,
              onSelected: (name) => setState(() => _selectedName = name),
            ),
            Expanded(
              child: comparison.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.compare_arrows,
                      message: 'No prices recorded for this commodity yet.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        if (best != null) _BestPriceCard(comparison: comparison),
                        const SizedBox(height: 16),
                        if (comparison.isComparable) ...[
                          CustomCard(
                            padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    AppStrings.priceByState,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 190,
                                  child: _StatePriceChart(comparison: comparison),
                                ),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Text(
                                    AppStrings.chartNote,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],
                        SectionTitle(
                          title: AppStrings.stateRanking,
                          actionLabel: comparison.options.length > 1
                              ? '${comparison.options.length} states'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        for (var i = 0; i < comparison.options.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _StatePriceRow(
                              rank: i + 1,
                              option: comparison.options[i],
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.commodityDetails,
                                arguments: comparison.options[i].commodity,
                              ),
                            ),
                          ),
                        if (!comparison.isComparable) ...[
                          const SizedBox(height: 4),
                          CustomCard(
                            color: AppColors.warning.withOpacity(0.12),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 18, color: AppColors.warning),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    AppStrings.onlyOneState,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        const Text(
                          AppStrings.comparisonNote,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flips the comparison between the farmer's view (highest price wins)
/// and the buyer's view (lowest price wins).
class _PerspectiveToggle extends StatelessWidget {
  final PricePerspective perspective;
  final ValueChanged<PricePerspective> onChanged;

  const _PerspectiveToggle({
    required this.perspective,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<PricePerspective>(
              segments: const [
                ButtonSegment<PricePerspective>(
                  value: PricePerspective.sell,
                  label: Text(AppStrings.sellMode),
                  icon: Icon(Icons.sell_outlined, size: 16),
                ),
                ButtonSegment<PricePerspective>(
                  value: PricePerspective.buy,
                  label: Text(AppStrings.buyMode),
                  icon: Icon(Icons.shopping_basket_outlined, size: 16),
                ),
              ],
              selected: {perspective},
              onSelectionChanged: (selection) => onChanged(selection.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              perspective == PricePerspective.sell
                  ? AppStrings.sellModeHint
                  : AppStrings.buyModeHint,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal list of commodities the user can compare.
class _CommoditySelector extends StatelessWidget {
  final List<String> names;
  final String selectedName;
  final ValueChanged<String> onSelected;

  const _CommoditySelector({
    required this.names,
    required this.selectedName,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final name = names[index];
          final isSelected = name == selectedName;
          return ChoiceChip(
            label: Text(name, style: const TextStyle(fontSize: 12)),
            selected: isSelected,
            onSelected: (_) => onSelected(name),
            showCheckmark: false,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryLight.withOpacity(0.3),
            ),
            backgroundColor: Theme.of(context).cardTheme.color,
          );
        },
      ),
    );
  }
}

/// Headline answer: cheapest state, its price, and the saving compared
/// with the most expensive state.
class _BestPriceCard extends StatelessWidget {
  final PriceComparison comparison;

  const _BestPriceCard({required this.comparison});

  @override
  Widget build(BuildContext context) {
    final best = comparison.bestOption!;
    final worst = comparison.worstOption;

    return CustomCard(
      color: AppColors.primary.withOpacity(0.10),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium,
                        size: 13, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      AppStrings.bestPrice,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                comparison.commodityName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppFormatters.price(best.currentPrice),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${best.state} • ${best.market}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (comparison.isComparable && worst != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.primary.withOpacity(0.15)),
            const SizedBox(height: 10),
            Text(
              comparison.isSellView
                  ? 'Selling here instead of ${worst.state} earns '
                      '${AppFormatters.price(comparison.savings)} more '
                      '(${comparison.savingsPercent.toStringAsFixed(1)}%)'
                  : 'Buying here instead of ${worst.state} saves '
                      '${AppFormatters.price(comparison.savings)} '
                      '(${comparison.savingsPercent.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Price per state as bars — the cheapest state's bar is highlighted.
class _StatePriceChart extends StatelessWidget {
  final PriceComparison comparison;

  const _StatePriceChart({required this.comparison});

  @override
  Widget build(BuildContext context) {
    final options = comparison.options;
    // Zoom the axis to the actual price range: a zero baseline makes
    // states that differ by 10% look identical, which hides the very
    // gap this chart exists to show.
    final minPrice = comparison.lowestPrice * 0.90;
    final maxPrice = comparison.highestPrice * 1.06;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BarChart(
      BarChartData(
        minY: minPrice,
        maxY: maxPrice,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxPrice - minPrice) / 3,
          getDrawingHorizontalLine: (_) => FlLine(
            color: isDark ? Colors.white12 : Colors.black12,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= options.length) {
                  return const SizedBox();
                }
                final isBest = options[index].isBestPrice;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    options[index].state,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isBest ? FontWeight.bold : FontWeight.normal,
                      color: isBest
                          ? AppColors.primary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final option = options[group.x];
              return BarTooltipItem(
                '${option.state}\n${AppFormatters.price(rod.toY)}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        barGroups: [
          for (var i = 0; i < options.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: options[i].price,
                  width: 20,
                  color: options[i].isBestPrice
                      ? AppColors.primary
                      : AppColors.primaryLight.withOpacity(0.65),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// One ranked state row: rank, state, market, price and the gap to the
/// best price (or a "Best Price" badge for the cheapest state).
class _StatePriceRow extends StatelessWidget {
  final int rank;
  final StatePriceOption option;
  final VoidCallback onTap;

  const _StatePriceRow({
    required this.rank,
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBest = option.isBestPrice;

    return CustomCard(
      onTap: onTap,
      color: isBest ? AppColors.primary.withOpacity(0.08) : null,
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isBest
                  ? AppColors.primary
                  : AppColors.textSecondaryLight.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isBest ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.state,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  option.market,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.price(option.price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              if (isBest)
                const Text(
                  AppStrings.bestPrice,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  '${option.differenceFromBest < 0 ? '−' : '+'}'
                  '${AppFormatters.price(option.differenceFromBest.abs())} '
                  '(${option.percentDifference.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
