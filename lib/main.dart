import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stocker/SplashScreen.dart';
import 'RegisterPage.dart';
import 'LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform, // Use platform-specific options
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
