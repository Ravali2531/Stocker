import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountClosurePage extends StatefulWidget {
  @override
  _AccountClosurePageState createState() => _AccountClosurePageState();
}

class _AccountClosurePageState extends State<AccountClosurePage> {
  bool _isProcessing = false;

  Future<void> closeAccount() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Delete user document from Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // Delete user from Firebase Authentication
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );

        // Navigate back to the login page or any appropriate page
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Closure'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Closure Rules:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. This action is permanent and cannot be undone.\n'
                  '2. All your data, including personal information and transaction history, will be deleted.\n'
                  '3. Ensure you have withdrawn all funds before proceeding.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: closeAccount,
                child: const Text('Confirm Account Closure'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
