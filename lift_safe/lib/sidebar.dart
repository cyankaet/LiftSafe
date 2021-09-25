import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  double height = 120;
  String wingspan = "hi";
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
            leading: Icon(Icons.message),
            title: const TextField(
                decoration: const InputDecoration(
                    hintText: "height"))), // TODO ft/inches input
        ListTile(
            leading: Icon(Icons.accessibility_outlined),
            title: TextField(
                decoration: const InputDecoration(hintText: "wingspan"),
                onSubmitted: (text) {
                  wingspan = text;
                })),
        Text(wingspan),
      ],
    ));
  }
}
