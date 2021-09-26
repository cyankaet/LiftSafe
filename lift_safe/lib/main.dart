import 'package:flutter/material.dart';
import 'package:lift_safe/lift_tracker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Accelerometer Test',
      home: LiftTracker(),
    );
  }
}
