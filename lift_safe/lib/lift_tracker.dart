import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

import 'sidebar.dart';

class LiftTracker extends StatefulWidget {
  const LiftTracker({Key? key}) : super(key: key);

  @override
  _LiftTrackerState createState() => _LiftTrackerState();
}

class _LiftTrackerState extends State<LiftTracker> {
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  String test = 'testing';

  Widget _buildSuggestions() {
    final List<String>? userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    final List<String>? gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("LiftSafe",
                    textScaleFactor: 5.0,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _accelVal(userAccelerometer?[0], gyroscope?[0]),
                _accelVal(userAccelerometer?[1], gyroscope?[1]),
                _accelVal(userAccelerometer?[2], gyroscope?[2]),
                Text(test),
                TextButton(
                    child: Text("Start recording"), onPressed: _startRecording)
              ],
            ),
          ),
          /*3*/
        ],
      ),
    );
  }

  _startRecording() {
    setState(() {
      if (test == 'start') {
        test = 'no';
      } else
        test = 'start';
    });
  }

  Widget _accelVal(String? str, String? str2) {
    if (str != null && str2 != null) {
      return Text("Acceleration: " + str + " Gyroscope Value: " + str2);
    }
    return Text("Accelerometer values finished.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      body: Container(
          padding: const EdgeInsets.only(top: 20), child: _buildSuggestions()),
    );
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }
}
