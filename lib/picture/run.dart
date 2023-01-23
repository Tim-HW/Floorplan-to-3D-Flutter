import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class ImageInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  String? imagePath;

  void _getFromGallery() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      imagePath = image.path;
      setState(() {});
    } else {}
  }

  Future<void> _getFromCamera() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (image != null) {
      imagePath = image.path;
      setState(() {});
    }
  }

  void _OpenImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text('Pick an Image'),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _getFromCamera();
                },
                icon: Icon(
                  // <-- Icon
                  Icons.camera_alt,
                  size: 24.0,
                ),
                label: Text('From Camera'), // <-- Text
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _getFromGallery();
                },
                icon: Icon(
                  // <-- Icon
                  Icons.folder_open,
                  size: 24.0,
                ),
                label: Text('From Gallery'), // <-- Text
              ),
              SizedBox(height: 50.0),
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: (imagePath != null)
              ? Column(children: [
                  SizedBox(
                    height: 20,
                  ),
                  Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: const [Icon(Icons.upgrade), Text('Run')],
                        ),
                      ),
                    ),
                  ),
                ])
              : Column(children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 300.0,
                    width: 300.0,
                    color: Colors.grey,
                    child: Center(child: Text("No image selected")),
                  ),
                ])),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        //Floating action button on Scaffold
        onPressed: () {
          _OpenImagePicker(context);
        },
        child: Icon(Icons.camera_alt), //icon inside button
      ),
    );
  }
}
