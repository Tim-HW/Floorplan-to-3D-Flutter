import 'package:floorplan2vr/information.dart';
import 'package:flutter/material.dart';
import 'picture/image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  List _screens = [ImageInput(), information()];

  void _updateIndex(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Floorplans 2 Mesh")),
      ),
      body: _screens[_currentIndex],
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
