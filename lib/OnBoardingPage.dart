import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/EditProfilePage.dart';
import 'package:stocker/HomePageWithNavBar.dart';
import 'HomePage.dart';  // Import your HomePage
import 'ProfilePage.dart';  // Import your Profile Setup Page

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentIndex = 0;

  final List<String> _images = [
    'assets/onboard.jpg', // Replace with your onboarding image paths
    'assets/onboard.jpg',
    'assets/onboard.jpg',
  ];

  final List<String> _titles = [
    "Track Your Investments",
    "Analyze Market Trends",
    "Buy & Sell with Ease",
  ];

  final List<String> _descriptions = [
    "Stay updated with real-time stock updates.",
    "Analyze market trends with detailed charts.",
    "Invest smartly with quick buying and selling options.",
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to check if the user profile exists in Firestore
  Future<void> _onNextButtonPressed() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Check if the user's document exists in the 'users' collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // If the user profile exists, navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageWithNavBar()),
        );
      } else {
        // If the user profile doesn't exist, navigate to ProfilePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EditProfilePage()),
        );
      }
    } else {
      // If no user is logged in, navigate to ProfilePage (prompt for sign up)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.6,
              autoPlay: true,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: _images.map((image) {
              int index = _images.indexOf(image);
              return Column(
                children: [
                  Image.asset(
                    image,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Text(
                    _titles[index],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _descriptions[index],
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _images.map((url) {
              int index = _images.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Colors.blue
                      : Colors.grey[400],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _onNextButtonPressed,
              child: Text(
                'Next',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
