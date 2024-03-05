import 'package:flutter/material.dart';
import 'chat_screen.dart';

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
    );
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
                // Add your logic for handling "Add Cloth" button press
                // Navigate to the screen for adding cloth or perform related actions
              },
              child: const Text('Add Cloth'),
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
              child: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
