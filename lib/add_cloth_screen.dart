import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_vision/flutter_vision.dart';

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'dart:ui';
import 'package:palette_generator/palette_generator.dart';
import 'store_cloth_details.dart';
// import 'package:pytorch_lite/pytorch_lite.dart';

// import 'package:flutter_pytorch/flutter_pytorch.dart';
// import 'package:pytorch_mobile/pytorch_mobile.dart';
class AddClothScreen extends StatefulWidget {
  @override
  _AddClothScreenState createState() => _AddClothScreenState();
}

class _AddClothScreenState extends State<AddClothScreen> {
  dynamic _image;
  dynamic _imageHeight;
  dynamic _imageWidth;
  dynamic _imgPath;
  dynamic _clothColor;
  final picker = ImagePicker();
  bool _loading = false;
  String _description = '';
  dynamic _result;
  dynamic _endpoint;

  // late FlutterVision vision;

  @override
  void initState() {
    super.initState();
    // loadModel();
    _loadEndpoint();
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
    final ref = FirebaseDatabase.instance.ref().child('cloth');
    print("Getting Snapshot");
    dynamic snapshot = await ref.get();
    _endpoint = snapshot.value.toString();
    print(snapshot.value.toString());

    // Data fetched, set isLoading to false

  }

  // Future<void> loadModel() async {
  //   vision = FlutterVision();
  //   await vision.loadYoloModel(
  //       labels: 'assets/labels.txt',
  //       modelPath: 'assets/best-fp16.tflite',
  //       modelVersion: "yolov5",
  //       quantization: false,
  //       numThreads: 1,
  //       useGpu: false);
  //   print("Model Loaded Successfully!!");
  // }

  Future<void> processImage() async {
    setState(() {
      _loading = true;
    });
    // dynamic _imageModel = await PyTorchMobile
    //     .loadModel('assets/model.pt');

    print('Hello.....');
    final Uint8List byte = await _image.readAsBytes();

    print('Running Model.....');

    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      print("Firebase Initialized Successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
    final ref = FirebaseDatabase.instance.ref().child('cloth');
    print("Getting Snapshot");
    dynamic snapshot = await ref.get();
    _endpoint = snapshot.value.toString();
    print(snapshot.value.toString());

    // Data fetched, set isLoading to false



    // var request = http.MultipartRequest("POST", Uri.parse(_endpoint+"/upload-image"));
    // var multipartFile = await http.MultipartFile.fromPath("file", _image!.path);
    // request.files.add(multipartFile);
    //
    // var response = await request.send();
    //
    // if (response.statusCode == 200) {
    //   print("Image uploaded successfully");
    //   print(response.toString());
    // } else {
    //   print("Image upload failed");
    //   print(response.toString());
    // }
    // if (response.statusCode == 200) {
    //   var responseBody = await response.stream.bytesToString();
    //   var jsonResponse = json.decode(responseBody); // If response is JSON
    //   print("Success: ${jsonResponse['message']}"); // Reading a specific key
    // } else {
    //   print("Failed with status code: ${response.statusCode}");
    //   var responseBody = await response.stream.bytesToString();
    //   var jsonResponse = json.decode(responseBody); // If response is JSON
    //   print("Success: ${jsonResponse['message']}"); // Readi
    // }
    // var request = http.MultipartRequest(
    //   'POST',
    //   Uri.parse(_endpoint+"/upload-image"),
    // );
    // Map<String, String> headers = {"Content-type": "multipart/form-data"};
    // request.files.add(
    //   http.MultipartFile(
    //     'image',
    //     _image.readAsBytes().asStream(),
    //     _image.lengthSync(),
    //     filename: 'filename',
    //
    //   ),
    // );
    // request.headers.addAll(headers);
    // print("request: " + request.toString());
    // request.send().then((value) => print(value.statusCode));

    // var request = http.MultipartRequest('POST', Uri.parse(_endpoint+"/upload-image"));
    //
    // // Attach the file to the multipart request
    // var stream = await _image.openRead().toList();
    // var fileBytes = stream.expand((i) => i).toList();
    // request.files.add(http.MultipartFile.fromBytes('image', fileBytes, filename: _image.path.split('/').last));
    //
    // // Send the request
    // var response = await request.send();
    // if (response.statusCode == 200) {
    //   print("Image uploaded successfully");
    // } else {
    //   print("Failed to upload image");
    // }

    var fileBytes = await _image.readAsBytes();

    // Send HTTP POST request with raw bytes
    var response = await http.post(
      Uri.parse(_endpoint+"/upload-image"),
      headers: {
        'Content-Type': 'application/octet-stream',  // or another content type as needed
      },
      body: fileBytes,
    );

    if (response.statusCode == 200) {
      print("Successfully sent bytes");
    } else {
      print("Failed to send bytes: ${response.statusCode}");
    }
    dynamic data = json.decode(response.body.toString());
    Color color = Color(int.parse("0xff"+data['color']));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessedImageScreen(
            imagePath: _imgPath, category: data['cloth'], color: color),
      ),
    );




