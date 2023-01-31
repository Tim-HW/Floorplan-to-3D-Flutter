import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:model_viewer/model_viewer.dart';

class RenderingVeiwer extends StatefulWidget {
  const RenderingVeiwer({super.key});

  @override
  State<RenderingVeiwer> createState() => _RenderingState();
}

class _RenderingState extends State<RenderingVeiwer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          brightness: Brightness.light,
          primarySwatch: Colors.red),
      home: Scaffold(
        appBar: AppBar(title: Text("3D Floorplan Viewer")),
        body: ModelViewer(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          src: 'https://shoothouse.cylab.be/floorplan.glb',
          alt: "A 3D model of an astronaut",
          ar: true,
          autoRotate: true,
          cameraControls: true,
        ),
      ),
    );
  }
}
