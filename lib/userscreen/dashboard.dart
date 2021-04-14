import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:signupexample/Drowsiness/FaceDetection.dart';
import 'package:signupexample/userscreen/map.dart';
import 'package:signupexample/userscreen/userscreen.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool isCameraOn = false;
  // ignore: unused_field
  static const TextStyle optionStyle = TextStyle(
    fontSize: 22,
  );
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> myList = [
    //Text("Home"),
    FaceDetection(),
    UserScreen(),
    //Text("emergency")
  ];
// _widgetOptions.elementAt(_selectedIndex),
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //     appBar: AppBar(
      // title:  _widgetOptions.elementAt(_selectedIndex),
      // automaticallyImplyLeading: false,
      //     ),
      body: Center(
        // child: _widgetOptions.elementAt(_selectedIndex),
        child: Container(
          child: myList[_selectedIndex],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
          height: 50,
          color: Colors.deepPurpleAccent,
          items: [
            Icon(Icons.home),
            Icon(Icons.settings),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.home),
            //   label: 'Home',
            //   // backgroundColor: Colors.red,
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.settings),
            //   label: 'Settings',

            // backgroundColor: Colors.pink,
            // ),
          ],
          // currentIndex: _selectedIndex,
          // selectedItemColor: Colors.black,
          onTap: _onItemTapped,
          backgroundColor: Colors.cyanAccent),
    );
  }
}
