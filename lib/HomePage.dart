import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Stock> stocksData = [];
  final List<Stock> filteredStocks = [];
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('historical_data');
  final TextEditingController searchController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user

  late DatabaseReference watchlistRef;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      watchlistRef = FirebaseDatabase.instance.ref('watchlist/${user!.uid}');
    }
    fetchAllStocksData();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAllStocksData() async {
    try {
      DatabaseEvent event = await databaseRef.once();
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        List<Stock> fetchedStocks = [];

        data.forEach((stockName, stockEntries) {
          if (stockEntries is Map<dynamic, dynamic>) {
            List<String> dates = stockEntries.keys.cast<String>().toList()..sort();
            String latestDate = dates.last;
            Map<dynamic, dynamic> latestData = stockEntries[latestDate];

            fetchedStocks.add(Stock(
              symbol: latestData['Stock Name'] ?? stockName,
              open: latestData['open']?.toDouble() ?? 0.0,
              close: latestData['close']?.toDouble() ?? 0.0,
              high: latestData['high']?.toDouble() ?? 0.0,
              low: latestData['low']?.toDouble() ?? 0.0,
              volume: latestData['volume']?.toInt() ?? 0,
              timestamp: latestData['timestamp'] ?? '',
            ));
          }
        });

        setState(() {
          stocksData.clear();
          stocksData.addAll(fetchedStocks);
          filteredStocks.addAll(fetchedStocks);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void onSearchChanged() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredStocks.clear();
      filteredStocks.addAll(
        stocksData.where((stock) => stock.symbol.toLowerCase().contains(query)),
      );
    });
  }

  void clearSearch() {
    searchController.clear();
    onSearchChanged();
  }

  void addToWatchlist(Stock stock) {
    if (user != null) {
      watchlistRef.push().set({
        'stockName': stock.symbol,
        'open': stock.open,
        'close': stock.close,
        'high': stock.high,
        'low': stock.low,
        'volume': stock.volume,
        'timestamp': stock.timestamp,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${stock.symbol} added to watchlist')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to add to the watchlist')),
      );
    }
  }

  void showStockDetails(Stock stock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addToWatchlist(stock),
                ),
              ],
            ),
            Text('Open: ${stock.open}'),
            Text('Close: ${stock.close}'),
            Text('High: ${stock.high}'),
            Text('Low: ${stock.low}'),
            Text('Volume: ${stock.volume}'),
            Text('Timestamp: ${stock.timestamp}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('BUY'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('SELL'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search & add',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearSearch,
                )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: filteredStocks.isEmpty
                ? const Center(child: Text('No stocks found'))
                : ListView.builder(
              itemCount: filteredStocks.length,
              itemBuilder: (context, index) {
                final stock = filteredStocks[index];
                return ListTile(
                  onTap: () => showStockDetails(stock),
                  title: Text(stock.symbol, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text('Open: ${stock.open.toStringAsFixed(2)}'),
                  trailing: Text('Close: ${stock.close.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Stock {
  final String symbol;
  final double open;
  final double close;
  final double high;
  final double low;
  final int volume;
  final String timestamp;

  Stock({
    required this.symbol,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.volume,
    required this.timestamp,
  });
}
