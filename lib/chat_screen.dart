import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'dart:io';


class ChatMessage {
  final String text;
  final List<dynamic> clothes;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser,required this.clothes});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'clothes':clothes,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        clothes:json['clothes']
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<List<String>> _clothes=[];
  String forecast="";
  bool _showimage=false;
  stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  dynamic _endpoint;
  bool _isLoading = true; // Flag to control loading state
  bool _isListening = false;
  @override
  void initState() {
    super.initState();
    _loadEndpoint();
    _loadChatHistory();
    _initializeSpeech();
    _getForecast();
  }

  void _initializeSpeech() async {
    bool isAvailable = await _speech.initialize();
    if (!isAvailable) {
      print('Speech recognition not available');
    }
  }

  Future<http.Response> sendQuery(String message,String user,String pass) async {
    final response = await http.post(
        Uri.parse(
            _endpoint + "/chat"), // Replace api_endpoint with your API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"body": json.encode({"message":message,"user":user,"pass":pass})})
    ).timeout(Duration(seconds: 30));
    return response;
  }



  Future<void> _loadEndpoint() async {
    print("Connecting to database !!!");
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      print("Firebase Initialized Successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
    final ref = FirebaseDatabase.instance.ref().child('api');
    print("Getting Snapshot");
    dynamic snapshot = await ref.get();
    _endpoint = snapshot.value.toString();
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
    List<String> clothes=[];
    _showimage=true;
    // Your code to send message and handle response goes here...
    setState(() {
      _isLoading = true;
      // Add the user's message to the chat history
      _messages.add(ChatMessage(
        text: message,
        clothes:clothes,
        isUser: true,
      ));
    });

    // Simulating API call delay
    //   await Future.delayed(Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ?? '';
    dynamic response = await sendQuery(message+forecast,username,password);

    clothes=List<String>.from(json.decode(response.body.toString())['response'] as List);
    print(clothes);
    Set<String> uniquePaths = Set(); // Using a set to avoid duplicates
    List<String> validPaths = []; // To store valid paths

    for (String path in clothes) {
      // Check if the path exists (file or directory)
      bool exists = await (File("/data/user/0/com.example.wardrobe_whiz/app_flutter/savedImages/"+path).exists());

      // Add to the list if it's valid and not a duplicate
      if (exists && !uniquePaths.contains(path)) {
        uniquePaths.add(path); // Add to the set to avoid duplicates
        validPaths.add(path); // Add to the list of valid paths
      }

    }
      String resText="Recommended clothes :";
      if(validPaths.isEmpty)
        {
          resText="Sorry, I couldn't find any clothes that match your preferences at the moment. Could you please try again?";
        }

    // Simulate the chatbot's response (replace with actual chatbot response)
    setState(() {
      _isLoading = false;
      print(response.body.toString());
      _messages.add(ChatMessage(
          text: resText,
          isUser: false,
          clothes:validPaths
      ));
    });

    // Save the updated chat history to SharedPreferences

    prefs.setStringList(
      'chat_history',
      _messages.map((message) => jsonEncode(message.toJson())).toList(),
    );

    // Clear the message text field
    _messageController.clear();
    // Example code to simulate response from chatbot
  }

  Future<Position> _getLocation() async{
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    dynamic loc= await Geolocator.getCurrentPosition();
    print("Getting Location!!");
    print(loc);
    return loc;
  }
  Future<http.Response> getWeather(String message) async {
    final response = await http.get(
      Uri.parse("http://api.weatherapi.com/v1/current.json?key=f2316321459d48e2a5c34518242404&q="
          +message+"Bangalore&aqi=no"),
      // Replace api_endpoint with your API endpoint
    );
    return response;
  }
  void _getForecast() async
  {
    Position position = await _getLocation();
    final response= await getWeather(position.latitude.toString()+","+position.longitude.toString());
    dynamic x=json.decode(response.body.toString());
    print(x);
    String f=x["current"]["condition"]["text"];
    String p="precipitation:"+x["current"]["precip_mm"].toString()+"huidity:"+x["current"]["humidity"].toString();
    // forecast="Weather forecast : "+f+" "+p;
    forecast="Weather forecast : "+f;


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('chat_history',[]);
              setState(() {
                _messages = [];
              });
              // Handle button tap, navigate, or perform an action
              print('delete button tapped');
            },
          ),
        ],
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
                    child:Column(
                        children: <Widget>[ ChatBubble(
                          message: _messages[index],
                        ),

                        ]
                    )
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
                  icon: Icon(!_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _isLoading // Disable button when loading
                      ? null
                      : () {
                    setState(() {
                      _isListening = !_isListening;
                    });
                    if (_isListening) {
                      _speech.listen(
                        onResult: (result) {
                          setState(() {
                            _messageController.text =
                                result.recognizedWords;

                          });
                        },
                      );
                    } else {
                      _speech.stop();
                      if (_messageController.text.isNotEmpty) {
                        _sendMessage(_messageController.text);
                      }
                    }
                  },
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

        child:Column(

            children: <Widget>[ Text(
              message.text,
              style: TextStyle(fontSize: 16.0),
            ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: message.clothes.length,
                itemBuilder: (context, i) {
                  String imagePath = message.clothes[i];

                  return GestureDetector(
                    child: Card(
                      child: Image.file(
                        File("/data/user/0/com.example.wardrobe_whiz/app_flutter/savedImages/"+imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ]
        ),
      ),
    );
  }
}
