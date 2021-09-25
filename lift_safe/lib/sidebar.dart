import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  double arm = 60.0;
  String exercise = 'Bench Press';
  String voice = 'American';

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Container(
                child: Text("Settings",
                    textScaleFactor: 2,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    )),
                alignment: Alignment(0.0, 1.0))),
        ListTile(
            title: TextFormField(
                initialValue: '160',
                autovalidate: true,
                decoration: InputDecoration(
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
        Container(
            alignment: Alignment(0.0, 1.0),
            child: DropdownButton<String>(
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
        Container(
            alignment: Alignment(0.0, 1.0),
            child: DropdownButton<String>(
              value: voice,
              items: <String>['American', 'British', 'Anime']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  voice = value!;
                });
              },
            )),
      ],
    ));
  }
}
