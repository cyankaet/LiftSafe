import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  double arm = 60.0;
  int reps = 3;
  static String exercise = 'Bench Press';
  static String voice = 'American';

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Container(
                child: const Text("Settings",
                    textScaleFactor: 2,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    )),
                alignment: const Alignment(0.0, 1.0))),
        ListTile(
            title: TextFormField(
                autovalidateMode: AutovalidateMode.always,
                initialValue: '3',
                decoration: const InputDecoration(
                  icon: Icon(Icons.sports_handball),
                  labelText: 'Reps per Set',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (text) {
                  reps = int.parse(text);
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return "Please enter an integer.";
                  }
                  return null;
                })),
        ListTile(
            // alignment: const Alignment(0.0, 1.0),
            title: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            icon: Icon(Icons.fitness_center),
            labelText: 'Exercise',
            border: OutlineInputBorder(),
          ),
          value: exercise,
          items: <String>['Bench Press', 'Squat', 'Deadlift']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              exercise = value!;
            });
          },
        )),
        ListTile(
            title: DropdownButtonFormField<String>(
          value: voice,
          decoration: const InputDecoration(
            icon: Icon(Icons.record_voice_over),
            labelText: 'Trainer Voice',
            border: OutlineInputBorder(),
          ),
          items: <String>['American', 'British', 'Anime', 'test.wav']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              voice = value!;
              Navigator.pop(context, voice);
            });
          },
        )),
        ListTile(
            title: TextFormField(
                autovalidateMode: AutovalidateMode.always,
                initialValue: '160',
                decoration: const InputDecoration(
                  icon: Icon(Icons.accessibility_outlined),
                  labelText: 'Arm Length',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (text) {
                  arm = double.parse(text);
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return "Please enter a length in meters.";
                  }
                  return null;
                })),
      ],
    ));
  }
}
