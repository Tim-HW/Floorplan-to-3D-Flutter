import 'package:flutter/material.dart';
import 'picture/image.dart';
import './informations/RMA-info.dart';
import './informations/XR-LAB-info.dart';
import './informations/IRSD.dart';

class information extends StatelessWidget {
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
