import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WatchlistPage extends StatelessWidget {
  final CollectionReference watchlistRef =
  FirebaseFirestore.instance.collection('watchlist');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: watchlistRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Your watchlist is empty!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final watchlist = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final stock = watchlist[index].data() as Map<String, dynamic>;
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
          );
        },
      ),
    );
  }
}
