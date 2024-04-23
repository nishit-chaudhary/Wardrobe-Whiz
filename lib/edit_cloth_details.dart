import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

class EditClothDetails extends StatelessWidget {
  dynamic image;
  dynamic category;
  dynamic color;
  String details = "Additional Details";
  String imagePath;
  dynamic initCat;
  dynamic _categoryController;

  EditClothDetails(
      {required this.imagePath,
        required this.category,
        required this.color,
        required this.details});

  @override
  Widget build(BuildContext context) {
    image = File(imagePath);
    initCat = category;
    _categoryController = TextEditingController(text: category);
    if (color == null) {
      color = Colors.green;
    }
    return Dialog(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                width: 200,
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
                  CircleAvatar(
                    backgroundColor: color,
                    radius: 16,
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
              padding: EdgeInsets.only(top: 20),
              child: Row(
                // Place the color circle and button in a row
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () async {
                        print(category);
                        print(color);
                        await storeClothDetails(
                            imagePath, category, color, details);

                        _saveClothSuccessAlert(context);
                      },
                      child: Text('Save')),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () async {
                        print(category);
                        print(color);
                        await deleteCloth(imagePath, category, color, details);

                        _deleteClothSuccessAlert(context);
                      },
                      child: Text('Delete')),
                ],
              ),
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

    Map<String, dynamic> clothes;
    Map<String, dynamic> catMap;
    if (clothesMapString != null && categoryMap != null) {
      clothes = json.decode(clothesMapString);
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

    clothInfo.add(category);
    clothInfo.add(details);
    clothInfo
        .add(color.toString().replaceAll('Color(', '').replaceAll(')', ''));
    clothDetails[imagePath] = clothInfo;

    if (!catMap.containsKey(category)) {
      List<String> cat = [];
      catMapDetails[category] = cat;
    }

    if (category != initCat) {
      catMapDetails.update(initCat, (value) {
        value.removeWhere((item) => item == imagePath);
        return value;
      });

      catMapDetails.update(category, (value) {
        value.add(imagePath);
        return value;
      });
    }

    print(catMapDetails);
    print(clothDetails);
    await prefs.setString('savedClothes', json.encode(clothDetails));
    await prefs.setString('catMap', json.encode(catMapDetails));

    String? storedUsername = prefs.getString('username') ?? '';
    String storedPassword = prefs.getString('password') ?? '';
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

    print("Cloth Details Stored Successfully!!!");
  }

  Future<void> deleteCloth(
      String imagePath, String category, Color color, String details) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clothesMapString = prefs.getString('savedClothes');
    String? categoryMap = prefs.getString('catMap');

    Map<String, dynamic> clothes;
    Map<String, dynamic> catMap;
    if (clothesMapString != null && categoryMap != null) {
      clothes = json.decode(clothesMapString);
      catMap = json.decode(categoryMap);
    } else {
      clothes = {};
      catMap = {};
    }
    Map<String, List<dynamic>> clothDetails =
    Map<String, List<dynamic>>.from(clothes);
    Map<String, List<dynamic>> catMapDetails =
    Map<String, List<dynamic>>.from(catMap);

    if (!catMap.containsKey(category)) {
      List<String> cat = [];
      catMapDetails[category] = cat;
    }

    catMapDetails.update(initCat, (value) {
      value.removeWhere((item) => item == imagePath);
      return value;
    });
    clothDetails.remove(imagePath);

    print(catMapDetails);
    print(clothDetails);
    await prefs.setString('savedClothes', json.encode(clothDetails));
    await prefs.setString('catMap', json.encode(catMapDetails));

    image.delete().then((_) {
      print('Image file deleted successfully');
    }).catchError((error) {
      print('Error deleting image file: $error');
    });

    String? storedUsername = prefs.getString('username') ?? '';
    String storedPassword = prefs.getString('password') ?? '';
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

    print("Cloth Deleted Successfully!!!");
  }

  void _saveClothSuccessAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Cloth Details'),
          content: Text('Cloth Details saved Successfully !!!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.popUntil(
                    context, ModalRoute.withName('/viewWardrobe'));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteClothSuccessAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Cloth'),
          content: Text('Cloth Deleted Successfully !!!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.popUntil(
                    context, ModalRoute.withName('/viewWardrobe'));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
