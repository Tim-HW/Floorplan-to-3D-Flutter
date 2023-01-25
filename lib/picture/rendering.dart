import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Rendering extends StatefulWidget {
  const Rendering({ super.key });

  @override
  State<Rendering> createState() => _RenderingState();
}

class _RenderingState extends State<Rendering> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Cube(
          onSceneCreated: (Scene scene) {
            scene.world.add(Object(fileName: 'assets/cubo.obj'));
          },
        ),
      ),
    );
  }
}