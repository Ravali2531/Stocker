import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stocker/ProfileDetailsPage.dart';
import 'HomePage.dart'; // Replace with your actual page names
import 'PortfolioPage.dart';
import 'WatchListPage.dart';
import 'OrdersPage.dart';
import 'ProfilePage.dart';

class HomePageWithNavBar extends StatefulWidget {
  @override
  _HomePageWithNavBarState createState() => _HomePageWithNavBarState();
}

class _HomePageWithNavBarState extends State<HomePageWithNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(), // Home page
    WatchlistPage(), // Watchlist page
    PortfolioPage(), // Portfolio page
    OrdersPage(), // Orders page
    ProfileDetailsPage(), // Profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock App"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.lightBlue[50], // Light blue background
        selectedItemColor: Colors.blue, // Blue color for selected item
        unselectedItemColor: Colors.grey, // Grey for unselected items
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed, // Keeps the icons aligned
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
