class Stock {
  final String key;
  final String symbol;
  double price;
  double? investedPrice; // New field for the invested price
  final double change;
  final double changePercentage;
  final double marketCap;
  final double volume;
  final int rank;
  final double open;
  final double close;
  final double high;
  final double low;
  final String timestamp;
  double? quantity; // Make it mutable

  Stock({
    required this.key,
    required this.symbol,
    required this.price,
    this.investedPrice, // Default to null if not provided
    required this.change,
    required this.changePercentage,
    required this.marketCap,
    required this.volume,
    required this.rank,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.timestamp,
    this.quantity,
  });

  factory Stock.fromMap(String key, Map<dynamic, dynamic> data) {
    return Stock(
      key: key,
      symbol: data['symbol'] ?? 'N/A',
      price: (data['price'] ?? 0).toDouble(),
      investedPrice: (data['price'] ?? 0).toDouble(), // Use 'price' as invested price
      change: (data['change'] ?? 0).toDouble(),
      changePercentage: (data['changePercentage'] ?? 0).toDouble(),
      marketCap: (data['marketCap'] ?? 0).toDouble(),
      volume: (data['volume'] ?? 0).toDouble(),
      rank: (data['rank'] ?? 0).toInt(),
      open: (data['open'] ?? 0).toDouble(),
      close: (data['close'] ?? 0).toDouble(),
      high: (data['high'] ?? 0).toDouble(),
      low: (data['low'] ?? 0).toDouble(),
      timestamp: data['timestamp'] ?? 'N/A',
      quantity: (data['quantity'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'price': price,
      'investedPrice': investedPrice, // Include investedPrice in the map
      'change': change,
      'changePercentage': changePercentage,
      'marketCap': marketCap,
      'volume': volume,
      'rank': rank,
      'open': open,
      'close': close,
      'high': high,
      'low': low,
      'timestamp': timestamp,
      if (quantity != null) 'quantity': quantity,
    };
  }

  Stock copyWith({
    String? key,
    String? symbol,
    double? price,
    double? investedPrice, // Include investedPrice in copyWith
    double? change,
    double? changePercentage,
    double? marketCap,
    double? volume,
    int? rank,
    double? open,
    double? close,
    double? high,
    double? low,
    String? timestamp,
    double? quantity,
  }) {
    return Stock(
      key: key ?? this.key,
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      investedPrice: investedPrice ?? this.investedPrice,
      change: change ?? this.change,
      changePercentage: changePercentage ?? this.changePercentage,
      marketCap: marketCap ?? this.marketCap,
      volume: volume ?? this.volume,
      rank: rank ?? this.rank,
      open: open ?? this.open,
      close: close ?? this.close,
      high: high ?? this.high,
      low: low ?? this.low,
      timestamp: timestamp ?? this.timestamp,
      quantity: quantity ?? this.quantity,
    );
  }
}
