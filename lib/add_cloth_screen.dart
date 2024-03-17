import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'dart:io';
import 'dart:ui';
import 'package:palette_generator/palette_generator.dart';
import 'store_cloth_details.dart';

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
        imageHeight: _imageHeight,
        imageWidth: _imageWidth,
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.7);
    print('Lesgoooo!!!');
    print(result);
    // print(result[0]["tag"]);


    // Parse output to get description
    // Replace this with your actual parsing logic
    // _description = 'This is a description of the processed image';
    if (result.isEmpty) {
      // Show alert

      _showEmptyResultsAlert(context);
    } else {
      _description = result[0]["tag"];
      _result=result;
      await extractColorFromYOLOCoordinates();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessedImageScreen(
              image: _image, description: _description, color: _clothColor),
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

  Future extractColorFromYOLOCoordinates()  async {
    // Load the image
    // final ImageProvider imageProvider = AssetImage(_imgPath);

    // Define the YOLO coordinates (left, top, width, height)
    double left = _result[0]["box"][0]; // X-coordinate of the top-left corner
    double top = _result[0]["box"][1]; // Y-coordinate of the top-left corner
    double width = _result[0]["box"][2]; // Width of the region
    double height = _result[0]["box"][3];
    print(height.floor());
    //  print(_imageHeight);
    // if(width.floor()>_imageWidth)
    //   {
    //     width=_imageWidth-1;
    //   }
    // if(height.floor()>_imageHeight)
    //   {
    //     height=_imageHeight-1;
    //   }
    width=width/1.2;
    height=height/1.2;

    // dynamic left = double.arse('$_result[0]["box"][0].toStringAsFixed(2)'); // X-coordinate of the top-left corner
    // dynamic top = double.tryParse('$_result[0]["box"][1].toStringAsFixed(2)'); // Y-coordinate of the top-left corner
    // dynamic width = double.tryParse('$_result[0]["box"][2].toStringAsFixed(2)'); // Width of the region
    // dynamic height = double.tryParse('$_result[0]["box"][3].toStringAsFixed(2)');// Height of the region
    print("defining region");
    // Define the region using the YOLO coordinates
    final Rect region = Rect.fromLTWH(left, top, width, height);
    print("Region Defined .... Extracting color");
    // Extract the dominant color from the specified region
    // extractDominantColorFromRegion(imageProvider, region).then((Color color) {
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      FileImage(_image),
      size: Size(_imageWidth+0.0,_imageHeight+0.0), // Specify image size if necessary
      region:region, // Specify region if necessary
    );
    Color color = paletteGenerator.dominantColor!.color;
    _clothColor = color;

    print('Dominant color in the region: $color');
    // Use the extracted color as needed
    // });
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
