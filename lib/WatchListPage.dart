import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Stock.dart';
import 'StockDetailPage.dart';

class WatchlistPage extends StatefulWidget {
  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference watchlistRef;

  List<Stock> watchlistStocks = [];
  List<Stock> filteredStocks = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (user != null) {
      watchlistRef = FirebaseDatabase.instance.ref('watchlist/${user!.uid}');
      fetchWatchlistData();
    }
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchWatchlistData() async {
    try {
      DatabaseEvent event = await watchlistRef.once();
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        List<Stock> fetchedStocks = [];

        data.forEach((key, value) {
          final stock = value as Map<dynamic, dynamic>;
          fetchedStocks.add(Stock.fromMap(key, stock));
        });

        // Fetch the latest prices for the stocks
        await fetchStockPrices(fetchedStocks);

        setState(() {
          watchlistStocks = fetchedStocks;
          filteredStocks = List.from(fetchedStocks);
        });
      }
    } catch (e) {
      print('Error fetching watchlist data: $e');
    }
  }

  Future<void> fetchStockPrices(List<Stock> stocks) async {
    const apiKey = 'S4ts5DZG3QleS272pmnx1fQKJ8mVZvYn';
    for (int i = 0; i < stocks.length; i++) {
      final apiUrl =
          'https://financialmodelingprep.com/api/v3/quote/${stocks[i].symbol}?apikey=$apiKey';
      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.isNotEmpty) {
            stocks[i] = stocks[i].copyWith(
              price: data[0]['price']?.toDouble() ?? 0.0,
            );
          }
        }
      } catch (e) {
        print('Error fetching price for ${stocks[i].symbol}: $e');
      }
    }
  }

  void onSearchChanged() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredStocks = watchlistStocks
          .where((stock) => stock.symbol.toLowerCase().contains(query))
          .toList();
    });
  }

  void clearSearch() {
    searchController.clear();
    onSearchChanged();
  }

  Future<void> removeFromWatchlist(String key) async {
    try {
      await watchlistRef.child(key).remove();
      setState(() {
        watchlistStocks.removeWhere((stock) => stock.key == key);
        filteredStocks.removeWhere((stock) => stock.key == key);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock removed from watchlist')),
      );
    } catch (e) {
      print('Error removing stock: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove stock')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      stock.symbol,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                        'Price: \$${stock.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeFromWatchlist(stock.key),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StockDetailPage(stock: stock),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
