import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    fetchChartData();
    fetchStockDescription();
  }

  // 📊 Fetch Chart Data
  Future<void> fetchChartData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    String apiKey = 'PYWqXHmLwwGxgwOdUxtEhZBzRDlJdZhF';
    String symbol = widget.stock.symbol;
    String apiUrl;

    if (selectedPeriod == '1D') {
      apiUrl = 'https://financialmodelingprep.com/api/v3/historical-chart/1min/$symbol?apikey=$apiKey';
    } else if (selectedPeriod == '5D') {
      apiUrl = 'https://financialmodelingprep.com/api/v3/historical-chart/5min/$symbol?apikey=$apiKey';
    } else if (selectedPeriod == '1M') {
      DateTime today = DateTime.now();
      DateTime thirtyDaysAgo = today.subtract(Duration(days: 30));
      apiUrl = 'https://financialmodelingprep.com/api/v3/historical-price-full/$symbol?from=${DateFormat('yyyy-MM-dd').format(thirtyDaysAgo)}&to=${DateFormat('yyyy-MM-dd').format(today)}&apikey=$apiKey';
    } else {
      DateTime today = DateTime.now();
      DateTime oneYearAgo = today.subtract(Duration(days: 365));
      apiUrl = 'https://financialmodelingprep.com/api/v3/historical-price-full/$symbol?from=${DateFormat('yyyy-MM-dd').format(oneYearAgo)}&to=${DateFormat('yyyy-MM-dd').format(today)}&apikey=$apiKey';
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          chartData.clear();

          if (selectedPeriod == '1D' || selectedPeriod == '5D') {
            chartData = (data as List<dynamic>).map((entry) {
              double close = entry['close']?.toDouble() ?? 0.0;
              double timestamp = DateTime.parse(entry['date']).millisecondsSinceEpoch.toDouble();
              return FlSpot(timestamp, close);
            }).toList();
          } else if (data['historical'] != null) {
            chartData = (data['historical'] as List<dynamic>).map((entry) {
              double close = entry['close']?.toDouble() ?? 0.0;
              double timestamp = DateTime.parse(entry['date']).millisecondsSinceEpoch.toDouble();
              return FlSpot(timestamp, close);
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

  // 📖 Fetch Stock Description
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
            Text(widget.stock.symbol,
                style: TextStyle(
                    color: Colors.pink,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(widget.stock.symbol,
                style: TextStyle(color: Colors.pink, fontSize: 18)),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedPeriod,
                items: ['1D', '5D', '1M', '1Y']
                    .map((period) => DropdownMenuItem(
                  value: period,
                  child: Text(period, style: TextStyle(color: Colors.white)),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                    fetchChartData();
                  });
                },
                dropdownColor: Colors.black,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 300,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: chartData.length.toDouble(), // Static X-axis range
                    minY: 0,
                    maxY: 500, // Static Y-axis range
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false), // Hide titles
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        colors: [Colors.pink],
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          colors: [Colors.pink.withOpacity(0.3)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: TextStyle(
                        color: Colors.pink,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          showFullDescription ? 'Show less' : 'Read more..',
                          style: TextStyle(
                              color: Colors.pink,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
