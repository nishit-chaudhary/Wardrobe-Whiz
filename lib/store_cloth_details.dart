import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';

class ProcessedImageScreen extends StatelessWidget {
  dynamic image;
  String category;
  dynamic color;
  String details = "Additional Details";
  String imagePath;
  dynamic _categoryController;

  ProcessedImageScreen(
      {required this.imagePath, required this.category, required this.color});

  Future<void> _loadEndpoint() async {
    print("Connecting to database !!!");
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      print("Firebase Initialized Successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
    final ref = FirebaseDatabase.instance.ref().child('users');
    print("Getting Snapshot");
    dynamic snapshot = await ref.get();
    // _endpoint = snapshot.value.toString();
    print(snapshot.value.toString());
    print(json.decode(snapshot.value.toString()));
    // Data fetched, set isLoading to false
    // setState(() {
    //   _isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    image = File(imagePath);
    _categoryController = TextEditingController(text: category);
    if (color == null) {
      color = Colors.green;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Processed Image'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Image.file(
              image,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.only(top: 25),
              child: Container(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Cloth Category',
                    border: OutlineInputBorder(),
                  ),
                  controller: _categoryController,
                  onChanged: (value) {
                    category = value;
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              padding: EdgeInsets.all(15.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Your existing widgets...
                    Container(
                      height: 100,
                      width: 300, // Set the height of the text field
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 4, // Allow unlimited lines
                        decoration: InputDecoration(
                          labelText: 'Additional Details :',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          details = value;
                          // Handle text field changes
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                // Place the color circle and button in a row
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 40),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 16,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Show color picker dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Pick a color'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: color,
                                  onColorChanged: (c) {
                                    c = color;
                                  },
                                  showLabel: true,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Done'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Cloth Color'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 25),
              child: ElevatedButton(
                  onPressed: () async {
                    print(category);
                    print(color);
                    await storeClothDetails(
                        imagePath, category, color, details);
                    // Navigator.pop(context);
                    // _addClothSuccessAlert(context);
                    _addClothSuccessAlert(context);
                  },
                  child: Text('Save')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> storeClothDetails(
      String imagePath, String category, Color color, String details) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clothesMapString = prefs.getString('savedClothes');
    String? categoryMap = prefs.getString('catMap');
    String? index = prefs.getString("index");
    String imgName = "image_";
    int uni = 0;

    String? storedUsername = prefs.getString('username') ?? '';
    String storedPassword = prefs.getString('password') ?? '';

    Map<String, dynamic> clothes;
    Map<String, dynamic> catMap;
    if (clothesMapString != null && index != null && categoryMap != null) {
      clothes = json.decode(clothesMapString);
      uni = int.parse(index);
      catMap = json.decode(categoryMap);
    } else {
      clothes = {};
      catMap = {};
    }
    Map<String, List<dynamic>> clothDetails =
    Map<String, List<dynamic>>.from(clothes);
    Map<String, List<dynamic>> catMapDetails =
    Map<String, List<dynamic>>.from(catMap);
    List<String> clothInfo = [];
    Directory appDir = await getApplicationDocumentsDirectory();
    String appDirPath = appDir.path;
    imgName = imgName + uni.toString();
    uni += 1;
    String newImagePath = '$appDirPath/savedImages/$category/$imgName.jpg';
    Directory('$appDirPath/savedImages/$category').createSync(recursive: true);

    File(imagePath).copySync(newImagePath);
    clothInfo.add(category);
    clothInfo.add(details);
    clothInfo
        .add(color.toString().replaceAll('Color(', '').replaceAll(')', ''));
    clothDetails[newImagePath] = clothInfo;

    if (!catMap.containsKey(category)) {
      List<String> cat = [];
      catMapDetails[category] = cat;
    }

    catMapDetails.update(category, (value) {
      value.add(newImagePath);
      return value;
    });

    print(catMapDetails);
    print(clothDetails);
    await prefs.setString('savedClothes', json.encode(clothDetails));
    await prefs.setString('index', uni.toString());
    await prefs.setString('catMap', json.encode(catMapDetails));

    print("Connecting to database !!!");
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      print("Firebase Initialized Successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
    final ref = FirebaseDatabase.instance
        .ref()
        .child('users/' + storedUsername + '/' + storedPassword);
    print("Getting Snapshot");
    dynamic snapshot = await ref.get();
    // print(snapshot.value.toString());
    print(snapshot.value);
    ref.update({"wardrobe": json.encode(clothDetails)});

    // Data fetched, set isLoading to false

    print("Cloth Details Stored Successfully!!!");
  }

  void _addClothSuccessAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Cloth'),
          content: Text('Cloth Details saved Successfully !!!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
