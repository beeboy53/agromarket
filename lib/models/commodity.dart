/// A single point in a commodity's price history, used to draw the
/// price trend chart on the Commodity Details screen.
class PricePoint {
  final DateTime date;
  final double price;

  const PricePoint({required this.date, required this.price});

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'price': price,
      };
}

/// Represents one market-price record for a commodity:
/// a specific commodity, at a specific market, in a specific state,
/// on a specific date. Multiple records can share the same [name]
/// (e.g. "Rice") but differ by [market]/[state] — this is how the
/// "Available Markets" list on the Details screen is built.
class Commodity {
  final String id;
  final String name;
  final String category;
  final String market;
  final String state;
  final double currentPrice;
  final double previousPrice;
  final DateTime dateUpdated;
  final String description;
  final List<PricePoint> priceHistory;

  const Commodity({
    required this.id,
    required this.name,
    required this.category,
    required this.market,
    required this.state,
    required this.currentPrice,
    required this.previousPrice,
    required this.dateUpdated,
    required this.description,
    required this.priceHistory,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      market: json['market'] as String,
      state: json['state'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      previousPrice: (json['previousPrice'] as num).toDouble(),
      dateUpdated: DateTime.parse(json['dateUpdated'] as String),
      description: json['description'] as String,
      priceHistory: (json['priceHistory'] as List<dynamic>)
          .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Used by DatabaseService to persist a commodity to SQLite
  /// (mobile) or SharedPreferences (web) — priceHistory is nested
  /// here as a list of maps, which the database layer re-encodes
  /// to a single JSON string column.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'market': market,
        'state': state,
        'currentPrice': currentPrice,
        'previousPrice': previousPrice,
        'dateUpdated': dateUpdated.toIso8601String(),
        'description': description,
        'priceHistory': priceHistory.map((p) => p.toJson()).toList(),
      };

  /// Positive when price went up since the previous update,
  /// negative when it went down, zero when unchanged.
  double get priceChange => currentPrice - previousPrice;

  /// Percentage change, e.g. 4.2 means price rose by 4.2%.
  double get percentChange =>
      previousPrice == 0 ? 0 : (priceChange / previousPrice) * 100;

  bool get isPriceUp => priceChange > 0;
  bool get isPriceDown => priceChange < 0;
}