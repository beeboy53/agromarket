import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/commodity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/commodity_provider.dart';
import '../../shared/widgets/custom_button.dart';

/// Lets an admin add a new market-price record. The record is
/// persisted offline (SQLite/web storage via CommodityProvider ->
/// DatabaseService) and merged into the live commodity list right
/// away — no app restart needed.
class AddMarketScreen extends StatefulWidget {
  const AddMarketScreen({super.key});

  @override
  State<AddMarketScreen> createState() => _AddMarketScreenState();
}

class _AddMarketScreenState extends State<AddMarketScreen> {
  final _nameController = TextEditingController();
  final _marketController = TextEditingController();
  final _stateController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _previousPriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = AppCategories.all.first.name;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _marketController.dispose();
    _stateController.dispose();
    _currentPriceController.dispose();
    _previousPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final market = _marketController.text.trim();
    final state = _stateController.text.trim();
    final currentPrice = double.tryParse(_currentPriceController.text.trim());
    final previousPrice = double.tryParse(_previousPriceController.text.trim());
    final description = _descriptionController.text.trim();

    if (name.isEmpty || market.isEmpty || state.isEmpty || currentPrice == null) {
      setState(() => _errorMessage =
          'Please fill in commodity name, market, state, and a valid current price.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final now = DateTime.now();
    final commodity = Commodity(
      id: 'admin_${now.millisecondsSinceEpoch}',
      name: name,
      category: _category,
      market: market,
      state: state,
      currentPrice: currentPrice,
      previousPrice: previousPrice ?? currentPrice,
      dateUpdated: now,
      description:
          description.isEmpty ? 'Market price added by admin.' : description,
      priceHistory: [
        PricePoint(
          date: now.subtract(const Duration(days: 7)),
          price: previousPrice ?? currentPrice,
        ),
        PricePoint(date: now, price: currentPrice),
      ],
    );

    await context.read<CommodityProvider>().addAdminCommodity(commodity);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Market price added successfully.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.addMarketPrice)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Only admin accounts can add market prices.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addMarketPrice)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Commodity Name'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppCategories.all
                    .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val ?? _category),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _marketController,
                decoration: const InputDecoration(labelText: 'Market Name'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currentPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Current Price (₦)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _previousPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Previous Price (₦)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(_errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 22),
              CustomButton(
                label: 'Save Market Price',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}