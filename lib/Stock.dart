class Stock {
  final String symbol;
  final double price;
  final double change;
  final double changePercentage;
  final double marketCap;
  final double volume;
  final int rank;

  Stock({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercentage,
    required this.marketCap,
    required this.volume,
    required this.rank,
  });
}
