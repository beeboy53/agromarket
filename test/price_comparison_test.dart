import 'package:flutter_test/flutter_test.dart';

import 'package:agromarket/models/commodity.dart';
import 'package:agromarket/models/price_comparison.dart';

Commodity record({
  required String id,
  required String state,
  required String market,
  required double price,
  String name = 'Rice (50kg bag)',
}) {
  return Commodity(
    id: id,
    name: name,
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
  final records = [
    record(id: '1', state: 'Lagos', market: 'Mile 12 Market', price: 81000),
    record(id: '2', state: 'Kano', market: 'Dawanau Market', price: 68000),
    record(id: '3', state: 'Oyo', market: 'Bodija Market', price: 72000),
    // A second Kano market, dearer than Dawanau: must not be used.
    record(id: '4', state: 'Kano', market: 'Kurmi Market', price: 70500),
  ];

  group('PriceComparison.from', () {
    test('keeps only the cheapest market in each state', () {
      final comparison = PriceComparison.from(records, 'Rice (50kg bag)');

      expect(comparison.options.length, 3);
      final kano = comparison.optionForState('Kano');
      expect(kano, isNotNull);
      expect(kano!.market, 'Dawanau Market');
      expect(kano.price, 68000);
    });

    test('sell view ranks the highest price first and treats it as best', () {
      final comparison = PriceComparison.from(records, 'Rice (50kg bag)');

      expect(comparison.perspective, PricePerspective.sell);
      expect(comparison.bestPrice, 81000);
      expect(comparison.bestOption!.state, 'Lagos');
      expect(comparison.worstPrice, 68000);
      expect(comparison.options.first.isBestPrice, isTrue);
      expect(comparison.options.last.isBestPrice, isFalse);
      expect(comparison.savings, 13000);
      expect(comparison.savingsPercent, closeTo(13000 / 68000 * 100, 0.001));
    });

    test('buy view ranks the lowest price first and treats it as best', () {
      final comparison = PriceComparison.from(
        records,
        'Rice (50kg bag)',
        perspective: PricePerspective.buy,
      );

      expect(comparison.isSellView, isFalse);
      expect(comparison.bestPrice, 68000);
      expect(comparison.bestOption!.state, 'Kano');
      expect(comparison.worstPrice, 81000);
      expect(comparison.savings, 13000);
      expect(comparison.savingsPercent, closeTo(13000 / 81000 * 100, 0.001));
    });

    test('difference from best is signed relative to the ranking', () {
      final sell = PriceComparison.from(records, 'Rice (50kg bag)');
      final buy = PriceComparison.from(
        records,
        'Rice (50kg bag)',
        perspective: PricePerspective.buy,
      );

      expect(sell.optionForState('Kano')!.differenceFromBest, -13000);
      expect(sell.optionForState('Kano')!.percentDifference,
          closeTo(13000 / 81000 * 100, 0.001));
      expect(buy.optionForState('Lagos')!.differenceFromBest, 13000);
      expect(buy.optionForState('Kano')!.differenceFromBest, 0);
    });

    test('ignores records for other commodities', () {
      final comparison = PriceComparison.from(records, 'Maize (100kg bag)');

      expect(comparison.isEmpty, isTrue);
      expect(comparison.isComparable, isFalse);
      expect(comparison.savings, 0);
      expect(comparison.bestOption, isNull);
    });

    test('a single state is not comparable', () {
      final comparison = PriceComparison.from(
        [record(id: '1', state: 'Lagos', market: 'Mile 12 Market', price: 81000)],
        'Rice (50kg bag)',
      );

      expect(comparison.options.length, 1);
      expect(comparison.isComparable, isFalse);
      expect(comparison.savings, 0);
    });
  });
}
