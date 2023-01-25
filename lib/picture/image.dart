import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rendering.dart';


class ImageInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? selectedImage;
  String? imagePath;
  String? message = "";

  send() async {
    // Init the Type of request
    final request =
        http.MultipartRequest("POST", Uri.parse("https://shoothouse.cylab.be/"));
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
    // Decode the answer
    final resJson = jsonDecode(res.body);
    // Get the message in the json
    message = resJson['message'];
    // Update the state
    setState(() {});
  }

  void _getFromGallery() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      imagePath = image.path;
      setState(() {});
    } else {}
  }

  Future _getFromGallery2() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage = File(image.path);
      imagePath = image.path;
      setState(() {});
    } else {}
  }

  Future _getFromCamera() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (image != null) {
      imagePath = image.path;
      setState(() {});
    }
  }

  Future _getFromCamera2() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (image != null) {
      selectedImage = File(image.path);
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
                  _getFromCamera2();
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
                  _getFromGallery2();
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
          child: (selectedImage != null)
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
                  (message == "")
                      ? SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              send();
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: const [
                                  Icon(Icons.upgrade),
                                  Text('Run')
                                ],
                              ),
                            ),
                          ),
                        )
                      : Column(children: [
                        SizedBox(
                          width: 230,
                          child: ElevatedButton(
                            onPressed: () { },
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.grey)),
                            child:
                              Padding(padding: const EdgeInsets.all(4),
                                child: Row(children: const [Text('Image uploaded successfully')
                          ],
                        ),
                      ),
                    ),
                  ),SizedBox(
                      width: 230,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Rendering()),
                          );
                        },
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.red)),
                        child:
                        Padding(padding: const EdgeInsets.all(4),
                          child: Row(children: const [Icon(Icons.download),Text('       Open 3D viewer')
                          ],
                          ),
                        ),
                      ),
                    ),
                  ])
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
