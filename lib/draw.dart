//import 'dart:html';
//import 'dart:io' as io;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
//import 'package:http/http.dart';
//import 'package:image_painter/image_painter.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:image/image.dart' as image;
import 'package:flutter/services.dart';
//import 'dart:typed_data';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FacePainter extends CustomPainter{
  FacePainter(this.image,this.position);

  final ui.Image image;
  final Offset position;




  void paint(Canvas canvas, Size size){
    canvas.drawImage(image, Offset.zero, Paint());
    //for(var i = 0 ; i < face.length; i++)
    //{
    //  canvas.drawRect(face[i], Paint());
    //}
    canvas.drawCircle(position, 20, Paint());


  }
  @override
  bool shouldRepaint(FacePainter oldDelegate){

    if(image != oldDelegate.image || position != oldDelegate.position)
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
  Offset _Position = Offset(0, 0);
  
  @override
  void initState() {
  _asyncInit();

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
      _Position = tapPosition;
      print(_Position);
    });
  }



  Widget build(BuildContext context) {
    return 
    Scaffold(
      body:
      GestureDetector(
      onTapDown: (details) => _getTapPosition(details),
        child: 
          FittedBox(
          child: 
          SizedBox(
            width: _Background.width.toDouble(),
            height: _Background.height.toDouble(),
            child: 
              CustomPaint(
                painter: FacePainter(_Background,_Position),
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
             onTap: () {},
           ),
           SpeedDialChild(
             child: const Icon(Icons.window,color: Colors.white),
             label: 'Window',
             backgroundColor: Colors.red,
             onTap: () {},
           ),
         ]),

  );
}
}



