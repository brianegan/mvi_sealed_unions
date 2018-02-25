import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/screen.dart';

void main() => runApp(new MviApp());

class MviApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Sealed Union Example',
      theme: new ThemeData.dark().copyWith(
        primaryColor: Colors.grey[800],
        accentColor: Colors.pink[200],
      ),
      home: new ShotsList(),
    );
  }
}
