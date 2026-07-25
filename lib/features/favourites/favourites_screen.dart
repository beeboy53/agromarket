import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/favourite_provider.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../commodity/widgets/commodity_card.dart';

/// Shows every commodity the user has marked as favourite.
/// Backed by SQLite/web storage via [FavouriteProvider], so this
/// list is available even offline.
class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavouriteProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.favourites)),
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.favourites.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.favorite_border,
                  message: AppStrings.noFavourites,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.favourites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final commodity = provider.favourites[index];
                    return CommodityCard(
                      commodity: commodity,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.commodityDetails,
                        arguments: commodity,
                      ),
                    );
                  },
                ),
    );
  }
}