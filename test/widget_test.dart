import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:agromarket/core/theme/app_theme.dart';
import 'package:agromarket/features/commodity/screens/price_comparison_screen.dart';
import 'package:agromarket/models/commodity.dart';
import 'package:agromarket/providers/commodity_provider.dart';

Commodity record({
  required String id,
  required String state,
  required String market,
  required double price,
}) {
  return Commodity(
    id: id,
    name: 'Rice (50kg bag)',
    category: 'Grains',
    market: market,
    state: state,
    currentPrice: price,
    previousPrice: price,
    dateUpdated: DateTime(2026, 7, 21),
    description: 'Test record',
    priceHistory: [
      PricePoint(date: DateTime(2026, 7, 14), price: price),
      PricePoint(date: DateTime(2026, 7, 21), price: price),
    ],
  );
}

void main() {
  Widget buildScreen(CommodityProvider provider) {
    return ChangeNotifierProvider<CommodityProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const PriceComparisonScreen(),
      ),
    );
  }

  testWidgets('shows the best price per state and flips with the toggle',
      (tester) async {
    final provider = CommodityProvider(autoLoad: false)
      ..debugSetCommodities([
        record(id: '1', state: 'Lagos', market: 'Mile 12 Market', price: 81000),
        record(id: '2', state: 'Kano', market: 'Dawanau Market', price: 68000),
        record(id: '3', state: 'Oyo', market: 'Bodija Market', price: 72000),
      ]);

    await tester.pumpWidget(buildScreen(provider));
    await tester.pumpAndSettle();

    // Sell view (default): Kano offers the highest price.
    expect(find.text('Selling'), findsOneWidget);
    expect(find.text('Kano'), findsWidgets);
    expect(find.text('Best Price'), findsWidgets);
    expect(find.textContaining('earns'), findsOneWidget);
    expect(find.textContaining('13,000'), findsWidgets);

    // Switch to the buyer's view: Lagos becomes the cheapest and best.
    await tester.tap(find.text('Buying'));
    await tester.pumpAndSettle();

    expect(find.textContaining('saves'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_basket_outlined), findsWidgets);
  });

  testWidgets('explains when only one state has a price', (tester) async {
    final provider = CommodityProvider(autoLoad: false)
      ..debugSetCommodities([
        record(id: '1', state: 'Lagos', market: 'Mile 12 Market', price: 81000),
      ]);

    await tester.pumpWidget(buildScreen(provider));
    await tester.pumpAndSettle();

    expect(find.textContaining('Only one state'), findsOneWidget);
  });
}
