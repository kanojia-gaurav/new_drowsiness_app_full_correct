import 'dart:async';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:signupexample/Database/database_helper.dart';
import 'package:signupexample/Drowsiness/FaceOutput.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:sms_maintained/sms.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

class FaceDetection extends StatefulWidget {
  @override
  _FaceDetectionState createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  dynamic _scanResults;
  CameraController _camera;
  bool _isDetecting = false;
  bool _dialogBox = false, isCameraOn = true;
  int count = 0;
  int ecount = 0;
  int _snackbarCounter = 0;
  final dbHelper = DatabaseHelper.instance;
  Map<String, dynamic> _useData;
  // ignore: prefer_final_fields
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // ignore: unnecessary_const
  static const LatLng _center = const LatLng(19.2118334, 72.8319243);
  // bool _fetchingData = true;
  CameraLensDirection _direction = CameraLensDirection.front;

  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      mode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    _query();
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _camera.dispose().then((_) {
      _faceDetector.close();
    });

    super.dispose();
  }

  void _incrementCounter() {
    // ignore: omit_local_variable_types
    SmsSender sender = SmsSender();
    // ignore: omit_local_variable_types
    String address = "${_useData['contact']}";

    // ignore: omit_local_variable_types
    SmsMessage message =
        SmsMessage(address, 'Hello! ${_useData['name']} is Drowsy.');
    message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        // ignore: prefer_single_quotes
        print("SMS is sent!");
      } else if (state == SmsMessageState.Delivered) {
        // ignore: prefer_single_quotes
        print("SMS is delivered!");
      }
    });
    sender.sendSms(message);
  }

  void _initializeCamera() async {
    // ignore: omit_local_variable_types
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);
    setState(() {});
    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.android
          ? ResolutionPreset.high
          : ResolutionPreset.high,
    );
    await _camera.initialize().catchError((onError) => print(onError));

    // ignore: unawaited_futures
    _camera.startImageStream((CameraImage image) async {
      if (_isDetecting) return;

      _isDetecting = true;

      dynamic results = await ScannerUtils.detect(
        image: image,
        detectInImage: _faceDetector.processImage,
        imageRotation: description.sensorOrientation,
      ).whenComplete(() => _isDetecting = false);
      setState(() {
        _scanResults = results;
      });
    });
  }

  Widget _buildResults() {
    // ignore: omit_local_variable_types
    Text noResultsText = Text('No Face detected yet!',
        style: TextStyle(
          fontSize: 20,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w500,
        ));

    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    CustomPainter painter;
//    final Size imageSize = Size(
//      _camera.value.previewSize.height,
//      _camera.value.previewSize.width,
//    );
    if (_scanResults is! List<Face>) return noResultsText;
    final List<Face> faces = _scanResults;
    // ignore: prefer_is_empty
    if (faces.length == 0) {
      // ignore: prefer_single_quotes
      print("face not detected");
      setState(() {
        _snackbarCounter += 1;
      });
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        // ignore: prefer_single_quotes
        content: Text("No Face Detected"),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red[500],
      ));
    } else {
      // ignore: prefer_single_quotes
      print("face detected");
      // ignore: omit_local_variable_types
      for (int snackbarsLeft = _snackbarCounter;
          snackbarsLeft > 0;
          snackbarsLeft = snackbarsLeft - 1) {
        // ignore: deprecated_member_use
        _scaffoldKey.currentState.removeCurrentSnackBar();
      }
    }
    // ignore: omit_local_variable_types
    for (Face face in faces) {
      // ignore: omit_local_variable_types
      double l = face.leftEyeOpenProbability;
      // ignore: omit_local_variable_types
      double r = face.rightEyeOpenProbability;
      // ignore: omit_local_variable_types
      Rect rect = face.boundingBox;
      print(rect);
      print(l);
      print(r);
      if (l < 0.3 && r < 0.3 && _dialogBox == false) {
        setState(() {
          count = count + 1;
        });
        print(count);

        if (count > 4) {
          Future.delayed(Duration(seconds: 0), () {
            setState(() {
              _dialogBox = true;
            });
            _showDialogBox(context);
            playSound();
            setState(() {
              ecount = ecount + 1;
            });
            if (ecount > 2) {
              _incrementCounter();
              print(ecount);
              setState(() {
                ecount = 0;
              });
            }
          });
          // ignore: prefer_single_quotes
          print("Fuction called");
        } else {
          break;
        }
      } else {
        setState(() {
          count = 0;
          _dialogBox = false;
        });
        print(count);
      }
    }
