import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/screen.dart';

void main() => runApp(new MviApp());

class MviApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Sealed Union Example',
      theme: new ThemeData.light().copyWith(
        primaryColor: Colors.pink[100],
        accentColor: Colors.pink[200],
      ),
      home: new Screen(),
    );
  }
}
