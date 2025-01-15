import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<FlSpot> chartData = [];
  String selectedPeriod = '1D';
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
    fetchChartData();
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

  Future<void> fetchChartData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    String apiKey = 'PYWqXHmLwwGxgwOdUxtEhZBzRDlJdZhF';
    String symbol = widget.stock.symbol;
    String apiUrl;

    switch (selectedPeriod) {
      case '1D':
        apiUrl = 'https://financialmodelingprep.com/api/v3/historical-chart/1min/$symbol?apikey=$apiKey';
        break;
      case '5D':
        apiUrl = 'https://financialmodelingprep.com/api/v3/historical-chart/5min/$symbol?apikey=$apiKey';
        break;
      case '1M':
        DateTime today = DateTime.now();
        DateTime thirtyDaysAgo = today.subtract(Duration(days: 30));
        apiUrl =
        'https://financialmodelingprep.com/api/v3/historical-price-full/$symbol?from=${DateFormat('yyyy-MM-dd').format(thirtyDaysAgo)}&to=${DateFormat('yyyy-MM-dd').format(today)}&apikey=$apiKey';
        break;
      case '1Y':
        DateTime today = DateTime.now();
        DateTime oneYearAgo = today.subtract(Duration(days: 365));
        apiUrl =
        'https://financialmodelingprep.com/api/v3/historical-price-full/$symbol?from=${DateFormat('yyyy-MM-dd').format(oneYearAgo)}&to=${DateFormat('yyyy-MM-dd').format(today)}&apikey=$apiKey';
        break;
      default:
        apiUrl = '';
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          chartData.clear();

          if (data != null && data.isNotEmpty) {
            List<dynamic> historicalData = selectedPeriod == '1D' || selectedPeriod == '5D'
                ? data
                : data['historical'] ?? [];

            chartData = historicalData.map<FlSpot>((entry) {
              double close = entry['close'].toDouble();
              DateTime date = DateTime.parse(entry['date']);
              return FlSpot(date.millisecondsSinceEpoch.toDouble(), close);
            }).toList();
          } else {
            hasError = true;
          }
        });
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      print('Error fetching chart data: $e');
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.stock.symbol, style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(isInWatchlist ? Icons.favorite : Icons.favorite_border, color: Colors.pink),
              onPressed: toggleWatchlist,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
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
              DropdownButton<String>(
                value: selectedPeriod,
                items: ['1D', '5D', '1M', '1Y']
                    .map((period) => DropdownMenuItem<String>(
                  value: period,
                  child: Text(period, style: TextStyle(color: Colors.black)),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                    fetchChartData();
                  });
                },
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: LineChart(
                  LineChartData(
                    minY: chartData.isEmpty ? 0 : chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b),
                    maxY: chartData.isEmpty ? 0 : chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        colors: [Colors.pink],
                        barWidth: 4,
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(
                        showTitles: true,
                        interval: ((chartData.isNotEmpty ? chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) : 1) / 4),
                        getTitles: (value) => '\$${value.toStringAsFixed(2)}',
                        getTextStyles: (value) => TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Overview', style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildStockDetailGrid(),
              SizedBox(height: 20),
              Text('Description', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
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
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Text(
                      showFullDescription ? 'Show less' : 'Read more..',
                      style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

