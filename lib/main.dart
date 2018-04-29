import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/trending/trending_screen.dart';

void main() {
  // ignore: deprecated_member_use
  MaterialPageRoute.debugEnableFadingRoutes = true;

  runApp(MviApp());
}

class MviApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giphy Sealed Unions',
      theme: ThemeData(
        fontFamily: 'Joystix',
        primaryColor: Colors.black,
        backgroundColor: Colors.black,
        brightness: Brightness.dark,
        accentColor: Colors.lightGreenAccent,
        scaffoldBackgroundColor: Colors.black,
        textSelectionColor: Colors.lightGreen,
        textSelectionHandleColor: Colors.lightGreenAccent,
      ),
      home: TrendingScreen(),
    );
  }
}
