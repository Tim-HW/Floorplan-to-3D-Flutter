import 'dart:ui' as ui;
import 'dart:io' as io;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
  DrawImage(this.ImagePath);
  String ImagePath;

  @override
  _DrawImageState createState() => _DrawImageState();
}

class _DrawImageState extends State<DrawImage> {
  /*
################################################################
                          VARIABLES
################################################################
*/

  // Image
  late ui.Image FinalImage;
  // Backgronud image
  late ui.Image _Background;
  // Which item is selected
  bool IsDoorsAndWindows = false;
  // Current start position
  Offset _PositionStart = Offset(0, 0);
  // Current end position
  Offset _PositionEnd = Offset(0, 0);
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
  void ChangeObject(bool value) {
    IsDoorsAndWindows = value;
  }

  void ErasePrevious() {
    // Create empty list
    List<Rect> Buffer = List.empty(growable: true);

    setState(() {
      if (IsDoorsAndWindows) {
        for (int i = 0; i < Doors.length - 1; i++) {
          Buffer.add(Doors[i]);
        }

        Doors = Buffer;
      } else {
        for (int i = 0; i < Windows.length - 1; i++) {
          Buffer.add(Windows[i]);
        }
        Windows = Buffer;
      }
    });
  }

  void Erasedall() {
    setState(() {
      // Update the variable
      Doors = List.empty(growable: true);
      Windows = List.empty(growable: true);
    });
  }

  _Save() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas1 = Canvas(pictureRecorder);

    canvas1.drawImage(_Background, Offset.zero, Paint());
    // Render the door list
    for (var i = 0; i < Doors.length; i++) {
      canvas1.drawRect(
          Doors[i], Paint()..color = ui.Color.fromARGB(255, 27, 0, 179));
    }
    // Render the Window list
    for (var j = 0; j < Windows.length; j++) {
      canvas1.drawRect(
          Windows[j], Paint()..color = ui.Color.fromARGB(255, 0, 179, 95));
    }

    // If the current object is a door render it

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(200, 200);

    if (img != null) {
      print("------ IMAGE LOADED ---");
      FinalImage = img;
      img.

    } else {
      print("------UNABLE TO LOAD IMAGE---");
    }
  }

  _Upload() async {
    setState(() {}); //show loader
    // Init the Type of request
    final ByteData? data = await FinalImage.toByteData();

    final image = data!.buffer;
    
    
    final Length = data!.buffer.lengthInBytes;

    final request = http.MultipartRequest(
        "POST", Uri.parse("https://shoothouse.cylab.be/upload"));
    // Init the Header of the request
    final header = {"Content-type": "multipart/from-data"};
    // Add the image to the request
    request.files.add(http.MultipartFile(
        'image', data,Length,
        filename: " "));
    // Fill the request with the header
    request.headers.addAll(header);
    // Send the request
    final response = await request.send();
    // Get the answer
    http.Response res = await http.Response.fromStream(response);
    // Decode the answer
    final resJson = jsonDecode(res.body);
    // Get the message in the json
    String message = resJson['ID'];
    // Update the state
    setState(() {});
  }

  // Function to load the Background
  Future<void> _asyncInit() async {
    // Load the image
    final image = await _loadImage(widget.ImagePath);
    setState(() {
      // Update the variable
      _Background = image;
    });
  }

  // Load image function
  Future<ui.Image> _loadImage(imageString) async {
    ByteData bd = await rootBundle.load(imageString);
    // ByteData bd = await rootBundle.load("graphics/bar-1920×1080.jpg");
    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image image = (await codec.getNextFrame()).image;
    return image;
    // setState(() => imageStateVarible = image);
  }

  void _getStartPosition(DragStartDetails details) async {
    final tapPosition = details.localPosition;
    setState(() {
      _PositionStart = Offset(tapPosition.dx, tapPosition.dy);

      //print('Start : ' + _PositionStart.toString());
    });
  }

  void _getEndPosition(DragUpdateDetails details) async {
    final tapPosition = details.localPosition;
    setState(() {
      _PositionEnd = Offset(tapPosition.dx, tapPosition.dy);

      //print('End : ' + tapPosition.toString());
    });
  }

  void _getEnd(DragEndDetails details) async {
    final value = details.velocity.toString();
    setState(() {
      if (value != null) {
        //print('Value : ' + value);
        if (IsDoorsAndWindows) {
          double X2 = _PositionEnd.dx - _PositionStart.dx;
          double Y2 = _PositionEnd.dy - _PositionStart.dy;

          Rect myRect = _PositionStart & ui.Size(X2, Y2);
          Doors.add(myRect);

          //print(Doors);
        } else {
          double X2 = _PositionEnd.dx - _PositionStart.dx;
          double Y2 = _PositionEnd.dy - _PositionStart.dy;

          Rect myRect = _PositionStart & ui.Size(X2, Y2);
          Windows.add(myRect);
          //print(Doors);

        }
        _PositionStart = Offset(0, 0);
        _PositionEnd = Offset(0, 0);
      }
    });
  }

/*
################################################################
                          BUILD WIDGET
################################################################
*/

  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
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
            width: _Background.width.toDouble(),
            // Canvas takes the height of the image
            height: _Background.height.toDouble(),
            // Render the canvas
            child: CustomPaint(
              painter: FacePainter(_Background, _PositionStart, _PositionEnd,
                  Doors, Windows, IsDoorsAndWindows),
            ),
          ),
        ),
      ),
      // Add floating button to switch between doors and windows
      floatingActionButton:
          SpeedDial(icon: Icons.add, backgroundColor: Colors.red, children: [
        SpeedDialChild(
          child: const Icon(Icons.door_back_door, color: Colors.white),
          label: 'Door',
          backgroundColor: Colors.red,
          onTap: () {
            ChangeObject(true);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.window, color: Colors.white),
          label: 'Window',
          backgroundColor: Colors.red,
          onTap: () {
            ChangeObject(false);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.replay, color: Colors.white),
          label: 'Erase previous object',
          backgroundColor: Colors.red,
          onTap: () {
            ErasePrevious();
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.do_not_disturb, color: Colors.white),
          label: 'Erase everything',
          backgroundColor: Colors.red,
          onTap: () {
            Erasedall();
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.upload, color: Colors.white),
          label: 'Send',
          backgroundColor: Colors.red,
          onTap: () {
            _Save();
            _Upload();
          },
        ),
      ]),
    );
  }
}
