import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> stocksData = [];
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchAllStocksData();
  }

  Future<void> fetchAllStocksData() async {
    try {
      final snapshot = await databaseRef.child('historical_data').get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> fetchedStocksData = [];
        Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

        data?.forEach((stockName, stockData) {
          // Find the latest timestamp
          String? latestTimestampKey;
          DateTime? latestTimestamp;

          (stockData as Map<dynamic, dynamic>).forEach((key, value) {
            if (value is Map<dynamic, dynamic> && value['timestamp'] != null) {
              DateTime currentTimestamp = DateTime.parse(value['timestamp']);

              if (latestTimestamp == null || currentTimestamp.isAfter(latestTimestamp!)) {
                latestTimestamp = currentTimestamp;
                latestTimestampKey = key;
              }
            }
          });

          // Add the latest data to the fetched list
          if (latestTimestampKey != null) {
            fetchedStocksData.add({
              'stockName': stockName,
              'latestData': stockData[latestTimestampKey],
            });
          }
        });

        // Update the state with the fetched data
        setState(() {
          stocksData.clear();
          stocksData.addAll(fetchedStocksData);
        });

        print('Fetched Stocks Data: $stocksData');
      } else {
        print('No data available');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks Data'),
      ),
      body: stocksData.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: stocksData.length,
        itemBuilder: (context, index) {
          final stock = stocksData[index];
          final stockName = stock['stockName'];
          final latestData = stock['latestData'] as Map<dynamic, dynamic>;

          return Card(
            margin: EdgeInsets.only(bottom: 16.0),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock: $stockName',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Timestamp: ${latestData['timestamp']}'),
                  Text('Open: ${latestData['open']}'),
                  Text('Close: ${latestData['close']}'),
                  Text('High: ${latestData['high']}'),
                  Text('Low: ${latestData['low']}'),
                  Text('Volume: ${latestData['volume']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
