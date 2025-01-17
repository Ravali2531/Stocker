// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'Stock.dart';
// import 'PortfolioPage.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class StockDetailPage extends StatefulWidget {
//   final Stock stock;
//
//   StockDetailPage({required this.stock});
//
//   @override
//   _StockDetailPageState createState() => _StockDetailPageState();
// }
//
// class _StockDetailPageState extends State<StockDetailPage> {
//   List<FlSpot> chartData = [];
//   String selectedPeriod = '1D';
//   String description = '';
//   bool showFullDescription = false;
//   bool isLoading = false;
//   bool hasError = false;
//   bool isInWatchlist = false;
//
//   double open = 0.0;
//   double close = 0.0;
//   double high = 0.0;
//   double low = 0.0;
//   double price = 0.0;
//   double volume = 0.0;
//   double balance = 0.0;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late DatabaseReference _watchlistRef;
//   late DatabaseReference _balanceRef;
//   late DatabaseReference _portfolioRef;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize Firebase Database references
//     final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     _portfolioRef = FirebaseDatabase.instance.ref('portfolio/$userId');
//     _balanceRef = FirebaseDatabase.instance.ref('users/$userId/balance'); // Update path
//     _watchlistRef = FirebaseDatabase.instance.ref('watchlist/$userId'); // Optional if used
//     fetchStockQuantity();
//     checkIfInWatchlist();
//     fetchBalance();
//     fetchStockDetails();
//     fetchChartData();
//     fetchStockDescription();
//   }
//
//   Future<void> fetchStockQuantity() async {
//     try {
//       final snapshot = await _portfolioRef.child(widget.stock.symbol).get();
//       if (snapshot.exists) {
//         final data = snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           widget.stock.quantity = data['quantity']?.toDouble() ?? 0.0;
//         });
//       } else {
//         setState(() {
//           widget.stock.quantity = 0.0; // Default to 0 if not found
//         });
//       }
//     } catch (e) {
//       print('Error fetching stock quantity: $e');
//       setState(() {
//         widget.stock.quantity = 0.0; // Default to 0 on error
//       });
//     }
//   }
//   Future<void> checkIfInWatchlist() async {
//     final snapshot = await _watchlistRef.child(widget.stock.symbol).get();
//     setState(() {
//       isInWatchlist = snapshot.exists;
//     });
//   }
//
//   Future<void> fetchBalance() async {
//     try {
//       final snapshot = await _balanceRef.get();
//       if (snapshot.exists) {
//         setState(() {
//           balance = double.parse(snapshot.value.toString());
//         });
//       }
//     } catch (e) {
//       print('Error fetching balance: $e');
//     }
//   }
//
//   Future<void> toggleWatchlist() async {
//     if (isInWatchlist) {
//       await _watchlistRef.child(widget.stock.symbol).remove();
//       setState(() {
//         isInWatchlist = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Removed from watchlist')),
//       );
//     } else {
//       await _watchlistRef.child(widget.stock.symbol).set({
//         'symbol': widget.stock.symbol,
//         'open': open,
//         'close': close,
//         'high': high,
//         'low': low,
//         'volume': volume,
//         'price': price,
//       });
//       setState(() {
//         isInWatchlist = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Added to watchlist')),
//       );
//     }
//   }
//
//   Future<void> fetchStockDetails() async {
//     String apiKey = 'S4ts5DZG3QleS272pmnx1fQKJ8mVZvYn';
//     String symbol = widget.stock.symbol;
//     String apiUrl = 'https://financialmodelingprep.com/api/v3/quote/$symbol?apikey=$apiKey';
//
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           setState(() {
//             open = data[0]['open']?.toDouble() ?? 0.0;
//             close = data[0]['previousClose']?.toDouble() ?? 0.0;
//             high = data[0]['dayHigh']?.toDouble() ?? 0.0;
//             low = data[0]['dayLow']?.toDouble() ?? 0.0;
//             price = data[0]['price']?.toDouble() ?? 0.0;
//             volume = data[0]['volume']?.toDouble() ?? 0.0;
//           });
//         }
//       } else {
//         throw Exception('Failed to fetch stock details');
//       }
//     } catch (e) {
//       print('Error fetching stock details: $e');
//     }
//   }
//
//   Future<void> fetchChartData() async {
//     setState(() {
//       isLoading = true;
//       hasError = false;
//     });
//
//     String apiKey = 'S4ts5DZG3QleS272pmnx1fQKJ8mVZvYn';
//     String symbol = widget.stock.symbol;
//     String apiUrl;
//
//     switch (selectedPeriod) {
//       case '1D':
//         apiUrl =
//         'https://financialmodelingprep.com/api/v3/historical-chart/1min/$symbol?apikey=$apiKey';
//         break;
//       case '5D':
//         apiUrl =
//         'https://financialmodelingprep.com/api/v3/historical-chart/5min/$symbol?apikey=$apiKey';
//         break;
//       case '1M':
//         DateTime today = DateTime.now();
//         DateTime thirtyDaysAgo = today.subtract(Duration(days: 30));
//         apiUrl =
//         'https://financialmodelingprep.com/api/v3/historical-price-full/$symbol?from=${DateFormat(
//             'yyyy-MM-dd').format(thirtyDaysAgo)}&to=${DateFormat('yyyy-MM-dd')
//             .format(today)}&apikey=$apiKey';
//         break;
//       case '1Y':
//         DateTime today = DateTime.now();
//         DateTime oneYearAgo = today.subtract(Duration(days: 365));
//         apiUrl =
//         'https://financialmodelingprep.com/api/v3/historical-price-full/$symbol?from=${DateFormat(
//             'yyyy-MM-dd').format(oneYearAgo)}&to=${DateFormat('yyyy-MM-dd')
//             .format(today)}&apikey=$apiKey';
//         break;
//       default:
//         apiUrl = '';
//     }
//
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         setState(() {
//           chartData.clear();
//
//           if (data != null && data.isNotEmpty) {
//             List<dynamic> historicalData = selectedPeriod == '1D' ||
//                 selectedPeriod == '5D'
//                 ? data
//                 : data['historical'] ?? [];
//
//             chartData = historicalData.map<FlSpot>((entry) {
//               double close = entry['close'].toDouble();
//               DateTime date = DateTime.parse(entry['date']);
//               return FlSpot(date.millisecondsSinceEpoch.toDouble(), close);
//             }).toList();
//           } else {
//             hasError = true;
//           }
//         });
//       } else {
//         throw Exception('Failed to load chart data');
//       }
//     } catch (e) {
//       print('Error fetching chart data: $e');
//       setState(() {
//         hasError = true;
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> fetchStockDescription() async {
//     String apiKey = 'S4ts5DZG3QleS272pmnx1fQKJ8mVZvYn';
//     String symbol = widget.stock.symbol;
//     String apiUrl = 'https://financialmodelingprep.com/api/v3/profile/$symbol?apikey=$apiKey';
//
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           description = data[0]['description'] ?? 'No description available.';
//         });
//       } else {
//         throw Exception('Failed to load stock description');
//       }
//     } catch (e) {
//       print('Error fetching stock description: $e');
//     }
//   }
//
//   void showBuyDialog() {
//     TextEditingController amountController = TextEditingController();
//     double quantity = 0.0;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: Text('Buy ${widget.stock.symbol}'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: amountController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                         hintText: 'Enter amount to spend'),
//                     onChanged: (value) {
//                       double enteredAmount = double.tryParse(value) ?? 0.0;
//                       if (enteredAmount > 0 && price > 0) {
//                         setDialogState(() {
//                           quantity = enteredAmount / price;
//                         });
//                       } else {
//                         setDialogState(() {
//                           quantity = 0.0;
//                         });
//                       }
//                     },
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Available Balance: \$${balance.toStringAsFixed(2)}',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Quantity: ${quantity.toStringAsFixed(2)} shares',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     double enteredAmount = double.tryParse(
//                         amountController.text) ?? 0.0;
//                     if (enteredAmount > balance) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Insufficient balance!')),
//                       );
//                     } else if (enteredAmount > 0 && quantity > 0) {
//                       await completePurchase(quantity, enteredAmount);
//                       Navigator.pop(context);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Invalid amount entered!')),
//                       );
//                     }
//                   },
//                   child: Text('Buy'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void showSellDialog() {
//     TextEditingController quantityController = TextEditingController();
//     double amountEarned = 0.0;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: Text('Sell ${widget.stock.symbol}'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: quantityController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(hintText: 'Enter quantity to sell'),
//                     onChanged: (value) {
//                       double enteredQuantity = double.tryParse(value) ?? 0.0;
//                       if (enteredQuantity > 0 && price > 0) {
//                         setDialogState(() {
//                           amountEarned = enteredQuantity * price;
//                         });
//                       } else {
//                         setDialogState(() {
//                           amountEarned = 0.0;
//                         });
//                       }
//                     },
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Available Quantity: ${widget.stock.quantity?.toStringAsFixed(2) ?? 'N/A'}',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Amount Earned: \$${amountEarned.toStringAsFixed(2)}',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     double enteredQuantity =
//                         double.tryParse(quantityController.text) ?? 0.0;
//                     if (enteredQuantity > (widget.stock.quantity ?? 0.0)) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Insufficient quantity to sell!')),
//                       );
//                     } else if (enteredQuantity > 0) {
//                       await completeSale(enteredQuantity, amountEarned);
//                       Navigator.pop(context);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Invalid quantity entered!')),
//                       );
//                     }
//                   },
//                   child: Text('Sell'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> sendNotification(String title, String body) async {
//     final FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     // Request notification permissions (if not already granted)
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('Notification permission granted.');
//     } else {
//       print('Notification permission denied.');
//     }
//
//     // Sending a local push notification (can integrate with a server to send real FCM notifications)
//     FirebaseMessaging.instance.subscribeToTopic("notifications");
//
//     print("Notification sent: $title - $body");
//   }
//
//
//   // Future<void> completePurchase(double quantity, double amountSpent) async {
//   //   DatabaseReference ordersRef = FirebaseDatabase.instance.ref(
//   //       'orders/${_auth.currentUser?.uid ?? ''}');
//   //   DatabaseReference portfolioRef = FirebaseDatabase.instance.ref(
//   //       'portfolio/${_auth.currentUser?.uid ?? ''}');
//   //   try {
//   //     setState(() {
//   //       balance -= amountSpent;
//   //     });
//   //     await _balanceRef.set(balance);
//   //
//   //     await ordersRef.push().set({
//   //       'symbol': widget.stock.symbol,
//   //       'quantity': quantity,
//   //       'price': price,
//   //       'amountSpent': amountSpent,
//   //       'date': DateTime.now().toIso8601String(),
//   //     });
//   //
//   //     final portfolioSnapshot = await portfolioRef.child(widget.stock.symbol)
//   //         .get();
//   //     if (portfolioSnapshot.exists) {
//   //       final currentQuantity = (portfolioSnapshot.value as Map)['quantity'] ??
//   //           0.0;
//   //       await portfolioRef.child(widget.stock.symbol).update({
//   //         'quantity': currentQuantity + quantity,
//   //       });
//   //     } else {
//   //       await portfolioRef.child(widget.stock.symbol).set({
//   //         'symbol': widget.stock.symbol,
//   //         'quantity': quantity,
//   //         'price': price,
//   //       });
//   //     }
//   //
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Purchase successful!')),
//   //     );
//   //   } catch (e) {
//   //     print('Error completing purchase: $e');
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Purchase failed!')),
//   //     );
//   //   }
//   // }
//   Future<void> completePurchase(double quantity, double amountSpent) async {
//     DatabaseReference ordersRef = FirebaseDatabase.instance.ref(
//         'orders/${_auth.currentUser?.uid ?? ''}');
//     DatabaseReference portfolioRef = FirebaseDatabase.instance.ref(
//         'portfolio/${_auth.currentUser?.uid ?? ''}');
//     try {
//       setState(() {
//         balance -= amountSpent;
//       });
//       await _balanceRef.set(balance);
//
//       await ordersRef.push().set({
//         'symbol': widget.stock.symbol,
//         'quantity': quantity.toStringAsFixed(2),
//         'price': price,
//         'amountSpent': amountSpent,
//         'date': DateTime.now().toIso8601String(),
//       });
//
//       final portfolioSnapshot = await portfolioRef.child(widget.stock.symbol)
//           .get();
//       if (portfolioSnapshot.exists) {
//         final currentQuantity = (portfolioSnapshot.value as Map)['quantity'] ??
//             0.0;
//         await portfolioRef.child(widget.stock.symbol).update({
//           'quantity': currentQuantity + quantity,
//         });
//       } else {
//         await portfolioRef.child(widget.stock.symbol).set({
//           'symbol': widget.stock.symbol,
//           'quantity': quantity.toStringAsFixed(2),
//           'price': price,
//         });
//       }
//
//       // Send Push Notification
//       await sendNotification(
//         'Purchase Successful',
//         'You bought $quantity shares of ${widget.stock.symbol} for \$${amountSpent.toStringAsFixed(2)}.',
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Purchase successful!')),
//       );
//     } catch (e) {
//       print('Error completing purchase: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Purchase failed!')),
//       );
//     }
//   }
//
//   // Future<void> completeSale(double quantitySold, double amountEarned) async {
//   //   DatabaseReference ordersRef =
//   //   FirebaseDatabase.instance.ref('orders/${_auth.currentUser?.uid ?? ''}');
//   //   DatabaseReference portfolioRef =
//   //   FirebaseDatabase.instance.ref('portfolio/${_auth.currentUser?.uid ?? ''}');
//   //   try {
//   //     setState(() {
//   //       balance += amountEarned;
//   //     });
//   //     await _balanceRef.set(balance);
//   //
//   //     await ordersRef.push().set({
//   //       'symbol': widget.stock.symbol,
//   //       'quantity': -quantitySold,
//   //       'price': price,
//   //       'amountSpent': -amountEarned,
//   //       'date': DateTime.now().toIso8601String(),
//   //     });
//   //
//   //     final portfolioSnapshot =
//   //     await portfolioRef.child(widget.stock.symbol).get();
//   //     if (portfolioSnapshot.exists) {
//   //       final currentQuantity =
//   //           (portfolioSnapshot.value as Map)['quantity'] ?? 0.0;
//   //       final updatedQuantity = currentQuantity - quantitySold;
//   //
//   //       if (updatedQuantity > 0) {
//   //         await portfolioRef.child(widget.stock.symbol).update({
//   //           'quantity': updatedQuantity,
//   //         });
//   //       } else {
//   //         await portfolioRef.child(widget.stock.symbol).remove();
//   //       }
//   //     }
//   //
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Sale successful!')),
//   //     );
//   //   } catch (e) {
//   //     print('Error completing sale: $e');
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Sale failed!')),
//   //     );
//   //   }
//   // }
//
//   Future<void> completeSale(double quantitySold, double amountEarned) async {
//     DatabaseReference ordersRef =
//     FirebaseDatabase.instance.ref('orders/${_auth.currentUser?.uid ?? ''}');
//     DatabaseReference portfolioRef =
//     FirebaseDatabase.instance.ref('portfolio/${_auth.currentUser?.uid ?? ''}');
//     try {
//       print('Starting sale...');
//       print('Quantity Sold: $quantitySold');
//       print('Amount Earned: $amountEarned');
//
//       // Update balance
//       setState(() {
//         balance += amountEarned;
//       });
//       await _balanceRef.set(balance);
//       print('Balance updated: $balance');
//
//       // Log sale in orders
//       await ordersRef.push().set({
//         'symbol': widget.stock.symbol,
//         'quantity': -quantitySold,
//         'price': price,
//         'amountSpent': -amountEarned,
//         'date': DateTime.now().toIso8601String(),
//       });
//       print('Order added to Firebase');
//
//       // Update portfolio
//       final portfolioSnapshot = await portfolioRef.child(widget.stock.symbol).get();
//       print('Portfolio snapshot: ${portfolioSnapshot.value}');
//
//       if (portfolioSnapshot.exists) {
//         final currentQuantity =
//             (portfolioSnapshot.value as Map)['quantity']?.toDouble() ?? 0.0;
//         print('Current Quantity: $currentQuantity');
//
//         final updatedQuantity = currentQuantity - quantitySold;
//         print('Updated Quantity: $updatedQuantity');
//
//         if (updatedQuantity > 0) {
//           await portfolioRef.child(widget.stock.symbol).update({
//             'quantity': updatedQuantity,
//           });
//           print('Quantity updated in portfolio');
//         } else if (updatedQuantity == 0) {
//           await portfolioRef.child(widget.stock.symbol).remove();
//           print('Stock removed from portfolio');
//         } else {
//           print('Unexpected quantity update: $updatedQuantity');
//         }
//       }
//
//       // Send Push Notification
//       await sendNotification(
//         'Sale Successful',
//         'You sold $quantitySold shares of ${widget.stock.symbol} for \$${amountEarned.toStringAsFixed(2)}.',
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sale successful!')),
//       );
//     } catch (e) {
//       print('Error completing sale: $e'); // Log the error for debugging
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sale failed!')),
//       );
//     }
//   }
//
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Stock.dart';
import 'PortfolioPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  double price = 0.0;
  double volume = 0.0;
  double balance = 0.0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _watchlistRef;
  late DatabaseReference _balanceRef;
  late DatabaseReference _portfolioRef;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _portfolioRef = FirebaseDatabase.instance.ref('portfolio/$userId');
    _balanceRef = FirebaseDatabase.instance.ref('users/$userId/balance');
    _watchlistRef = FirebaseDatabase.instance.ref('watchlist/$userId');
    fetchStockQuantity();
    checkIfInWatchlist();
    fetchBalance();
    fetchStockDetails();
    fetchChartData();
    fetchStockDescription();
  }

  Future<void> fetchStockQuantity() async {
    try {
      final snapshot = await _portfolioRef.child(widget.stock.symbol).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          widget.stock.quantity = double.parse(data['quantity'].toString());
        });
      } else {
        setState(() {
          widget.stock.quantity = 0.0;
        });
      }
    } catch (e) {
      print('Error fetching stock quantity: $e');
      setState(() {
        widget.stock.quantity = 0.0;
      });
    }
  }

  Future<void> checkIfInWatchlist() async {
    final snapshot = await _watchlistRef.child(widget.stock.symbol).get();
    setState(() {
      isInWatchlist = snapshot.exists;
    });
  }

  Future<void> fetchBalance() async {
    try {
      final snapshot = await _balanceRef.get();
      if (snapshot.exists) {
        setState(() {
          balance = double.parse(snapshot.value.toString());
        });
      }
    } catch (e) {
      print('Error fetching balance: $e');
    }
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
        'price': price,
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
    String apiKey = 'S4ts5DZG3QleS272pmnx1fQKJ8mVZvYn';
    String symbol = widget.stock.symbol;
    String apiUrl = 'https://financialmodelingprep.com/api/v3/quote/$symbol?apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            open = data[0]['open']?.toDouble() ?? 0.0;
            close = data[0]['previousClose']?.toDouble() ?? 0.0;
            high = data[0]['dayHigh']?.toDouble() ?? 0.0;
            low = data[0]['dayLow']?.toDouble() ?? 0.0;
            price = data[0]['price']?.toDouble() ?? 0.0;
            volume = data[0]['volume']?.toDouble() ?? 0.0;
          });
        }
      } else {
        throw Exception('Failed to fetch stock details');
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

    String apiKey = 'S4ts5DZG3QleS272pmnx1fQKJ8mVZvYn';
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
        apiUrl = 'https://financialmodelingprep.com/api/v3/historical-price-full/$symbol?from=${DateFormat('yyyy-MM-dd').format(thirtyDaysAgo)}&to=${DateFormat('yyyy-MM-dd').format(today)}&apikey=$apiKey';
        break;
      case '1Y':
        DateTime today = DateTime.now();
        DateTime oneYearAgo = today.subtract(Duration(days: 365));
        apiUrl = 'https://financialmodelingprep.com/api/v3/historical-price-full/$symbol?from=${DateFormat('yyyy-MM-dd').format(oneYearAgo)}&to=${DateFormat('yyyy-MM-dd').format(today)}&apikey=$apiKey';
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
            List<dynamic> historicalData = selectedPeriod == '1D' || selectedPeriod == '5D' ? data : data['historical'] ?? [];

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
    String apiKey = 'S4ts5DZG3QleS272pmnx1fQKJ8mVZvYn';
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
  void showSellDialog() {
    TextEditingController quantityController = TextEditingController();
    double amountEarned = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Sell ${widget.stock.symbol}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Enter quantity to sell'),
                    onChanged: (value) {
                      double enteredQuantity = double.tryParse(value) ?? 0.0;
                      if (enteredQuantity > 0 && price > 0) {
                        setDialogState(() {
                          amountEarned = enteredQuantity * price;
                        });
                      } else {
                        setDialogState(() {
                          amountEarned = 0.0;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Available Quantity: ${widget.stock.quantity?.toStringAsFixed(2) ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Amount Earned: \$${amountEarned.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    double enteredQuantity = double.tryParse(quantityController.text) ?? 0.0;
                    if (enteredQuantity > (widget.stock.quantity ?? 0.0)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Insufficient quantity to sell!')),
                      );
                    } else if (enteredQuantity > 0) {
                      await completeSale(enteredQuantity, amountEarned);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid quantity entered!')),
                      );
                    }
                  },
                  child: Text('Sell'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showBuyDialog() {
    TextEditingController amountController = TextEditingController();
    double quantity = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Buy ${widget.stock.symbol}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Enter amount to spend'),
                    onChanged: (value) {
                      double enteredAmount = double.tryParse(value) ?? 0.0;
                      if (enteredAmount > 0 && price > 0) {
                        setDialogState(() {
                          quantity = enteredAmount / price;
                        });
                      } else {
                        setDialogState(() {
                          quantity = 0.0;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Available Balance: \$${balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Quantity: ${quantity.toStringAsFixed(2)} shares',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
                    if (enteredAmount > balance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Insufficient balance!')),
                      );
                    } else if (enteredAmount > 0 && quantity > 0) {
                      await completePurchase(quantity, enteredAmount);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid amount entered!')),
                      );
                    }
                  },
                  child: Text('Buy'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> completePurchase(double quantity, double amountSpent) async {
    DatabaseReference ordersRef = FirebaseDatabase.instance.ref('orders/${_auth.currentUser?.uid ?? ''}');
    DatabaseReference portfolioRef = FirebaseDatabase.instance.ref('portfolio/${_auth.currentUser?.uid ?? ''}');
    try {
      setState(() {
        balance -= amountSpent;
      });
      await _balanceRef.set(balance);

      await ordersRef.push().set({
        'symbol': widget.stock.symbol,
        'quantity': quantity.toStringAsFixed(2),
        'price': price,
        'amountSpent': amountSpent,
        'date': DateTime.now().toIso8601String(),
      });

      final portfolioSnapshot = await portfolioRef.child(widget.stock.symbol).get();
      if (portfolioSnapshot.exists) {
        final currentQuantity = double.parse((portfolioSnapshot.value as Map)['quantity'].toString());
        await portfolioRef.child(widget.stock.symbol).update({
          'quantity': (currentQuantity + quantity).toStringAsFixed(2),
        });
      } else {
        await portfolioRef.child(widget.stock.symbol).set({
          'symbol': widget.stock.symbol,
          'quantity': quantity.toStringAsFixed(2),
          'price': price,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase successful!')),
      );
    } catch (e) {
      print('Error completing purchase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed!')),
      );
    }
  }

  Future<void> completeSale(double quantitySold, double amountEarned) async {
    DatabaseReference ordersRef = FirebaseDatabase.instance.ref('orders/${_auth.currentUser?.uid ?? ''}');
    DatabaseReference portfolioRef = FirebaseDatabase.instance.ref('portfolio/${_auth.currentUser?.uid ?? ''}');
    try {
      setState(() {
        balance += amountEarned;
      });
      await _balanceRef.set(balance);

      await ordersRef.push().set({
        'symbol': widget.stock.symbol,
        'quantity': (-quantitySold).toStringAsFixed(2),
        'price': price,
        'amountSpent': -amountEarned,
        'date': DateTime.now().toIso8601String(),
      });

      final portfolioSnapshot = await portfolioRef.child(widget.stock.symbol).get();
      if (portfolioSnapshot.exists) {
        final currentQuantity = double.parse((portfolioSnapshot.value as Map)['quantity'].toString());
        final updatedQuantity = currentQuantity - quantitySold;

        if (updatedQuantity > 0) {
          await portfolioRef.child(widget.stock.symbol).update({
            'quantity': updatedQuantity.toStringAsFixed(2),
          });
        } else {
          await portfolioRef.child(widget.stock.symbol).remove();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale successful!')),
      );
    } catch (e) {
      print('Error completing sale: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale failed!')),
      );
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
            Text(widget.stock.symbol, style: TextStyle(color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  onPressed: showBuyDialog,
                  child: Text('Buy'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: showSellDialog,
                  child: Text('Sell'),
                ),
                IconButton(
                  icon: Icon(
                      isInWatchlist ? Icons.favorite : Icons.favorite_border,
                      color: Colors.pink),
                  onPressed: toggleWatchlist,
                ),
              ],
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
                    .map((period) =>
                    DropdownMenuItem<String>(
                      value: period,
                      child: Text(period, style: TextStyle(color: Colors
                          .black)),
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
                    minY: chartData.isEmpty ? 0 : chartData.map((e) => e.y)
                        .reduce((a, b) => a < b ? a : b),
                    maxY: chartData.isEmpty ? 0 : chartData.map((e) => e.y)
                        .reduce((a, b) => a > b ? a : b),
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
                        interval: chartData.isNotEmpty
                            ? (chartData.map((e) => e.y).reduce((a, b) =>
                        a > b
                            ? a
                            : b)) / 4
                            : 1,
                        getTitles: (value) => '\$${value.toStringAsFixed(2)}',
                        getTextStyles: (value) =>
                            TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Overview', style: TextStyle(color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildStockDetailGrid(),
              SizedBox(height: 20),
              Text('Description', style: TextStyle(color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
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
                      showFullDescription ? 'Show less' : 'Read more...',
                      style: TextStyle(color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
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
          _buildStockDetailTile('Price', '\$${price.toStringAsFixed(2)}'),
          _buildStockDetailTile('Open', '\$${open.toStringAsFixed(2)}'),
          _buildStockDetailTile('Close', '\$${close.toStringAsFixed(2)}'),
          _buildStockDetailTile('High', '\$${high.toStringAsFixed(2)}'),
          _buildStockDetailTile('Low', '\$${low.toStringAsFixed(2)}'),
          _buildStockDetailTile('Volume', volume.toStringAsFixed(0)),
        ],
      ),
    );
  }

  Widget _buildStockDetailTile(String title, String value) {
    return Container(
      width: (MediaQuery
          .of(context)
          .size
          .width / 2) - 24,
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
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}