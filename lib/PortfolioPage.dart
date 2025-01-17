import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Stock.dart';
import 'StockDetailPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PortfolioPage extends StatefulWidget {
  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _portfolioRef;
  late DatabaseReference _balanceRef;

  List<Stock> portfolio = [];
  List<Stock> filteredPortfolio = [];
  double balance = 0.0;
  double totalInvested = 0.0;
  double totalReturns = 0.0;
  double currentPortfolioValue = 0.0;
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid;
    _portfolioRef = FirebaseDatabase.instance.ref('portfolio/$userId');
    _balanceRef = FirebaseDatabase.instance.ref('users/$userId/balance');
    fetchPortfolioData();
  }

  Future<void> fetchPortfolioData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch balance
      final balanceSnapshot = await _balanceRef.get();
      if (balanceSnapshot.exists) {
        setState(() {
          balance = double.tryParse(balanceSnapshot.value.toString()) ?? 0.0;
        });
      }

      // Fetch portfolio
      final portfolioSnapshot = await _portfolioRef.get();
      if (portfolioSnapshot.exists) {
        final data = Map<String, dynamic>.from(portfolioSnapshot.value as Map);
        List<Stock> fetchedPortfolio = [];
        double invested = 0.0;
        double currentValue = 0.0;
        double returnsSum = 0.0;

        for (var entry in data.entries) {
          final stockData = Map<String, dynamic>.from(entry.value);

          final stock = Stock.fromMap(
            entry.key,
            {
              'symbol': stockData['symbol'],
              'price': double.tryParse(stockData['price'].toString()) ?? 0.0,
              'quantity': double.tryParse(stockData['quantity'].toString()) ?? 0.0,
            },
          );

          // Fetch current price from API
          final currentPrice = await fetchCurrentPrice(stock.symbol);

          final investedValue = stock.price * (stock.quantity ?? 0.0);
          final currentValueForStock = currentPrice * (stock.quantity ?? 0.0);
          final stockReturns = currentValueForStock - investedValue;

          invested += investedValue;
          currentValue += currentValueForStock;
          returnsSum += stockReturns;

          stock.price = currentPrice; // Update the stock price to current
          fetchedPortfolio.add(stock);
        }

        setState(() {
          portfolio = fetchedPortfolio;
          filteredPortfolio = fetchedPortfolio;
          totalInvested = invested;
          currentPortfolioValue = currentValue;
          totalReturns = returnsSum;
        });
      }
    } catch (e) {
      print('Error fetching portfolio data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<double> fetchCurrentPrice(String symbol) async {
    const apiKey = 'S4ts5DZG3QleS272pmnx1fQKJ8mVZvYn'; // Replace with your API key
    final url = 'https://financialmodelingprep.com/api/v3/quote/$symbol?apikey=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.isNotEmpty ? data[0]['price']?.toDouble() ?? 0.0 : 0.0;
      } else {
        throw Exception('Failed to fetch price');
      }
    } catch (e) {
      print('Error fetching price for $symbol: $e');
      return 0.0;
    }
  }

  void searchPortfolio(String query) {
    final filtered = portfolio
        .where((stock) =>
        stock.symbol.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      searchQuery = query;
      filteredPortfolio = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        toolbarHeight: 40, // Adjust toolbar height to reduce the top gap
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : portfolio.isEmpty
          ? Center(
        child: Text(
          'No investments yet!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Column(
        children: [
          // Portfolio summary block
          _buildSummaryBlock(),
          Divider(thickness: 1, color: Colors.grey[300]),
          // Search bar
          _buildSearchBar(),
          // Portfolio list
          _buildPortfolioList(),
        ],
      ),
    );
  }

  Widget _buildSummaryBlock() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Portfolio',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryTile('Invested', '₹${totalInvested.toStringAsFixed(2)}'),
              _buildSummaryTile('Current', '₹${currentPortfolioValue.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryTile(
                'Total Returns',
                '₹${totalReturns.toStringAsFixed(2)}',
                totalReturns >= 0 ? Colors.green : Colors.red,
              ),
              _buildSummaryTile(
                'Returns %',
                totalInvested > 0
                    ? '${((totalReturns / totalInvested) * 100).toStringAsFixed(2)}%'
                    : '0.00%',
                totalReturns >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search portfolio...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        onChanged: (value) {
          searchPortfolio(value);
        },
      ),
    );
  }

  Widget _buildPortfolioList() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredPortfolio.length,
        itemBuilder: (context, index) {
          final stock = filteredPortfolio[index];
          final investedValue = stock.price * (stock.quantity ?? 0.0);
          final stockValue = (stock.quantity ?? 0.0) * stock.price;
          final stockReturns = stockValue - investedValue;

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: ListTile(
              title: Text(
                stock.symbol,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(stock.quantity ?? 0.0).toStringAsFixed(4)} ${stock.symbol}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Returns: ₹${stockReturns.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: stockReturns >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '₹${stockValue.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockDetailPage(stock: stock),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryTile(String title, String value, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
