import 'dart:ui' as ui;
import 'dart:io' as io;
import 'dart:convert';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:floorplan2vr/home.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class FacePainter extends CustomPainter {
  FacePainter(this.image, this.positionStart, this.positionEnd, this.Listvoids,
      this.Listwall, this.IsAvoid);

  // To know if the void/walls is selected
  final bool IsAvoid;
  // List of voids
  final List<Rect> Listvoids;
  // List of walls
  final List<Rect> Listwall;
  // Background Image
  final ui.Image image;
  // Current startposition
  final Offset positionStart;
  // Current Endposition
  final Offset positionEnd;

  // Color for walls
  Color colorwalls = ui.Color.fromARGB(255, 255, 255, 255);
  // Color for voids
  Color colorvoids = ui.Color.fromARGB(255, 0, 0, 0);

  // Main function to print on the canvas

  void paint(Canvas canvas, ui.Size size) {
    // Upload image on the background
    canvas.drawImage(image, Offset.zero, Paint());
    // Render the void list
    for (var i = 0; i < Listvoids.length; i++) {
      canvas.drawRect(Listvoids[i], Paint()..color = colorvoids);
    }
    // Render the wall list
    for (var j = 0; j < Listwall.length; j++) {
      canvas.drawRect(Listwall[j], Paint()..color = colorwalls);
    }

    // If the current object is a door render it
    if (IsAvoid) {
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
        Listvoids != oldDelegate.Listvoids ||
        Listwall != oldDelegate.Listwall ||
        IsAvoid != oldDelegate.IsAvoid) {
      return true;
    } else {
      return false;
    }
  }
}

class DrawWall extends StatefulWidget {
  DrawWall(this.imageWall);

  ui.Image imageWall;

  @override
  _DrawWallState createState() => _DrawWallState();
}

class _DrawWallState extends State<DrawWall> {
  /*
################################################################
                          VARIABLES
################################################################
*/
  String pathUpload = 'https://shoothouse.cylab.be/walls-upload';
  String pathString = 'https://shoothouse.cylab.be/walls-string';

  bool loading = false;
  String? ID;

  // Which item is selected
  bool IsvoidsAndwalls = false;
  // Current start position
  Offset _PositionStart = Offset(0, 0);
  // Current end position
  Offset _PositionEnd = Offset(0, 0);
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
    IsvoidsAndwalls = value;
  }

  void _erasePrevious() {
    // Create empty list
    List<Rect> Buffer = List.empty(growable: true);

    setState(() {
      if (IsvoidsAndwalls) {
        for (int i = 0; i < voids.length - 1; i++) {
          Buffer.add(voids[i]);
        }

        voids = Buffer;
      } else {
        for (int i = 0; i < walls.length - 1; i++) {
          Buffer.add(walls[i]);
        }
        walls = Buffer;
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

  Future<void> _uploadImage(selectedImage) async {
    setState(() {}); //show loader
    // Init the Type of request
    final request = http.MultipartRequest("POST", Uri.parse(pathUpload));
    // Init the Header of the request
    final header = {"Content-type": "multipart/from-data"};
    // Add the image to the request
    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: selectedImage!.path.split("/").last));
    // Fill the request with the header
    request.headers.addAll(header);
    // Send the request
    final response = await request.send();
    // Get the answer
    http.Response res = await http.Response.fromStream(response);
    var responseBody = jsonDecode(res.body);

    // Update the state
    setState(() {});
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
        if (IsvoidsAndwalls) {
          double X2 = _PositionEnd.dx - _PositionStart.dx;
          double Y2 = _PositionEnd.dy - _PositionStart.dy;

          Rect myRect = _PositionStart & ui.Size(X2, Y2);
          voids.add(myRect);

          //print(voids);
        } else {
          double X2 = _PositionEnd.dx - _PositionStart.dx;
          double Y2 = _PositionEnd.dy - _PositionStart.dy;

          Rect myRect = _PositionStart & ui.Size(X2, Y2);
          walls.add(myRect);
          //print(voids);
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
                    painter: FacePainter(widget.imageWall, _PositionStart,
                        _PositionEnd, voids, walls, IsvoidsAndwalls),
                  ),
                ),
              ),
            )
          : Column(children: [
              SizedBox(
                height: 50,
              ),
              SizedBox(width: 100, child: CircularProgressIndicator())
            ]),
      // Add floating button to switch between voids and walls
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
          child: const Icon(Icons.rectangle_outlined, color: Colors.white),
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
