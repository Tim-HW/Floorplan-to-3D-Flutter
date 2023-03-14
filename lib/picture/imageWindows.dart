import 'dart:convert';
import 'dart:io' as io;
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './email.dart';
import '../rendering/ViewerRendering.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import './../draw.dart';

class ImageInputWindows extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageInputWindowsState();
  }
}

class _ImageInputWindowsState extends State<ImageInputWindows> {
  io.File? selectedImage;
  String? imagePath;
  String message = "";
  bool _isLoading = false;

  Future<void> _launchUrl(Uri _url) async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  //-------------------------------------------------
  //   function to send the image to server
  //-------------------------------------------------
  _upload() async {
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

  //-------------------------------------------------
  //   Open file picker from windows + Linux
  //-------------------------------------------------

  void _getFromGalleryWindowsLinux() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      dialogTitle: 'Select an image',
      type: FileType.image,
    );

    if (result == null) return;

    PlatformFile file = result.files.single;

    if (file.path != null) {
      imagePath = file.path;
      selectedImage = io.File(file.path as String);
      setState(() {});
    }
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
                    io.File(imagePath!),
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,
                  ),
                  //-------------------------------------------------
                  //         If the image is not uploaded
                  //-------------------------------------------------
                  (message == "")
                      ? (_isLoading == false)
                          //-------------------------------------------------
                          //       If The image is selected but not send
                          //-------------------------------------------------
                          ? Column(
                              children: [
                                SizedBox(height: 50),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //_upload();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DrawImage(imagePath!)),
                                      );
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
                          //-------------------------------------------------
                          //         If the image selected and uploaded
                          //-------------------------------------------------
                          : Column(children: [
                              SizedBox(
                                height: 50,
                              ),
                              SizedBox(
                                  width: 100,
                                  child: CircularProgressIndicator())
                            ])

                      //-------------------------------------------------
                      //         If the image uploaded failed
                      //-------------------------------------------------
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

                          //-------------------------------------------------
                          //   If the image uploaded Successfuly transformed
                          //-------------------------------------------------
                          : Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: 230,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final Uri _url = Uri.parse(
                                            'https://shoothouse.cylab.be/veiwer?ID=' +
                                                message);
                                        _launchUrl(_url);
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
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: 230,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DrawImage(imagePath!)),
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
                                            Icon(Icons.window),
                                            Text('    Add Objects')
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ])
                ])
              :
              //-------------------------------------------------
              //   If the image is not selected yet
              //-------------------------------------------------

              Column(children: [
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
                        _getFromGalleryWindowsLinux();
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
