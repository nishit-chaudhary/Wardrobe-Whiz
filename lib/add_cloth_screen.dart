
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'dart:io';

class AddClothScreen extends StatefulWidget {
  @override
  _AddClothScreenState createState() => _AddClothScreenState();
}

class _AddClothScreenState extends State<AddClothScreen> {
  dynamic _image;
  dynamic _imageHeight;
  dynamic _imageWidth;
  final picker = ImagePicker();
  bool _loading = false;
  String _description = '';
  dynamic _recognitions;
  late FlutterVision vision;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    vision = FlutterVision();
    await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/best-fp16.tflite',
        modelVersion: "yolov5",
        quantization: false,
        numThreads: 1,
        useGpu: false);
    print("Model Loaded Successfully!!");
  }

  Future<void> processImage() async {
    setState(() {
      _loading = true;
    });

    // Convert image to byte data
    print('Hello.....');
    final Uint8List byte = await _image.readAsBytes();
    // ByteBuffer buffer = byteData.buffer;

// Create a Uint8List view of the buffer
//     final Uint8List byte = Uint8List.view(buffer);
//     final Uint8List byte = await _image.readAsBytes();
//     final Uint8List byte = byteData.buffer.asUint8List();
    print('Running Model.....');
    // Perform inference with TensorFlow Lite model
    // List? output = await Tflite.runModelOnBinary(
    //   binary: uint8List,
    //   asynch: true,
    // );

    // var recognitions = await Tflite.detectObjectOnImage(
    //   path: _image.path,
    //   model: "YOLO",
    // );

    // setState(() {
    //   _recognitions = recognitions;
    // });
    //
    // print(recognitions);
    // ByteBuffer buffer = byteData.buffer;

// Create a Uint8List view of the buffer
//     Uint8List byte = Uint8List.view(buffer);
//     Uint8List imgBytes = buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    final result = await vision.yoloOnImage(
        bytesList: byte,
        imageHeight:_imageHeight,
        imageWidth:_imageWidth,
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.7);
    print('Lesgoooo!!!');
    print(result);
    // Parse output to get description
    // Replace this with your actual parsing logic
    _description = 'This is a description of the processed image';
    if (result.isEmpty) {
      // Show alert


      _showEmptyResultsAlert(context);
    }
    else
    {
      _description ="The given image contains the Following Clothing items :";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessedImageScreen(image: _image, description: _description),
        ),
      );


    }


    setState(() {
      _loading = false;
    });


  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    print("Got Image !!!");
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        final image = Image.file(File(pickedFile.path));
        image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener(
              (ImageInfo info, bool _) {
            print("Storing Size !!!!");
            _imageWidth=info.image.width;
            _imageHeight=info.image.height;
          },
        ));



      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Cloth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image selected.')
                : Image.file(
              _image,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: ()=>getImage(ImageSource.camera),
              child: Text('Take Photo'),
            ),
            ElevatedButton(
                onPressed: () => getImage(ImageSource.gallery),
                child: Text('Choose from Gallery')),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator() // Show loading indicator if processing
                : ElevatedButton(
              onPressed: _image != null ? processImage : null,
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcessedImageScreen extends StatelessWidget {
  final File image;
  final String description;

  ProcessedImageScreen({required this.image, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processed Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(
              image,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

void _showEmptyResultsAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('No Clothing Detected'),
        content: Text('Could not detect any clothing. Please try with another picture.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
