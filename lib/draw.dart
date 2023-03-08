
import 'dart:ffi';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math' as math;





class FacePainter extends CustomPainter{
  
  FacePainter(this.image,this.positionStart,this.positionEnd,this.ListDoors,this.ListWindow,this.IsADoor);
  final bool IsADoor;
  final List<Rect> ListDoors;
  final List<Rect> ListWindow;
  final ui.Image image;
  final Offset positionStart;
  final Offset positionEnd;


  late double x = positionEnd.dx - positionStart.dx;
  late double y = positionEnd.dy - positionStart.dy;

  Color colorWindows = ui.Color.fromARGB(255, 27, 0, 179);
  Color colorDoors   = ui.Color.fromARGB(255, 0, 179, 95);


  void paint(Canvas canvas, ui.Size size){
    canvas.drawImage(image, Offset.zero, Paint());
    
    for(var i = 0 ; i < ListDoors.length; i++)
    {
      canvas.drawRect(ListDoors[i], Paint()..color=colorDoors);
    }

    for(var j = 0 ; j < ListWindow.length; j++)
    {
      canvas.drawRect(ListWindow[j], Paint()..color=colorWindows);
    }

    if(IsADoor){
      canvas.drawRect(positionStart & ui.Size(x,y), Paint()..color=colorDoors);
    }
    else
    {
    canvas.drawRect(positionStart & ui.Size(x,y), Paint()..color=colorWindows);
    }
   
    


  }
  @override
  bool shouldRepaint(FacePainter oldDelegate){

    if(image != oldDelegate.image || positionStart != oldDelegate.positionStart || positionEnd != oldDelegate.positionEnd || ListDoors != oldDelegate.ListDoors || ListWindow != oldDelegate.ListWindow)
    {return true;}
    else
    {return false;}
  }
}












class DrawImage extends StatefulWidget {


  @override
  _DrawImageState createState() => _DrawImageState();
}

class _DrawImageState extends State<DrawImage> {

  late ui.Image _Background;

  bool IsDoorsAndWindows = false;

  Offset _PositionStart = Offset(0, 0);
  Offset _PositionEnd = Offset(0, 0);


  final List<Rect> Doors   = List.empty(growable: true);
  final List<Rect> Windows = List.empty(growable: true);
  List<int> test     = [];

  

  
  @override
  void initState() {
  _asyncInit();
}


  void ChangeObject(bool value)
  {
    IsDoorsAndWindows = value;
  }

  Future<void> _asyncInit() async {
    final image = await loadImage('./assets/VR.png');
    setState(() {
      _Background = image;
    });
  }

  Future<ui.Image> loadImage(imageString) async {
    ByteData bd = await rootBundle.load(imageString);
    // ByteData bd = await rootBundle.load("graphics/bar-1920×1080.jpg");
    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image image = (await codec.getNextFrame()).image;
    return image;
    // setState(() => imageStateVarible = image);
  }


  void _getTapPosition(TapDownDetails details) async 
  {
    final tapPosition = details.globalPosition;
    setState(() {

      _PositionStart = Offset(tapPosition.dx,tapPosition.dy-56);
      
      
      print(_PositionStart);
    
    });
  }


  void _getStartPosition(DragStartDetails details) async 
  {
    final tapPosition = details.globalPosition;
    setState(() {

      _PositionStart = Offset(tapPosition.dx,tapPosition.dy-56);
      
      
      print('Start : '+_PositionStart.toString());
    
    });
  }

  void _getEndPosition(DragUpdateDetails details) async 
  {
    final tapPosition = details.globalPosition;
    setState(() {

      _PositionEnd = Offset(tapPosition.dx,tapPosition.dy-56);

      print('End : '+tapPosition.toString());
    
    });
  }

  void _getEnd(DragEndDetails details) async 
  {
    final value = details.velocity.toString();
    setState(() {

      if(value != null)
      {
        print('Value : '+value);
        if(IsDoorsAndWindows)
        {

          double X2   = _PositionEnd.dx - _PositionStart.dx;
          double Y2   = _PositionEnd.dy - _PositionStart.dy;

          Rect myRect = _PositionStart & ui.Size(X2,Y2);
          Doors.add(myRect);
          print(Doors);

        }else{

          double X2   = _PositionEnd.dx - _PositionStart.dx;
          double Y2   = _PositionEnd.dy - _PositionStart.dy;

          Rect myRect = _PositionStart & ui.Size(X2,Y2);
          Windows.add(myRect);
          //print(Doors);

        }
        
      }
    });

  }



  Widget build(BuildContext context) {
    return 
    Scaffold(
      body:
      GestureDetector(
      //onTapDown: (details) => _getTapPosition(details),

      onPanStart: (details) => _getStartPosition(details),
      onPanUpdate: (details) => _getEndPosition(details),
      onPanEnd: (details) => _getEnd(details),
      
        child: 
          FittedBox(
          child: 
          SizedBox(
            width:  _Background.width.toDouble(),
            height: _Background.height.toDouble(),
            child: 
              CustomPaint(
                painter: FacePainter(_Background,_PositionStart,_PositionEnd,Doors,Windows,IsDoorsAndWindows),
            ), 
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        backgroundColor: Colors.red,

        children: [
          SpeedDialChild(
            child: const Icon(Icons.door_back_door,color: Colors.white),
            label: 'Door',
            backgroundColor: Colors.red,
            onTap: () {
              ChangeObject(true);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.window,color: Colors.white),
            label: 'Window',
            backgroundColor: Colors.red,
            onTap: () {
              ChangeObject(false);
            },
          ),
        ]
      ),
    );
  }
}



