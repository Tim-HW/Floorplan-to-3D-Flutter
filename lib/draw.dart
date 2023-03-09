import 'dart:ui' as ui;
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
  @override
  _DrawImageState createState() => _DrawImageState();
}

class _DrawImageState extends State<DrawImage> {
  /*
################################################################
                          VARIABLES
################################################################
*/
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
    setState(() {
      if (IsDoorsAndWindows) {
        Doors.removeLast();
      } else {
        Windows.removeLast();
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

  // Function to load the Background
  Future<void> _asyncInit() async {
    // Load the image
    final image = await loadImage('assets/VR.png');
    setState(() {
      // Update the variable
      _Background = image;
    });
  }

  // Load image function
  Future<ui.Image> loadImage(imageString) async {
    ByteData bd = await rootBundle.load(imageString);
    // ByteData bd = await rootBundle.load("graphics/bar-1920×1080.jpg");
    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image image = (await codec.getNextFrame()).image;
    return image;
    // setState(() => imageStateVarible = image);
  }

  // Function to get the position tapped
  void _getTapPosition(TapDownDetails details) async {
    // init variable
    final tapPosition = details.globalPosition;
    setState(() {
      // Update variable
      _PositionStart = Offset(tapPosition.dx, tapPosition.dy - 56);

      print(_PositionStart);
    });
  }

  void _getStartPosition(DragStartDetails details) async {
    final tapPosition = details.globalPosition;
    setState(() {
      _PositionStart = Offset(tapPosition.dx, tapPosition.dy - 56);

      print('Start : ' + _PositionStart.toString());
    });
  }

  void _getEndPosition(DragUpdateDetails details) async {
    final tapPosition = details.globalPosition;
    setState(() {
      _PositionEnd = Offset(tapPosition.dx, tapPosition.dy - 56);

      print('End : ' + tapPosition.toString());
    });
  }

  void _getEnd(DragEndDetails details) async {
    final value = details.velocity.toString();
    setState(() {
      if (value != null) {
        print('Value : ' + value);
        if (IsDoorsAndWindows) {
          double X2 = _PositionEnd.dx - _PositionStart.dx;
          double Y2 = _PositionEnd.dy - _PositionStart.dy;

          Rect myRect = _PositionStart & ui.Size(X2, Y2);
          Doors.add(myRect);

          print(Doors);
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
      ]),
    );
  }
}
