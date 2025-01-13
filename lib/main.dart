import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Import flutter_stripe
import 'SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize Stripe
    Stripe.publishableKey =
    "pk_test_51QLXl2L0kLdfcs5yhjcDuc0WAnDoZgIu1Ts88JhU7ZpGDDmkZ8X6mkhAnRuFuhYQLePpmWrcKXJby0qtvMiw6FVc00DTOLaHK5"; // Replace with your Stripe Publishable Key
    Stripe.merchantIdentifier = 'merchant.com.stocker.app'; // Optional for Apple Pay
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint("Initialization error: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stocker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
