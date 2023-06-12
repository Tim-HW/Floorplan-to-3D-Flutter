import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WindowsDownload extends StatelessWidget {
  const WindowsDownload(this.id, {super.key});
  final String id;

  Future<void> _launchUrl() async {
    final Uri _url =
        Uri.parse('https://shoothouse.cylab.be/windows-download?id=$id');
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
