class Stock {
  final String key;
  final String symbol;
  final double price;
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

  Stock({
    required this.key,
    required this.symbol,
    required this.price,
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
  });

  // Convert from Firebase data to Stock object
  factory Stock.fromMap(String key, Map<dynamic, dynamic> data) {
    return Stock(
      key: key,
      symbol: data['symbol'] ?? 'N/A',
      price: (data['price'] ?? 0).toDouble(),
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
    );
  }

  // Convert Stock object to Map for storing in Firebase
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'price': price,
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
    };
  }
}