//    painter = FaceDetectorPainter(imageSize, _scanResults,flag);

    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: BoxConstraints.expand(),
      child: _camera == null
          ? Center(
              child: Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  void _map() {
    // ignore: omit_local_variable_types
    Completer<GoogleMapController> _controller = Completer();

    void _onMapCreated(GoogleMapController controller) {
      _controller.complete(controller);
    }

    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        title: Text(
          'Drowsiness Detection',
          style: TextStyle(
            fontSize: 30.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      // ignore: prefer_single_quotes
      body: isCameraOn ? _buildImage() : Center(child: Text("Camera is Off")),
      floatingActionButton: SpeedDial(
        marginEnd: 18,
        marginBottom: 20,
        icon: Icons.add,
        activeIcon: Icons.remove,
        buttonSize: 56.0,
        visible: true,
        closeManually: false,
        renderOverlay: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            onTap: _toggleCameraDirection,
            child: _direction == CameraLensDirection.front
                ? Icon(Icons.camera_rear)
                : Icon(Icons.camera_front),
            backgroundColor: Colors.red,
            label: 'Camera switch',
            labelStyle: TextStyle(fontSize: 18.0),
          ),
          SpeedDialChild(
            onTap: () {
              // ignore: prefer_single_quotes
              print("Camera OFF");
              setState(() {
                isCameraOn = false;
              });
            },
            child: Icon(Icons.stop),
            backgroundColor: Colors.blue,
            label: 'Stop',
            labelStyle: TextStyle(fontSize: 18.0),
          ),
          SpeedDialChild(
            onTap: () {
              // ignore: prefer_single_quotes
              print("Camera ON");
              setState(() {
                isCameraOn = true;
              });
            },
            child: Icon(Icons.play_arrow),
            backgroundColor: Colors.green,
            label: 'Start',
            labelStyle: TextStyle(fontSize: 18.0),
          ),
          SpeedDialChild(
            onTap: () {
              // ignore: prefer_single_quotes
              print("Map");
              _map();
            },
            child: Icon(Icons.map),
            backgroundColor: Colors.yellowAccent,
            label: 'Map',
            labelStyle: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  final assetsAudioPlayer = AssetsAudioPlayer();

  void playSound() {
    assetsAudioPlayer.open(
      // ignore: prefer_single_quotes
      Audio("assets/alarm.wav"),
    );
    assetsAudioPlayer.loop = true;
    print('playing sound');
    assetsAudioPlayer.play();
  }

  // ignore: always_declare_return_types
  _showDialogBox(BuildContext context) {
    // set up the button
    // ignore: deprecated_member_use
    Widget okButton = FlatButton(
      // ignore: prefer_single_quotes
      // ignore: sort_child_properties_last
      child: Text("OK"),
      onPressed: () {
        //dispose();
        assetsAudioPlayer.stop();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    // ignore: omit_local_variable_types
    AlertDialog alert = AlertDialog(
      // ignore: prefer_single_quotes
      title: Text("Drowsiness Detected"),
      // ignore: prefer_single_quotes
      content: Text("Click Ok to turn off."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');

    allRows.forEach((row) => print(row));
    setState(() {
      _useData = allRows[0];
      // _fetchingData = false;
    });
  }
}
