import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _ordersRef;

  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _ordersRef = FirebaseDatabase.instance.ref('orders/$userId');
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    try {
      final snapshot = await _ordersRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final fetchedOrders = data.values.map((order) {
          return Map<String, dynamic>.from(order as Map);
        }).toList();

        setState(() {
          orders = fetchedOrders;
        });
      }
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders History'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(
        child: Text(
          'No orders found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final date = DateTime.parse(order['date']);
          final formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(date);

          // Parse numeric values to double
          final double quantity =
              double.tryParse(order['quantity'].toString()) ?? 0.0;
          final double price =
              double.tryParse(order['price'].toString()) ?? 0.0;
          final double amountSpent =
              double.tryParse(order['amountSpent'].toString()) ?? 0.0;

          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                order['symbol'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Quantity: ${quantity.toStringAsFixed(4)}'), // Safely parsed
                  Text(
                      'Price: \$${price.toStringAsFixed(2)}'), // Safely parsed
                  Text(
                      'Amount Spent: \$${amountSpent.toStringAsFixed(2)}'), // Safely parsed
                  Text('Date: $formattedDate'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
