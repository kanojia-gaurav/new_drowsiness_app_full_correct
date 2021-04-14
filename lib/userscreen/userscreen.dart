import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:signupexample/Database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signupexample/main.dart';

import 'package:url_launcher/url_launcher.dart';

class UserScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserScreen();
}

class _UserScreen extends State<UserScreen> with WidgetsBindingObserver {
  final dbHelper = DatabaseHelper.instance;
  // ignore: unnecessary_const
  static const LatLng _center = const LatLng(19.2118334, 72.8319243);
  Map<String, dynamic> _useData;
  bool _fetchingData = true;
  @override
  void initState() {
    _query();
    super.initState();
  }

  void getLocation() async {
    final String numb = _useData['contact'];
    // ignore: omit_local_variable_types
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // ignore: omit_local_variable_types
    String uri =
        'sms:+91 $numb ?body=I%20am%20in%20danger,%20my%20location%20is:%20$position';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      const uri = 'sms:0039-222-060-888';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  Widget titleSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _useData['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Text(
                  _useData['email'],
                  style: TextStyle(color: Colors.grey[500], fontSize: 18),
                ),
              ],
            ),
          ),
          /*3*/
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.account_circle,
              color: _useData['gender'] == 'Man'
                  ? Colors.blue[700]
                  : Colors.red[700],
              size: 28,
            ),
          ),
          Text(
            _useData['age'].toString(),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget textSection() {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 32),
      child: Text(
        _useData['intro'],
        softWrap: true,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  // void _map() {
  //   // ignore: omit_local_variable_types
  //   Completer<GoogleMapController> _controller = Completer();

  //   void _onMapCreated(GoogleMapController controller) {
  //     _controller.complete(controller);
  //   }

  //   showMaterialModalBottomSheet(
  //     context: context,
  //     builder: (context) => SingleChildScrollView(
  //       controller: ModalScrollController.of(context),
  //       child: Container(
  //         width: MediaQuery.of(context).size.width,
  //         height: MediaQuery.of(context).size.height,
  //         child: GoogleMap(
  //           onMapCreated: _onMapCreated,
  //           initialCameraPosition: CameraPosition(
  //             target: _center,
  //             zoom: 11.0,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _deleteUser() {
    return Container(
      padding: const EdgeInsets.all(16),
      // ignore: deprecated_member_use
      child: RaisedButton(
        color: Colors.redAccent,
        onPressed: () {
          print('delete user');
          _delete();
        },
        // ignore: sort_child_properties_last
        child: Text('Delete user',
            style: TextStyle(
                fontWeight: FontWeight.w700, letterSpacing: 0.0, fontSize: 20)),
        textColor: Colors.white,
      ),
    );
  }

  // static const platform = const MethodChannel('sendSms');
  @override
  Widget build(BuildContext context) {
    // Future<Null> sendSms() async {
    //   print("SendSMS");
    //   print(_useData['contact']);
    //   try {
    //     final String result =
    //         await platform.invokeMethod('send', <String, dynamic>{
    //       "phone": "${_useData['contact']}",
    //       "msg": "Hello! ${_useData['name']} is Drowsy."
    //     }); //Replace a 'X' with 10 digit phone number
    //     print(result);
    //   } on PlatformException catch (e) {
    //     print(e.toString());
    //   }
    // }

    // void _incrementCounter() {
    //   SmsSender sender = SmsSender();
    //   String address = "${_useData['contact']}";

    //   SmsMessage message =
    //       SmsMessage(address, 'Hello! ${_useData['name']} is Drowsy.');
    //   message.onStateChanged.listen((state) {
    //     if (state == SmsMessageState.Sent) {
    //       print("SMS is sent!");
    //     } else if (state == SmsMessageState.Delivered) {
    //       print("SMS is delivered!");
    //     }
    //   });
    //   sender.sendSms(message);
    // }

    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_single_quotes
        title: Text("Emergency Contact"),
        backgroundColor: Colors.deepPurpleAccent,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            getLocation();
          },
          child: Icon(
            Icons.announcement_rounded, // add custom icons also
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                _logout();
              },
              child: Icon(Icons.logout),
            ),
          )
        ],
      ),
      body: Container(
        child: _fetchingData
            ? CircularProgressIndicator()
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.greenAccent[700],
                      // child: Image.file(
                      //   File(_useData['image0']),
                      //   //height: 240,
                      //   fit: BoxFit.cover,
                      // ),
                      backgroundImage: FileImage(
                        File(_useData['image0']),
                      ),
                      radius: 110,
                    ),
                  ),
                  titleSection(),
                  textSection(),
                  _deleteUser(),
                  // ignore: deprecated_member_use
                  // RaisedButton(
                  //   onPressed: () {
                  //     _map();
                  //   },
                  //   // ignore: prefer_single_quotes
                  //   child: Text("Map"),
                  // )
                ],
              ),
      ),
    );
  }

  void _logout() async {
    // ignore: omit_local_variable_types
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: unawaited_futures
    prefs.setBool("isLogin", false);
    // ignore: unawaited_futures
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');

    allRows.forEach((row) => print(row));
    setState(() {
      _useData = allRows[0];
      _fetchingData = false;
    });
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');

    // ignore: omit_local_variable_types
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);

    // ignore: unawaited_futures
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }
}
