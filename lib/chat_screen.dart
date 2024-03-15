import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatMessage {
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

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
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
    setState(() {
      // Add the user's message to the chat history
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
      ));

      // Simulate the chatbot's response (replace with actual chatbot response)
      _messages.add(ChatMessage(
        text: "Thanks for your message!",
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
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
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
