import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'add_cloth_screen.dart';
import 'view_wardrobe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Wardrobe Whiz',
        theme: ThemeData(
          // Your theme configurations here
        ),
        home: const MyHomePage(title: 'Wardrobe Whiz'),
        routes: {
          '/addCloth': (context) => AddClothScreen(),
          '/viewWardrobe': (context) => MyWardrobeScreen()
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddClothScreen()),
                );
                // Add your logic for handling "Add Cloth" button press
                // Navigate to the screen for adding cloth or perform related actions
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent, // Button text color
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20), // Decreased border radius
                ),
                elevation: 4, // Button shadow
                fixedSize: Size(
                    screenWidth * 0.8,
                    screenWidth *
                        0.2), // Set the minimum width of the button to 80% of the screen width
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline), // Hanger icon for "Add Cloth"
                  SizedBox(width: 8), // Add spacing between icon and text
                  Text(
                    'Add Cloth',
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the ChatScreen when the "Chat" button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.greenAccent, // Button text color
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20), // Decreased border radius
                ),
                elevation: 4, // Button shadow
                fixedSize: Size(
                    screenWidth * 0.8,
                    screenWidth *
                        0.2), // Set the minimum width of the button to 80% of the screen width
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message), // Message icon for "Chat"
                  SizedBox(width: 8), // Add spacing between icon and text
                  Text(
                    'Chat',
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/viewWardrobe');
                // Add your logic for handling "Add Cloth" button press
                // Navigate to the screen for adding cloth or perform related actions
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple, // Button text color
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20), // Decreased border radius
                ),
                elevation: 4, // Button shadow
                fixedSize: Size(
                    screenWidth * 0.8,
                    screenWidth *
                        0.2), // Set the minimum width of the button to 80% of the screen width
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons
                      .inventory_2_outlined), // Hanger icon for "Add Cloth"
                  SizedBox(width: 8), // Add spacing between icon and text
                  Text(
                    'My Wardrobe',
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
