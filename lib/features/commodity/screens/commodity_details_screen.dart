import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/commodity.dart';
import '../../../providers/commodity_provider.dart';
import '../../../providers/favourite_provider.dart';
import '../../../shared/widgets/custom_card.dart';

/// Full details for one commodity market-price record:
/// category banner, current/previous price, price trend chart,
/// last updated date, description, and other markets selling the
/// same commodity.
class CommodityDetailsScreen extends StatelessWidget {
  final Commodity commodity;

  const CommodityDetailsScreen({super.key, required this.commodity});

  AppCategory _categoryInfo() {
    return AppCategories.all.firstWhere(
      (c) => c.name == commodity.category,
      orElse: () => AppCategories.all.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = _categoryInfo();
    final commodityProvider = context.watch<CommodityProvider>();
    // Highest price first: a farmer selling produce wants to know
    // where this commodity fetches the most money.
    final comparison = commodityProvider.comparePricesFor(commodity.name);
    final otherMarkets = commodityProvider.availableMarketsFor(commodity);
    final bestPrice = comparison.bestPrice;
    final favouriteProvider = context.watch<FavouriteProvider>();
    final isFavourite = favouriteProvider.isFavourite(commodity.id);

    Widget marketRow(Commodity other) {
      final isBestPrice = other.currentPrice == bestPrice;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CustomCard(
          color: isBestPrice ? AppColors.primary.withOpacity(0.08) : null,
          onTap: () => Navigator.of(context).pushReplacementNamed(
            AppRoutes.commodityDetails,
            arguments: other,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(other.market,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(other.state,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.price(other.currentPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isBestPrice
                        ? 'Best price'
                        : '${AppFormatters.price(bestPrice - other.currentPrice)} lower',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isBestPrice
                          ? AppColors.primary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: category.color,
            actions: [
              IconButton(
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () =>
                    context.read<FavouriteProvider>().toggleFavourite(commodity),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: category.color,
                child: Center(
                  child: Icon(category.icon, size: 72, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(commodity.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 15, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(
                        '${commodity.market}, ${commodity.state}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _PriceSummaryCard(commodity: commodity),
                  const SizedBox(height: 12),
                  _CompareAcrossStatesCard(commodity: commodity),
                  const SizedBox(height: 20),
                  Text(AppStrings.priceTrend, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  CustomCard(
                    padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
                    child: SizedBox(
                      height: 180,
                      child: _PriceTrendChart(commodity: commodity),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(AppStrings.description, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    commodity.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Text(AppStrings.availableMarkets, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  if (otherMarkets.isEmpty)
                    Text(
                      'No other markets recorded for this commodity yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...otherMarkets.map(marketRow),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Entry point to the cross-state price comparison for this commodity.
class _CompareAcrossStatesCard extends StatelessWidget {
  final Commodity commodity;

  const _CompareAcrossStatesCard({required this.commodity});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: AppColors.primary.withOpacity(0.10),
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.comparePrices,
        arguments: commodity,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.compare_arrows,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.compareAcrossStates,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'See this price in every state',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 20, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  final Commodity commodity;
  const _PriceSummaryCard({required this.commodity});

  @override
  Widget build(BuildContext context) {
    final isUp = commodity.isPriceUp;
    final isDown = commodity.isPriceDown;
    final changeColor = isUp
        ? AppColors.priceUp
        : isDown
            ? AppColors.priceDown
            : AppColors.textSecondaryLight;

    return CustomCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.currentPrice, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.price(commodity.currentPrice),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      isUp
                          ? Icons.arrow_upward
                          : isDown
                              ? Icons.arrow_downward
                              : Icons.remove,
                      size: 14,
                      color: changeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${commodity.percentChange.abs().toStringAsFixed(1)}% since last update',
                      style: TextStyle(color: changeColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.previousPrice, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.price(commodity.previousPrice),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '${AppStrings.lastUpdated}: ${AppFormatters.date(commodity.dateUpdated)}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTrendChart extends StatelessWidget {
  final Commodity commodity;
  const _PriceTrendChart({required this.commodity});

  @override
  Widget build(BuildContext context) {
    final history = commodity.priceHistory;
    final spots = <FlSpot>[
      for (int i = 0; i < history.length; i++) FlSpot(i.toDouble(), history[i].price),
    ];

    final prices = history.map((p) => p.price).toList();
    final minY = prices.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY = prices.reduce((a, b) => a > b ? a : b) * 1.05;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= history.length) return const SizedBox();
                final date = history[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                AppFormatters.price(spot.y),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}