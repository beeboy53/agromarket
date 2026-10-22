import 'commodity.dart';

/// Which side of the trade the comparison is helping.
///
/// The thesis targets farmers SELLING produce, so the default is
/// [sell]: the highest price in the country is the best price. The
/// [buy] view flips the ranking for anyone shopping for produce.
enum PricePerspective { sell, buy }

/// One state's best available price for a commodity.
///
/// A state can have more than one market selling the same commodity
/// (e.g. Kano has both Dawanau and Kurmi markets), so [commodity] holds
/// the CHEAPEST market record found in that state.
class StatePriceOption {
  final Commodity commodity;

  /// How this state compares with the best price, in naira:
  /// 0 for the best state, negative when it is cheaper than the best
  /// (sell view), positive when it is dearer than the best (buy view).
  final double differenceFromBest;

  const StatePriceOption({
    required this.commodity,
    required this.differenceFromBest,
  });

  String get state => commodity.state;
  String get market => commodity.market;
  double get price => commodity.currentPrice;

  bool get isBestPrice => differenceFromBest == 0;

  /// How far this state is from the best price, as a percentage of
  /// the best price.
  double get percentDifference {
    final best = price - differenceFromBest;
    if (best <= 0) return 0;
    return (differenceFromBest.abs() / best) * 100;
  }
}

/// The result of comparing one commodity's price across every state
/// that has a recorded price for it. Options are sorted so the BEST
/// price comes first — where the user should buy (or sell) — and
/// [savings] is the money gained by choosing it over the worst state.
class PriceComparison {
  final String commodityName;
  final PricePerspective perspective;

  /// One entry per state, best price first.
  final List<StatePriceOption> options;

  const PriceComparison({
    required this.commodityName,
    required this.perspective,
    required this.options,
  });

  /// Builds a comparison from the full commodity list by keeping only
  /// the cheapest market record per state for [commodityName].
  ///
  /// [perspective] decides whether the highest price ([PricePerspective.sell])
  /// or the lowest price ([PricePerspective.buy]) is ranked first.
  factory PriceComparison.from(
    List<Commodity> records,
    String commodityName, {
    PricePerspective perspective = PricePerspective.sell,
  }) {
    // Cheapest market per state (a state may have several markets).
    final bestPerState = <String, Commodity>{};
    for (final commodity in records) {
      if (commodity.name != commodityName) continue;
      final current = bestPerState[commodity.state];
      if (current == null || commodity.currentPrice < current.currentPrice) {
        bestPerState[commodity.state] = commodity;
      }
    }

    final sorted = bestPerState.values.toList()
      ..sort((a, b) {
        final byPrice = a.currentPrice.compareTo(b.currentPrice);
        final ranking =
            perspective == PricePerspective.buy ? byPrice : -byPrice;
        return ranking != 0 ? ranking : a.state.compareTo(b.state);
      });

    if (sorted.isEmpty) {
      return PriceComparison(
        commodityName: commodityName,
        perspective: perspective,
        options: const [],
      );
    }

    final bestPrice = sorted.first.currentPrice;
    return PriceComparison(
      commodityName: commodityName,
      perspective: perspective,
      options: [
        for (final commodity in sorted)
          StatePriceOption(
            commodity: commodity,
            differenceFromBest: commodity.currentPrice - bestPrice,
          ),
      ],
    );
  }

  bool get isEmpty => options.isEmpty;

  /// True when there is something to compare (prices in 2+ states).
  bool get isComparable => options.length > 1;

  bool get isSellView => perspective == PricePerspective.sell;

  /// The state to choose (highest price when selling, lowest when buying).
  double get bestPrice => options.isEmpty ? 0 : options.first.price;

  /// The state to avoid — the other extreme of the ranking.
  double get worstPrice => options.isEmpty ? 0 : options.last.price;

  double get highestPrice => options.isEmpty
      ? 0
      : options
          .map((o) => o.price)
          .reduce((a, b) => a > b ? a : b);

  double get lowestPrice => options.isEmpty
      ? 0
      : options.map((o) => o.price).reduce((a, b) => a < b ? a : b);

  /// Gap between the best and worst price in the country, i.e. the
  /// money at stake by choosing well.
  double get savings => worstPrice == 0 ? 0 : (highestPrice - lowestPrice);

  /// [savings] as a percentage of the worst price.
  double get savingsPercent =>
      worstPrice == 0 ? 0 : (savings / worstPrice) * 100;

  Commodity? get bestOption => options.isEmpty ? null : options.first.commodity;

  Commodity? get worstOption => options.isEmpty ? null : options.last.commodity;

  /// The comparison entry for [state], or null if that state has no
  /// recorded price for this commodity.
  StatePriceOption? optionForState(String state) {
    for (final option in options) {
      if (option.state == state) return option;
    }
    return null;
  }
}
