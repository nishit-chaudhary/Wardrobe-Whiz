import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;



class ChatMessage
{

  final String text;
  final bool isUser;


  ChatMessage({required this.text, required this.isUser});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key});


  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  dynamic _endpoint;
  bool _isLoading = true; // Flag to control loading state

  @override
  void initState() {
    super.initState();
    _loadEndpoint();
    _loadChatHistory();
  }

  Future<http.Response> sendQuery(String message) async {
    final response = await http.post(
      Uri.parse(_endpoint+"/chat"), // Replace api_endpoint with your API endpoint
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"body":message}),
    );
    return response;
  }

  // Future<http.Response> sendQuery(String message) async {
  //   final response = await http.get(
  //     Uri.parse(_endpoint+"/chatbot").replace(queryParameters: {"body":message}),
  //     // Replace api_endpoint with your API endpoint
  //   );
  //   return response;
  // }

  Future<void> _loadEndpoint() async
  {
    print("Connecting to database !!!");
    try {
      await Firebase.initializeApp(
          options : DefaultFirebaseOptions.currentPlatform
      );
      print("Firebase Initialized Successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
    final ref = FirebaseDatabase.instance.ref().child('api');
    print("Getting Snapshot");
    dynamic snapshot = await ref.get();
    _endpoint=snapshot.value.toString();
    print(snapshot.value.toString());

    // Data fetched, set isLoading to false
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? messages = prefs.getStringList('chat_history');
    if (messages != null) {
      setState(() {
        _messages = messages.map((message) {
          Map<String, dynamic> json = jsonDecode(message);
          return ChatMessage.fromJson(json);
        }).toList();
      });
    }
  }

  void _sendMessage(String message) async {

    // Your code to send message and handle response goes here...
    setState(() {
      _isLoading = true;
      // Add the user's message to the chat history
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
      ));
    });

    // Simulating API call delay
    //   await Future.delayed(Duration(seconds: 2));
    dynamic response = await sendQuery(message);
    // Simulate the chatbot's response (replace with actual chatbot response)
    setState(() {
      _isLoading=false;
      _messages.add(ChatMessage(
        text: json.decode(response.body.toString())['messageResponse'],
        isUser: false,
      ));
    });

    // Save the updated chat history to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'chat_history',
      _messages.map((message) => jsonEncode(message.toJson())).toList(),
    );

    // Clear the message text field
    _messageController.clear();
    // Example code to simulate response from chatbot




  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  child: ChatBubble(
                    message: _messages[index],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isLoading, // Disable input field when loading
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isLoading // Disable button when loading
                      ? null
                      : () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                ),
                if (_isLoading) // Show loading indicator if loading
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ChatBubble extends StatelessWidget
{
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          message.text,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
