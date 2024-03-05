import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Assistant'),
      ),
      body: const ChatWidget(),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage(String message) {
    setState(() {
      _messages.add("User: $message");
      _messages.add("Chatbot: Thanks for your message!");
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_messages[index]),
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
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
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
    );
  }
}
