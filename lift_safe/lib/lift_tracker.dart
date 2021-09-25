import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

class LiftTracker extends StatefulWidget {
  const LiftTracker({Key? key}) : super(key: key);

  @override
  _LiftTrackerState createState() => _LiftTrackerState();
}

class _LiftTrackerState extends State<LiftTracker> {
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double> _userAccelerometerZValues = [];
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  String buttonText = "Start Recording";
  String finishedList = "No data yet";
  int delta_t = 0;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _accelVal(userAccelerometer?[0], gyroscope?[0]),
                _accelVal(userAccelerometer?[1], gyroscope?[1]),
                _accelVal(userAccelerometer?[2], gyroscope?[2]),
                Text(finishedList),
                TextButton(child: Text(buttonText), onPressed: _startRecording),
              ],
            ),
          ),
          /*3*/
        ],
      ),
    );
  }

  _startRecording() {
    if (buttonText == "Start Recording") {
      setState(() {
        _streamSubscriptions[0].resume();
        _streamSubscriptions[1].resume();
        buttonText = "Stop Recording";
      });
    } else {
      setState(() {
        _streamSubscriptions[0].pause();
        _streamSubscriptions[1].pause();
        buttonText = "Start Recording";
        finishedList = _userAccelerometerZValues
            .map((double v) => v.toStringAsFixed(1))
            .toList()
            .join(", ");
      });
    }
  }

  Widget _accelVal(String? str, String? str2) {
    if (str != null && str2 != null) {
      return Text("Acceleration: " + str + " Gyroscope Value: " + str2);
    }
    return Text("Start Recording to get Values");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
      ),
      body: Column(
        children: [
          _buildSuggestions(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
        _userAccelerometerZValues.add(_userAccelerometerValues?[2] ?? -20000);
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
    _streamSubscriptions[0].pause();
    _streamSubscriptions[1].pause();
  }
}
