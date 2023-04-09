import 'package:flutter/material.dart';
import 'informations/RMA-info.dart';
import 'informations/XR-LAB-info.dart';
import 'informations/IRSD.dart';

class Information extends StatelessWidget {
  const Information({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ), //AppBar
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Center(
            child: (Column(
              children: [XRInfo(), RMAInfo(), IRSD()],
            )),
          ),
        ],
      ),
    );
  }
}
