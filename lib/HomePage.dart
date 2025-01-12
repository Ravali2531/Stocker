import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'StockDetailPage.dart';
import 'Stock.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Stock> stocksData = [];
  final List<Stock> filteredStocks = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStockData();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchStockData() async {
    const String apiKey = 'PYWqXHmLwwGxgwOdUxtEhZBzRDlJdZhF';
    const String apiUrl = 'https://financialmodelingprep.com/api/v3/quote/AAPL,GOOG,MSFT?apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          stocksData.clear();
          filteredStocks.clear();
          for (var stock in data) {
            stocksData.add(Stock(
              symbol: stock['symbol'] ?? '',
              price: stock['price']?.toDouble() ?? 0.0,
              change: stock['change']?.toDouble() ?? 0.0,
              changePercentage: stock['changesPercentage']?.toDouble() ?? 0.0,
              marketCap: stock['marketCap']?.toDouble() ?? 0.0,
              volume: stock['volume']?.toDouble() ?? 0.0,
              rank: stock['rank'] ?? 0,
            ));
          }
          filteredStocks.addAll(stocksData);
        });
      } else {
        throw Exception('Failed to load stock data');
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

  void showStockDetails(Stock stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailPage(stock: stock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredStocks.length,
              itemBuilder: (context, index) {
                final stock = filteredStocks[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text(
                      stock.symbol,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Price: ${stock.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${stock.change.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: stock.change >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${stock.changePercentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: stock.changePercentage >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => showStockDetails(stock),
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

