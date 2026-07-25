import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/commodity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/commodity_provider.dart';
import '../../shared/widgets/custom_button.dart';

/// Lets an admin update the price/description of an EXISTING
/// commodity record (Update). Name/Category/Market/State are shown
/// read-only, since changing those would really mean creating a
/// different record (use Add Market Price for that instead).
///
/// Updating the price automatically:
///  - moves the current price into "previous price"
///  - appends a new point to the price trend history
///  - stamps a fresh "last updated" date
class EditMarketScreen extends StatefulWidget {
  final Commodity commodity;

  const EditMarketScreen({super.key, required this.commodity});

  @override
  State<EditMarketScreen> createState() => _EditMarketScreenState();
}

class _EditMarketScreenState extends State<EditMarketScreen> {
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _priceController =
        TextEditingController(text: widget.commodity.currentPrice.toStringAsFixed(0));
    _descriptionController = TextEditingController(text: widget.commodity.description);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPrice = double.tryParse(_priceController.text.trim());
    if (newPrice == null || newPrice <= 0) {
      setState(() => _errorMessage = 'Please enter a valid price.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final now = DateTime.now();
    final original = widget.commodity;

    final updated = Commodity(
      id: original.id,
      name: original.name,
      category: original.category,
      market: original.market,
      state: original.state,
      currentPrice: newPrice,
      previousPrice: original.currentPrice,
      dateUpdated: now,
      description: _descriptionController.text.trim().isEmpty
          ? original.description
          : _descriptionController.text.trim(),
      priceHistory: [
        ...original.priceHistory,
        PricePoint(date: now, price: newPrice),
      ],
    );

    await context.read<CommodityProvider>().updateCommodity(updated);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Market price updated.')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this record?'),
        content: Text(
          '"${widget.commodity.name}" at ${widget.commodity.market}, '
          '${widget.commodity.state} will be permanently removed.',
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

    if (confirmed == true && mounted) {
      await context.read<CommodityProvider>().deleteCommodity(widget.commodity.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final commodity = widget.commodity;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.editMarketPrice)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Only admin accounts can edit market prices.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editMarketPrice),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppStrings.delete,
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReadOnlyField(label: 'Commodity Name', value: commodity.name),
              const SizedBox(height: 10),
              _ReadOnlyField(label: 'Category', value: commodity.category),
              const SizedBox(height: 10),
              _ReadOnlyField(label: 'Market', value: commodity.market),
              const SizedBox(height: 10),
              _ReadOnlyField(label: 'State', value: commodity.state),
              const SizedBox(height: 18),
              Text(
                'Current price will become the "previous price" once saved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'New Current Price (₦)'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 6),
              Text(
                'Previous price on record: ${AppFormatters.price(commodity.currentPrice)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 22),
              CustomButton(
                label: 'Save Changes',
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

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}