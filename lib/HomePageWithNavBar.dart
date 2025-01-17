import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'HomePage.dart';
import 'PortfolioPage.dart';
import 'WatchListPage.dart';
import 'OrdersPage.dart';
import 'ProfilePage.dart';
import 'Stock.dart';

class HomePageWithNavBar extends StatefulWidget {
  @override
  _HomePageWithNavBarState createState() => _HomePageWithNavBarState();
}

class _HomePageWithNavBarState extends State<HomePageWithNavBar> {
  int _selectedIndex = 0;
  double balance = 0.0;
  final List<Stock> portfolio = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid;
    _userRef = FirebaseDatabase.instance.ref('users/$userId');
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      // Fetch balance
      final balanceSnapshot = await _userRef.child('balance').get();
      if (balanceSnapshot.exists) {
        setState(() {
          balance = double.parse(balanceSnapshot.value.toString());
        });
      }

      // Fetch portfolio
      final portfolioSnapshot = await _userRef.child('portfolio').get();
      if (portfolioSnapshot.exists) {
        setState(() {
          final data = Map<String, dynamic>.from(portfolioSnapshot.value as Map);
          portfolio.clear();
          data.forEach((symbol, stockData) {
            final stock = Stock.fromMap(symbol, stockData);
            portfolio.add(stock);
          });
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      WatchlistPage(),
      PortfolioPage(),
      OrdersPage(),
      ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Stock App"),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.lightBlue[50],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
