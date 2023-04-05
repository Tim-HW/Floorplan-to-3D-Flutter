import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'windowsDraw.dart';

class ImageInputWindows extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageInputWindowsState();
  }
}

class _ImageInputWindowsState extends State<ImageInputWindows> {
  io.File? selectedImage;
  String? imagePath;
  double height = 300;
  double width = 300;

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
  void initState() {}

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
                      height: MediaQuery.of(context).size.height! / 2.round(),
                      width: MediaQuery.of(context).size.width! / 2.round(),
                    ),
                    //-------------------------------------------------
                    //         If the image is not uploaded
                    //-------------------------------------------------

                    //-------------------------------------------------
                    //       If The image is selected but not send
                    //-------------------------------------------------
                    Column(
                      children: [
                        SizedBox(height: 50),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: () async {
                              height = MediaQuery.of(context).size.height;
                              width = MediaQuery.of(context).size.width;

                              io.File image = io.File(
                                  imagePath!); // Or any other way to get a File instance.
                              var decodedImage = await decodeImageFromList(
                                  image.readAsBytesSync());

                              var imageWidth = decodedImage.width.toDouble();
                              var imageHeight = decodedImage.height.toDouble();

                              var finalWidth = imageWidth.toDouble();
                              var finalHeight = imageHeight.toDouble();

                              if (imageWidth > width) {
                                var ratio = (imageWidth / imageHeight);
                                //print("image  : " + imageWidth.toString());
                                //print('screen : ' + width.toString());
                                var results = (imageWidth ~/ width);

                                finalWidth = width * results;
                                finalHeight = finalWidth / ratio;
                              }
                              if (finalHeight > height) {
                                var ratio = (finalWidth / finalHeight);
                                //print("image  : " + imageWidth.toString());
                                //print('screen : ' + width.toString());
                                var results = (finalHeight ~/ height);

                                finalHeight = height * results;
                                finalWidth = finalHeight * ratio;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DrawImage(
                                        imagePath!, finalHeight, finalWidth)),
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
                    ),
                  ],
                )

              //-------------------------------------------------
              //   If the image is not selected yet
              //-------------------------------------------------
              : Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height! / 2.round(),
                      width: MediaQuery.of(context).size.width! / 2.round(),
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
        ));
  }
}
