import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/commodity_provider.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/section_title.dart';
import '../commodity/widgets/commodity_card.dart';

/// The Home tab content. Shown as the first tab inside
/// MainNavigationScreen (see main_navigation_screen.dart).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommodityProvider>();
    // Show a small preview of the most recently updated commodities.
    final latest = [...provider.all]
      ..sort((a, b) => b.dateUpdated.compareTo(a.dateUpdated));
    final preview = latest.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (provider.isOffline) const _OfflineBanner(),
            if (provider.isOffline) const SizedBox(height: 12),
            _SearchBar(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
            ),
            const SizedBox(height: 12),
            const _ComparePricesCard(),
            const SizedBox(height: 24),
            SectionTitle(
              title: AppStrings.categories,
              actionLabel: AppStrings.seeAll,
              onActionTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.categories),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppCategories.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = AppCategories.all[index];
                  return _CategoryTile(
                    name: category.name,
                    icon: category.icon,
                    color: category.color,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.commodityList,
                      arguments: category.name,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            SectionTitle(
              title: AppStrings.latestPrices,
              actionLabel: AppStrings.seeAll,
              onActionTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.commodityList),
            ),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: LoadingWidget(message: 'Loading commodities...'),
              )
            else if (preview.isEmpty)
              const CustomCard(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: EmptyStateWidget(
                  icon: Icons.storefront_outlined,
                  message: 'No commodity data available yet.',
                ),
              )
            else
              Column(
                children: [
                  for (final commodity in preview)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CommodityCard(
                        commodity: commodity,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.commodityDetails,
                          arguments: commodity,
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
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondaryLight),
            const SizedBox(width: 10),
            Text(
              AppStrings.searchHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action that opens the cross-state price comparison.
class _ComparePricesCard extends StatelessWidget {
  const _ComparePricesCard();

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.comparePrices),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.compare_arrows, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.compareAcrossStates,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.compareHint,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing offline data — could not reach the latest prices.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}