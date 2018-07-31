import 'package:flutter/material.dart';
import 'package:app/pages/DevicesPage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Bad Smell Detector',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new DevicesPage(),
    );
  }
}
