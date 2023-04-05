import 'dart:ui' as ui;
import 'dart:io' as io;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'windowsWall.dart';

class FacePainter extends CustomPainter {
  FacePainter(this.image, this.positionStart, this.positionEnd, this.ListDoors,
      this.ListWindow, this.IsADoor);

  // To know if the door/windows is selected
  final bool IsADoor;
  // List of Doors
  final List<Rect> ListDoors;
  // List of Windows
  final List<Rect> ListWindow;
  // Background Image
  final ui.Image image;
  // Current startposition
  final Offset positionStart;
  // Current Endposition
  final Offset positionEnd;

  // Color for Windows
  Color colorWindows = ui.Color.fromARGB(255, 27, 0, 179);
  // Color for Doors
  Color colorDoors = ui.Color.fromARGB(255, 0, 179, 95);

  // Main function to print on the canvas

  void paint(Canvas canvas, ui.Size size) {
    // Upload image on the background
    canvas.drawImage(image, Offset.zero, Paint());
    // Render the door list
    for (var i = 0; i < ListDoors.length; i++) {
      canvas.drawRect(ListDoors[i], Paint()..color = colorDoors);
    }
    // Render the Window list
    for (var j = 0; j < ListWindow.length; j++) {
      canvas.drawRect(ListWindow[j], Paint()..color = colorWindows);
    }

    // If the current object is a door render it
    if (IsADoor) {
      double x = positionEnd.dx - positionStart.dx;
      double y = positionEnd.dy - positionStart.dy;
      canvas.drawRect(
          positionStart & ui.Size(x, y), Paint()..color = colorDoors);
    } else {
      // If the current object is a window render it
      double x = positionEnd.dx - positionStart.dx;
      double y = positionEnd.dy - positionStart.dy;
      canvas.drawRect(
          positionStart & ui.Size(x, y), Paint()..color = colorWindows);
    }
  }

  @override
  // This function triggers the main function everytime an element change
  bool shouldRepaint(FacePainter oldDelegate) {
    if (image != oldDelegate.image ||
        positionStart != oldDelegate.positionStart ||
        positionEnd != oldDelegate.positionEnd ||
        ListDoors != oldDelegate.ListDoors ||
        ListWindow != oldDelegate.ListWindow ||
        IsADoor != oldDelegate.IsADoor) {
      return true;
    } else {
      return false;
    }
  }
}

class DrawImage extends StatefulWidget {
  DrawImage(this.imagePath, this.height, this.width);
  String imagePath;
  double height;
  double width;

  @override
  _DrawImageState createState() => _DrawImageState();
}

class _DrawImageState extends State<DrawImage> {
  /*
################################################################
                          VARIABLES
################################################################
*/
  String pathUpload = 'https://shoothouse.cylab.be/windows-upload';
  String pathDownload = 'https://shoothouse.cylab.be/windows-wall';

  io.File? imagefile;
  late ui.Image imagewall;
  bool loading = false;
  String? id;

  // Backgronud image
  late ui.Image _background;
  // Which item is selected
  bool IsDoorsAndWindows = false;
  // Current start position
  Offset _positionStart = Offset(0, 0);
  // Current end position
  Offset _positionEnd = Offset(0, 0);
  // List of door
  List<Rect> Doors = List.empty(growable: true);
  // List of window
  List<Rect> Windows = List.empty(growable: true);

  /*
################################################################
                          FUNCTIONS
################################################################
*/

  @override
  // Init function to load the background
  void initState() {
    _asyncInit();
  }

  // Function to change the door/window selection
  void _changeObject(bool value) {
    IsDoorsAndWindows = value;
  }

  void _erasePrevious() {
    // Create empty list
    List<Rect> buffer = List.empty(growable: true);

    setState(() {
      if (IsDoorsAndWindows) {
        for (int i = 0; i < Doors.length - 1; i++) {
          buffer.add(Doors[i]);
        }

        Doors = buffer;
      } else {
        for (int i = 0; i < Windows.length - 1; i++) {
          buffer.add(Windows[i]);
        }
        Windows = buffer;
      }
    });
  }

  void _erasedall() {
    setState(() {
      // Update the variable
      Doors = List.empty(growable: true);
      Windows = List.empty(growable: true);
    });
  }

  Future<ui.Image> _downloadImage() async {
    final uri = Uri.parse(pathDownload + '?id=' + id.toString()!);

    var request = http.MultipartRequest("GET", uri);
    var response = await request.send();

    // Get the answer
    http.Response res = await http.Response.fromStream(response);

    final Uint8List bytes = Uint8List.view(res.bodyBytes.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    imagewall = (await codec.getNextFrame()).image;

    return imagewall;
  }

  Future<String> _uploadImage(selectedImage) async {
    setState(() {}); //show loader
    // Init the Type of request
    final request = http.MultipartRequest(
        "POST",
        Uri.parse(pathUpload +
            "?doors=" +
            Doors.toString() +
            "&windows=" +
            Windows.toString() +
            "&height=" +
            widget.height.toString() +
            "&width=" +
            widget.width.toString()));
    // Add the image to the request
    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: selectedImage!.path.split("/").last));

