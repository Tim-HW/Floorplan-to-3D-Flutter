import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FacePainter extends CustomPainter {
  FacePainter(this.image, this.positionStart, this.positionEnd, this.listvoids,
      this.listwall, this.isAvoid);

  // To know if the void/walls is selected
  final bool isAvoid;
  // List of voids
  final List<Rect> listvoids;
  // List of walls
  final List<Rect> listwall;
  // Background Image
  final ui.Image image;
  // Current startposition
  final Offset positionStart;
  // Current Endposition
  final Offset positionEnd;

  // Color for walls
  Color colorwalls = const ui.Color.fromARGB(255, 255, 255, 255);
  // Color for voids
  Color colorvoids = const ui.Color.fromARGB(255, 0, 0, 0);

  // Main function to print on the canvas
  @override
  void paint(Canvas canvas, ui.Size size) {
    // Upload image on the background
    canvas.drawImage(image, Offset.zero, Paint());
    // Render the void list
    for (var i = 0; i < listvoids.length; i++) {
      canvas.drawRect(listvoids[i], Paint()..color = colorvoids);
    }
    // Render the wall list
    for (var j = 0; j < listwall.length; j++) {
      canvas.drawRect(listwall[j], Paint()..color = colorwalls);
    }

    // If the current object is a door render it
    if (isAvoid) {
      double x = positionEnd.dx - positionStart.dx;
      double y = positionEnd.dy - positionStart.dy;
      canvas.drawRect(
          positionStart & ui.Size(x, y), Paint()..color = colorvoids);
    } else {
      // If the current object is a wall render it
      double x = positionEnd.dx - positionStart.dx;
      double y = positionEnd.dy - positionStart.dy;
      canvas.drawRect(
          positionStart & ui.Size(x, y), Paint()..color = colorwalls);
    }
  }

  @override
  // This function triggers the main function everytime an element change
  bool shouldRepaint(FacePainter oldDelegate) {
    if (image != oldDelegate.image ||
        positionStart != oldDelegate.positionStart ||
        positionEnd != oldDelegate.positionEnd ||
        listvoids != oldDelegate.listvoids ||
        listwall != oldDelegate.listwall ||
        isAvoid != oldDelegate.isAvoid) {
      return true;
    } else {
      return false;
    }
  }
}

class DrawWall extends StatefulWidget {
  DrawWall(this.imageWall, this.id);
  ui.Image imageWall;
  String id;

  @override
  _DrawWallState createState() => _DrawWallState();
}

class _DrawWallState extends State<DrawWall> {
  /*
################################################################
                          VARIABLES
################################################################
*/
  String pathUpload = 'https://shoothouse.cylab.be/windows-wall';

  bool loading = false;

  // Which item is selected
  bool isvoidsAndwalls = false;
  // Current start position
  Offset _positionStart = const Offset(0, 0);
  // Current end position
  Offset _positionEnd = const Offset(0, 0);
  // List of door
  List<Rect> voids = List.empty(growable: true);
  // List of wall
  List<Rect> walls = List.empty(growable: true);

  /*
################################################################
                          FUNCTIONS
################################################################
*/
  // Function to change the door/wall selection
  void _changeObject(bool value) {
    isvoidsAndwalls = value;
  }

  void _erasePrevious() {
    // Create empty list
    List<Rect> buffer = List.empty(growable: true);

    setState(() {
      if (isvoidsAndwalls) {
        for (int i = 0; i < voids.length - 1; i++) {
          buffer.add(voids[i]);
        }

        voids = buffer;
      } else {
        for (int i = 0; i < walls.length - 1; i++) {
          buffer.add(walls[i]);
        }
        walls = buffer;
      }
    });
  }

  void _erasedall() {
    setState(() {
      // Update the variable
      voids = List.empty(growable: true);
      walls = List.empty(growable: true);
    });
  }

  Future<void> _uploadImage(ui.Image selectedImage) async {
    setState(() {}); //show loader
    // Init the Type of request

    final bytes = await selectedImage.toByteData();

    final stream = List<int>.from(bytes!.buffer.asUint8List());

    String param = "?voids=$voids&walls=$walls&ID{widget.id}";

    final request =
        http.MultipartRequest("POST", Uri.parse(pathUpload + param));
    // Add the image to the request
    request.files.add(
        http.MultipartFile.fromBytes('image', stream, filename: "wut.png"));
    // Fill the request with the header
    // Send the request
    //final response = await request.send();
    // Get the answer
    //http.Response res = await http.Response.fromStream(response);
    //var responseBody = jsonDecode(res.body);

    // Update the state
    setState(() {});
  }

  void _getStartPosition(DragStartDetails details) async {
    final tapPosition = details.localPosition;
    setState(() {
      _positionStart = Offset(tapPosition.dx, tapPosition.dy);

      //print('Start : ' + _positionStart.toString());
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
    setState(() {
      //print('Value : ' + value);
      if (isvoidsAndwalls) {
        double x2 = _positionEnd.dx - _positionStart.dx;
        double y2 = _positionEnd.dy - _positionStart.dy;

        Rect myRect = _positionStart & ui.Size(x2, y2);
        voids.add(myRect);

        //print(voids);
      } else {
        double x2 = _positionEnd.dx - _positionStart.dx;
        double y2 = _positionEnd.dy - _positionStart.dy;

        Rect myRect = _positionStart & ui.Size(x2, y2);
        walls.add(myRect);
        //print(voids);
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
  @override
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
                      .width, //_Background.width.toDouble(),
                  // Canvas takes the height of the image
                  height: MediaQuery.of(context)
                      .size
                      .height, //_Background.height.toDouble(),
                  // Render the canvas
                  child: CustomPaint(
                    painter: FacePainter(widget.imageWall, _positionStart,
                        _positionEnd, voids, walls, isvoidsAndwalls),
                  ),
                ),
              ),
            )
          : Column(children: const [
              SizedBox(
                height: 50,
              ),
              SizedBox(width: 100, child: CircularProgressIndicator())
            ]),
      // Add floating button to switch between voids and walls
      floatingActionButton:
          SpeedDial(icon: Icons.add, backgroundColor: Colors.red, children: [
        SpeedDialChild(
          child: const Icon(Icons.rectangle_outlined, color: Colors.white),
          label: 'void',
          backgroundColor: Colors.red,
          onTap: () {
            _changeObject(true);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.rectangle, color: Colors.white),
          label: 'wall',
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
          onTap: () {
            setState(() {
              loading = true;
            });

            _uploadImage(widget.imageWall);

            setState(() {
              loading = false;
            });
            //Navigator.push(
            //  context,
            //  MaterialPageRoute(builder: (context) => Home()),
            //);
          },
        ),
      ]),
    );
  }
}
