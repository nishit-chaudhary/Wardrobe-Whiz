import 'dart:convert';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  final String title = 'Wardrobe Whiz';

  @override
  State<SideMenu> createState() => _SideMenu();
}

class _SideMenu extends State<SideMenu> {
  dynamic _details;
  String name="John Doe";
  String email="john.doe@gmail.com";

  void initState()
  {
    _loadDetails();
  }

  Future<void> _loadDetails() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic det=await prefs.getString('userInfo');
    _details=json.decode(det);
    setState(() {
      name = _details['fname'] + " " + _details['lname'];
      email = _details["email"];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture:
            Icon(Icons.account_circle,size: 64.0),

          ),
          // ListTile(
          //   leading: Icon(Icons.account_circle),
          //   title: Text('View Profile'),
          //   onTap: () {
          //     // Navigate to the profile page
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => ProfilePage()),
          //     );
          //   },
          // ),
          Spacer(), // Pushes logout button to the bottom
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: ()async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              // await prefs.setBool('isLoggedIn',false);
              await prefs.clear();
              // Logout logic
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false, // This removes all previous routes
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Name: John Doe'),
            Text('Email: john.doe@example.com'),
            // Add more user details here
          ],
        ),
      ),
    );
  }
}
