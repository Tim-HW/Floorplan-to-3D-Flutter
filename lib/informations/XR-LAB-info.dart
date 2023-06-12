import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class XRInfo extends StatelessWidget {
  // This widget is the root of your application.

  final Uri _url = Uri.parse('https://xrlab.rma.ac.be/');

  XRInfo({super.key});

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 50,
      shadowColor: Colors.black,
      color: Colors.orange[100],
      child: SizedBox(
        width: 400,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            CircleAvatar(
              backgroundColor: Colors.orangeAccent[500],
              radius: 108,
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/VR.png'),
                radius: 100,
              ), //CircleAvatar
            ), //CircleAvatar
            const SizedBox(
              height: 10,
            ), //SizedBox
            Text(
              'XR-Lab',
              style: TextStyle(
                fontSize: 30,
                color: Colors.red[900],
                fontWeight: FontWeight.w500,
              ), //Textstyle
            ), //Text
            const SizedBox(
              height: 10,
            ), //SizedBox
            const Text(
              'The XR-lab is a Laboratory specialised in the extended reality domain at the Royal Military Academy. Our project involves also Robotics and Computer vision. More informations can be found in our website.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
              ), //Textstyle
            ), //Text
            const SizedBox(
              height: 10,
            ), //SizedBox
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _launchUrl,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: const [Icon(Icons.touch_app), Text('Visit')],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
