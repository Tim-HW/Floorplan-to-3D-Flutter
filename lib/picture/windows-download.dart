import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WindowsDownload extends StatelessWidget {
  WindowsDownload(this.id);
  final String id;
  final Uri _url =
      Uri.parse('https://www.defence-institute.be/en/accueil-english/');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ), //AppBar
      body: Center(
        child: SizedBox(
          width: 150,
          child: ElevatedButton(
            onPressed: () {
              _launchUrl();
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: const [Icon(Icons.upgrade), Text('Download')],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
