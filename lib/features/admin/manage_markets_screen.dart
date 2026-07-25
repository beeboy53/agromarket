import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../models/commodity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/commodity_provider.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/empty_state_widget.dart';

/// Admin hub for managing market price data: view every commodity
/// currently in the system, edit (Update) or delete (Delete) any
/// one of them, or add a brand-new record (Create) via the FAB.
class ManageMarketsScreen extends StatefulWidget {
  const ManageMarketsScreen({super.key});

  @override
  State<ManageMarketsScreen> createState() => _ManageMarketsScreenState();
}

class _ManageMarketsScreenState extends State<ManageMarketsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Commodity commodity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this record?'),
        content: Text(
          '"${commodity.name}" at ${commodity.market}, ${commodity.state} '
          'will be removed and will not reappear after refreshing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CommodityProvider>().deleteCommodity(commodity.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.manageMarketPrices)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Only admin accounts can manage market prices.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final provider = context.watch<CommodityProvider>();
    final all = [...provider.all]..sort((a, b) => a.name.compareTo(b.name));
    final results = _query.isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.manageMarketPrices)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addMarket),
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search records to manage...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      message: 'No matching records found.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final commodity = results[index];
                        return CustomCard(
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.editMarket,
                            arguments: commodity,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      commodity.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${commodity.market}, ${commodity.state}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppFormatters.price(commodity.currentPrice),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                onPressed: () => Navigator.of(context).pushNamed(
                                  AppRoutes.editMarket,
                                  arguments: commodity,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () => _confirmDelete(context, commodity),
                              ),
                            ],
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