    final response = await request.send();
    // Get the answer
    http.Response res = await http.Response.fromStream(response);
    // Decode the answer
    final resJson = jsonDecode(res.body);
    // Get the message in the json
    return resJson['ID'];
  }

  // Function to load the Background
  Future<void> _asyncInit() async {
    // Update the variable
    _background = await _loadImage(widget.imagePath);
    imagefile = io.File(widget.imagePath);

    setState(() {});
  }

  // Load image function
  Future<ui.Image> _loadImage(imageString) async {
    ByteData bd = await rootBundle.load(imageString);
    // ByteData bd = await rootBundle.load("graphics/bar-1920×1080.jpg");
    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes,
        targetHeight: widget.height.toInt(), targetWidth: widget.width.toInt());
    final ui.Image image = (await codec.getNextFrame()).image;
    return image;
    // setState(() => imageStateVarible = image);
  }

  void _getStartPosition(DragStartDetails details) async {
    final tapPosition = details.localPosition;
    setState(() {
      _positionStart = Offset(tapPosition.dx, tapPosition.dy);

      //print('Start : ' + _PositionStart.toString());
    });
  }

  void _getEndPosition(DragUpdateDetails details) async {
    final tapPosition = details.localPosition;
    setState(() {
      _positionEnd = Offset(tapPosition.dx, tapPosition.dy);

      //print('End : ' + tapPosition.toString());
    });
  }

  void _getEnd(DragEndDetails details) async {
    final value = details.velocity.toString();
    setState(() {
      if (IsDoorsAndWindows) {
        double x2 = _positionEnd.dx - _positionStart.dx;
        double y2 = _positionEnd.dy - _positionStart.dy;

        Rect myRect = _positionStart & ui.Size(x2, y2);
        Doors.add(myRect);

        //print(Doors);
      } else {
        double x2 = _positionEnd.dx - _positionStart.dx;
        double y2 = _positionEnd.dy - _positionStart.dy;

        Rect myRect = _positionStart & ui.Size(x2, y2);
        Windows.add(myRect);
        //print(Doors);
      }
      _positionStart = const Offset(0, 0);
      _positionEnd = const Offset(0, 0);
    });
  }

/*
################################################################
                          BUILD WIDGET
################################################################
*/

  Widget build(BuildContext context) {
    return Scaffold(
      body: (loading == false)
          ? GestureDetector(
              // Function to update start position of the drag
              onPanStart: (details) => _getStartPosition(details),
              // Function to update the current position of the drag
              onPanUpdate: (details) => _getEndPosition(details),
              // Function to trigger the end of the drag event
              onPanEnd: (details) => _getEnd(details),
              // Actual canvas rendering
              child: FittedBox(
                child: SizedBox(
                  // Canvas takes the width of the image
                  width: MediaQuery.of(context)
                      .size
                      .width, //_background.width.toDouble(),
                  // Canvas takes the height of the image
                  height: MediaQuery.of(context)
                      .size
                      .height, //_background.height.toDouble(),
                  // Render the canvas
                  child: CustomPaint(
                    painter: FacePainter(_background, _positionStart,
                        _positionEnd, Doors, Windows, IsDoorsAndWindows),
                  ),
                ),
              ),
            )
          : Center(
              child: Column(children: [
                SizedBox(
                  height: 50,
                ),
                SizedBox(width: 100, child: CircularProgressIndicator())
              ]),
            ),
      // Add floating button to switch between doors and windows
      floatingActionButton:
          SpeedDial(icon: Icons.add, backgroundColor: Colors.red, children: [
        SpeedDialChild(
          child: const Icon(Icons.door_back_door, color: Colors.white),
          label: 'Door',
          backgroundColor: Colors.red,
          onTap: () {
            _changeObject(true);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.window, color: Colors.white),
          label: 'Window',
          backgroundColor: Colors.red,
          onTap: () {
            _changeObject(false);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.replay, color: Colors.white),
          label: 'Erase previous object',
          backgroundColor: Colors.red,
          onTap: () {
            _erasePrevious();
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.do_not_disturb, color: Colors.white),
          label: 'Erase everything',
          backgroundColor: Colors.red,
          onTap: () {
            _erasedall();
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.upload, color: Colors.white),
          label: 'Send',
          backgroundColor: Colors.red,
          onTap: () async {
            setState(() {
              loading = true;
            });
            //print("width  : " + widget.width.toString());
            //print("height : " + widget.height.toString());
            id = await _uploadImage(imagefile);
            imagewall = await _downloadImage();

            setState(() {
              loading = false;
            });

            if (imagewall == null) {
              print("image didn't load");
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DrawWall(imagewall, id!)),
              );
            }
          },
        ),
      ]),
    );
  }
}
