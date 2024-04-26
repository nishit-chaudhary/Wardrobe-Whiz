import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'home_screen.dart'; // The main screen to navigate to after login
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void initState() {
    _checkLogin();
  }



  void _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') ?? false) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false, // This removes all previous routes
      );
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Check if the credentials match stored user data
      String? storedUsername = prefs.getString('username');
      String? storedPassword = prefs.getString('password');

      try {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
        print("Firebase Initialized Successfully");
      } catch (e) {
        print("Error initializing Firebase: $e");
      }
      var bytes = utf8.encode(_emailController.text); // data being hashed

      var email = sha256.convert(bytes).toString();

      bytes = utf8.encode(_passwordController.text);
      // print(email.toString());

      var pass = sha256.convert(bytes).toString();
      print(pass);
      final ref =
      FirebaseDatabase.instance.ref().child('users/' + email + '/' + pass);
      var check = await ref.get();
      print(check.value);
      dynamic x=check.value;
      if (check.exists) {


        await prefs.setString('username', email);
        await prefs.setString('password', pass);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userInfo',json.encode(check.value));
        _checkLogin();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false, // This removes all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid username or password")),
        );
      }

      // if (storedUsername == _usernameController.text && storedPassword == _passwordController.text) {
      //   await prefs.setBool('isLoggedIn', true);  // Set the login flag
      // Navigate to home screen
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Invalid username or password")),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkLogin();
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                ),
                obscureText: true, // For password fields
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  ); // Navigate to signup screen
                },
                child: Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
