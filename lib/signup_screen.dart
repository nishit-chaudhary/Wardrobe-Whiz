import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedGender = ''; // This will store the selected gender
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: "First Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your first name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: "Last Name",
                ),
                validator: (value) {
                  if (value == null) {
                    return "Please enter your last name";
                  }
                  return null;
                },
              ),
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
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: "Age",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null) {
                    return "Please enter your age";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Gender",
                ),
                value: _selectedGender.isEmpty
                    ? null
                    : _selectedGender, // Default to null if no gender is selected
                items: ["Male", "Female", "Other"]
                    .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value ?? ''; // Update the selected gender
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a gender";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return "Please enter a password";
                  } else if (value.length < 6) {
                    return "Password must be at least 6 characters long";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Re-enter Password",
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return "Please re-enter your password";
                  } else if (value != _passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Handle signup logic here
                    _SignUp();
                    // You can navigate to the next screen or save the data
                    print("Error !");
                  }
                },
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _SignUp() async {
    print("Connecting to database !!!");
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      print("Firebase Initialized Successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
    final ref = FirebaseDatabase.instance.ref().child('users');

    print("Storing Details!!!");
    var bytes = utf8.encode(_emailController.text); // data being hashed

    var email = sha256.convert(bytes).toString();

    bytes = utf8.encode(_passwordController.text);
    // print(email.toString());
    print(email);
    var pass = sha256.convert(bytes).toString();
    var check = await ref.child(email).get();
    print(check.exists);
    // if (ref.child()) {
    //run som
    if (!check.exists) {
      await ref.update({
        email: {
          pass: {
            "fname": _firstNameController.text,
            "lname": _lastNameController.text,
            "age": _ageController.text,
            "gender": _selectedGender,
            "email": _emailController.text
          },
        },
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Check if the credentials match stored user data
      await prefs.setString('username', email);
      await prefs.setString('password', pass);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userInfo',json.encode({
        "fname": _firstNameController.text,
        "lname": _lastNameController.text,
        "age": _ageController.text,
        "gender": _selectedGender,
        "email": _emailController.text
      }));

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false, // This removes all previous routes
      );
    } else {
      _userExitsAlert(context);
    }
  }

  void _userExitsAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Up Failed'),
          content: Text('User already exists !!!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
                // Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
