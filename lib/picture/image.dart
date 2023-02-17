import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:floorplan2vr/home.dart';
import './email.dart';
import '../rendering/ViewerRendering.dart';

class ImageInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? selectedImage;
  String? imagePath;
  String message = "";
  bool _isLoading = false;

  Future<http.Response> SendID(String title) {
    return http.post(
      Uri.parse("https://shoothouse.cylab.be/viewer"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
      }),
    );
  }

  send() async {
    setState(() {
      _isLoading = true;
    }); //show loader
    // Init the Type of request
    final request = http.MultipartRequest(
        "POST", Uri.parse("https://shoothouse.cylab.be/upload"));
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
    message = resJson['ID'];
    // Update the state
    setState(() {});
  }

  void _getFromGallery_windows() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      dialogTitle: 'Select an image',
      type: FileType.image,
    );

    if (result == null) return;

    PlatformFile file = result.files.single;

    if (file.path != null) {
      imagePath = file.path;
      selectedImage = File(file.path as String);
      setState(() {});
    }
  }

  Future _getFromGallery_android() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage = File(image.path);
      imagePath = image.path;
      setState(() {});
    } else {}
  }

  Future _getFromCamera_android() async {
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
          return (Platform.isAndroid == true)
              ? Container(
                  height: 200.0,
                  padding: EdgeInsets.all(10.0),
                  child: Column(children: [
                    Text('Pick an Image'),
                    SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _getFromCamera_android();
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
                        _getFromGallery_android();
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
                )
              : (Platform.isWindows == true || Platform.isLinux == true)
                  ? Container(
                      height: 200.0,
                      padding: EdgeInsets.all(10.0),
                      child: Column(children: [
                        Text('Pick an Image'),
                        SizedBox(
                          height: 10.0,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _getFromGallery_windows();
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
                    )
                  : Text("Device not supported");
        });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/back.png"), fit: BoxFit.contain),
      ),
      child: Center(
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
                  (message == "")
                      ? (_isLoading == false)
                          ? Column(
                              children: [
                                SizedBox(height: 50),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      send();
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.upgrade),
                                          Text('Run')
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Column(children: [
                              SizedBox(
                                height: 50,
                              ),
                              SizedBox(
                                  width: 100,
                                  child: CircularProgressIndicator())
                            ])
                      : (message == 'ERROR')
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  child: Text('ERROR cannot transform in 3D'),
                                )
                              ],
                            )
                          : Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 230,
                                child: SizedBox(
                                  width: 230,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      SendID(message);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RenderingVeiwer()),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.remove_red_eye),
                                          Text('       Open 3D viewer')
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 230,
                                child: SizedBox(
                                  width: 230,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EmailForm(message)),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.download),
                                          Text('    Download')
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
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
                  SizedBox(height: 50),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        _OpenImagePicker(context);
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: const [
                            Icon(Icons.upload_file),
                            Text(' Upload')
                          ],
                        ),
                      ),
                    ),
                  )
                ])),
    );
  }
}
