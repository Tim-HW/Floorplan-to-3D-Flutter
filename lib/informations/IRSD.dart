import 'package:floorplan2vr/information.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IRSD extends StatelessWidget {
  // This widget is the root of your application.

  final Uri _url = Uri.parse('https://www.defence-institute.be/en/accueil-english/');

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
        height: 750,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            CircleAvatar(
              backgroundColor: Colors.orangeAccent[500],
              radius: 108,
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/IRSD.png'),
                radius: 100,
              ), //CircleAvatar
            ), //CircleAvatar
            const SizedBox(
              height: 10,
            ), //SizedBox
            Text(
              'Royal Higher Institute for Defense',
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
              'This research has been founded by the Royal Higher Institute for Defense (RHID) : It is the reference body of the Belgian Ministry of Defence in the field of security and defence (Royal Decree of 10 August 2006). The RHID assumes two interlinked roles in support of the Ministry of Defence and of the Nation. First, in its role as a “think tank” for security and defence, it realises the objectives of deepening and disseminating knowledge by organising conferences, colloquia and seminars as well as publishing papers by researchers. The High Studies for Security and Defence, in the form of a course composed of residential seminars and visits, provides training in these fields for high-level staff, both from Defence and the civil sector, and promotes reflexion, debate and networking between participants. Through national and international partnerships, the RHID has developed an extensive network to exchange ideas and experiences. ',
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
