import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/commodity.dart';
import '../../../providers/favourite_provider.dart';
import '../../../shared/widgets/custom_card.dart';

/// A single commodity row shown in list screens (category list,
/// search results, home preview, favourites). Tapping it opens the
/// Details screen; the heart icon toggles favourite status.
class CommodityCard extends StatelessWidget {
  final Commodity commodity;
  final VoidCallback onTap;

  const CommodityCard({
    super.key,
    required this.commodity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = commodity.isPriceUp;
    final isDown = commodity.isPriceDown;
    final changeColor = isUp
        ? AppColors.priceUp
        : isDown
            ? AppColors.priceDown
            : AppColors.textSecondaryLight;
    final changeIcon = isUp
        ? Icons.arrow_upward
        : isDown
            ? Icons.arrow_downward
            : Icons.remove;

    final favouriteProvider = context.watch<FavouriteProvider>();
    final isFavourite = favouriteProvider.isFavourite(commodity.id);

    return CustomCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        commodity.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          context.read<FavouriteProvider>().toggleFavourite(commodity),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavourite
                              ? AppColors.secondary
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 14, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${commodity.market}, ${commodity.state}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Updated ${AppFormatters.date(commodity.dateUpdated)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.price(commodity.currentPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(changeIcon, size: 13, color: changeColor),
                  const SizedBox(width: 2),
                  Text(
                    '${commodity.percentChange.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}