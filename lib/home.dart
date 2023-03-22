import 'dart:io' as io;

import 'package:floorplan2vr/information.dart';
import 'package:floorplan2vr/picture/imageAndroid.dart';
import 'package:flutter/material.dart';
import 'picture/imageWindows.dart';
import 'picture/imageAndroid.dart';
import 'picture/WindowsDraw.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List _screensWindows = [
    ImageInputWindows(),
    information(),
  ];

  final List _screensAndroid = [
    ImageInputAndroid(),
    information(),
  ];

  void _updateIndex(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (io.Platform.isWindows || io.Platform.isLinux)
        ? Scaffold(
            appBar: AppBar(
              title: Center(child: Text("Floorplans 2 Mesh")),
            ),
            body: _screensWindows[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: _updateIndex,
              selectedFontSize: 13,
              unselectedFontSize: 13,
              iconSize: 30,
              //bottom navigation bar on scaffold
              items: [
                //items inside navigation bar
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: "Add floorplan",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info),
                  label: "Informations",
                ),

                //put more items here
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Center(child: Text("Floorplans 2 Mesh")),
            ),
            body: _screensAndroid[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: _updateIndex,
              selectedFontSize: 13,
              unselectedFontSize: 13,
              iconSize: 30,
              //bottom navigation bar on scaffold
              items: [
                //items inside navigation bar
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: "Add floorplan",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info),
                  label: "Informations",
                ),
                //put more items here
              ],
            ),
          );
  }
}
