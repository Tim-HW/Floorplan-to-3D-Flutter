import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'WindowsDraw.dart';

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
            image: AssetImage("assets/backgroundWindows.png"),
            fit: BoxFit.contain),
      ),
      child: Center(
        child: (selectedImage != null)
            ? Column(
                children: [
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
                      ?
                      //-------------------------------------------------
                      //       If The image is selected but not send
                      //-------------------------------------------------
                      Column(
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
                                        MaterialStateProperty.all(Colors.red)),
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
                      : Column(
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            SizedBox(
                                width: 100, child: CircularProgressIndicator())
                          ],
                        ),
                ],
              )

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

                :
                //-------------------------------------------------
                //   If the image is not selected yet
                //-------------------------------------------------

                Column(
                    children: [
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
                    ],
                  ),
      ),
    );
  }
}