    // final result = await vision.yoloOnImage(
    //     bytesList: byte,
    //     imageHeight: _imageHeight,
    //     imageWidth: _imageWidth,
    //     iouThreshold: 0.8,
    //     confThreshold: 0.4,
    //     classThreshold: 0.7);
    // print('Lesgoooo!!!');
    // print(result);
    // print(result[0]["tag"]);

    // Parse output to get description
    // if (result.isEmpty) {
    //   // Show alert
    //   _showEmptyResultsAlert(context);
    // } else {
    //   _description = result[0]["tag"];
    //   _result = result;
    //   await extractColorFromYOLOCoordinates();
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ProcessedImageScreen(
    //           imagePath: _imgPath, category: _description, color: _clothColor),
    //     ),
    //   );
    // }
    // ClassificationModel classificationModel= await FlutterPytorch.loadClassificationModel(
    //     "assets/model.pt", _imageWidth, _imageHeight,labelPath: "assets/classes_imp.txt");
    // String imagePrediction = await classificationModel.getImagePrediction(byte);
    // print("Model Result !!!");
    // print(imagePrediction);
    // String prediction = await _imageModel
    //     .getImagePrediction(_image, 224, 224, "assets/classes_imp.txt");
    //
    // print(prediction);

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
        _imgPath = pickedFile.path;
        final image = Image.file(File(pickedFile.path));
        image.image
            .resolve(ImageConfiguration())
            .addListener(ImageStreamListener(
              (ImageInfo info, bool _) {
            print("Storing Size !!!!");
            _imageWidth = info.image.width;
            _imageHeight = info.image.height;
          },
        ));
      } else {
        print('No image selected.');
      }
    });
  }

  Future extractColorFromYOLOCoordinates() async {

    // Define the YOLO coordinates (left, top, width, height)
    double left = _result[0]["box"][0]; // X-coordinate of the top-left corner
    double top = _result[0]["box"][1]; // Y-coordinate of the top-left corner
    double width = _result[0]["box"][2]; // Width of the region
    double height = _result[0]["box"][3];
    print(height.floor());

    width = width / 1.2;
    height = height / 1.2;
    if(width+left>_imageWidth)
    {
      width=_imageWidth-left-1;
    }
    if(height+top>_imageHeight)
    {
      height=_imageHeight-top-1;
    }


    print("defining region");
    // Define the region using the YOLO coordinates
    final Rect region = Rect.fromLTWH(left, top, width, height);
    print("Region Defined .... Extracting color");
    // Extract the dominant color from the specified region

    final PaletteGenerator paletteGenerator =
    await PaletteGenerator.fromImageProvider(
      FileImage(_image),
      size: Size(_imageWidth + 0.0,
          _imageHeight + 0.0), // Specify image size if necessary
      region: region, // Specify region if necessary
    );
    Color color = paletteGenerator.dominantColor!.color;
    _clothColor = color;

    print('Dominant color in the region: $color');


  }

  Future<Color> extractDominantColorFromRegion(
      ImageProvider imageProvider, Rect region) async {
    // Load the image
    final PaletteGenerator paletteGenerator =
    await PaletteGenerator.fromImageProvider(imageProvider,
        region: region); // Specify the region to analyze
    // Get the dominant color from the palette
    Color dominantColor = paletteGenerator.dominantColor!.color;
    return dominantColor;
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
              onPressed: () => getImage(ImageSource.camera),
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

void _showEmptyResultsAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('No Clothing Detected'),
        content: Text(
            'Could not detect any clothing. Please try with another picture.'),
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
