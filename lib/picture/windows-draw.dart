import 'dart:ui' as ui;
import 'dart:io' as io;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'windows-wall.dart';

ui.ParagraphBuilder vector(int direction) {
  var style =
      const TextStyle(color: ui.Color.fromARGB(255, 180, 0, 0), fontSize: 30);
  final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      fontSize: style.fontSize,
      fontFamily: style.fontFamily,
      fontStyle: style.fontStyle,
      fontWeight: style.fontWeight,
      textAlign: TextAlign.justify,
    ),
  )..pushStyle(style.getTextStyle());
  if (direction == 0) {
    paragraphBuilder.addText("→");
  } else if (direction == 1) {
    paragraphBuilder.addText("↑");
  } else if (direction == 2) {
    paragraphBuilder.addText("←");
  } else if (direction == 3) {
    paragraphBuilder.addText("↓");
  }

  return paragraphBuilder;
}

class FacePainter extends CustomPainter {
  FacePainter(this.image, this.positionStart, this.positionEnd, this.listdoors,
      this.listWindow, this.isADoor, this.doorsOrientation);

  // To know if the door/windows is selected
  final bool isADoor;
  // List of doors
  final List<Rect> listdoors;
  final List<int> doorsOrientation;
  // List of windows
  final List<Rect> listWindow;
  // Background Image
  final ui.Image image;
  // Current startposition
  final Offset positionStart;
  // Current Endposition
  final Offset positionEnd;

  // Color for windows
  Color colorwindows = const ui.Color.fromARGB(255, 27, 0, 179);
  // Color for doors
  Color colordoors = const ui.Color.fromARGB(255, 0, 179, 95);

  // Main function to print on the canvas
  @override
  void paint(Canvas canvas, ui.Size size) {
    // Upload image on the background
    canvas.drawImage(image, Offset.zero, Paint());

    // Render the door list
    for (var i = 0; i < listdoors.length; i++) {
      canvas.drawRect(listdoors[i], Paint()..color = colordoors);

      ui.ParagraphBuilder para = vector(doorsOrientation[i]);

      final ui.Paragraph paragraph = para.build()
        ..layout(ui.ParagraphConstraints(width: size.width));

      final position = listdoors[i].center;
      canvas.drawParagraph(paragraph, position);
    }
    // Render the Window list
    for (var j = 0; j < listWindow.length; j++) {
      canvas.drawRect(listWindow[j], Paint()..color = colorwindows);
    }

    // If the current object is a door render it
    if (isADoor) {
      double x = positionEnd.dx - positionStart.dx;
      double y = positionEnd.dy - positionStart.dy;
      canvas.drawRect(
          positionStart & ui.Size(x, y), Paint()..color = colordoors);
    } else {
      // If the current object is a window render it
      double x = positionEnd.dx - positionStart.dx;
      double y = positionEnd.dy - positionStart.dy;
      canvas.drawRect(
          positionStart & ui.Size(x, y), Paint()..color = colorwindows);
    }
  }

  @override
  // This function triggers the main function everytime an element change
  bool shouldRepaint(FacePainter oldDelegate) {
    if (image != oldDelegate.image ||
        positionStart != oldDelegate.positionStart ||
        positionEnd != oldDelegate.positionEnd ||
        listdoors != oldDelegate.listdoors ||
        listWindow != oldDelegate.listWindow ||
        isADoor != oldDelegate.isADoor ||
        doorsOrientation != oldDelegate.doorsOrientation) {
      return true;
    } else {
      return false;
    }
  }
}

class DrawImage extends StatefulWidget {
  const DrawImage(this.imagePath, this.height, this.width, {super.key});
  final String imagePath;
  final double height;
  final double width;

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
  // Image
  late ui.Image imagewall;
  // When turned True show a loading screen to the user
  bool loading = false;
  // Image ID
  String? id;

  // Backgronud image
  late ui.Image _background;
  // Which item is selected
  bool isdoorsAndwindows = false;
  // Current start position
  Offset _positionStart = const Offset(0, 0);
  // Current end position
  Offset _positionEnd = const Offset(0, 0);
  // List of door
  List<Rect> doors = List.empty(growable: true);
  List<int> doorsOrientation = List.empty(growable: true);
  // List of window
  List<Rect> windows = List.empty(growable: true);

  /*
################################################################
                          FUNCTIONS
################################################################
*/

  @override
  // Init function to load the background
  void initState() {
    loading = true;
    _asyncInit();
    loading = false;
    setState(() {});
  }

  // Function to load the Background
  _asyncInit() async {
    setState(() {
      loading = true;
    });
    // Update the variable
    print(widget.imagePath);

    _background = await _loadImage(widget.imagePath);
    imagefile = io.File(widget.imagePath);

    setState(() {
      loading = false;
    });
  }

  // Function to change the door/window selection
  void _changeObject(bool value) {
    isdoorsAndwindows = value;
  }

  void _erasePrevious() {
    // Create empty list
    List<Rect> buffer = List.empty(growable: true);

    setState(() {
      if (isdoorsAndwindows) {
        for (int i = 0; i < doors.length - 1; i++) {
          buffer.add(doors[i]);
        }

        doors = buffer;
      } else {
        for (int i = 0; i < windows.length - 1; i++) {
          buffer.add(windows[i]);
        }
        windows = buffer;
      }
    });
  }

