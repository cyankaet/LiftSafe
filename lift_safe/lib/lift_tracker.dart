import 'dart:async';

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
  final Map audioFiles = {
    'American': 'just-do-it.mp3',
    'British': 'you-donkey.mp3',
    'Japanese': 'test.wav'
  };
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double> _userAccelerometerZValues = [];
  List<double> _velocities = [0.0];
  List<double> tot_velocities = [0.0];
  int numReps = 0;
  int numEgo = 0;
  List<int> _times = [0];
  Stopwatch _stopwatch = Stopwatch();
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  String buttonText = "Start Recording";
  String textHolder = (100).toString() + '%';
  changeText() {
    setState(() {
      textHolder =
          (100 * (numReps - numEgo) / numReps).toInt().toString() + "%";
    });
  }

  String motivation = "";
  String audio = "American";

  bool audioPlayed = false;
  int timeSinceRepStart = 0;
  double minDist = 0;
  bool inRep = false;
  int counter = 0;
  bool start = false;
  static AudioCache player = AudioCache();

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

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
                MaterialButton(
                  height: 275,
                  minWidth: 275,
                  color: Colors.blue,
                  shape: CircleBorder(),
                  onPressed: _startRecording,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '$textHolder',
                      style: TextStyle(color: Colors.white, fontSize: 45),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    _getAudio(context);
                  },
                  child: Text("Pick Trainer Voice"),
                ),
              ],
            ),
          ),
          /*3*/
        ],
      ),
    );
  }

  _getAudio(BuildContext context) async {
    final String voice = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => NavBar()));
    setState(() {
      audio = voice;
    });
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
        numEgo = 0;
        counter = 0;
        inRep = false;
        minDist = 0;
        audioPlayed = false;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LiftSafe'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline_outlined),
            tooltip: 'Show Instructions',
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('AlertDialog Title'),
                content: const Text('AlertDialog description'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          changeText();
          counter = 0;
          inRep = true;
          motivation = "";
          audioPlayed = false;
        } else if (_velocities[_velocities.length - 1].abs() < 0.2 &&
            inRep == true) {
          if (counter >= 2) {
            inRep = false;
            counter = 0;
            if (_times[_times.length - 1] - timeSinceRepStart < 3000000) {
              motivation = "You can dew it!!!";
              numEgo++;
              changeText();
              if (!audioPlayed) {
                player.play("test.wav");
                audioPlayed = true;
              }
            }
          } else {
            counter++;
          }
        } else {
          counter = 0;
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
