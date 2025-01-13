import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BankAccountPage extends StatefulWidget {
  @override
  _BankAccountPageState createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  double _balance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Stripe initialization
    Stripe.instance.applySettings().then((_) {
      debugPrint("Stripe initialized");
    });

    _fetchBalance();
  }

  // Fetch user balance from Firebase
  Future<void> _fetchBalance() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _databaseRef.child('users/${user.uid}/balance').get();
    if (snapshot.value != null) {
      setState(() {
        _balance = snapshot.value as double;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Add funds using the Stripe Payment Sheet
  Future<void> _addFunds(double amount) async {
    try {
      // Step 1: Create a payment intent using your backend
      final clientSecret = await _createPaymentIntent(amount);

      // Step 2: Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your App Name',
        ),
      );

      // Step 3: Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Update the balance in Firebase and the UI
      User? user = _auth.currentUser;
      if (user != null) {
        final newBalance = _balance + amount;
        await _databaseRef.child('users/${user.uid}/balance').set(newBalance);

        setState(() {
          _balance = newBalance;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Funds added successfully!')),
        );
      }
    } catch (e) {
      // Handle errors
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stripe Error: ${e.error.localizedMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Create a payment intent using your backend
  Future<String> _createPaymentIntent(double amount) async {
    final response = await http.post(
      Uri.parse('http://192.168.2.47:3000/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': (amount * 100).toInt(), // Convert to cents
        'currency': 'usd',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['clientSecret'];
    } else {
      throw Exception('Failed to create payment intent');
    }
  }

  // Show a dialog to enter the amount to add
  void _showAddFundsDialog() {
    double enteredAmount = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Amount'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter amount in USD'),
            onChanged: (value) {
              enteredAmount = double.tryParse(value) ?? 0.0;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (enteredAmount > 0) {
                  _addFunds(enteredAmount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid amount!')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Account'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Balance: \$${_balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _balance == 0.0
                ? Text('No funds available, add funds!')
                : SizedBox.shrink(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddFundsDialog,
              child: Text('Add Funds'),
            ),
          ],
        ),
      ),
    );
  }
}