  void _erasedall() {
    setState(() {
      // Update the variable
      doors = List.empty(growable: true);
      doorsOrientation = List.empty(growable: true);
      windows = List.empty(growable: true);
    });
  }

  void _rotate() {
    setState(() {
      if (doorsOrientation.last == 0) {
        doorsOrientation.last = 2;
      } else if (doorsOrientation.last == 2) {
        doorsOrientation.last = 0;
      } else if (doorsOrientation.last == 1) {
        doorsOrientation.last = 3;
      } else if (doorsOrientation.last == 3) {
        doorsOrientation.last = 1;
      }
    });
  }

  Future<ui.Image> _downloadImage() async {
    String urlid = '?id=$id';
    String finalurl = pathDownload + urlid;

    final uri = Uri.parse(finalurl);

    var request = http.MultipartRequest("GET", uri);
    var response = await request.send();

    // Get the answer
    http.Response res = await http.Response.fromStream(response);

    final Uint8List bytes = Uint8List.view(res.bodyBytes.buffer);

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    imagewall = (await codec.getNextFrame()).image;

    return imagewall;
  }

  Future<String> _uploadImage(io.File selectedImage) async {
    setState(() {}); //show loader
    // Init the Type of request

    String doorsURL = "?doors=$doors";
    String windowsURL = "&windows=$windows";
    String doorOrientationURL = "&doororientation=$doorsOrientation";
    String heightURL = "&height=${widget.height}";
    String widthURL = "&width=${widget.width}";

    //print("Doors URL : " + doorsURL);

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(pathUpload +
          doorsURL +
          windowsURL +
          heightURL +
          widthURL +
          doorOrientationURL),
    );

    // Add the image to the request
    request.files.add(http.MultipartFile('image',
        selectedImage.readAsBytes().asStream(), selectedImage.lengthSync(),
        filename: selectedImage.path.split("/").last));

    final response = await request.send();
    // Get the answer
    http.Response res = await http.Response.fromStream(response);
    // Decode the answer
    final resJson = jsonDecode(res.body);
    // Get the message in the json
    return resJson['ID'];
  }

  // Load image function
  Future<ui.Image> _loadImage(imageString) async {
    ByteData f = ByteData.view(io.File(imageString).readAsBytesSync().buffer);
    // ByteData bd = await rootBundle.load("graphics/bar-1920×1080.jpg");
    final Uint8List bytes = Uint8List.view(f.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes,
        targetHeight: widget.height.toInt(), targetWidth: widget.width.toInt());
    final ui.Image image = (await codec.getNextFrame()).image;
    //print("image height is : " + widget.height.toString());
    //print("image width is  : " + widget.width.toString());
    return image;
  }

  void _getStartPosition(DragStartDetails details) async {
    final tapPosition = details.localPosition;
    setState(() {
      _positionStart = Offset(tapPosition.dx, tapPosition.dy);

      //print('Start : ' + tapPosition.toString());
    });
  }

  void _getEndPosition(DragUpdateDetails details) async {
    final tapPosition = details.localPosition;
    setState(() {
      _positionEnd = Offset(tapPosition.dx, tapPosition.dy);

      print('End : ' + tapPosition.toString());
    });
  }

  void _getEnd(DragEndDetails details) async {
    setState(() {
      if (isdoorsAndwindows) {
        double x2 = _positionEnd.dx - _positionStart.dx;
        double y2 = _positionEnd.dy - _positionStart.dy;

        //print('width  is : ' + x2.toString() + ' ');
        //print('height is : ' + y2.toString() + ' ');

        Rect myRect = _positionStart & ui.Size(x2, y2);
        doors.add(myRect);

        if (x2.abs() > y2.abs()) {
          doorsOrientation.add(1);
        } else {
          doorsOrientation.add(0);
        }

        //print(doors);
      } else {
        double x2 = _positionEnd.dx - _positionStart.dx;
        double y2 = _positionEnd.dy - _positionStart.dy;

        Rect myRect = _positionStart & ui.Size(x2, y2);
        windows.add(myRect);
        //print(doors);
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
                      .width, //_background.width.toDouble(),
                  // Canvas takes the height of the image
                  height: MediaQuery.of(context)
                      .size
                      .height, //_background.height.toDouble(),
                  // Render the canvas
                  child: CustomPaint(
                    painter: FacePainter(
                        _background,
                        _positionStart,
                        _positionEnd,
                        doors,
                        windows,
                        isdoorsAndwindows,
                        doorsOrientation),
                  ),
                ),
              ),
            )
          : Center(
              child: Column(children: const [
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
          child: const Icon(Icons.autorenew_rounded, color: Colors.white),
          label: 'Rotate door opening',
          backgroundColor: Colors.red,
          onTap: () {
            _rotate();
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

            id = await _uploadImage(imagefile!);
            imagewall = await _downloadImage();

            loading = false;

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrawWall(imagewall, id!)),
            );
          },
        ),
      ]),
    );
  }
}
