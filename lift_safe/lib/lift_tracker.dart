import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:stream_transform/stream_transform.dart';

import 'sidebar.dart';

class LiftTracker extends StatefulWidget {
  const LiftTracker({Key? key}) : super(key: key);

  @override
  _LiftTrackerState createState() => _LiftTrackerState();
}

class _LiftTrackerState extends State<LiftTracker> {
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double> _userAccelerometerZValues = [];
  List<double> _velocities = [0.0];
  List<double> tot_velocities = [0.0];
  int numReps = 0;
  List<int> _times = [0];
  Stopwatch _stopwatch = Stopwatch();
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  String buttonText = "Start Recording";
  String finishedList = "No data yet";
  String motivation = "";

  int timeSinceRepStart = 0;
  double minDist = 0;
  bool inRep = false;
  int counter = 0;
  static AudioCache player = AudioCache();

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
                // Text(finishedList),
                Text("Min Distance: $minDist"),
                Text("Reps: $numReps"),
                Text(motivation),
                TextButton(child: Text(buttonText), onPressed: _startRecording),
                TextButton(
                    child: Text("play test"),
                    onPressed: () {
                      player.play("test.wav");
                    })
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
        _stopwatch = Stopwatch();
        _stopwatch.start();
        _streamSubscriptions[0].resume();
        _streamSubscriptions[1].resume();
        _userAccelerometerZValues = [];
        _times = [];
        numReps = 0;
        counter = 0;
        inRep = false;
        minDist = 0;

        buttonText = "Stop Recording";
      });
    } else {
      setState(() {
        _streamSubscriptions[0].pause();
        _streamSubscriptions[1].pause();
        _stopwatch.stop();
        List<double> tot_velocities = [];
        tot_velocities.add(0.0);
        for (int i = 1; i < _velocities.length; i++) {
          tot_velocities.add(tot_velocities[i - 1] + _velocities[i]);
        }
        print(numReps);

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
    return const Text("Start Recording to get Values");
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
    _streamSubscriptions.add(userAccelerometerEvents
        .audit(const Duration(milliseconds: 100))
        .listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
        _userAccelerometerZValues.add(_userAccelerometerValues?[2] ?? -20000);
        _times.add(_stopwatch.elapsedMicroseconds);
        _velocities.add(0.5 *
            (_times[_times.length - 1] - _times[_times.length - 2]) /
            1000000 *
            (_userAccelerometerZValues[_userAccelerometerZValues.length - 1] +
                _userAccelerometerZValues[
                    _userAccelerometerZValues.length - 2]));
        tot_velocities.add(tot_velocities[tot_velocities.length - 1] +
            _velocities[_velocities.length - 1]);
        if (_velocities[_velocities.length - 1].abs() > 0.2 && inRep == false) {
          timeSinceRepStart = _times[_times.length - 1];
          numReps++;
          counter = 0;
          inRep = true;
          motivation = "";
        } else if (_velocities[_velocities.length - 1].abs() < 0.2 &&
            inRep == true) {
          if (counter >= 2) {
            inRep = false;
            counter = 0;
          } else {
            counter++;
          }
        } else {
          counter = 0;
          if (_times[_times.length - 1] - timeSinceRepStart > 1000000) {
            motivation = "You can dew it!!!";
          }
        }
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
