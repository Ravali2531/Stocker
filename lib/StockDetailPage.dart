import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Stock.dart';

class StockDetailPage extends StatefulWidget {
  final Stock stock;

  StockDetailPage({required this.stock});

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  String description = '';
  bool showFullDescription = false;
  bool isLoading = false;
  bool hasError = false;
  bool isInWatchlist = false;

  double open = 0.0;
  double close = 0.0;
  double high = 0.0;
  double low = 0.0;
  int volume = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _watchlistRef;

  @override
  void initState() {
    super.initState();
    _watchlistRef = FirebaseDatabase.instance.ref('watchlist/${_auth.currentUser?.uid ?? ''}');
    checkIfInWatchlist();
    fetchStockDetails();
    fetchStockDescription();
  }

  Future<void> checkIfInWatchlist() async {
    final snapshot = await _watchlistRef.child(widget.stock.symbol).get();
    setState(() {
      isInWatchlist = snapshot.exists;
    });
  }

  Future<void> toggleWatchlist() async {
    if (isInWatchlist) {
      await _watchlistRef.child(widget.stock.symbol).remove();
      setState(() {
        isInWatchlist = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from watchlist')),
      );
    } else {
      await _watchlistRef.child(widget.stock.symbol).set({
        'symbol': widget.stock.symbol,
        'open': open,
        'close': close,
        'high': high,
        'low': low,
        'volume': volume,
      });
      setState(() {
        isInWatchlist = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to watchlist')),
      );
    }
  }

  Future<void> fetchStockDetails() async {
    String apiKey = 'PYWqXHmLwwGxgwOdUxtEhZBzRDlJdZhF';
    String symbol = widget.stock.symbol;
    String apiUrl = 'https://financialmodelingprep.com/api/v3/quote/$symbol?apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            open = data[0]['open']?.toDouble() ?? 0.0;
            close = data[0]['close']?.toDouble() ?? 0.0;
            high = data[0]['dayHigh']?.toDouble() ?? 0.0;
            low = data[0]['dayLow']?.toDouble() ?? 0.0;
            volume = data[0]['volume']?.toInt() ?? 0;
          });
        }
      } else {
        throw Exception('Failed to load stock details');
      }
    } catch (e) {
      print('Error fetching stock details: $e');
    }
  }

  Future<void> fetchStockDescription() async {
    String apiKey = 'PYWqXHmLwwGxgwOdUxtEhZBzRDlJdZhF';
    String symbol = widget.stock.symbol;
    String apiUrl = 'https://financialmodelingprep.com/api/v3/profile/$symbol?apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          description = data[0]['description'] ?? 'No description available.';
        });
      } else {
        throw Exception('Failed to load stock description');
      }
    } catch (e) {
      print('Error fetching stock description: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.stock.symbol, style: TextStyle(color: Colors.pink, fontSize: 24, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(isInWatchlist ? Icons.favorite : Icons.favorite_border, color: Colors.pink),
              onPressed: toggleWatchlist,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.pink))
          : hasError
          ? Center(
        child: Text(
          'Failed to load data. Please try again.',
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📄 Overview Section
              Text(
                'Overview',
                style: TextStyle(color: Colors.pink, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildStockDetailGrid(),

              SizedBox(height: 20),
              // 📖 Description Section
              Text(
                'Description',
                style: TextStyle(color: Colors.pink, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFullDescription = !showFullDescription;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showFullDescription
                          ? description
                          : description.split(' ').take(40).join(' ') + '...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      showFullDescription ? 'Show less' : 'Read more..',
                      style: TextStyle(color: Colors.pink, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockDetailGrid() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildStockDetailTile('Open', '\$${open.toStringAsFixed(2)}'),
          _buildStockDetailTile('Close', '\$${close.toStringAsFixed(2)}'),
          _buildStockDetailTile('High', '\$${high.toStringAsFixed(2)}'),
          _buildStockDetailTile('Low', '\$${low.toStringAsFixed(2)}'),
          _buildStockDetailTile('Volume', volume.toString()),
        ],
      ),
    );
  }

  Widget _buildStockDetailTile(String title, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 24,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
