import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Assuming your login screen is in this file
import 'home_screen.dart'; // Assuming your home screen is in this file

import 'add_cloth_screen.dart';
import 'view_wardrobe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Wardrobe Whiz',
        theme: ThemeData(
          // Your theme configurations here
        ),
        home: LoginScreen(),
        routes: {
          '/addCloth': (context) => AddClothScreen(),
          '/viewWardrobe': (context) => MyWardrobeScreen(),
          '/home': (context) => HomeScreen(),
        }
      // Redirect based on login status
    );
  }
}
