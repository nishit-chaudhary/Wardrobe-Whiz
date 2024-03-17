import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:io';


class ProcessedImageScreen extends StatelessWidget {
  final File image;
  String description;
  dynamic color;
  dynamic _categoryController;

  ProcessedImageScreen(
      {required this.image, required this.description, required this.color});

  @override
  Widget build(BuildContext context) {
    _categoryController = TextEditingController(text: description);
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
              width: 250,
              height: 250,
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
                    description = value;
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
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
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
                  onPressed: () {
                    print(description);
                    print(color);
                  },
                  child: Text('Submit')),
            ),
          ],
        ),
      ),
    );
  }
}