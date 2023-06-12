import 'dart:convert';
import 'dart:io' as io;
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'android-download.dart';
import 'android-rendering.dart';

class ImageInputAndroid extends StatefulWidget {
  const ImageInputAndroid({super.key});
  @override
  State<StatefulWidget> createState() {
    return _ImageInputAndroidState();
  }
}

class _ImageInputAndroidState extends State<ImageInputAndroid> {
  io.File? selectedImage;
  String? imagePath;
  String message = "";
  bool _isLoading = false;

  String pathUpload = "https://shoothouse.cylab.be/android-upload";

  void _startScan(BuildContext context) async {
    var image = await DocumentScannerFlutter.launch(context);
    if (image != null) {
      setState(() {
        //selectedImage = image;
        selectedImage = io.File(image.path);
        imagePath = image.path;
        setState(() {});
      });
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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/back.png"), fit: BoxFit.contain),
      ),
      child: Center(
          child: (selectedImage != null)
              ? Column(children: [
                  const SizedBox(
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
                                const SizedBox(height: 50),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _upload();
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red)),
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
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
                              const SizedBox(
                                height: 10,
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
                                                RenderingVeiwer(message)),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red)),
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.remove_red_eye),
                                          Text('       Open 3D viewer')
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
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
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.download),
                                          Text('       Download')
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ])
                ])
              :
              //-------------------------------------------------
              //   If the image is not selected yet
              //-------------------------------------------------

              Column(children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 300.0,
                    width: 300.0,
                    color: Colors.grey,
                    child: const Center(child: Text("No image selected")),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        _startScan(context);
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Row(
                          children: [
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
